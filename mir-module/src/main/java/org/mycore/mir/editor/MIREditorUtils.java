package org.mycore.mir.editor;

import java.util.stream.Stream;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Entities;
import org.jsoup.safety.Cleaner;
import org.jsoup.safety.Whitelist;
import org.mycore.common.config.MCRConfiguration2;

public class MIREditorUtils {

    public static String getPlainTextString(String text) {
        final Document document = Jsoup.parse(text);
        return document.text();
    }

    public static String getXHTMlSnippedString(String text) {
        Document document = Jsoup.parse(text);
        changeToXHTML(document);

        final Whitelist elementWhitelist = getWhiteList();
        document = getCleanDocument(document, elementWhitelist);
        changeToXHTML(document);
        return document.body().html();
    }

    private static void changeToXHTML(Document document) {
        document.outputSettings().syntax(Document.OutputSettings.Syntax.xml);
        document.outputSettings().escapeMode(Entities.EscapeMode.xhtml);
    }

    private static Document getCleanDocument(Document document, Whitelist elementWhitelist) {
        return new Cleaner(elementWhitelist).clean(document);
    }

    private static Whitelist getWhiteList() {
        final Whitelist elementWhitelist = Whitelist.none();

        final Stream<String> allowedElements = MCRConfiguration2.getString("MIR.Editor.HTML.Elements")
                .map(s -> Stream.of(s.split(" ")))
                .orElseThrow(() -> MCRConfiguration2.createConfigurationException("MIR.Editor.HTML.Elements"));

        allowedElements.forEach(elementWhitelist::addTags);
        return elementWhitelist;
    }

}
