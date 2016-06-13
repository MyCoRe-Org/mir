package org.mycore.mir.migration;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

import org.apache.log4j.Logger;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.datamodel.classifications2.MCRCategLinkServiceFactory;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;

/**
 * @author Thomas Scheffler (yagee)
 */
@MCRCommandGroup(
    name = "MIR migration 0.4")
public class MIRMigration0_4 {

    private static final Logger LOGGER = Logger.getLogger(MIRMigration0_4.class);

    @MCRCommand(
        syntax = "migrate note type",
        help = "set the type of mods:note to \"admin\" and converts \"mcr_intern\"  to \"admin\".")
    public static List<String> updateStateClassification() {
        URL styleFile = MIRMigration0_4.class.getResource("/xsl/mycoreobject-migrate-note.xsl");
        if (styleFile == null) {
            LOGGER.error("Could not find migration stylesheet. File a bug!");
            return null;
        }
        //get all categories:
        TreeSet<String> ids = new TreeSet<>(MCRXMLMetadataManager.instance().listIDsOfType("mods"));
        ArrayList<String> cmds = new ArrayList<>(ids.size());
        for (String id : ids) {
        	cmds.add("xslt " + id + " with file " + styleFile.toString());
        }
        return cmds;
    }
    

}
