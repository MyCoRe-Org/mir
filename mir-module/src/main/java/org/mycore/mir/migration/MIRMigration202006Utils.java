package org.mycore.mir.migration;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.StringReader;
import java.net.MalformedURLException;
import java.util.ArrayList;
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
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Entities;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.common.MCRDataURL;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetaClassification;
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
import org.xml.sax.SAXException;

@MCRCommandGroup(
    name = "MIR migration 2020.06")
public class MIRMigration202006Utils {

    public static final Logger LOGGER = LogManager.getLogger();

    private static final MCRCategoryID CONTENT_TYPE_ID = MCRCategoryID.fromString("derivate_types:content");

    @MCRCommand(syntax = "migrate derivate display to category {0}",
        help = "link derivates with @display=false to the given category {0}")
    public static List<String> migrateDerivateDisplay(String targetCategory) {
        MCRCategoryID categoryID = MCRCategoryID.fromString(targetCategory);
        if (!MCRCategoryDAOFactory.getInstance().exist(categoryID)) {
            throw new MCRException("Category " + categoryID + " does not exist!");
        }
        final MCRXMLMetadataManager mcrxmlMetadataManager = MCRXMLMetadataManager.instance();
        final List<String> derivates = mcrxmlMetadataManager.listIDsOfType("derivate");
        return derivates.stream()
            .map(MCRObjectID::getInstance)
            .map(mcrid -> {
                try {
                    return mcrxmlMetadataManager.retrieveXML(mcrid);
                } catch (IOException | JDOMException | SAXException e) {
                    throw new MCRException(e);
                }
            })
            .filter(
                der -> der.getRootElement().getChild("derivate").getAttributeValue("display", "true").equals("false"))
            .map(MCRDerivate::new)
            .peek(der -> addContentIfNeeded(der))
            .map(der -> getMigrationCommand(der, categoryID))
            .collect(Collectors.toList());
    }

    private static void addContentIfNeeded(MCRDerivate der) {
        final ArrayList<MCRMetaClassification> metaClassifications = der.getDerivate().getClassifications();
        if (!metaClassifications.isEmpty()) {
            return;
        }
        metaClassifications.add(new MCRMetaClassification("classification", 0, null, CONTENT_TYPE_ID));
    }

    private static String getMigrationCommand(MCRDerivate der, MCRCategoryID targetCategory) {
        return Stream.concat(
            der.getDerivate().getClassifications().stream().map(m -> new MCRCategoryID(m.getClassId(), m.getCategId())),
            Stream.of(targetCategory))
            .map(MCRCategoryID::toString)
            .collect(Collectors.joining(",", "set classification of derivate " + der.getId() + " to ", ""));
    }

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
        final DOMOutputter domOutputter = new DOMOutputter();
        final XMLOutputter xout = new XMLOutputter(Format.getRawFormat());

        final boolean changedAbstracts = abstracts.stream()
            .filter(_abstract -> Objects.nonNull(_abstract.getAttributeValue("altFormat")))
            .peek(element -> {
                try {
                    final Document decodedDocument = getEmbeddedDocument(sb, element);
                    final Element abstrct = decodedDocument.getRootElement();
                    fixHTML(xout, abstrct);
                    embedDocumentAsAltFormat(domOutputter, element, decodedDocument);
                } catch (JDOMException | IOException | TransformerException e) {
                    throw new MCRException("Error while building document!", e);
                }
            }).count() > 0;

        final List<Element> titleInfos = mods.getChildren("titleInfo", MCRConstants.MODS_NAMESPACE);
        final boolean changedTitleInfos = titleInfos.stream()
            .filter(el -> Objects.nonNull(el.getAttributeValue("altFormat")))
            .peek((element) -> {
                try {
                    final Document decodedDocument = getEmbeddedDocument(sb, element);
                    final Element titleInfo = decodedDocument.getRootElement();
                    Stream.of(MIRPostProcessor.TITLE_SUB_ELEMENTS)
                        .map(en -> Optional.ofNullable(titleInfo.getChild(en, MCRConstants.MODS_NAMESPACE))
                            .orElse(titleInfo.getChild(en)))
                        .filter(Objects::nonNull)
                        .forEach(child -> {
                            fixHTML(xout, child);
                        });
                    embedDocumentAsAltFormat(domOutputter, element, decodedDocument);
                } catch (JDOMException | IOException | TransformerException e) {
                    throw new MCRException("Error while building document!", e);
                }
            }).count() > 0;

        if (changedAbstracts || changedTitleInfos) {
            MCRMetadataManager.update(object);
        }
    }

    static void embedDocumentAsAltFormat(DOMOutputter domOutputter, Element target, Document embeddable)
        throws JDOMException, TransformerException, MalformedURLException {
        final org.w3c.dom.Document domDocument = domOutputter.output(embeddable);
        final String base64URL = MCRDataURL.build(domDocument, "base64", "text/xml", "UTF-8");
        target.setAttribute("altFormat", base64URL);
    }

    static void fixHTML(XMLOutputter xout, Element element) {
        //if child elements are present, the content is not yet encoded, print as XML string
        final String wrongHTML = element.getChildren().isEmpty() ? element.getTextTrim()
            : xout.outputString(element.getContent());
        element.setText(MIREditorUtils.getXHTMLSnippedString(wrongHTML));//set XML as text nodes
    }

    static Document getEmbeddedDocument(SAXBuilder saxBuilder, Element element)
        throws JDOMException, IOException {
        final String format = element.getAttributeValue("altFormat");
        final byte[] data = getBytesFromAltFormat(format);
        try {
            return saxBuilder.build(new ByteArrayInputStream(data));
        } catch (JDOMException | IOException e) {
            //parse as HTML, also resolves HTML entities like &ge;
            final org.jsoup.nodes.Document jsoupDoc = Jsoup.parse(new ByteArrayInputStream(data), null, "");
            //output as valid XML
            jsoupDoc.outputSettings().prettyPrint(false);
            jsoupDoc.outputSettings().escapeMode(Entities.EscapeMode.xhtml);
            jsoupDoc.outputSettings().syntax(org.jsoup.nodes.Document.OutputSettings.Syntax.xml);
            //re-parse as XML
            final Document decodedDocument = saxBuilder.build(new StringReader(jsoupDoc.body().html()));
            return decodedDocument;
        }
    }

    static byte[] getBytesFromAltFormat(String format) {
        final byte[] data;

        try {
            data = MCRDataURL.parse(format).getData();
        } catch (MalformedURLException e) {
            throw new MCRException("Error while building url", e);
        }
        return data;
    }
}
