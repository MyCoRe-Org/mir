package org.mycore.mir.editor;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.junit.jupiter.api.Test;
import org.mycore.common.MCRTestConfiguration;
import org.mycore.common.MCRTestProperty;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@MCRTestConfiguration(properties = {
    @MCRTestProperty(key = "MIR.Editor.HTML.AllowedElements", string = "h1[id],a[id|href|title],p,i")
})
public class MIREditorUtilsTest {

    @Test
    public void getCleanDocument() {
        Document document = Jsoup.parse("""
            <!DOCTYPE html>
            <html>
            <head></head>
            <body>
            <h1 id="test1">a h1</h1>
            <a id="test2" href='http://google.de' title='test'>test link</a>
            <script id="test3">alert("test1")</script>
            <a id="test4" href='javascript:alert("test2")'>test script</a>
            <a id="test5" onmouseover='alert("test3")'>test script2</a>
            <p>p</p>
            <i>i</i>
            </body>
            </html>""");
        final Document cleanDocument = MIREditorUtils.getCleanDocument(document, MIREditorUtils.getSafeList());

        final Element body = cleanDocument.body();
        final Element test1 = body.getElementById("test1");
        final Element test2 = body.getElementById("test2");
        final Element test3 = body.getElementById("test3");
        final Element test4 = body.getElementById("test4");
        final Element test5 = body.getElementById("test5");
        final Elements p = body.getElementsByTag("p");
        final Elements i = body.getElementsByTag("i");

        assertEquals("h1", test1.tagName(), "Element test1 should be present");

        assertEquals("a", test2.tagName(), "Element test2 should be present");
        assertTrue(test2.hasAttr("href"), "Attribute href with http is allowed");
        assertTrue(test2.hasAttr("title"), "Attribute title is allowed");

        assertNull(test3, "Element test3 should not be present");

        assertEquals("a", test4.tagName(), "Element test4 should be present");
        assertFalse(test4.hasAttr("href"), "If an attribute is href then only http and https is allowed");

        assertEquals("a", test5.tagName(), "Element test5 should be present");
        assertFalse(test5.hasAttr("onmouseover"), "Onmouseover is not allowed");

        assertEquals(1, p.size(), "Element p should be present");
        assertEquals(1, i.size(), "Element i should be present");
    }

}
