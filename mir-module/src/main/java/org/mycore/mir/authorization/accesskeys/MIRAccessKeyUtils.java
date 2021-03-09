package org.mycore.mir.authorization.accesskeys;

import java.util.List;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;

@MCRCommandGroup(
    name = "MIR access keys")
public class MIRAccessKeyUtils {

    public static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(syntax = "export all access keys to file {0}",
        help = "Exports all access keys the file {0}.")
    public static void exportAllAccessKeysToFile(String filename) throws Exception {
        List<MIRAccessKeyInformation> accessKeyInformations = MIRAccessKeyManager.getAccessKeyInformations();
        String json = MIRAccessKeyTransformer.accessKeyInformationsToJson(accessKeyInformations);
        Path path = Path.of(filename);
        if (Files.exists(path)) {
            LOGGER.warn("File {} yet exists, overwrite.", filename);
        }
        LOGGER.info("Writing to file {} ...", filename);
        Files.writeString(path, json, StandardCharsets.UTF_8);
    }

    @MCRCommand(syntax = "delete all access keys",
        help = "Deletes all access keys.")
    public static void exportAllAccessKeysToFile() throws Exception {
        MIRAccessKeyManager.deleteAccessKeyInformations();
    }

    @MCRCommand(syntax = "import all access keys from file {0}",
        help = "Imports all access keys from file {0}.")
    public static void loadAccessKeysToFile(String filename) throws Exception {
        Path path = Path.of(filename);
        if (!Files.exists(path)) {
            LOGGER.warn("File {} doesnt exists.", filename);
            return;
        }
        String json = Files.readString(path, StandardCharsets.UTF_8);
        List<MIRAccessKeyInformation> accessKeyInformations
            = MIRAccessKeyTransformer.jsonToAccessKeyInformations(json);
        MIRAccessKeyManager.setAccessKeysInformations(accessKeyInformations);
    }
}
