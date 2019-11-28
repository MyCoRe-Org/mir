package org.mycore.mir.sword2;

import java.io.IOException;
import java.io.InputStream;
import java.nio.channels.SeekableByteChannel;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ZipFile;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.input.sax.XMLReaders;
import org.mycore.access.MCRAccessException;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.function.MCRThrowFunction;
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
import org.xml.sax.SAXException;

public class MIRDeepGreepIngester extends MIRSwordIngesterBase {

    private static final Logger LOGGER = LogManager.getLogger();

    @Override
    public MCRObjectID ingestMetadata(Deposit deposit) throws SwordError, SwordServerException {
        final MCRObjectID newObjectId = MCRObjectID
            .getNextFreeId(MCRConfiguration.instance().getString("MIR.projectid.default") + "_mods");
        try {
            final Path dgZip = MCRSwordUtil
                .createTempFileFromStream("dgZip", deposit.getInputStream(), deposit.getMd5());

            LOGGER.info("Zip File is : " + dgZip.toAbsolutePath().toString());
            try (SeekableByteChannel sbc = Files.newByteChannel(dgZip)) {
                final ZipFile zipFile = new ZipFile(sbc);
                final List<ZipArchiveEntry> entriesInPhysicalOrder = Collections
                    .list(zipFile.getEntriesInPhysicalOrder());
                final Optional<ZipArchiveEntry> metadataEntryOpt = entriesInPhysicalOrder.stream()
                    .filter(e -> e.getName().endsWith(".xml")).findFirst();
                final Optional<ZipArchiveEntry> pdfEntryOpt = entriesInPhysicalOrder.stream()
                    .filter(e -> e.getName().endsWith(".pdf")).findFirst();

                if (metadataEntryOpt.isEmpty()) {
                    throw new SwordServerException("No Metadata File Found!");
                }

                if (pdfEntryOpt.isEmpty()) {
                    throw new SwordServerException("No PDF File Found!");
                }

                final ZipArchiveEntry metadataEntry = metadataEntryOpt.get();
                final ZipArchiveEntry pdfEntry = pdfEntryOpt.get();

                final MCRThrowFunction<ZipArchiveEntry, InputStream, IOException> getIS = zipFile::getInputStream;
                try (InputStream metadataIS = getIS.apply(metadataEntry); InputStream pdfIS = getIS.apply(pdfEntry)) {
                    final SAXBuilder saxBuilder = new SAXBuilder();

                    setBuilderNonValidating(saxBuilder);

                    final Document build = saxBuilder.build(metadataIS);
                    build.setDocType(null); // to prevent validating (missing .dtd)
                    final Document document = getTransformer().transform(new MCRJDOMContent(build)).asXML();
                    final MCRObject resultingObject = MCRMODSWrapper
                        .wrapMODSDocument(document.detachRootElement(), newObjectId.getProjectId());

                    resultingObject.setId(newObjectId);
                    resultingObject.getService().setState(getState());
                    resultingObject.getService().addFlag("sword", this.getLifecycleConfiguration().getCollection());

                    MCRMetadataManager.create(resultingObject);
                    final String fileName = pdfEntry.getName();
                    final MCRDerivate derivate = MCRSwordUtil.createDerivate(resultingObject.getId().toString());
                    Files.copy(pdfIS, MCRPath.getPath(derivate.getId().toString(), fileName));
                    derivate.getDerivate().getInternals().setMainDoc(fileName);
                    MCRMetadataManager.update(derivate);
                    return newObjectId;
                } catch (SAXException | JDOMException | MCRAccessException e) {
                    throw new SwordServerException("Error while creating mods", e);
                }
            } catch (IOException e) {
                throw new SwordServerException("Error while processing ZIP: " + dgZip.toAbsolutePath().toString(), e);
            }
        } catch (IOException e) {
            throw new SwordServerException("Error while saving ZIP.", e);
        }
    }

    private void setBuilderNonValidating(SAXBuilder saxBuilder) {
        saxBuilder.setXMLReaderFactory(XMLReaders.NONVALIDATING);
        saxBuilder.setExpandEntities(false);
        saxBuilder.setFeature("http://xml.org/sax/features/validation", false);
        saxBuilder.setFeature("http://apache.org/xml/features/nonvalidating/load-dtd-grammar", false);
        saxBuilder.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);
        saxBuilder.setFeature("http://xml.org/sax/features/resolve-dtd-uris", false);
    }

}
