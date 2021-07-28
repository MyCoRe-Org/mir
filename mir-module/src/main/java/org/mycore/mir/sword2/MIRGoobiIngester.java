package org.mycore.mir.sword2;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.naming.OperationNotSupportedException;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.JDOMException;
import org.mycore.access.MCRAccessException;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mods.MCRMODSWrapper;
import org.mycore.sword.MCRSwordUtil;
import org.swordapp.server.Deposit;
import org.swordapp.server.SwordError;
import org.swordapp.server.SwordServerException;
import org.swordapp.server.UriRegistry;
import org.xml.sax.SAXException;

public class MIRGoobiIngester extends MIRSwordIngesterBase {

    public static final Logger LOGGER = LogManager.getLogger();

    @Override
    public MCRObjectID ingestMetadata(Deposit entry) throws SwordError, SwordServerException {
        final MCRObjectID newObjectId = MCRObjectID
            .getNextFreeId(MCRConfiguration2.getStringOrThrow("MIR.projectid.default") + "_mods");
        final Map<String, List<String>> dublinCoreMetadata = entry.getSwordEntry().getDublinCore();

        Document dcDocument = buildDCDocument(dublinCoreMetadata);
        Document convertedDocument = convertDCToMods(dcDocument);

        final MCRObject mcrObject = MCRMODSWrapper.wrapMODSDocument(convertedDocument.detachRootElement(),
            newObjectId.getProjectId());
        mcrObject.setId(newObjectId);
        mcrObject.getService().setState(getState());
        mcrObject.getService().addFlag("sword", this.getLifecycleConfiguration().getCollection());
        try {
            MCRMetadataManager.create(mcrObject);
        } catch (MCRAccessException e) {
            throw new SwordError(UriRegistry.ERROR_BAD_REQUEST, HttpServletResponse.SC_UNAUTHORIZED, e.getMessage());
        }

        return newObjectId;
    }

    private Document convertDCToMods(Document dcDocument) throws SwordError, SwordServerException {
        final MCRContent mcrContent;
        try {
            mcrContent = getTransformer().transform(new MCRJDOMContent(dcDocument));
        } catch (IOException e) {
            throw new SwordError(UriRegistry.ERROR_BAD_REQUEST, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Error while transforming mods2dc!", e);
        }

        Document convertedDocument;
        try {
            convertedDocument = mcrContent.asXML();
        } catch (JDOMException | IOException | SAXException e) {
            throw new SwordServerException("Error getting transform result of mods to dc transformation!", e);
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
            throw new SwordServerException("Error while creating new derivate for object " + objectID.toString(), e);
        } catch (MCRAccessException e) {
            throw new SwordError(UriRegistry.ERROR_BAD_REQUEST, HttpServletResponse.SC_UNAUTHORIZED, e.getMessage());
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

    @Override
    public void updateMetadata(MCRObject object, Deposit entry, boolean replace)
        throws SwordServerException, SwordError {
        if (!replace) {
            throw new SwordServerException("Operation is not supported!", new OperationNotSupportedException());
        }
        final Document document = buildDCDocument(entry.getSwordEntry().getDublinCore());
        final Document newMetadata = convertDCToMods(document);
        object.getMetadata().setFromDOM(newMetadata.detachRootElement());
        try {
            MCRMetadataManager.update(object);
        } catch (MCRAccessException e) {
            throw new SwordError(UriRegistry.ERROR_BAD_REQUEST, HttpServletResponse.SC_UNAUTHORIZED, e.getMessage());
        }
    }

}
