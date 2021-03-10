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

    @MCRCommand(syntax = "backup all access keys to file {0}",
        help = "Backups all access keys the file {0}.")
    public static void backupAllAccessKeysToFile(String filename) throws Exception {
        List<MIRAccessKey> accessKeys = MIRAccessKeyManager.getAllAccessKeys();
        String json = MIRAccessKeyTransformer.accessKeysToJson(accessKeys);
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
        MIRAccessKeyManager.deleteAllAccessKeys();
    }

    @MCRCommand(syntax = "restore all access keys from file {0}",
        help = "Restores all access keys from file {0}.")
    public static void loadAccessKeysToFile(String filename) throws Exception {
        Path path = Path.of(filename);
        if (!Files.exists(path)) {
            LOGGER.warn("File {} doesnt exists.", filename);
            return;
        }
        String json = Files.readString(path, StandardCharsets.UTF_8);
        List<MIRAccessKey> accessKeys = MIRAccessKeyTransformer.jsonToAccessKeys(json);
        MIRAccessKeyManager.restoreAllAccessKeys(accessKeys);
    }
}
