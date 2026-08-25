package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.stream.Collectors;

import javax.xml.transform.TransformerException;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.Text;
import org.jdom2.filter.Filters;
import org.jdom2.input.SAXBuilder;
import org.jdom2.xpath.XPathFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.common.MCRTestConfiguration;
import org.mycore.common.MCRTestProperty;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.util.MCRTestCaseClassificationUtil;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MCRJPATestHelper;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
@MCRTestConfiguration(properties = {
    @MCRTestProperty(key = "MCR.URIResolver.xslImports.modsmeta",
        string = "metadata/test/modsmeta-test-base.xsl,metadata/mir-metadata-box.xsl,metadata/mir-admindata-box.xsl")
})
public class MIRMetadataBoxXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/metadata/test/metadata-boxes-test.xsl";

    private static final String RESOURCES = "/" + MIRMetadataBoxXSLTest.class.getSimpleName();

    private static final String INCLUDES = "MCR.URIResolver.xslIncludes.metadatabox";

    private static final String METADATA = "mir-metadata";

    private static final String ADMIN = "mir-admindata";

    @BeforeEach
    void setUp() throws Exception {
        for (String classification : List.of("identifier", "mir_genres", "noteTypes", "state",
            "typeOfResource")) {
            MCRTestCaseClassificationUtil.addClassification(RESOURCES + "/class/" + classification + ".xml");
        }
        MCRJPATestHelper.endTransaction();
    }

    @Test
    void testDefaultFieldOrder() throws Exception {
        Document result = render(null);

        assertEquals(List.of("alternativ:", "Konferenz:", "Supervisor:", "In Serie:", "Datum der Veröffentlichung:",
            "DOI:", "PPN:", "Sprache:", "Ressourcentyp:", "Schlagwörter:", "Physischer Standort:", "Bemerkung:",
            "Public note:"), labels(result, METADATA));
    }

    @Test
    void testAdminFieldOrder() throws Exception {
        Document result = render(null);

        assertEquals(List.of("Publikationsstatus:", "Erstellt am:", "von:", "Admin note:", "Letzte Änderung:", "von:",
            "MyCoRe ID:", "interne ID:", "Version:"), labels(result, ADMIN));
        assertEquals("mir_mods_00000001", text(value(result, ADMIN, "MyCoRe ID:")));
    }

    @Test
    @MCRTestConfiguration(properties = {
        @MCRTestProperty(key = "MIR.MetadataBox.Fields.thesis", string = "dates.issued,unknown-field,title")
    })
    void testGenreFallsBackToParentGenreAndSkipsUnknownFields() throws Exception {
        Document result = render("dissertation");

        assertEquals(List.of("Datum der Veröffentlichung:", "alternativ:"), labels(result, METADATA));
    }

    @Test
    @MCRTestConfiguration(properties = {
        @MCRTestProperty(key = "MIR.MetadataBox.Fields.article", string = "none")
    })
    void testGenreFieldListNoneHidesBox() throws Exception {
        Document result = render("article");

        assertNull(first(result, "//div[@id='" + METADATA + "']"));
        assertFalse(labels(result, ADMIN).isEmpty());
    }

    @Test
    @MCRTestConfiguration(properties = {
        @MCRTestProperty(key = "MIR.AdmindataBox.Fields", string = "version,object-id")
    })
    void testAdminFieldsAreConfigurable() throws Exception {
        Document result = render(null);

        assertEquals(List.of("Version:", "MyCoRe ID:"), labels(result, ADMIN));
    }

    @Test
    @MCRTestConfiguration(properties = {
        @MCRTestProperty(key = "MIR.MetadataBox.Fields.thesis", string = "title")
    })
    void testFieldOverrideWithPriorityReplacesFieldForGenre() throws Exception {
        Document thesis = withIncludedModule("metadata/test/thesis-title-override.xsl", () -> render("dissertation"));
        Document other = withIncludedModule("metadata/test/thesis-title-override.xsl", () -> render(null));

        assertEquals(List.of("Thesis"), labels(thesis, METADATA));
        assertEquals("alternativ:", labels(other, METADATA).get(0));
    }

    @Test
    void testDuplicateFieldRuleFails() {
        TransformerException exception = assertThrows(TransformerException.class,
            () -> withIncludedModule("metadata/test/duplicate-title.xsl", () -> render(null)));

        assertTrue(String.valueOf(exception.getMessage()).contains("Ambiguous rule match"), exception::getMessage);
    }

    private static <T> T withIncludedModule(String module, Callable<T> action) throws Exception {
        String original = MCRConfiguration2.getStringOrThrow(INCLUDES);
        MCRConfiguration2.set(INCLUDES, original + "," + module);
        try {
            return action.call();
        } finally {
            MCRConfiguration2.set(INCLUDES, original);
        }
    }

    private Document render(String genre) throws Exception {
        Document object;
        try (InputStream in = getClass().getResourceAsStream(RESOURCES + "/mir_mods_00000001.xml")) {
            object = new SAXBuilder().build(in);
        }
        if (genre != null) {
            Element genreElement = new Element("genre", MODS_NAMESPACE)
                .setAttribute("type", "intern")
                .setAttribute("authorityURI", "http://www.mycore.org/classifications/mir_genres")
                .setAttribute("valueURI", "http://www.mycore.org/classifications/mir_genres#" + genre);
            first(object, "//*[local-name()='mods']").addContent(0, genreElement);
        }
        return transformDocument(object, XSL, Map.of());
    }

    private static List<String> labels(Document result, String boxId) {
        return XPathFactory.instance().compile("//div[@id='" + boxId + "']/dl/dt", Filters.element())
            .evaluate(result).stream()
            .map(Element::getTextNormalize)
            .toList();
    }

    private static Element value(Document result, String boxId, String label) {
        Element dd = first(result,
            "//div[@id='" + boxId + "']/dl/dt[normalize-space(.)='" + label + "']/following-sibling::dd[1]");
        assertNotNull(dd, () -> "no row '" + label + "' in " + boxId);
        return dd;
    }

    private static String text(Element element) {
        return element.getContent(Filters.text()).stream()
            .map(Text::getTextNormalize)
            .filter(text -> !text.isEmpty())
            .collect(Collectors.joining(" "));
    }

    private static Element first(Document document, String xpath) {
        return XPathFactory.instance().compile(xpath, Filters.element()).evaluateFirst(document);
    }
}
