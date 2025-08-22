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
public class MIRWriteObjectACLTest extends MIRACLTest {

    @Override
    @BeforeEach
    public void setUp() {
        super.setUp();
    }

    @Test
    public void testWriteObjectGuest() {
        // status published
        testWriteObject("guest", "otherUser", "published", "mir_mods_0000001", false, "");

        // status new
        testWriteObject("guest", "otherUser", "new", "mir_mods_0000002", false, "");

        // status submitted
        testWriteObject("guest", "otherUser", "submitted", "mir_mods_0000003", false, "");

        // status blocked
        testWriteObject("guest", "otherUser", "blocked", "mir_mods_0000004", false, "");

        // status deleted
        testWriteObject("guest", "otherUser", "deleted", "mir_mods_0000005", false, "");
    }

    @Test
    public void testWriteObjectAdmin() {
        // status published
        testWriteObject("admin1", "otherUser", "published", "mir_mods_0000001", true, MIRTestConstants.MIR_ROLES_ADMIN);

        // status new
        testWriteObject("admin1", "otherUser", "new", "mir_mods_0000002", true, MIRTestConstants.MIR_ROLES_ADMIN);

        // status submitted
        testWriteObject("admin1", "otherUser", "submitted", "mir_mods_0000003", true, MIRTestConstants.MIR_ROLES_ADMIN);

        // status blocked
        testWriteObject("admin1", "otherUser", "blocked", "mir_mods_0000004", true, MIRTestConstants.MIR_ROLES_ADMIN);

        // status deleted
        testWriteObject("admin1", "otherUser", "deleted", "mir_mods_0000005", true, MIRTestConstants.MIR_ROLES_ADMIN);
    }

    @Test
    public void testWriteObjectEditor() {
        // status published
        testWriteObject("editor1", "otherUser", "published", "mir_mods_0000001", true, MIRTestConstants.MIR_ROLES_EDITOR);

        // status new
        testWriteObject("editor1", "otherUser", "new", "mir_mods_0000002", true, MIRTestConstants.MIR_ROLES_EDITOR);

        // status submitted
        testWriteObject("editor1", "otherUser", "submitted", "mir_mods_0000003", true, MIRTestConstants.MIR_ROLES_EDITOR);

        // status blocked
        testWriteObject("editor1", "otherUser", "blocked", "mir_mods_0000004", true, MIRTestConstants.MIR_ROLES_EDITOR);

        // status deleted
        testWriteObject("editor1", "otherUser", "deleted", "mir_mods_0000005", true, MIRTestConstants.MIR_ROLES_EDITOR);
    }

    @Test
    public void testWriteObjectReader() {
        // status published
        testWriteObject("reader1", "otherUser", "published", "mir_mods_0000001", false, MIRTestConstants.MIR_ROLES_READER);

        // status new
        testWriteObject("reader1", "otherUser", "new", "mir_mods_0000002", false, MIRTestConstants.MIR_ROLES_READER);

        // status submitted
        testWriteObject("reader1", "otherUser", "submitted", "mir_mods_0000003", false, MIRTestConstants.MIR_ROLES_READER);

        // status blocked
        testWriteObject("reader1", "otherUser", "blocked", "mir_mods_0000004", false, MIRTestConstants.MIR_ROLES_READER);

        // status deleted
        testWriteObject("reader1", "otherUser", "deleted", "mir_mods_0000005", false, MIRTestConstants.MIR_ROLES_READER);
    }

    @Test
    public void testWriteObjectSubmitter() {
        // status published
        testWriteObject("submitter1", "otherUser", "published", "mir_mods_0000001", false, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status new
        testWriteObject("submitter1", "otherUser", "new", "mir_mods_0000002", false, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status submitted
        testWriteObject("submitter1", "otherUser", "submitted", "mir_mods_0000003", false, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status blocked
        testWriteObject("submitter1", "otherUser", "blocked", "mir_mods_0000004", false, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status deleted
        testWriteObject("submitter1", "otherUser", "deleted", "mir_mods_0000005", false, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status new & creator
        testWriteObject("submitter1", "submitter1", "new", "mir_mods_0000006", true, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status submitted & creator
        testWriteObject("submitter1", "submitter1", "submitted", "mir_mods_0000007", false, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status published & creator
        testWriteObject("submitter1", "submitter1", "published", "mir_mods_0000007", false, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status deleted & creator
        testWriteObject("submitter1", "submitter1", "deleted", "mir_mods_0000008", false, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status blocked & creator
        testWriteObject("submitter1", "submitter1", "blocked", "mir_mods_0000009", false, MIRTestConstants.MIR_ROLES_SUBMITTER);
    }
    
}
