package org.mycore.mir.migration;

import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRPersistenceException;
import org.mycore.datamodel.common.MCRActiveLinkException;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mods.MCRMODSWrapper;

@MCRCommandGroup(
    name = "MIR migration 2017.06")
@SuppressWarnings("PMD.MCR.ResourceResolver")
public class MIRMigration201706Utils {

    private static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(
        syntax = "migrate URN for all derivates",
        help = "migrate URN from Derivate to Document")
    public static List<String> migrateURN() {
        TreeSet<String> ids = new TreeSet<>(MCRXMLMetadataManager.getInstance().listIDsOfType("derivate"));
        ArrayList<String> cmds = new ArrayList<>(ids.size());
        for (String id : ids) {
            cmds.add("migrate URN for derivate " + id);
        }
        return cmds;
    }

    @MCRCommand(
        syntax = "migrate URN for derivate {0}",
        help = "migrate URN from Derivate {0} to Document")
    public static void migrateURN(String derId)
        throws MCRPersistenceException, MCRActiveLinkException, MCRAccessException, IOException {
        MCRObjectID derivateID = MCRObjectID.getInstance(derId);
        if (!"derivate".equals(derivateID.getTypeId())) {
            LOGGER.error("Command needs derivate as parameter: ", derId);
            return;
        }
        MCRDerivate derivate = MCRMetadataManager.retrieveMCRDerivate(derivateID);
        String urn = derivate.getDerivate().getURN();
        if (urn == null) {
            return;
        }
        MCRObjectID objectID = derivate.getOwnerID();
        if (!MCRMODSWrapper.isSupported(objectID)) {
            LOGGER.error("Cannot move urn {} to object {}.", urn, objectID);
            return;
        }
        LOGGER.info("Move urn {} to object {} ...", urn, objectID);
        MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);
        boolean objNeedsUpdate = setURN(object, urn);
        if (objNeedsUpdate) {
            LOGGER.info("Updating object {} ...", objectID);
            MCRMetadataManager.update(object);
        }
        derivate.getDerivate().setURN(null);
        LOGGER.info("Updating derivate {} ...", derivateID);
        MCRMetadataManager.update(derivate);
    }

    @MCRCommand(
        syntax = "migrate old coordinates to new",
        help = "migrates all objects with coordinates(point) to new coordinates(point and polygon).")
    public static List<String> updateNameIdentifier() {
        URL styleFile = MIRMigration201706Utils.class.getResource("/xsl/mycoreobject-migrate-coordinates.xsl");
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

    private static boolean setURN(MCRObject object, String urn) {
        MCRMODSWrapper modsWrapper = new MCRMODSWrapper(object);
        boolean urnPresent = modsWrapper.getElements("mods:identifier[@type='urn']")
            .stream()
            .map(Element::getTextTrim)
            .filter(s -> s.equals(urn))
            .findAny().isPresent();
        if (urnPresent) {
            return false;
        }
        modsWrapper.addElement("identifier").setAttribute("type", "urn").setText(urn);
        return true;
    }
}
