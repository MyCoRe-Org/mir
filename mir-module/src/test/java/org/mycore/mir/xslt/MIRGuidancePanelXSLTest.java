package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.List;
import java.util.Map;

import org.jdom2.Element;
import org.jdom2.Namespace;
import org.junit.jupiter.api.Test;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIRGuidancePanelXSLTest extends MIRXSLTFunctionTestCase {

    public static final String XSLT_DIR = "/xslt/mir/guidance-panel/functions";

    private static final String LABEL_XSL = XSLT_DIR + "/mirguidancepanel-label.xsl";
    private static final String REL_PATH_XSL = XSLT_DIR + "/mirguidancepanel-rel-path.xsl";
    private static final String REL_PATH_SEGMENT_XSL = XSLT_DIR + "/mirguidancepanel-rel-path-segment.xsl";

    private static final List<Element> LABELS = List.of(
        createLabel("fr", "Revue"),
        createLabel("de", "Zeitschrift"),
        createLabel("en", "Journal"));

    @Test
    void testLabelCurrentLanguage() throws Exception {
        assertEquals("Journal", label(LABELS, "en", "de"));
    }

    @Test
    void testLabelFallbackToDefaultLanguage() throws Exception {
        assertEquals("Zeitschrift", label(LABELS, "es", "de"));
    }

    @Test
    void testLabelFallbackToFirstLabel() throws Exception {
        assertEquals("Revue", label(LABELS, "es", "it"));
    }

    @Test
    void testLabelWithoutLabels() throws Exception {
        assertEquals("", label(List.of(), "es", "it"));
    }

    private String label(List<Element> labels, String currentLang, String defaultLang) throws Exception {
        return transformRoot(LABEL_XSL, "test-label",
            labels.stream().map(Element::clone).toList(),
            Map.of("current-lang", currentLang, "default-lang", defaultLang))
            .getRootElement().getTextNormalize();
    }

    private static Element createLabel(String lang, String text) {
        Element label = new Element("label");
        label.setAttribute("lang", lang, Namespace.XML_NAMESPACE);
        label.setText(text);
        return label;
    }

    @Test
    void testEmptyRelPath() throws Exception {
        assertEquals("", relPath(""));
    }

    @Test
    void testSingleSlashRelPath() throws Exception {
        assertEquals("", relPath("/"));
    }

    @Test
    void testPathWithLeadingSlashRelPath() throws Exception {
        assertEquals("foo", relPath("/foo"));
    }

    @Test
    void testPathWithoutLeadingSlashRelPath() throws Exception {
        assertEquals("foo", relPath("foo"));
    }

    private String relPath(String path) throws Exception {
        return transformRoot(REL_PATH_XSL, "test", List.of(), Map.of("path", path))
            .getRootElement().getTextNormalize();
    }

    @Test
    void testEmptyRelPathSegment() throws Exception {
        assertEquals("", relPathSegment(""));
    }

    @Test
    void testSingleSlashRelPathSegment() throws Exception {
        assertEquals("/", relPathSegment("/"));
    }

    @Test
    void testPathWithLeadingAndTrailingSlashRelPathSegment() throws Exception {
        assertEquals("foo/", relPathSegment("/foo/"));
    }

    @Test
    void testPathWithLeadingSlashRelPathSegment() throws Exception {
        assertEquals("foo/", relPathSegment("/foo"));
    }

    @Test
    void testPathWithTrailingSlashRelPathSegment() throws Exception {
        assertEquals("foo/", relPathSegment("foo/"));
    }

    @Test
    void testPathWithoutLeadingOrTrailingSlashRelPathSegment() throws Exception {
        assertEquals("foo/", relPathSegment("foo"));
    }

    private String relPathSegment(String path) throws Exception {
        return transformRoot(REL_PATH_SEGMENT_XSL, "test", List.of(), Map.of("path", path))
                .getRootElement().getTextNormalize();
    }

}
