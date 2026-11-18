package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Map;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
public class MIRObjectXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/mir/functions/mirobject-test.xsl";

    @Test
    void testEditUrlAppendsObjectIdForNonPublishedObject() throws Exception {
        String url = resultText(XSL, "test-edit-url", Map.of("value", "mir_mods_00000001"));

        assertTrue(url.endsWith("MCRLockServlet?url=/editor/editor-dynamic.xed&id=mir_mods_00000001"), url);
    }

    @Test
    void testEditUrlIsEmptyWithoutUpdateMapping() throws Exception {
        assertEquals("", resultText(XSL, "test-edit-url", Map.of("value", "mir_derivate_00000001")));
    }
}
