package org.mycore.mir.imageware;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.FileSystem;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.PosixFilePermissions;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import java.util.function.Consumer;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.access.MCRAccessException;
import org.mycore.access.MCRAccessManager;
import org.mycore.access.MCRMissingPermissionException;
import org.mycore.common.MCRException;
import org.mycore.common.MCRUsageException;
import org.mycore.common.config.MCRConfigurationException;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.transformer.MCRContentTransformer;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.datamodel.ifs.MCRContentInputStream;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.datamodel.niofs.utils.MCRTreeCopier;
import org.mycore.mods.MCRMODSWrapper;
import org.mycore.mods.identifier.MCRGBVURLDetector;
import org.mycore.mods.identifier.MCRURLIdentifierDetector;
import org.mycore.services.packaging.MCRPacker;
import org.mycore.services.packaging.MCRPackerJobAction;

/**
 * <p>Creates the ZIP-Files for the image ware electronic reading room.</p>
 * <b>Parameters:</b>
 * <dl>
 * <dt>objectId</dt>
 * <dd>The objectID which should be packed (Linked derivates are automatic included)</dd>
 * </dl>
 * <b>Configuration:</b>
 * <dl>
 * <dt>TransformerID</dt>
 * <dd>The transformer which should be used to transform the metadata</dd>
 * <dt>Destination</dt>
 * <dd>The destination where the packets should be created</dd>
 * <dt>FlagType</dt>
 * <dd>The packer sets a date with $FlagType as name in the MyCoRe-Service part</dd>
 * <dt>DefaultPPNDB</dt>
 * <dd>If the PPN doesn't contain a database part then a default value will be set.</dd>
 * </dl>
 * <p><b>WARNING:</b> The system user needs write permission to the object id </p>
 */
public class MIRImageWarePacker extends MCRPacker {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String FILE_RIGHTS_CONFIGURATION_KEY = "FileRights";

    private static final String DEFAULT_PPN_DB_CONFIGURATION_KEY = "DefaultPPNDB";

    private static final String DESTINATION_CONFIGURATION_KEY = "Destination";

    private static final String TRANSFORMER_ID_CONFIGURATION_KEY = "TransformerID";

    private static final String FLAG_TYPE_CONFIGURATION_KEY = "FlagType";

    protected MCRObjectID getObjectID() {
        return MCRObjectID.getInstance(this.getParameters().get("objectId"));
    }

    protected MCRContentTransformer getTransformer() {
        String transformerID = this.getConfiguration().get(TRANSFORMER_ID_CONFIGURATION_KEY);
        MCRContentTransformer transformer = MCRContentTransformerFactory.getTransformer(transformerID);
        if (transformer == null) {
            throw new MCRConfigurationException("Could not resolve transformer with id : " + transformerID);
        }

        return transformer;
    }

    private static Optional<String> detectPPN(MCRObject mcrObject, String defaultPPNDB) {
        MCRMODSWrapper modsWrapper = new MCRMODSWrapper(mcrObject);
        List<Element> ppnElements = modsWrapper.getElements(".//mods:identifier[@type='ppn']");
        if (ppnElements.size() > 0) {
            Element firstPPNElement = ppnElements.stream().findFirst().get();
            String ppnElementContent = firstPPNElement.getText();
            String[] ppnParts = ppnElementContent.split(":");
            return switch (ppnParts.length) {
                case 1 ->
                    // User inserted 812684613, then defaultPPNDB will be used to build $defaultPPNDB_ppn_812684613
                    Optional.of(String.format(Locale.ROOT, "%s_ppn_%s", defaultPPNDB, ppnElementContent));
                case 2 ->
                    // User inserted  gvk:812684613, then gvk_ppn_812684613 will be build
                    Optional.of(String.format(Locale.ROOT, "%s_ppn_%s", ppnParts[0], ppnParts[1]));
                case 3 ->
                    // user inserted gvk:ppn:812684613, then gvk_ppn_812684613 will be build
                    Optional.of(ppnElementContent.replace(":", "_"));
                default -> throw new MCRException(
                    "ppn in mods:identifier[@type='ppn'] cannot be parsed (" + ppnElementContent + ")");
            };
        }

        List<Element> elements = modsWrapper.getElements(".//mods:identifier[@type='uri']");
        MCRURLIdentifierDetector identifierDetector = new MCRURLIdentifierDetector();
        identifierDetector.addDetector(new MCRGBVURLDetector());
        List<URI> possiblePPNURIs = elements.stream()
            .map(Element::getText)
            .map(s -> {
                try {
                    return new URI(s);
                } catch (URISyntaxException e) {
                    return null;
                }
            })
            .filter(o -> o != null)
            .collect(Collectors.toList());

        for (URI possiblePPNURI : possiblePPNURIs) {
            Optional<Map.Entry<String, String>> detectedIdentifiers = identifierDetector.detect(possiblePPNURI);

            if (!detectedIdentifiers.isPresent()) {
                continue;
            }

            Map.Entry<String, String> identifierValueEntry = detectedIdentifiers.get();
            if ("ppn".equals(identifierValueEntry.getKey())) {
                return Optional.of(identifierValueEntry.getValue().replace(":", "_"));
            }
        }
        return Optional.empty();
    }

    // used in mycoreobject-migrate-ppn.xsl
    public static final String detectPPN(String objectIDString) {
        MCRObjectID objectID = MCRObjectID.getInstance(objectIDString);
        MCRObject mcrObject = MCRMetadataManager.retrieveMCRObject(objectID);
        String defaultPPNDB = MCRPackerJobAction.getConfiguration("ImageWare").get(DEFAULT_PPN_DB_CONFIGURATION_KEY);
        String ppn = detectPPN(mcrObject, defaultPPNDB).orElse("");
        return ppn;
    }

    // used in modsdetails-external.xsl
    public static final boolean displayPackerButton(String objectIDString, String packerId) {
        MCRObjectID objectID = MCRObjectID.getInstance(objectIDString);
        MCRObject mcrObject = MCRMetadataManager.retrieveMCRObject(objectID);

        Map<String, String> configuration = MCRPackerJobAction.getConfiguration(packerId);

        if (configuration.size() == 0) {
            return false;
        }

        try {
            checkACL(objectID, packerId);
        } catch (MCRAccessException e) {
            return false;
        }

        Date date = mcrObject.getService().getDate(configuration.get(FLAG_TYPE_CONFIGURATION_KEY));

        return date == null || detectPPN(mcrObject, configuration.get(DEFAULT_PPN_DB_CONFIGURATION_KEY)).isPresent();
    }

    @Override
    public void checkSetup() throws MCRConfigurationException, MCRAccessException {
        Map<String, String> parameters = this.getParameters();
        if (!parameters.containsKey("objectId")) {
            throw new MCRUsageException("No ObjectID in parameters!");
        }

        MCRObjectID objectID = getObjectID();
        MCRObject mcrObject = MCRMetadataManager.retrieveMCRObject(objectID);
        Optional<String> ppn = detectPPN(mcrObject, "");

        if (!ppn.isPresent()) {
            throw new MCRUsageException("No PPN detected in object: " + objectID.toString());
        }

        if (!parameters.containsKey("packer")) {
            throw new MCRException("Packer is undefined! This should be impossible!");
        }

        String packer = parameters.get("packer");
        checkACL(objectID, packer);
    }

    private static void checkACL(MCRObjectID objectID, String packer) throws MCRAccessException {
        String permission = "packer-" + packer;
        if (!MCRAccessManager.checkPermission(objectID, permission)) {
            throw new MCRMissingPermissionException("Packing ImageWare packet", objectID.toString(), permission);
        }
        if (!MCRAccessManager.checkPermission(objectID, MCRAccessManager.PERMISSION_WRITE)) {
            throw new MCRMissingPermissionException("Add packer flag to " + objectID.toString(), objectID.toString(),
                MCRAccessManager.PERMISSION_WRITE);
        }
    }

    @Override
    public void pack() throws ExecutionException {
        MCRObjectID objectID = getObjectID();
        Map<String, String> configuration = getConfiguration();
        if (!configuration.containsKey(FLAG_TYPE_CONFIGURATION_KEY)) {
            LOGGER.error("No flag type specified in configuration!");
            throw new MCRConfigurationException("No flag type specified in configuration!");
        }

        MCRObject mcrObject = MCRMetadataManager.retrieveMCRObject(objectID);

        String defaultPPNDB = getConfiguration().get(DEFAULT_PPN_DB_CONFIGURATION_KEY);
        String ppn = detectPPN(mcrObject, defaultPPNDB)
            .orElseThrow(() -> new MCRException("Could not detect ppn of mycore object " + mcrObject.getId()));

        LOGGER.info("Start packing of : " + objectID);
        List<MCRObjectID> derivateIds = MCRMetadataManager.getDerivateIds(objectID);
        final String zipFileName = ppn + ".zip";
        openZip(zipFileSystem -> {
            try {
                // transform & write metadata
                MCRContent modsContent = MCRXMLMetadataManager.getInstance().retrieveContent(objectID);
                MCRContentInputStream resultStream = getTransformer().transform(modsContent).getContentInputStream();
                Files.copy(resultStream, zipFileSystem.getPath("/", ppn + ".xml"));

                // write derivate files
                Consumer<MCRPath> copyDerivates = getCopyDerivateConsumer(zipFileSystem, ppn);
                derivateIds.stream()
                    .map(id -> MCRPath.getPath(id.toString(), "/"))
                    .forEach(copyDerivates);
            } catch (IOException e) {
                LOGGER.error("Could get MCRContent for object with id: " + objectID.toString(), e);
            }
        }, zipFileName);

        if (!configuration.containsKey(FILE_RIGHTS_CONFIGURATION_KEY)) {
            LOGGER.info("No fileRights configuration found!");
        } else {
            Path targetZipPath = getTargetZipPath(zipFileName);
            String fileRights = configuration.get(FILE_RIGHTS_CONFIGURATION_KEY);
            try {
                Files.setPosixFilePermissions(targetZipPath, PosixFilePermissions.fromString(fileRights));
            } catch (IOException e) {
                throw new ExecutionException("Could not set right file rights!", e);
            }
        }

        String flagType = configuration.get(FLAG_TYPE_CONFIGURATION_KEY);
        mcrObject.getService().setDate(flagType, new Date());
        try {
            MCRMetadataManager.update(mcrObject);
        } catch (MCRAccessException e) {
            throw new ExecutionException("Could not set " + flagType + " flag!", e);
        }
    }

    private Consumer<MCRPath> getCopyDerivateConsumer(FileSystem zipFileSystem, String ppn) {
        return path -> {
            Path destinationFolder = zipFileSystem.getPath("/", ppn + "_" + path.getOwner());
            try {
                Files.createDirectory(destinationFolder);
                MCRTreeCopier derivateToZipCopier = new MCRTreeCopier(path, destinationFolder);
                Files.walkFileTree(path, derivateToZipCopier);
            } catch (IOException e) {
                LOGGER.error("Error while writing to ZIP: " + getTargetZipPath(ppn + ".zip").toString(), e);
            }
        };
    }

    private Path getTargetZipPath(String fileName) {
        String targetFolderPath = this.getConfiguration().get(DESTINATION_CONFIGURATION_KEY);
        return FileSystems.getDefault().getPath(targetFolderPath, fileName);
    }

    private URI openZip(Consumer<FileSystem> fileSystemConsumer, String fileName) {
        URI destination = getTargetZipPath(fileName).toUri();
        Map<String, String> env = new HashMap<>();
        env.put("create", "true");
        URI uri = URI.create("jar:" + destination.toString());
        try (FileSystem zipFs = FileSystems.newFileSystem(uri, env)) {
            fileSystemConsumer.accept(zipFs);
        } catch (IOException e) {
            LOGGER.error("Could not create/write to zip file: " + destination.toString(), e);
        }
        return uri;
    }

    @Override
    public void rollback() {
        MCRObjectID objectID = getObjectID();
        MCRObject mcrObject = MCRMetadataManager.retrieveMCRObject(objectID);
        Optional<String> ppn = detectPPN(mcrObject, getConfiguration().get(DEFAULT_PPN_DB_CONFIGURATION_KEY));

        if (ppn.isPresent()) {
            Path filePath = getTargetZipPath(ppn.get() + ".zip");
            LOGGER.info("Rollback: Check for existing ImageWarePackage: " + filePath.toString());
            if (Files.exists(filePath)) {
                LOGGER.info("Rollback: File found, try to delete: " + filePath.toString());
                try {
                    Files.delete(filePath);
                } catch (IOException e) {
                    LOGGER.error("Could not delete file " + filePath.toString(), e);
                }
            }
        }
    }
}
