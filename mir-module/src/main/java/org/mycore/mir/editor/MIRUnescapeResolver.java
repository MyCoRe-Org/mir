package org.mycore.mir.editor;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.StringReader;
import java.net.MalformedURLException;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import org.jdom2.Content;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.transform.JDOMSource;
import org.mycore.common.MCRConstants;
import org.mycore.datamodel.common.MCRDataURL;

public class MIRUnescapeResolver implements URIResolver {

    @Override
    public Source resolve(String s, String s1) throws TransformerException {
        final String base64URL = s.substring("unescape-html-content:".length());
        final byte[] data;
        try {
            data = MCRDataURL.parse(base64URL).getData();
        } catch (MalformedURLException e) {
            throw new TransformerException("Error while building url", e);
        }

        final Element abstractOrTitleInfo;

        try {
            final SAXBuilder sb = new SAXBuilder();
            final Document element = sb.build(new ByteArrayInputStream(data));
            abstractOrTitleInfo = element.getRootElement();
            unescapeElement(abstractOrTitleInfo, sb);

        } catch (JDOMException | IOException e) {
            throw new TransformerException("Error while building document!", e);
        }

        return new JDOMSource(abstractOrTitleInfo);
    }

    private void unescapeElement(Element elementWithHTML, SAXBuilder sb) throws JDOMException, IOException {
        elementWithHTML.setNamespace(MCRConstants.MODS_NAMESPACE);
        if (elementWithHTML.getContent().stream().noneMatch(content -> content instanceof Element)) {
            final String text = elementWithHTML.getText();
            final Document xhtml = sb
                .build(new StringReader("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<html>" + text + "</html>"));

            elementWithHTML.removeContent();
            xhtml.getRootElement().getContent().stream()
                .map(Content::clone)
                .forEach(elementWithHTML::addContent);
        } else {
            for (Content c : elementWithHTML.getContent()) {
                if (c instanceof Element) {
                    unescapeElement((Element) c, sb);
                }
            }
        }
    }
}
