package org.mycore.mir.migration;

import org.apache.log4j.Logger;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.urn.services.MCRURNManager;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;


@MCRCommandGroup(
    name = "MIR migration 2017.06")
public class MIRMigration2017_06 {

    private static final Logger LOGGER = Logger.getLogger(MIRMigration2017_06.class);

    @MCRCommand(
            syntax = "migrate URN",
            help = "migrate URN from Derivate to Document")
    public static List<String> migrateURN() {
        URL styleFile = MIRMigration2017_06.class.getResource("/xsl/mycoreobject-migrate-urn.xsl");
        if (styleFile == null) {
            LOGGER.error("Could not find migration stylesheet. File a bug!");
            return null;
        }
        TreeSet<String> ids = new TreeSet<>(MCRXMLMetadataManager.instance().listIDsOfType("mods"));
        ArrayList<String> cmds = new ArrayList<>(ids.size());
        for (String id : ids) {
            cmds.add("xslt " + id + " with file " + styleFile.toString());
        }
        return cmds;
    }

    public static String getURNforDerivate(String derivate) {
        return MCRURNManager.getURNforDocument(derivate);
    }
}
