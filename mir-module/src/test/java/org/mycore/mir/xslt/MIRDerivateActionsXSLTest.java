package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.Namespace;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathFactory;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.access.MCRAccessMock;
import org.mycore.access.strategies.MCRObjectIDStrategy;
import org.mycore.common.MCRTestConfiguration;
import org.mycore.common.MCRTestProperty;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MCRJPATestHelper;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
@MCRTestConfiguration(properties = {
    @MCRTestProperty(key = "MIR.DerivateActions", string = "zip,unknown-action,edit,md5,delete"),
    @MCRTestProperty(key = "MCR.Access.Class", classNameOf = MCRAccessMock.class),
    @MCRTestProperty(key = "MCR.Access.Strategy.Class", classNameOf = MCRObjectIDStrategy.class)
})
public class MIRDerivateActionsXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/mir/object-page/boxes/derivate-actions-test.xsl";

    private static final String INCLUDES = "MCR.URIResolver.xslIncludes.derivateactions";

    private static final String TEST_ACTION = "mir/object-page/boxes/test-derivate-action.xsl";

    private static final Namespace XLINK = Namespace.getNamespace("xlink", "http://www.w3.org/1999/xlink");

    private static final String OBJECT_ID = "mir_mods_00000001";

    private static final String DERIVATE_ID = "mir_derivate_00000001";

    @BeforeEach
    void setUp() {
        MCRJPATestHelper.endTransaction();
    }

    @AfterEach
    void tearDown() {
        MCRAccessMock.setMethodResult(true);
        MCRAccessMock.clearCheckPermissionCallsList();
    }

    @Test
    void testConfiguredOrderAndUnknownActionIsSkipped() throws Exception {
        Document result = render(true);

        assertEquals(List.of("zip", "edit", "md5", "delete"), actions(result));
    }

    @Test
    void testActionsAreGuardedByRights() throws Exception {
        Document result = render(false);

        assertNull(first(result, "//ul[contains(@class, 'dropdown-menu')]"));
    }

    @Test
    @MCRTestConfiguration(properties = {
        @MCRTestProperty(key = "MIR.DerivateActions", string = "none")
    })
    void testActionListNoneHidesMenu() throws Exception {
        Document result = render(true);

        assertNull(first(result, "//ul[contains(@class, 'dropdown-menu')]"));
    }

    @Test
    @MCRTestConfiguration(properties = {
        @MCRTestProperty(key = "MIR.DerivateActions", string = "test")
    })
    void testIncludedActionGetsDerivateAndObjectContext() throws Exception {
        Document result = withIncludedModule(TEST_ACTION, () -> render(true));

        Element link = first(result, "//ul[contains(@class, 'dropdown-menu')]/li/a[@class='test']");
        assertNotNull(link);
        assertEquals(OBJECT_ID, link.getAttributeValue("data-object-id"));
        assertEquals(DERIVATE_ID, link.getAttributeValue("data-derivate-id"));
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

    private Document render(boolean permitted) throws Exception {
        MCRAccessMock.setMethodResult(permitted);
        Element derobject = new Element("derobject").setAttribute("href", DERIVATE_ID, XLINK);
        Element object = new Element("mycoreobject").setAttribute("ID", OBJECT_ID)
            .addContent(new Element("structure").addContent(new Element("derobjects").addContent(derobject)));
        return transformDocument(new Document(object), XSL, Map.of());
    }

    private static List<String> actions(Document result) {
        return XPathFactory.instance()
            .compile("//ul[contains(@class, 'dropdown-menu')]/li/a", Filters.element())
            .evaluate(result).stream()
            .map(MIRDerivateActionsXSLTest::action)
            .toList();
    }

    private static String action(Element link) {
        String classes = link.getAttributeValue("class", "");
        String href = link.getAttributeValue("href", "");
        if (href.contains("editor-derivate.xed")) {
            return "edit";
        } else if (classes.contains("toggleMD5Link")) {
            return "md5";
        } else if (classes.contains("downloadzip")) {
            return "zip";
        } else if (classes.contains("confirm_deletion")) {
            return "delete";
        }
        return "";
    }

    private static Element first(Document document, String xpath) {
        return XPathFactory.instance().compile(xpath, Filters.element()).evaluateFirst(document);
    }
}
