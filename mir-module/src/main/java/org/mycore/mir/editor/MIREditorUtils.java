package org.mycore.mir.editor;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Entities;
import org.jsoup.safety.Cleaner;
import org.jsoup.safety.Safelist;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.frontend.MCRFrontendUtil;
import org.w3c.dom.Node;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.StringTokenizer;
import java.util.stream.Stream;

public class MIREditorUtils {

    public static String getPlainTextString(String text) {
        final Document document = Jsoup.parse(text);
        return document.text();
    }

    public static String getXHTMLSnippedString(String text) {
        Document document = Jsoup.parse(text);
        changeToXHTML(document);

        final Safelist elementWhitelist = getSafeList();
        document = getCleanDocument(document, elementWhitelist);
        document.outputSettings().prettyPrint(false);
        changeToXHTML(document);
        return document.body().html();
    }

    private static void changeToXHTML(Document document) {
        document.outputSettings().syntax(Document.OutputSettings.Syntax.xml);
        document.outputSettings().escapeMode(Entities.EscapeMode.xhtml);

        // this is just used to detect the protocol of relative urls
        document.setBaseUri(MCRFrontendUtil.getBaseURL() + "receive/placeholder");
    }

    protected static Document getCleanDocument(Document document, Safelist elementWhitelist) {
        return new Cleaner(elementWhitelist).clean(document);
    }

    public static String xmlAsString(Node node) throws TransformerException {
        StringWriter writer = new StringWriter();
        Transformer transformer = TransformerFactory.newInstance().newTransformer();
        transformer.transform(new DOMSource(node), new StreamResult(writer));
        return  writer.toString();
    }

    protected static Safelist getSafeList() {
        final Safelist elementSafelist = Safelist.none();

        String[] allowedElements = MCRConfiguration2.getOrThrow("MIR.Editor.HTML.AllowedElements", s -> s.split(","));
        Stream.of(allowedElements).forEach(content -> {
            StringTokenizer st = new StringTokenizer(content, "[|],", true);

            List<String> attributes = new ArrayList<>();
            List<String> elements = new ArrayList<>();
            boolean attrOptStarted;
            StringBuilder currentElement = new StringBuilder();
            StringBuilder currentAttribute = new StringBuilder();
            attrOptStarted = false;

            while (st.hasMoreTokens()) {
                final String token = st.nextToken();

                switch (token) {
                    case "[":
                        attrOptStarted = true;
                        break;
                    case "]":
                        if (attrOptStarted) {
                            final String attribute = currentAttribute.toString();
                            attributes.add(attribute);
                            currentAttribute = new StringBuilder();
                        }
                        attrOptStarted = false;
                        break;
                    case "|":
                        if (attrOptStarted) {
                            final String attribute = currentAttribute.toString();
                            attributes.add(attribute);
                            currentAttribute = new StringBuilder();
                        }
                        break;
                    default:
                        if (attrOptStarted) {
                            currentAttribute.append(token);
                        } else {
                            currentElement.append(token);
                        }
                        break;
                }
            }
            if (!currentElement.isEmpty()) {
                elements.add(currentElement.toString());
            }
            elements.forEach(tagName -> {
                elementSafelist.addTags(tagName);
                if (!attributes.isEmpty()) {
                    attributes.forEach(attr -> {
                        elementSafelist.addAttributes(tagName, attr);
                        if (Objects.equals(attr, "href")) {
                            elementSafelist.addProtocols(tagName, attr, "http", "https", "ftp", "mailto", "#");
                        }
                    });
                }
            });
        });
        elementSafelist.preserveRelativeLinks(true);
        return elementSafelist;
    }

}
