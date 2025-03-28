package org.mycore.mir.migration;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.datamodel.classifications2.MCRCategLinkServiceFactory;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;

/**
 * @author Thomas Scheffler (yagee)
 */
@MCRCommandGroup(
    name = "MIR migration 0.3")
public class MIRMigration03Utils {

    private static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(
        syntax = "migrate mir state classification",
        help = "migrates all object linked to \"mir_status\" classification to mycore's own \"state\".")
    public static List<String> updateStateClassification() {
        URL styleFile = MIRMigration03Utils.class.getResource("/xsl/mycoreobject-migrate-status.xsl");
        if (styleFile == null) {
            LOGGER.error("Could not find migration stylesheet. File a bug!");
            return null;
        }
        //get all categories:
        MCRCategory mirStatus = MCRCategoryDAOFactory.obtainInstance().getCategory(new MCRCategoryID("mir_status"), -1);
        if (mirStatus == null) {
            LOGGER.info("No classification 'mir_status' found.");
            return null;
        }
        boolean stateClassPresent = MCRCategoryDAOFactory.obtainInstance().exist(new MCRCategoryID("state"));
        TreeSet<String> ids = new TreeSet<>();
        for (MCRCategory state : mirStatus.getChildren()) {
            ids.addAll(MCRCategLinkServiceFactory.obtainInstance().getLinksFromCategoryForType(state.getId(), "mods"));
        }
        ArrayList<String> cmds = new ArrayList<>(ids.size() + (stateClassPresent ? 1 : 2));
        if (!stateClassPresent) {
            LOGGER.info("state classification is not present, loading from MyCoRe server.");
            cmds.add("load classification from url http://www.mycore.org/classifications/state.xml");
        }
        for (String id : ids) {
            cmds.add("xslt " + id + " with file " + styleFile.toString());
        }
        cmds.add("delete classification mir_status");
        return cmds;
    }

    @MCRCommand(
        syntax = "migrate mods originInfo eventType",
        help = "migrates all objects with originInfo without enventType to eventType \"publish\".")
    public static List<String> updateOriginInfo() {
        URL styleFile = MIRMigration03Utils.class.getResource("/xsl/mycoreobject-migrate-origininfo.xsl");
        if (styleFile == null) {
            LOGGER.error("Could not find migration stylesheet. File a bug!");
            return null;
        }
        TreeSet<String> ids = new TreeSet<>(MCRXMLMetadataManager.getInstance().listIDsOfType("mods"));
        ArrayList<String> cmds = new ArrayList<>(ids.size());
        for (String id : ids) {
            cmds.add("xslt " + id + " with file " + styleFile.toString());
        }
        return cmds;
    }

    @MCRCommand(
        syntax = "migrate mods name nameIdentifier",
        help = "migrates all objects with name property valueURI to nameIdentifier elements.")
    public static List<String> updateNameIdentifier() {
        URL styleFile = MIRMigration03Utils.class.getResource("/xsl/mycoreobject-migrate-nameIdentifier.xsl");
        if (styleFile == null) {
            LOGGER.error("Could not find migration stylesheet. File a bug!");
            return null;
        }
        TreeSet<String> ids = new TreeSet<>(MCRXMLMetadataManager.getInstance().listIDsOfType("mods"));
        ArrayList<String> cmds = new ArrayList<>(ids.size());
        for (String id : ids) {
            cmds.add("xslt " + id + " with file " + styleFile.toString());
        }
        return cmds;
    }

}
