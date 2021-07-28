package org.mycore.mir.sword2;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.FileSystem;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import jakarta.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.filter.Filters;
import org.jdom2.input.SAXBuilder;
import org.jdom2.xpath.XPathFactory;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.mods.MCRMODSWrapper;
import org.mycore.sword.MCRSwordUtil;
import org.swordapp.server.Deposit;
import org.swordapp.server.SwordError;
import org.swordapp.server.SwordServerException;
import org.swordapp.server.UriRegistry;
import org.xml.sax.SAXException;

public class MIRMETSIngester extends MIRSwordIngesterBase {

    public static final Logger LOGGER = LogManager.getLogger();

    private static Document readXMLFile(Path file) {
        try (InputStream metsIS = Files.newInputStream(file)) {
            return new SAXBuilder().build(metsIS);
        } catch (JDOMException e) {
            throw new MCRException("Error while parsing " + file.toAbsolutePath(), e);
        } catch (IOException e) {
            throw new MCRException("Error while reading " + file.toAbsolutePath() + " from zip", e);
        }
    }

    private static List<String> extractPathStringFromMets(Document metsFileDocument) {
        String fileXPath = "mets:mets/mets:fileSec/mets:fileGrp/mets:file/mets:FLocat";
        final List<Element> flocatElements = XPathFactory.instance()
            .compile(fileXPath, Filters.element(), null, MCRConstants.METS_NAMESPACE, MCRConstants.XLINK_NAMESPACE)
            .evaluate(metsFileDocument);

        return flocatElements.stream()
            .map(e -> e.getAttributeValue("href", MCRConstants.XLINK_NAMESPACE))
            .collect(Collectors.toList());
    }

    @Override
    public MCRObjectID ingestMetadata(Deposit entry) throws SwordError, SwordServerException {
        final MCRObjectID newObjectId = MCRObjectID
            .getNextFreeId(MCRConfiguration2.getStringOrThrow("MIR.projectid.default") + "_mods");
        Document convertedDocument;

        Path tempFile = null;
        try {
            tempFile = MCRSwordUtil
                .createTempFileFromStream(entry.getFilename(), entry.getInputStream(), entry.getMd5());

            try (FileSystem zipfs = FileSystems
                .newFileSystem(new URI("jar:" + tempFile.toUri()), Collections.emptyMap())) {

                Path metsPath = zipfs.getPath("/mets.xml");
                if (!Files.exists(metsPath)) {
                    throw new IOException("Error mets.xml does not exist!");
                }
                final Document metsFileDocument = readXMLFile(metsPath);
                convertedDocument = convertToMods(metsFileDocument);

                final MCRObject mcrObject = MCRMODSWrapper.wrapMODSDocument(convertedDocument.detachRootElement(),
                    newObjectId.getProjectId());
                mcrObject.setId(newObjectId);
                mcrObject.getService().setState(getState());
                mcrObject.getService().addFlag("sword", this.getLifecycleConfiguration().getCollection());
                try {
                    MCRMetadataManager.create(mcrObject);
                } catch (MCRAccessException e) {
                    throw new SwordError(UriRegistry.ERROR_BAD_REQUEST, HttpServletResponse.SC_UNAUTHORIZED,
                        e.getMessage());
                }

                final List<String> strings = extractPathStringFromMets(metsFileDocument);
                if (strings.size() > 0) {
                    final MCRDerivate derivate = MCRSwordUtil.createDerivate(newObjectId.toString());
                    MCRObjectID createdDerivateID = derivate.getId();
                    MCRPath derivateRoot = MCRPath.getPath(derivate.getId().toString(), "/");

                    strings.forEach(p -> {
                        Path source = zipfs.getPath(p);
                        Path target = derivateRoot.resolve(p);
                        try {
                            Files.copy(source, target);
                        } catch (IOException e) {
                            LOGGER.error("Error while copy " + source.toString() + " => " + target.toString(), e);
                        }
                    });
                    setDefaultMainFile(createdDerivateID.toString());
                }
            }
        } catch (IOException | URISyntaxException | MCRAccessException e) {
            throw new SwordError(UriRegistry.ERROR_BAD_REQUEST, e);
        }

        return newObjectId;
    }

    private Document convertToMods(Document metsDocument) throws SwordError, SwordServerException {
        final MCRContent mcrContent;
        try {
            mcrContent = getTransformer().transform(new MCRJDOMContent(metsDocument));
        } catch (IOException e) {
            throw new SwordError(UriRegistry.ERROR_BAD_REQUEST, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Error while transforming!", e);
        }

        Document convertedDocument;
        try {
            convertedDocument = mcrContent.asXML();
        } catch (JDOMException | IOException | SAXException e) {
            throw new SwordServerException("Error getting result of the transformation!", e);
        }
        return convertedDocument;
    }

    @Override
    public MCRObjectID ingestMetadataResources(Deposit entry) throws SwordError, SwordServerException {
        final MCRObjectID objectID = this.ingestMetadata(entry);
        this.ingestResource(MCRMetadataManager.retrieveMCRObject(objectID), entry);
        return objectID;
    }

    @Override
    public void ingestResource(MCRObject object, Deposit entry) throws SwordServerException, SwordError {
        final MCRObjectID objectID = object.getId();

        MCRObjectID createdDerivateID = null;
        boolean complete = false;
        try {
            final MCRDerivate derivate = MCRSwordUtil.createDerivate(objectID.toString());
            createdDerivateID = derivate.getId();
            getMediaHandler().addResource(createdDerivateID.toString(), "/", entry);
            complete = true;
        } catch (IOException e) {
            throw new SwordServerException("Error while creating new derivate for object " + objectID.toString(),
                e);
        } catch (MCRAccessException e) {
            throw new SwordError(UriRegistry.ERROR_BAD_REQUEST, HttpServletResponse.SC_UNAUTHORIZED,
                e.getMessage());
        } finally {
            if (createdDerivateID != null && !complete) {
                try {
                    MCRMetadataManager.deleteMCRDerivate(createdDerivateID);
                } catch (MCRAccessException e1) {
                    // derivate can be created but not deleted ?!
                    LOGGER.error("Derivate could not be deleted(deposit was invalid)", e1);
                }
            } else if (complete) {
                setDefaultMainFile(createdDerivateID.toString());
            }
        }
    }

}
