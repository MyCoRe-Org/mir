package org.mycore.mir.editor;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Entities;

public class MIREditorUtils {

    public static String getPlainTextString(String text) {
        final Document document = Jsoup.parse(text);
        return document.text();
    }

    public static String getXHTMlSnippedString(String text) {
        final Document document = Jsoup.parse(text);
        document.outputSettings().syntax(Document.OutputSettings.Syntax.xml);
        document.outputSettings().escapeMode(Entities.EscapeMode.xhtml);
        final String bodyContent = document.body().html();

        return bodyContent;
    }

}
