package org.mycore.mir.authorization.accesskeys;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;

@MCRCommandGroup(
    name = "MIR access keys")
public class MIRAccessKeyUtils {

    public static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(syntax = "export all access keys to file {0}",
        help = "Export all access keys the file {0}.")
    public static void exportAllAccessKeysToFile(String filename) throws Exception {
        //TODO
    }

    @MCRCommand(syntax = "import all access keys from file {0}",
        help = "import all access keys from file {0}.")
    public static void loadAccessKeysToFile(String filename) throws Exception {
        //TODO
    }
}
