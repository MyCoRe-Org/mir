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
public class MIRReadObjectACLTest extends MIRACLTest {

    @Override
    @BeforeEach
    public void setUp() {
        super.setUp();
    }

    @Test
    public void testReadObjectGuest() {
        // status published
        testReadObject("guest", "otherUser", "published", "mir_mods_0000001", true, "");

        // status new
        testReadObject("guest", "otherUser", "new", "mir_mods_0000002", false, "");

        // status submitted
        testReadObject("guest", "otherUser", "submitted", "mir_mods_0000003", false, "");

        // status blocked
        testReadObject("guest", "otherUser", "blocked", "mir_mods_0000004", true, "");

        // status deleted
        testReadObject("guest", "otherUser", "deleted", "mir_mods_0000005", true, "");

        // status published but with embargo read files
        testReadWriteObject("guest", "otherUser", "published", "mir_derivate_0000006", false, true, "", true);

        // status published but with embargo read metadata
        testReadWriteObject("guest", "otherUser", "published", "mir_mods_0000007", true, true, "", true);

        // status published without embargo read files
        testReadWriteObject("guest", "otherUser", "published", "mir_derivate_0000008", true, true, "", false);

        // status published without embargo read metadata
        testReadWriteObject("guest", "otherUser", "published", "mir_mods_0000009", true, true, "", false);

        // status published, read document, files intern
        testReadWriteObject("guest", "otherUser", "published", "mir_mods_0000010", true, true, "", false, false, true);

        // status published, read files, files intern
        testReadWriteObject("guest", "otherUser", "published", "mir_derivate_0000011", false, true, "", false, false,
            true);

        // status published, read document,  metadata intern
        testReadWriteObject("guest", "otherUser", "published", "mir_mods_0000012", false, true, "", false, true, false);

        // status published, read files,  metadata intern
        testReadWriteObject("guest", "otherUser", "published", "mir_derivate_0000013", false, true, "", false, true,
            false);
    }

    @Test
    public void testReadObjectAdmin() {
        // status published
        testReadObject("admin1", "otherUser", "published", "mir_mods_0000001", true, MIRTestConstants.MIR_ROLES_ADMIN);

        // status new
        testReadObject("admin1", "otherUser", "new", "mir_mods_0000002", true, MIRTestConstants.MIR_ROLES_ADMIN);

        // status submitted
        testReadObject("admin1", "otherUser", "submitted", "mir_mods_0000003", true, MIRTestConstants.MIR_ROLES_ADMIN);

        // status blocked
        testReadObject("admin1", "otherUser", "blocked", "mir_mods_0000004", true, MIRTestConstants.MIR_ROLES_ADMIN);

        // status deleted
        testReadObject("admin1", "otherUser", "deleted", "mir_mods_0000005", true, MIRTestConstants.MIR_ROLES_ADMIN);

        // status published but with embargo read files
        testReadWriteObject("admin1", "otherUser", "published", "mir_derivate_0000006", true, true,
            MIRTestConstants.MIR_ROLES_ADMIN, true);

        // status published but with embargo read metadata
        testReadWriteObject("admin1", "otherUser", "published", "mir_mods_0000007", true, true,
            MIRTestConstants.MIR_ROLES_ADMIN, true);

        // status published without embargo read files
        testReadWriteObject("admin1", "otherUser", "published", "mir_derivate_0000008", true, true,
            MIRTestConstants.MIR_ROLES_ADMIN, false);

        // status published without embargo read metadata
        testReadWriteObject("admin1", "otherUser", "published", "mir_mods_0000009", true, true,
            MIRTestConstants.MIR_ROLES_ADMIN, false);

        // status published, read document, files intern
        testReadWriteObject("admin1", "otherUser", "published", "mir_mods_0000010", true, true,
            MIRTestConstants.MIR_ROLES_ADMIN, false, false, true);

        // status published, read files, files intern
        testReadWriteObject("admin1", "otherUser", "published", "mir_derivate_0000011", true, true,
            MIRTestConstants.MIR_ROLES_ADMIN, false, false,
            true);

        // status published, read document,  metadata intern
        testReadWriteObject("admin1", "otherUser", "published", "mir_mods_0000012", true, true,
            MIRTestConstants.MIR_ROLES_ADMIN, false, true, false);

        // status published, read files,  metadata intern
        testReadWriteObject("admin1", "otherUser", "published", "mir_derivate_0000013", true, true,
            MIRTestConstants.MIR_ROLES_ADMIN, false, true,
            false);
    }

    @Test
    public void testReadObjectEditor() {
        // status published
        testReadObject("editor1", "otherUser", "published", "mir_mods_0000001", true,
            MIRTestConstants.MIR_ROLES_EDITOR);

        // status new
        testReadObject("editor1", "otherUser", "new", "mir_mods_0000002", true, MIRTestConstants.MIR_ROLES_EDITOR);

        // status submitted
        testReadObject("editor1", "otherUser", "submitted", "mir_mods_0000003", true,
            MIRTestConstants.MIR_ROLES_EDITOR);

        // status blocked
        testReadObject("editor1", "otherUser", "blocked", "mir_mods_0000004", true, MIRTestConstants.MIR_ROLES_EDITOR);

        // status deleted
        testReadObject("editor1", "otherUser", "deleted", "mir_mods_0000005", true, MIRTestConstants.MIR_ROLES_EDITOR);

        // status published, read document, files intern
        testReadWriteObject("editor1", "otherUser", "published", "mir_mods_0000010", true, true,
                MIRTestConstants.MIR_ROLES_EDITOR, false, false, true);

        // status published, read files, files intern
        testReadWriteObject("editor1", "otherUser", "published", "mir_derivate_0000011", true, true,
                MIRTestConstants.MIR_ROLES_EDITOR, false, false,
                true);

        // status published, read document,  metadata intern
        testReadWriteObject("editor1", "otherUser", "published", "mir_mods_0000012", true, true,
                MIRTestConstants.MIR_ROLES_EDITOR, false, true, false);

        // status published, read files,  metadata intern
        testReadWriteObject("editor1", "otherUser", "published", "mir_derivate_0000013", true, true,
                MIRTestConstants.MIR_ROLES_EDITOR, false, true,
                false);
    }

    @Test
    public void testReadObjectReader() {
        // status published
        testReadObject("reader1", "otherUser", "published", "mir_mods_0000001", true,
            MIRTestConstants.MIR_ROLES_READER);

        // status new
        testReadObject("reader1", "otherUser", "new", "mir_mods_0000002", false, MIRTestConstants.MIR_ROLES_READER);

        // status submitted
        testReadObject("reader1", "otherUser", "submitted", "mir_mods_0000003", false,
            MIRTestConstants.MIR_ROLES_READER);

        // status blocked
        testReadObject("reader1", "otherUser", "blocked", "mir_mods_0000004", true, MIRTestConstants.MIR_ROLES_READER);

        // status deleted
        testReadObject("reader1", "otherUser", "deleted", "mir_mods_0000005", true, MIRTestConstants.MIR_ROLES_READER);

        // status blocked
        testReadObject("reader1", "otherUser", "blocked", "mir_derivate_0000006", false,
            MIRTestConstants.MIR_ROLES_READER);

        // status deleted
        testReadObject("reader1", "otherUser", "deleted", "mir_derivate_0000007", false,
            MIRTestConstants.MIR_ROLES_READER);

        // status published, read document, files intern
        testReadWriteObject("reader1", "otherUser", "published", "mir_mods_0000008", true, true,
                MIRTestConstants.MIR_ROLES_READER, false, false, true);

        // status published, read files, files intern
        testReadWriteObject("reader1", "otherUser", "published", "mir_derivate_0000009", true, true,
                MIRTestConstants.MIR_ROLES_READER, false, false,
                true);

        // status published, read document,  metadata intern
        testReadWriteObject("reader1", "otherUser", "published", "mir_mods_0000010", true, true,
                MIRTestConstants.MIR_ROLES_READER, false, true, false);

        // status published, read files,  metadata intern
        testReadWriteObject("reader1", "otherUser", "published", "mir_derivate_0000011", true, true,
                MIRTestConstants.MIR_ROLES_READER, false, true,
                false);
    }

    @Test
    public void testReadObjectSubmitter() {
        // status published
        testReadObject("submitter1", "otherUser", "published", "mir_mods_0000001", true,
            MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status new
        testReadObject("submitter1", "otherUser", "new", "mir_mods_0000002", false, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status submitted
        testReadObject("submitter1", "otherUser", "submitted", "mir_mods_0000003", false,
            MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status blocked
        testReadObject("submitter1", "otherUser", "blocked", "mir_mods_0000004", true, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status deleted
        testReadObject("submitter1", "otherUser", "deleted", "mir_mods_0000005", true, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status new & creator
        testReadObject("submitter1", "submitter1", "new", "mir_mods_0000006", true, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status submitted & creator
        testReadObject("submitter1", "submitter1", "submitted", "mir_mods_0000007", true, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status published & creator
        testReadObject("submitter1", "submitter1", "published", "mir_mods_0000008", true, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status deleted & creator
        testReadObject("submitter1", "submitter1", "deleted", "mir_mods_0000009", true, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status blocked & creator
        testReadObject("submitter1", "submitter1", "blocked", "mir_mods_0000010", true, MIRTestConstants.MIR_ROLES_SUBMITTER);

        // status published but with embargo read files
        testReadWriteObject("submitter1", "otherUser", "published", "mir_derivate_0000011", false, true,
            MIRTestConstants.MIR_ROLES_SUBMITTER, true);

        // status published but with embargo read files, but submitter
        testReadWriteObject("submitter1", "submitter1", "published", "mir_derivate_0000012", true, true,
            MIRTestConstants.MIR_ROLES_SUBMITTER, true);

        // status published but with embargo read metadata
        testReadWriteObject("submitter1", "otherUser", "published", "mir_mods_0000013", true, true,
            MIRTestConstants.MIR_ROLES_SUBMITTER, true);

        // status published without embargo read files
        testReadWriteObject("submitter1", "otherUser", "published", "mir_derivate_0000014", true, true,
            MIRTestConstants.MIR_ROLES_SUBMITTER, false);

        // status published without embargo read metadata
        testReadWriteObject("submitter1", "otherUser", "published", "mir_mods_0000015", true, true,
            MIRTestConstants.MIR_ROLES_SUBMITTER, false);

        // status published, read document, files intern
        testReadWriteObject("submitter1", "otherUser", "published", "mir_mods_0000016", true, true,
                MIRTestConstants.MIR_ROLES_SUBMITTER, false, false, true);

        // status published, read files, files intern
        testReadWriteObject("submitter1", "otherUser", "published", "mir_derivate_0000017", true, true,
                MIRTestConstants.MIR_ROLES_SUBMITTER, false, false,
                true);

        // status published, read document,  metadata intern
        testReadWriteObject("submitter1", "otherUser", "published", "mir_mods_0000018", true, true,
                MIRTestConstants.MIR_ROLES_SUBMITTER, false, true, false);

        // status published, read files,  metadata intern
        testReadWriteObject("submitter1", "otherUser", "published", "mir_derivate_0000019", true, true,
                MIRTestConstants.MIR_ROLES_SUBMITTER, false, true,
                false);
    }

}
