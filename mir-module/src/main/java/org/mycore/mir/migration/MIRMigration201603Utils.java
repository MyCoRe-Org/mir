package org.mycore.mir.migration;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;

/**
 * @author Kathleen Neumann (mcrkkrebs)
 */
@MCRCommandGroup(
    name = "MIR migration 2016.03")
@SuppressWarnings("PMD.MCR.ResourceResolver")
public class MIRMigration201603Utils {

    private static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(
        syntax = "migrate ppn",
        help = "change all ppn entries to valid uri e.g. http://uri.gbv.de/document/gvk:ppn:813002605")
    public static List<String> updateIdentifierPPN() {
        URL styleFile = MIRMigration201603Utils.class.getResource("/xsl/mycoreobject-migrate-ppn.xsl");
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
        syntax = "migrate mir rights classification",
        help = "migrates all mods:accessCondition entries of type 'use and reproduction'. "
            + "CC licenses now contains version information, entries are now under mycore classification support "
            + "and renamed classification to licenses instead of rights.")
    public static List<String> updateStateClassification() {
        URL styleFile = MIRMigration201603Utils.class.getResource("/xsl/mycoreobject-migrate-rights.xsl");
        if (styleFile == null) {
            LOGGER.error("Could not find migration stylesheet. File a bug!");
            return null;
        }
        //get all categories:
        MCRCategory mirRights = MCRCategoryDAOFactory.obtainInstance().getCategory(new MCRCategoryID("mir_rights"), -1);
        if (mirRights == null) {
            LOGGER.info("No classification 'mir_rights' found.");
            return null;
        }

        TreeSet<String> ids = new TreeSet<>(MCRXMLMetadataManager.getInstance().listIDsOfType("mods"));
        ArrayList<String> cmds = new ArrayList<>(ids.size());
        MCRCategory mirLicenses = MCRCategoryDAOFactory.obtainInstance().getCategory(new MCRCategoryID("mir_licenses"),
            -1);
        if (mirLicenses == null) {
            LOGGER.info("licenses classification is not present, loading from MyCoRe server.");
            cmds.add("load classification from url http://www.mycore.org/classifications/mir_licenses.xml");
        }

        for (String id : ids) {
            cmds.add("xslt " + id + " with file " + styleFile.toString());
        }
        cmds.add("delete classification mir_rights");
        return cmds;
    }

    @MCRCommand(
        syntax = "migrate namePart",
        help = "splits mods:displayForm in to mods:namePart")
    public static List<String> updateNamePart() {
        URL styleFile = MIRMigration201603Utils.class.getResource("/xsl/mycoreobject-migrate-namePart.xsl");
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
