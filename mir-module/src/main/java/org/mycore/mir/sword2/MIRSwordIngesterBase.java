package org.mycore.mir.sword2;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;

import javax.naming.OperationNotSupportedException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.Namespace;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRPersistenceException;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.content.transformer.MCRContentTransformer;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.datamodel.niofs.utils.MCRFileCollectingFileVisitor;
import org.mycore.sword.application.MCRSwordIngester;
import org.mycore.sword.application.MCRSwordLifecycleConfiguration;
import org.mycore.sword.application.MCRSwordMediaHandler;
import org.swordapp.server.Deposit;
import org.swordapp.server.SwordError;
import org.swordapp.server.SwordServerException;

public abstract class MIRSwordIngesterBase implements MCRSwordIngester {

    protected static final Namespace DC_NAMESPACE = Namespace.getNamespace("dc", "http://purl.org/dc/elements/1.1/");

    private static final Logger LOGGER = LogManager.getLogger();

    private MCRSwordMediaHandler mcrSwordMediaHandler = new MCRSwordMediaHandler();

    private MCRSwordLifecycleConfiguration lifecycleConfiguration;

    /**
     * Sets a main file if not present.
     * @param derivateID the id of the derivate
     */
    protected static void setDefaultMainFile(String derivateID) {
        MCRPath path = MCRPath.getPath(derivateID, "/");
        try {
            MCRFileCollectingFileVisitor<Path> visitor = new MCRFileCollectingFileVisitor<>();
            Files.walkFileTree(path, visitor);
            MCRDerivate derivate = MCRMetadataManager.retrieveMCRDerivate(MCRObjectID.getInstance(derivateID));
            visitor.getPaths().stream()
                .map(MCRPath.class::cast)
                .filter(p -> !p.getOwnerRelativePath().endsWith(".xml"))
                .findFirst()
                .ifPresent(file -> {
                    derivate.getDerivate().getInternals().setMainDoc(file.getOwnerRelativePath());
                    try {
                        MCRMetadataManager.update(derivate);
                    } catch (MCRPersistenceException | MCRAccessException e) {
                        LOGGER.error("Could not set main file!", e);
                    }
                });
        } catch (IOException e) {
            LOGGER.error("Could not set main file!", e);
        }
    }

    protected MCRCategoryID getState() {
        return new MCRCategoryID("state", MCRConfiguration.instance()
            .getString("MCR.Sword." + this.lifecycleConfiguration.getCollection() + ".State"));
    }

    @Override
    public void init(MCRSwordLifecycleConfiguration lifecycleConfiguration) {
        this.lifecycleConfiguration = lifecycleConfiguration;
    }

    @Override
    public void destroy() {

    }

    protected MCRSwordLifecycleConfiguration getLifecycleConfiguration() {
        return lifecycleConfiguration;
    }

    protected void setLifecycleConfiguration(MCRSwordLifecycleConfiguration lifecycleConfiguration) {
        this.lifecycleConfiguration = lifecycleConfiguration;
    }

    protected MCRSwordMediaHandler getMediaHandler() {
        return mcrSwordMediaHandler;
    }

    protected MCRContentTransformer getTransformer() {
        return MCRContentTransformerFactory.getTransformer(MCRConfiguration.instance()
            .getString("MCR.Sword." + this.getLifecycleConfiguration().getCollection() + ".Transformer"));
    }

    @Override
    public void updateMetadata(MCRObject object, Deposit entry, boolean replace)
        throws SwordServerException, SwordError {
        throw new SwordServerException("Operation is not supported!", new OperationNotSupportedException());
    }

    @Override
    public void updateMetadataResources(MCRObject object, Deposit entry) throws SwordServerException {
        throw new SwordServerException("Operation is not supported!", new OperationNotSupportedException());
    }

    @Override
    public MCRObjectID ingestMetadataResources(Deposit deposit) throws SwordError, SwordServerException {
        throw new SwordServerException("Operation is not supported!", new OperationNotSupportedException());
    }

    @Override
    public void ingestResource(MCRObject mcrObject, Deposit deposit) throws SwordError, SwordServerException {
        throw new SwordServerException("Operation is not supported!", new OperationNotSupportedException());
    }

    public Document buildDCDocument(Map<String, List<String>> dublinCoreMetadata) {
        final Element dcRootElement = new Element("dc");
        final Document dc = new Document(dcRootElement);
        dublinCoreMetadata.entrySet().forEach(dcElementValueEntry -> {
            final String elemenName = dcElementValueEntry.getKey();
            dcElementValueEntry.getValue().forEach(value -> {
                final Element dcElement = new Element(elemenName, DC_NAMESPACE);
                dcElement.setText(value);
                dcRootElement.addContent(dcElement);
            });
        });
        return dc;
    }
}
