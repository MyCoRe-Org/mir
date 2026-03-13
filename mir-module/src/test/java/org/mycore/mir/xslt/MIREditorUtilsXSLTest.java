package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.Map;

import org.jdom2.Document;
import org.jdom2.Element;
import org.junit.jupiter.api.Test;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIREditorUtilsXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/functions/mireditorutils-test.xsl";

    @Test
    void testSerializeNode() throws Exception {
        Element sample = new Element("sample");
        sample.setAttribute("foo", "bar");
        sample.addContent(new Element("child").setText("text"));

        assertEquals("<sample foo=\"bar\"><child>text</child></sample>",
            resultText(XSL, "test-serialize-node", sample, Map.of()));
    }

    @Test
    void testIsValidObjectId() throws Exception {
        assertEquals("true", resultText(XSL, "test-is-valid-object-id", Map.of("value", "mir_mods_00000001")));
        assertEquals("false", resultText(XSL, "test-is-valid-object-id", Map.of("value", "mir:mods_00000001")));
        assertEquals("false", resultText(XSL, "test-is-valid-object-id", Map.of("value", "mir_mods")));
        assertEquals("false", resultText(XSL, "test-is-valid-object-id", Map.of("value", "")));
    }

    @Test
    void testBuildExtentPagesForRanges() throws Exception {
        Document result = transformRoot(XSL, "test-build-extent-pages", Map.of("value", "S. 123-27."));
        Element extent = result.getRootElement().getChild("extent", MODS_NAMESPACE);

        assertEquals("pages", extent.getAttributeValue("unit"));
        assertEquals("123", extent.getChildTextTrim("start", MODS_NAMESPACE));
        assertEquals("127", extent.getChildTextTrim("end", MODS_NAMESPACE));
    }

    @Test
    void testBuildExtentPagesForTotalPages() throws Exception {
        Document result = transformRoot(XSL, "test-build-extent-pages", Map.of("value", "(123 Seiten)"));
        Element extent = result.getRootElement().getChild("extent", MODS_NAMESPACE);

        assertEquals("123", extent.getChildTextTrim("total", MODS_NAMESPACE));
    }

    @Test
    void testBuildExtentPagesForFollowingPages() throws Exception {
        Document result = transformRoot(XSL, "test-build-extent-pages", Map.of("value", "p. 17 ff."));
        Element extent = result.getRootElement().getChild("extent", MODS_NAMESPACE);

        assertEquals("17", extent.getChildTextTrim("start", MODS_NAMESPACE));
    }

    @Test
    void testBuildExtentPagesFallsBackToList() throws Exception {
        Document result = transformRoot(XSL, "test-build-extent-pages", Map.of("value", "between 10 and 20"));
        Element extent = result.getRootElement().getChild("extent", MODS_NAMESPACE);

        assertEquals("between 10 and 20", extent.getChildTextTrim("list", MODS_NAMESPACE));
    }
}
