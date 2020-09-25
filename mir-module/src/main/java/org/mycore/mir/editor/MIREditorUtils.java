package org.mycore.mir.editor;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Entities;
import org.jsoup.safety.Cleaner;
import org.jsoup.safety.Whitelist;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.frontend.MCRFrontendUtil;

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

        final Whitelist elementWhitelist = getWhiteList();
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

    protected static Document getCleanDocument(Document document, Whitelist elementWhitelist) {
        return new Cleaner(elementWhitelist).clean(document);
    }

    protected static Whitelist getWhiteList() {
        final Whitelist elementWhitelist = Whitelist.none();

        String[] allowedElements = MCRConfiguration2.getOrThrow("MIR.Editor.HTML.Elements", s -> s.split(";"));
        Stream.of(allowedElements).forEach(content -> {
            StringTokenizer st = new StringTokenizer(content, "[ ],", true);

            List<String> attributes = new ArrayList<>();
            List<String> elements = new ArrayList<>();
            boolean attrOptStarted;
            StringBuilder currentElement = new StringBuilder();
            StringBuilder currentAttribute = new StringBuilder();
            attrOptStarted = false;

            while (st.hasMoreTokens()) {
                final String token = st.nextToken();

                switch (token) {
                    case " ":
                        if (!attrOptStarted && currentElement.length() > 0) {
                            elements.add(currentElement.toString());
                            currentElement = new StringBuilder();
                        }
                        break;
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
                    case ",":
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
            if (currentElement.length() > 0) {
                elements.add(currentElement.toString());
            }
            elements.forEach(tagName -> {
                elementWhitelist.addTags(tagName);
                if (attributes.size() > 0) {
                    attributes.forEach(attr -> {
                        elementWhitelist.addAttributes(tagName, attr);
                        if (Objects.equals(attr, "href")) {
                            elementWhitelist.addProtocols(tagName, attr, "http", "https", "ftp", "mailto", "#");
                        }
                    });
                }
            });
        });
        elementWhitelist.preserveRelativeLinks(true);
        return elementWhitelist;
    }

}
