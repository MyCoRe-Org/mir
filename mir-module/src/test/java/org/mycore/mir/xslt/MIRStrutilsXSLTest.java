package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.Map;

import org.junit.jupiter.api.Test;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIRStrutilsXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/functions/mirstrutils-test.xsl";

    @Test
    void testEscapeXml() throws Exception {
        assertEquals("&lt;abc&gt;", resultRawText(XSL, "test-escape-xml", Map.of("value", "<abc>")));
        assertEquals("ain&apos;t", resultRawText(XSL, "test-escape-xml", Map.of("value", "ain't")));
        assertEquals("&#161;", resultRawText(XSL, "test-escape-xml", Map.of("value", "\u00A1")));
        assertEquals("a&lt;b&gt;c&quot;d&apos;e&amp;f",
            resultRawText(XSL, "test-escape-xml", Map.of("value", "a<b>c\"d'e&f")));
    }

    @Test
    void testUnescapeXml() throws Exception {
        assertEquals("<abc>", resultRawText(XSL, "test-unescape-xml", Map.of("value", "&lt;abc&gt;")));
        assertEquals("\u00A0", resultRawText(XSL, "test-unescape-xml", Map.of("value", "&#160;")));
        assertEquals("ain't", resultRawText(XSL, "test-unescape-xml", Map.of("value", "ain&apos;t")));
        assertEquals("test & <", resultRawText(XSL, "test-unescape-xml", Map.of("value", "test & &lt;")));
    }

    @Test
    void testUnescapeHtml() throws Exception {
        assertEquals("Fran\u00E7ais", resultRawText(XSL, "test-unescape-html", Map.of("value", "Fran&ccedil;ais")));
        assertEquals("\u0392", resultRawText(XSL, "test-unescape-html", Map.of("value", "&Beta;")));
        assertEquals("\u0080\u009F",
            resultRawText(XSL, "test-unescape-html", Map.of("value", "&#x80;&#X9F;")));
        assertEquals("&zzzz;", resultRawText(XSL, "test-unescape-html", Map.of("value", "&zzzz;")));
        assertEquals("& &", resultRawText(XSL, "test-unescape-html", Map.of("value", "& &amp;")));
    }
}
