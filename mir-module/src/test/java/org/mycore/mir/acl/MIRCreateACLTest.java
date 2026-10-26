/*
 *  This file is part of ***  M y C o R e  ***
 *  See http://www.mycore.de/ for details.
 *
 *  MyCoRe is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  MyCoRe is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.mycore.mir.acl;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MCRMetadataExtension;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
@ExtendWith(MCRMetadataExtension.class)
public class MIRCreateACLTest extends MIRACLTest {

    private static final List<String> STATES = List.of("new", "submitted", "published", "blocked", "deleted");

    @Override
    @BeforeEach
    public void setUp() {
        super.setUp();
    }

    @Test
    public void testCreateGuest() {
        testPermission("guest", "create-mods", false, "");
    }

    @Test
    public void testCreateAdmin() {
        enableDebug();
        testPermission("admin1", "create-mods", true, MIRTestConstants.MIR_ROLES_ADMIN);
        disableDebug();
    }

    @Test
    public void testCreateEditor() {
        testPermission("editor1", "create-mods", true, MIRTestConstants.MIR_ROLES_EDITOR);
    }

    @Test
    public void testCreateReader() {
        testPermission("reader1", "create-mods", false, MIRTestConstants.MIR_ROLES_READER);
    }

    @Test
    public void testCreateSubmitter() {
        testPermission("submitter1", "create-mods", true, MIRTestConstants.MIR_ROLES_SUBMITTER);
    }

    @Test
    public void testCreateDerivateGuest() {
        for (String status : STATES) {
            testCreateDerivate("guest", "otherUser", status, false, "");
        }
    }

    @Test
    public void testCreateDerivateAdminAndEditor() {
        for (String status : STATES) {
            testCreateDerivate("admin1", "otherUser", status, true, MIRTestConstants.MIR_ROLES_ADMIN);
            testCreateDerivate("editor1", "otherUser", status, true, MIRTestConstants.MIR_ROLES_EDITOR);
        }
    }

    @Test
    public void testCreateDerivateReader() {
        for (String status : STATES) {
            testCreateDerivate("reader1", "otherUser", status, false, MIRTestConstants.MIR_ROLES_READER);
        }
    }

    @Test
    public void testCreateDerivateSubmitter() {
        // only on own objects with status new
        testCreateDerivate("submitter1", "submitter1", "new", true, MIRTestConstants.MIR_ROLES_SUBMITTER);
        testCreateDerivate("submitter1", "otherUser", "new", false, MIRTestConstants.MIR_ROLES_SUBMITTER);
        for (String status : List.of("submitted", "published", "blocked", "deleted")) {
            testCreateDerivate("submitter1", "submitter1", status, false, MIRTestConstants.MIR_ROLES_SUBMITTER);
        }
    }

    private void testCreateDerivate(String user, String creator, String status, boolean shouldBeAbleTo,
        String role) {
        testObject(user, creator, status, "mir_mods_0000001", shouldBeAbleTo, "create-derivate", role, false, false,
            false);
    }

}
