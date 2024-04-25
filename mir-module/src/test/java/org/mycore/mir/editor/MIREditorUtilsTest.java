package org.mycore.mir.editor;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.junit.Assert;
import org.junit.Test;
import org.mycore.common.MCRTestCase;

import java.util.Map;

public class MIREditorUtilsTest extends MCRTestCase {

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

        Assert.assertEquals("Element test1 should be present", "h1", test1.tagName());

        Assert.assertEquals("Element test2 should be present", "a", test2.tagName());
        Assert.assertTrue("Attribute href with http is allowed", test2.hasAttr("href"));
        Assert.assertTrue("Attribute title is allowed", test2.hasAttr("title"));

        Assert.assertNull("Element test3 should not be present", test3);

        Assert.assertEquals("Element test4 should be present", "a", test4.tagName());
        Assert.assertFalse("If an attribute is href then only http and https is allowed", test4.hasAttr("href"));

        Assert.assertEquals("Element test5 should be present", "a", test5.tagName());
        Assert.assertFalse("Onmouseover is not allowed", test5.hasAttr("onmouseover"));

        Assert.assertEquals("Element p should be present", 1, p.size());
        Assert.assertEquals("Element i should be present", 1, i.size());
    }

    @Override
    protected Map<String, String> getTestProperties() {
        final Map<String, String> testProperties = super.getTestProperties();

        testProperties.put("MIR.Editor.HTML.Elements", "h1[id];a[id,href,title];p i");

        return testProperties;
    }
}
