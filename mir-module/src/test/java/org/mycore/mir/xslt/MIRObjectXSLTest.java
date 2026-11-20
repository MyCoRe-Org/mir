package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Map;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
public class MIRObjectXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/mir/functions/mirobject-test.xsl";

    private static final String ID = "mir_mods_00000001";

    @AfterEach
    void resetUser() {
        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.GUEST);
    }

    @Test
    void testEditUrlAppendsObjectId() throws Exception {
        String url = resultText(XSL, "test-edit-url", Map.of("value", ID));

        assertTrue(url.endsWith("MCRLockServlet?url=/editor/editor-dynamic.xed&id=" + ID), url);
    }

    @Test
    void testEditUrlIsEmptyWithoutUpdateMapping() throws Exception {
        assertEquals("", resultText(XSL, "test-edit-url", Map.of("value", "mir_derivate_00000001")));
    }

    @Test
    void testAdminEditUrlIsEmptyForGuest() throws Exception {
        assertEquals("", resultText(XSL, "test-edit-url", Map.of("value", ID, "action", "update-admin")));
    }

    @Test
    void testAdminEditUrlForAdmin() throws Exception {
        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.SUPER_USER);

        String url = resultText(XSL, "test-edit-url", Map.of("value", ID, "action", "update-admin"));

        assertTrue(url.endsWith("MCRLockServlet?url=/editor/editor-admins.xed&id=" + ID), url);
    }
}
