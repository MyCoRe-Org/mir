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

/**
 * Checks if a user can open a specific editor
 */
@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
@ExtendWith(MCRMetadataExtension.class)
public class MIREditorACLTest extends MIRACLTest {

    @Override
    @BeforeEach
    public void setUp() {
        super.setUp();
    }

    @Test
    public void testEditorGuest() {
        checkWebpage( "/editor/editor-dynamic.xed", false, "");
        checkWebpage( "/editor/editor-derivate.xed", false, "");
        checkWebpage( "/editor/editor-admins.xed", false, "");
    }

    @Test
    public void testEditorAdmin(){
        checkWebpage( "/editor/editor-dynamic.xed", true, MIRTestConstants.MIR_ROLES_ADMIN);
        checkWebpage( "/editor/editor-derivate.xed", true, MIRTestConstants.MIR_ROLES_ADMIN);
        checkWebpage( "/editor/editor-admins.xed", true, MIRTestConstants.MIR_ROLES_ADMIN);
    }

    @Test
    public void testEditorEditor(){
        checkWebpage("/editor/editor-dynamic.xed", true, MIRTestConstants.MIR_ROLES_EDITOR);
        checkWebpage( "/editor/editor-derivate.xed", true, MIRTestConstants.MIR_ROLES_EDITOR);
        checkWebpage( "/editor/editor-admins.xed", true, MIRTestConstants.MIR_ROLES_EDITOR);

    }

    @Test
    public void testEditorReader(){
        checkWebpage( "/editor/editor-dynamic.xed", false, MIRTestConstants.MIR_ROLES_READER);
        checkWebpage( "/editor/editor-derivate.xed", false, MIRTestConstants.MIR_ROLES_READER);
        checkWebpage( "/editor/editor-admins.xed", false, MIRTestConstants.MIR_ROLES_READER);
    }

    @Test
    public void testEditorSubmitter(){
        checkWebpage( "/editor/editor-dynamic.xed", true, MIRTestConstants.MIR_ROLES_SUBMITTER);
        checkWebpage( "/editor/editor-derivate.xed", true, MIRTestConstants.MIR_ROLES_SUBMITTER);
        checkWebpage( "/editor/editor-admins.xed", false, MIRTestConstants.MIR_ROLES_SUBMITTER);
    }


}
