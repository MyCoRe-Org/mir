package org.mycore.mir.migration;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

import org.apache.log4j.Logger;
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
    name = "MIR migration 0.3")
public class MIRMigration0_3 {

    private static final Logger LOGGER = Logger.getLogger(MIRMigration0_3.class);

    @MCRCommand(
        syntax = "migrate mir state classification",
        help = "migrates all object linked to \"mir_status\" classification to mycore's own \"state\".")
    public static List<String> updateStateClassification() {
        URL styleFile = MIRMigration0_3.class.getResource("/xsl/mycoreobject-migrate-status.xsl");
        if (styleFile == null) {
            LOGGER.error("Could not find migration stylesheet. File a bug!");
            return null;
        }
        //get all categories:
        MCRCategory mirStatus = MCRCategoryDAOFactory.getInstance().getCategory(MCRCategoryID.rootID("mir_status"), -1);
        if (mirStatus == null) {
            LOGGER.info("No classification 'mir_status' found.");
            return null;
        }
        boolean stateClassPresent = MCRCategoryDAOFactory.getInstance().exist(MCRCategoryID.rootID("state"));
        TreeSet<String> ids = new TreeSet<>();
        for (MCRCategory state : mirStatus.getChildren()) {
            ids.addAll(MCRCategLinkServiceFactory.getInstance().getLinksFromCategoryForType(state.getId(), "mods"));
        }
        ArrayList<String> cmds = new ArrayList<>(ids.size() + (stateClassPresent ? 1 : 2));
        if (!stateClassPresent){
            LOGGER.info("state classification is not present, loading from MyCoRe server.");
            cmds.add("load classification from url http://www.mycore.org/classifications/state.xml");
        }
        for (String id : ids) {
            cmds.add("xslt " + id + " with file " + styleFile.toString());
        }
        cmds.add("delete classification mir_status");
        return cmds;
    }

}
