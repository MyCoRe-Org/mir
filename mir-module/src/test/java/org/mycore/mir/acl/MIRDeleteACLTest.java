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

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MCRMetadataExtension;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
@ExtendWith(MCRMetadataExtension.class)
public class MIRDeleteACLTest extends MIRACLTest{

    @Override
    @BeforeEach
    public void setUp() {
        super.setUp();
    }

    @Test
    public void testDeleteObjectGuest() {
        // status published
        testObject(MIRTestConstants.MIR_ROLES_GUEST, "otherUser", "published", "mir_mods_0000001", false, "deletedb", "", false, false, false);

        // status new
        testObject(MIRTestConstants.MIR_ROLES_GUEST, "otherUser", "new", "mir_mods_0000002", false, "deletedb", "", false, false, false);

        // status submitted
        testObject(MIRTestConstants.MIR_ROLES_GUEST, "otherUser", "submitted", "mir_mods_0000003", false, "deletedb", "", false, false, false);

        // status blocked
        testObject(MIRTestConstants.MIR_ROLES_GUEST, "otherUser", "blocked", "mir_mods_0000004", false, "deletedb", "", false, false, false);

        // status deleted
        testObject(MIRTestConstants.MIR_ROLES_GUEST, "otherUser", "deleted", "mir_mods_0000005", false, "deletedb", "", false, false, false);

    }

    @Test
    public void testDeleteObjectAdmin() {
        // status published
        testObject("admin1", "otherUser", "published", "mir_mods_0000001", true, "deletedb", MIRTestConstants.MIR_ROLES_ADMIN, false, false, false);

        // status new
        testObject("admin1", "otherUser", "new", "mir_mods_0000002", true, "deletedb", MIRTestConstants.MIR_ROLES_ADMIN, false, false, false);

        // status submitted
        testObject("admin1", "otherUser", "submitted", "mir_mods_0000003", true, "deletedb", MIRTestConstants.MIR_ROLES_ADMIN, false, false, false);

        // status blocked
        testObject("admin1", "otherUser", "blocked", "mir_mods_0000004", true, "deletedb", MIRTestConstants.MIR_ROLES_ADMIN, false, false, false);

        // status deleted
        testObject("admin1", "otherUser", "deleted", "mir_mods_0000005", true, "deletedb", MIRTestConstants.MIR_ROLES_ADMIN, false, false, false);

    }


    @Test
    public void testDeleteObjectEditor() {
        // status published
        testObject("editor1", "otherUser", "published", "mir_mods_0000001", false, "deletedb", MIRTestConstants.MIR_ROLES_EDITOR, false, false, false);

        // status new
        testObject("editor1", "otherUser", "new", "mir_mods_0000002", true, "deletedb", MIRTestConstants.MIR_ROLES_EDITOR, false, false, false);

        // status submitted
        testObject("editor1", "otherUser", "submitted", "mir_mods_0000003", true, "deletedb", MIRTestConstants.MIR_ROLES_EDITOR, false, false, false);

        // status blocked
        testObject("editor1", "otherUser", "blocked", "mir_mods_0000004", false, "deletedb", MIRTestConstants.MIR_ROLES_EDITOR, false, false, false);

        // status deleted
        testObject("editor1", "otherUser", "deleted", "mir_mods_0000005", false, "deletedb", MIRTestConstants.MIR_ROLES_EDITOR, false, false, false);

    }


    @Test
    public void testDeleteObjectReader() {
        // status published
        String userName = "reader1";

        testObject(userName, "otherUser", "published", "mir_mods_0000001", false, "deletedb", MIRTestConstants.MIR_ROLES_READER, false, false, false);

        // status new
        testObject(userName, "otherUser", "new", "mir_mods_0000002", false, "deletedb", MIRTestConstants.MIR_ROLES_READER, false, false, false);

        // status submitted
        testObject(userName, "otherUser", "submitted", "mir_mods_0000003", false, "deletedb", MIRTestConstants.MIR_ROLES_READER, false, false, false);

        // status blocked
        testObject(userName, "otherUser", "blocked", "mir_mods_0000004", false, "deletedb", MIRTestConstants.MIR_ROLES_READER, false, false, false);

        // status deleted
        testObject(userName, "otherUser", "deleted", "mir_mods_0000005", false, "deletedb", MIRTestConstants.MIR_ROLES_READER, false, false, false);
    }


    @Test
    public void testDeleteObjectSubmitter() {
        // status published
        String userName = "submitter1";

        // status published
        testObject(userName, userName, "published", "mir_mods_0000001", false, "deletedb", MIRTestConstants.MIR_ROLES_SUBMITTER, false, false, false);

        // status new
        testObject(userName, userName, "new", "mir_mods_0000002", true, "deletedb", MIRTestConstants.MIR_ROLES_SUBMITTER, false, false, false);

        // status submitted
        testObject(userName, userName, "submitted", "mir_mods_0000003", false, "deletedb", MIRTestConstants.MIR_ROLES_SUBMITTER, false, false, false);

        // status blocked
        testObject(userName, userName, "blocked", "mir_mods_0000004", false, "deletedb", MIRTestConstants.MIR_ROLES_SUBMITTER, false, false, false);

        // status deleted
        testObject(userName, userName, "deleted", "mir_mods_0000005", false, "deletedb", MIRTestConstants.MIR_ROLES_SUBMITTER, false, false, false);

        // status published, but not the submitter
        testObject(userName, "otherUser", "published", "mir_mods_0000006", false, "deletedb", MIRTestConstants.MIR_ROLES_SUBMITTER, false, false, false);

        // status new,  but not the submitter
        testObject(userName, "otherUser", "new", "mir_mods_0000007", false, "deletedb", MIRTestConstants.MIR_ROLES_SUBMITTER, false, false, false);

        // status submitted,  but not the submitter
        testObject(userName, "otherUser", "submitted", "mir_mods_0000008", false, "deletedb", MIRTestConstants.MIR_ROLES_SUBMITTER, false, false, false);

        // status blocked,  but not the submitter
        testObject(userName, "otherUser", "blocked", "mir_mods_0000009", false, "deletedb", MIRTestConstants.MIR_ROLES_SUBMITTER, false, false, false);

        // status deleted,  but not the submitter
        testObject(userName, "otherUser", "deleted", "mir_mods_0000010", false, "deletedb", MIRTestConstants.MIR_ROLES_SUBMITTER, false, false, false);

    }

}
