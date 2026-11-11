package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.io.InputStream;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.input.SAXBuilder;
import org.jdom2.xpath.XPathFactory;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.access.MCRAccessMock;
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
        string = "mir/object-page/boxes/modsmeta-test-base.xsl,mir/object-page/boxes/actions/box.xsl"),
    @MCRTestProperty(key = "MIR.ObjectActions", string = "no-rights,edit,unknown-action,delete"),
    @MCRTestProperty(key = "MCR.Access.Class", classNameOf = MCRAccessMock.class)
})
public class MIRObjectActionsXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/mir/object-page/boxes/object-actions-test.xsl";

    private static final String RESOURCES = "/" + MIRMetadataBoxXSLTest.class.getSimpleName();

    private static final String INCLUDES = "MCR.URIResolver.xslIncludes.objectactions";

    private static final String TEST_ACTION = "mir/object-page/boxes/test-action.xsl";

    private static final String PREFIX = "mir-action-item-";

    private static final String OBJECT_ID = "mir_mods_00000001";

    @BeforeEach
    void setUp() throws Exception {
        MCRTestCaseClassificationUtil.addClassification(RESOURCES + "/class/mir_genres.xml");
        MCRJPATestHelper.endTransaction();
    }

    @AfterEach
    void tearDown() {
        MCRAccessMock.setMethodResult(true);
        MCRAccessMock.clearCheckPermissionCallsList();
    }

    @Test
    void testConfiguredOrderAndUnknownActionIsSkipped() throws Exception {
        Document result = render(null, true);

        assertEquals(List.of("edit-object", "delete-object"), actions(result));
    }

    @Test
    void testActionsAreGuardedByRights() throws Exception {
        Document result = render(null, false);

        assertEquals(List.of("no-rights"), actions(result));
        assertNotNull(first(result, "//div[@id='mir-edit']//a[contains(@href, 'MCRBasketServlet')]"));
    }

    @Test
    @MCRTestConfiguration(properties = {
        @MCRTestProperty(key = "MIR.ObjectActions.article", string = "none")
    })
    void testActionListNoneHidesMenu() throws Exception {
        Document result = render("article", true);

        assertNull(first(result, "//div[@id='mir-edit']//ul[contains(@class, 'dropdown-menu')]"));
        assertNotNull(first(result, "//div[@id='mir-edit']//a[contains(@href, 'MCRBasketServlet')]"));
    }

    @Test
    @MCRTestConfiguration(properties = {
        @MCRTestProperty(key = "MIR.ObjectActions.thesis", string = "test,edit")
    })
    void testIncludedActionsAndGenreOverride() throws Exception {
        Document thesis = withIncludedModule(TEST_ACTION, () -> render("dissertation", true));
        Document other = withIncludedModule(TEST_ACTION, () -> render(null, true));

        assertEquals(List.of("test", "edit-thesis"), actions(thesis));
        assertEquals(List.of("edit-object", "delete-object"), actions(other));
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

    private Document render(String genre, boolean permitted) throws Exception {
        Document object;
        try (InputStream in = getClass().getResourceAsStream(RESOURCES + "/" + OBJECT_ID + ".xml")) {
            object = new SAXBuilder().build(in);
        }
        if (genre != null) {
            Element genreElement = new Element("genre", MODS_NAMESPACE)
                .setAttribute("type", "intern")
                .setAttribute("authorityURI", "http://www.mycore.org/classifications/mir_genres")
                .setAttribute("valueURI", "http://www.mycore.org/classifications/mir_genres#" + genre);
            first(object, "//*[local-name()='mods']").addContent(0, genreElement);
        }
        MCRAccessMock.setMethodResult(permitted);
        return transformDocument(object, XSL, Map.of());
    }

    private static List<String> actions(Document result) {
        return XPathFactory.instance()
            .compile("//div[@id='mir-edit']//ul/li", Filters.element())
            .evaluate(result).stream()
            .map(li -> Arrays.stream(li.getAttributeValue("class", "").split("\\s+"))
                .filter(token -> token.startsWith(PREFIX))
                .map(token -> token.substring(PREFIX.length()))
                .findFirst()
                .orElse(""))
            .toList();
    }

    private static Element first(Document document, String xpath) {
        return XPathFactory.instance().compile(xpath, Filters.element()).evaluateFirst(document);
    }
}
