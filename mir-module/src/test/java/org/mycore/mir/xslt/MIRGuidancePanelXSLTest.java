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

    private static final String XSL = "/xslt/mir/guidance-panel/functions/mirguidancepanel-test.xsl";

    private static final List<Element> LABELS = List.of(createLabel("fr", "Revue"), createLabel("de", "Zeitschrift"),
        createLabel("en", "Journal"));

    @Test
    void testLabelCurrentLanguage() throws Exception {
        assertEquals("Journal", label("en", "de"));
    }

    @Test
    void testLabelFallbackToDefaultLanguage() throws Exception {
        assertEquals("Zeitschrift", label("es", "de"));
    }

    @Test
    void testLabelFallbackToFirstLabel() throws Exception {
        assertEquals("Revue", label("es", "it"));
    }

    @Test
    void testLabelWithoutLabels() throws Exception {
        assertEquals("", transformRoot(XSL, "test-label", List.of(), Map.of("current-lang", "de",
            "default-lang", "de")).getRootElement().getTextNormalize());
    }

    private String label(String currentLang, String defaultLang) throws Exception {
        List<Element> labels = LABELS.stream().map(Element::clone).toList();
        return transformRoot(XSL, "test-label", labels, Map.of("current-lang", currentLang,
            "default-lang", defaultLang)).getRootElement().getTextNormalize();
    }

    private static Element createLabel(String lang, String text) {
        Element label = new Element("label");
        label.setAttribute("lang", lang, Namespace.XML_NAMESPACE);
        label.setText(text);
        return label;
    }
}
