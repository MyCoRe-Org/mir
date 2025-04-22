package org.mycore.mir.migration;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;

/**
 * @author Thomas Scheffler (yagee)
 */
@MCRCommandGroup(
    name = "MIR migration 0.4")
@SuppressWarnings("PMD.MCR.ResourceResolver")
public class MIRMigration04Utils {

    private static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(
        syntax = "migrate note type",
        help = "set the type of mods:note to \"admin\" and converts \"mcr_intern\"  to \"admin\".")
    public static List<String> updateStateClassification() {
        URL styleFile = MIRMigration04Utils.class.getResource("/xsl/mycoreobject-migrate-note.xsl");
        if (styleFile == null) {
            LOGGER.error("Could not find migration stylesheet. File a bug!");
            return null;
        }
        //get all categories:
        TreeSet<String> ids = new TreeSet<>(MCRXMLMetadataManager.getInstance().listIDsOfType("mods"));
        ArrayList<String> cmds = new ArrayList<>(ids.size());
        for (String id : ids) {
            cmds.add("xslt " + id + " with file " + styleFile.toString());
        }
        return cmds;
    }

}
