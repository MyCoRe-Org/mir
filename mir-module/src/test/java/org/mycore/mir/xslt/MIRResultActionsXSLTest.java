package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;

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
import org.mycore.common.MCRTestConfiguration;
import org.mycore.common.MCRTestProperty;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MCRJPATestHelper;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
@MCRTestConfiguration(properties = {
    @MCRTestProperty(key = "MIR.ResultActions", string = "edit,unknown-action,basket"),
    @MCRTestProperty(key = "MCR.Access.Class", classNameOf = MCRAccessMock.class)
})
public class MIRResultActionsXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/mir/solr/response/result-actions-test.xsl";

    private static final String OBJECT_ID = "mir_mods_00000001";

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

        assertEquals(List.of("edit", "basket"), actions(result));
    }

    @Test
    void testActionsAreGuardedByRights() throws Exception {
        Document result = render(false);

        assertEquals(List.of("basket"), actions(result));
    }

    @Test
    @MCRTestConfiguration(properties = {
        @MCRTestProperty(key = "MIR.ResultActions", string = "none")
    })
    void testActionListNoneRendersNothing() throws Exception {
        Document result = render(true);

        assertEquals(List.of(), actions(result));
    }

    private Document render(boolean permitted) throws Exception {
        MCRAccessMock.setMethodResult(permitted);
        Element doc = new Element("doc")
            .addContent(new Element("str").setAttribute("name", "id").setText(OBJECT_ID))
            .addContent(new Element("str").setAttribute("name", "state").setText("published"));
        return transformDocument(new Document(new Element("response").addContent(doc)), XSL, Map.of());
    }

    private static List<String> actions(Document result) {
        return XPathFactory.instance()
            .compile("/actions/li/a", Filters.element())
            .evaluate(result).stream()
            .map(MIRResultActionsXSLTest::action)
            .toList();
    }

    private static String action(Element link) {
        String classes = link.getAttributeValue("class", "");
        if (classes.contains("hit_edit")) {
            return "edit";
        } else if (classes.contains("hit_to_basket")) {
            return "basket";
        }
        return "";
    }
}
