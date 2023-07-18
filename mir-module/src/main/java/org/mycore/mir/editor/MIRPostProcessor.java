package org.mycore.mir.editor;

import static org.mycore.common.xml.MCRXMLFunctions.isHtml;

import java.io.IOException;
import java.io.StringReader;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Stream;

import javax.xml.transform.TransformerException;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.filter.Filters;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.DOMOutputter;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.datamodel.common.MCRDataURL;
import org.mycore.frontend.xeditor.MCRPostProcessorXSL;

public class MIRPostProcessor extends MCRPostProcessorXSL {

    public static final String[] TITLE_SUB_ELEMENTS = { "nonSort", "title", "subTitle" };

    @Override
    public Document process(Document oldXML) throws IOException, JDOMException {
        final Document newXML = oldXML.clone();

        fixAbstracts(newXML);
        fixTitleInfos(newXML);

        final XPathExpression<Element> subjectsXPath = XPathFactory.instance().compile(".//mods:subjectXML",
            Filters.element(), null, MCRConstants.MODS_NAMESPACE,
            MCRConstants.XLINK_NAMESPACE);
        final List<Element> subjectElements = new ArrayList<>(subjectsXPath.evaluate(newXML));

        for (Element subject : subjectElements) {
            subject.setName("subject");
            String xmlContent = subject.getText();
            SAXBuilder saxBuilder = new SAXBuilder();
            Document result;
            try (StringReader characterStream = new StringReader(xmlContent)) {
                result = saxBuilder.build(characterStream);
            }
            Element newSubject = result.getRootElement();
            subject.removeContent();
            new ArrayList<>(newSubject.getChildren()).forEach(child -> {
                child.detach();
                subject.addContent(child);
            });
        }

        return super.process(newXML);
    }

    private static void fixTitleInfos(Document newXML) {
        final XPathExpression<Element> titleInfoXPath = XPathFactory.instance().compile(".//mods:titleInfo",
            Filters.element(), null, MCRConstants.MODS_NAMESPACE,
            MCRConstants.XLINK_NAMESPACE);
        final List<Element> titleInfos = titleInfoXPath.evaluate(newXML);

        titleInfos.stream().filter(ti -> Stream.of(TITLE_SUB_ELEMENTS)
            .anyMatch(elementName -> {
                final Element element = ti.getChild(elementName, MCRConstants.MODS_NAMESPACE);
                return element != null && isHtml(element.getText());
            })).forEach(titleInfoElement -> {
                try {
                    fixTitle(titleInfoElement);
                } catch (JDOMException | TransformerException | MalformedURLException e) {
                    throw new MCRException("Error while converting HTML title!", e);
                }
            });
    }

    private static void fixTitle(Element titleInfoElement)
        throws TransformerException, MalformedURLException, JDOMException {
        final Element modsElement = (Element) titleInfoElement.getParent();
        final String altRepGroup = getRandomRepGroup();

        titleInfoElement.setAttribute("altRepGroup", altRepGroup);

        final Element altTitleInfo = titleInfoElement.clone();
        final Element altTitleContent = altTitleInfo.clone();
        altTitleContent.setNamespace(Namespace.NO_NAMESPACE);
        Stream.of(TITLE_SUB_ELEMENTS)
            .map(en -> altTitleContent.getChild(en, MCRConstants.MODS_NAMESPACE))
            .filter(Objects::nonNull)
            .forEach(child -> {
                child.setNamespace(Namespace.NO_NAMESPACE);
                if(isHtml(child.getText())){
                    child.setText(MIREditorUtils.getXHTMLSnippedString(child.getText()));
                } else {
                    child.setText(child.getText());
                }
            });

        final Document document = new Document(altTitleContent);
        final DOMOutputter domOutputter = new DOMOutputter();
        final org.w3c.dom.Document domDocument = domOutputter.output(document);
        final String base64URL = MCRDataURL.build(domDocument, "base64", "text/xml", "UTF-8");

        altTitleInfo.removeContent();
        altTitleInfo.setAttribute("altRepGroup", altRepGroup);
        altTitleInfo.setAttribute("contentType", "text/xml");
        altTitleInfo.setAttribute("altFormat", base64URL);

        Stream.of(TITLE_SUB_ELEMENTS)
            .map(en -> titleInfoElement.getChild(en, MCRConstants.MODS_NAMESPACE))
            .filter(Objects::nonNull)
            .filter(child -> isHtml(child.getText()))
            .forEach(child -> child.setText(MIREditorUtils.getPlainTextString(child.getText())));
        modsElement.addContent(modsElement.indexOf(titleInfoElement), altTitleInfo);
    }

    private void fixAbstracts(Document newXML) {
        final XPathExpression<Element> abstractXPath = XPathFactory.instance().compile(".//mods:abstract",
            Filters.element(), null, MCRConstants.MODS_NAMESPACE,
            MCRConstants.XLINK_NAMESPACE);
        final List<Element> abstracts = abstractXPath.evaluate(newXML);

        abstracts.stream()
            .filter(abstractElement -> isHtml(abstractElement.getText()))
            .forEach(abstractElement1 -> {
                try {
                    fixAbstract(abstractElement1);
                } catch (JDOMException | TransformerException | MalformedURLException e) {
                    throw new MCRException("Error while converting HTML abstract!", e);
                }
            });
    }

    private static void fixAbstract(Element abstractElement)
        throws JDOMException, TransformerException, MalformedURLException {
        final String dirtyHTMLText = abstractElement.getText();
        final Element modsElement = (Element) abstractElement.getParent();

        final String altRepGroup = getRandomRepGroup();

        abstractElement.setAttribute("altRepGroup", altRepGroup);
        abstractElement.setText(MIREditorUtils.getPlainTextString(dirtyHTMLText));

        // need to generate a w3c document with the clean html as text
        final Element altAbstractContent = abstractElement.clone();
        altAbstractContent.setNamespace(Namespace.NO_NAMESPACE);
        altAbstractContent.setText(MIREditorUtils.getXHTMLSnippedString(dirtyHTMLText));
        final Document document = new Document(altAbstractContent);
        final DOMOutputter domOutputter = new DOMOutputter();
        final org.w3c.dom.Document domDocument = domOutputter.output(document);
        final String base64URL = MCRDataURL.build(domDocument, "base64", "text/xml", "UTF-8");

        final Element altAbstract = abstractElement.clone();
        altAbstract.removeContent();
        altAbstract.setAttribute("altRepGroup", altRepGroup);
        altAbstract.setAttribute("contentType", "text/xml");
        altAbstract.setAttribute("altFormat", base64URL);
        modsElement.addContent(modsElement.indexOf(abstractElement), altAbstract);
    }

    private static String getRandomRepGroup() {
        return UUID.randomUUID().toString().substring(16);
    }

}
