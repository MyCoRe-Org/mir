package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.util.List;
import java.util.Map;

import org.jdom2.Document;
import org.jdom2.Element;
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

    private Document render(boolean permitted) throws Exception {
        MCRAccessMock.setMethodResult(permitted);
        Element derivate = new Element("derivate").setAttribute("id", DERIVATE_ID);
        return transformDocument(new Document(derivate), XSL, Map.of());
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
