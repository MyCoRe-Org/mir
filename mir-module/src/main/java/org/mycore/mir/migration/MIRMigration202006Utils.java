package org.mycore.mir.migration;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.xml.transform.TransformerException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.DOMOutputter;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.datamodel.common.MCRDataURL;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.MCRObjectCommands;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mir.editor.MIREditorUtils;
import org.mycore.mir.editor.MIRPostProcessor;
import org.mycore.mir.editor.MIRUnescapeResolver;
import org.mycore.mods.MCRMODSWrapper;

@MCRCommandGroup(
    name = "MIR migration 2020.06")
public class MIRMigration202006Utils {

    public static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(
        syntax = "select objects which need titleInfo or abstract migration",
        help = "select objects which need titleInfo or abstract migration")
    public static void selectObjectWhichNeedMigration() {
        final List<String> objectIds = MCRXMLMetadataManager.instance().listIDsOfType("mods");
        final MIRUnescapeResolver unescapeResolver = new MIRUnescapeResolver();

        final List<String> objectsToMigrate = objectIds.stream().filter((mycoreObject) -> {
            final MCRObjectID objectID = MCRObjectID.getInstance(mycoreObject);

            final MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);
            final MCRMODSWrapper wrapper = new MCRMODSWrapper(object);
            final Element mods = wrapper.getMODS();

            try {
                final List<Element> abstracts = mods.getChildren("abstract", MCRConstants.MODS_NAMESPACE);

                final Predicate<String> isInvalidAltFormat = altFormat -> {
                    try {
                        return !unescapeResolver.resolve("unescape-html-content:" + altFormat, "").isEmpty();
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
                    .filter(Objects::nonNull)
                    .map(el -> el.getAttributeValue("altFormat"))
                    .filter(Objects::nonNull)
                    .anyMatch(isInvalidAltFormat);

                return abstractMigrationRequired || titleInfoMigrationRequired;
            } catch (RuntimeException e) {
                return true;
            }
        }).collect(Collectors.toList());

        MCRObjectCommands.setSelectedObjectIDs(objectsToMigrate);
    }

    @MCRCommand(
        syntax = "migrate titleInfo or abstract {0}",
        help = "migrate titleInfo or abstract for the Object {0} is required")
    public static void tryMigrationOfTitleInfoOrAbstractRequired(String mycoreObject) throws MCRAccessException {
        final MCRObjectID objectID = MCRObjectID.getInstance(mycoreObject);

        final MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);
        final MCRMODSWrapper wrapper = new MCRMODSWrapper(object);
        final Element mods = wrapper.getMODS();

        final List<Element> abstracts = mods.getChildren("abstract", MCRConstants.MODS_NAMESPACE);
        final SAXBuilder sb = new SAXBuilder();

        final boolean changedAbstracts = abstracts.stream()
            .filter(_abstract -> Objects.nonNull(_abstract.getAttributeValue("altFormat")))
            .peek(element -> {
                final String format = element.getAttributeValue("altFormat");
                final byte[] data = getBytesFromAltFormat(format);

                final Element abstrct;

                try {
                    final Document decodedDocument = sb.build(new ByteArrayInputStream(data));
                    abstrct = decodedDocument.getRootElement();
                    final String wrongHTML = abstrct.getTextNormalize();
                    abstrct.setText(MIREditorUtils.getXHTMLSnippedString(wrongHTML));

                    final DOMOutputter domOutputter = new DOMOutputter();
                    final org.w3c.dom.Document domDocument = domOutputter.output(decodedDocument);
                    final String base64URL = MCRDataURL.build(domDocument, "base64", "text/xml", "UTF-8");
                    element.setAttribute("altFormat", base64URL);
                } catch (JDOMException | IOException | TransformerException e) {
                    throw new MCRException("Error while building document!", e);
                }
            }).count() > 0;

        final List<Element> titleInfos = mods.getChildren("titleInfo", MCRConstants.MODS_NAMESPACE);
        final boolean changedTitleInfos = titleInfos.stream()
            .filter(el -> Objects.nonNull(el.getAttributeValue("altFormat")))
            .peek((element) -> {
                final String format = element.getAttributeValue("altFormat");
                final byte[] data = getBytesFromAltFormat(format);
                final Element titleInfo;

                try {
                    final Document decodedDocument = sb.build(new ByteArrayInputStream(data));
                    titleInfo = decodedDocument.getRootElement();
                    Stream.of(MIRPostProcessor.TITLE_SUB_ELEMENTS)
                        .map(en -> Optional.ofNullable(titleInfo.getChild(en, MCRConstants.MODS_NAMESPACE))
                            .orElse(titleInfo.getChild(en)))
                        .filter(Objects::nonNull)
                        .forEach(child -> {
                            final String wrongHTML = child.getTextNormalize();
                            child.setText(MIREditorUtils.getXHTMLSnippedString(wrongHTML));
                        });

                    final DOMOutputter domOutputter = new DOMOutputter();
                    final org.w3c.dom.Document domDocument = domOutputter.output(decodedDocument);
                    final String base64URL = MCRDataURL.build(domDocument, "base64", "text/xml", "UTF-8");
                    element.setAttribute("altFormat", base64URL);
                } catch (JDOMException | IOException | TransformerException e) {
                    throw new MCRException("Error while building document!", e);
                }
            }).count() > 0;

        if (changedAbstracts || changedTitleInfos) {
            MCRMetadataManager.update(object);
        }
    }

    private static byte[] getBytesFromAltFormat(String format) {
        final byte[] data;

        try {
            data = MCRDataURL.parse(format).getData();
        } catch (MalformedURLException e) {
            throw new MCRException("Error while building url", e);
        }
        return data;
    }
}
