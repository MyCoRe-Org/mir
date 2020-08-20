package org.mycore.mir.migration;

import java.util.List;
import java.util.Objects;
import java.util.function.Predicate;
import java.util.stream.Stream;

import javax.xml.transform.TransformerException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mir.editor.MIRUnescapeResolver;
import org.mycore.mods.MCRMODSWrapper;

@MCRCommandGroup(
    name = "MIR migration 2020.06")
public class MIRMigration202006Utils {

    public static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(
        syntax = "check migration of titleInfo or abstract {0}",
        help = "check migration of titleInfo or abstract for the Object {0} is required")
    public static void checkMigrationOfTitleInfoOrAbstractRequired(String mycoreObject) {
        final MCRObjectID objectID = MCRObjectID.getInstance(mycoreObject);

        if (!MCRMetadataManager.exists(objectID)) {
            throw new MCRException("The object " + objectID.toString() + " does not exist!");
        }

        final MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);
        final MCRMODSWrapper wrapper = new MCRMODSWrapper(object);
        final Element mods = wrapper.getMODS();

        final List<Element> abstracts = mods.getChildren("abstract", MCRConstants.MODS_NAMESPACE);

        final Predicate<String> isInvalidAltFormat = altFormat -> {
            try {
                return !new MIRUnescapeResolver().resolve("unescape-html-content:" + altFormat, "").isEmpty();
            } catch (TransformerException e) {
                return true;
            }
        };
        final boolean abstractMigrationRequired = abstracts.stream()
            .map(_abstract -> _abstract.getAttributeValue("altFormat"))
            .filter(Objects::nonNull)
            .anyMatch(isInvalidAltFormat);

        final List<Element> titleInfo = mods.getChildren("titleInfo", MCRConstants.MODS_NAMESPACE);
        final boolean titleInfoMigrationRequired = titleInfo.stream()
            .flatMap(ti -> Stream.concat(Stream.concat(ti.getChildren("nonSort", MCRConstants.MODS_NAMESPACE).stream(),
                ti.getChildren("title", MCRConstants.MODS_NAMESPACE).stream()),
                ti.getChildren("subTitle", MCRConstants.MODS_NAMESPACE).stream()))
            .filter(Objects::nonNull)
            .map(el -> el.getAttributeValue("altFormat"))
            .filter(Objects::nonNull)
            .anyMatch(isInvalidAltFormat);

        if(abstractMigrationRequired) {
            throw new MCRException("Abstract migration needed for " + mycoreObject);
        }

        if(titleInfoMigrationRequired) {
            throw new MCRException("TitleInfo migration needed for " + mycoreObject);
        }
    }

}
