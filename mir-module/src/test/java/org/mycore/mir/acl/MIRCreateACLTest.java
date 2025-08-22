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
public class MIRCreateACLTest extends MIRACLTest {

    @Override
    @BeforeEach
    public void setUp() {
        super.setUp();
    }

    @Test
    public void testCreateGuest() {
        testPermission("guest", "create-mods", false, "");

        testPermission("guest", "create-derivate", false, "");
    }

    @Test
    public void testCreateAdmin(){
        enableDebug();
        testPermission("admin1", "create-mods", true, MIRTestConstants.MIR_ROLES_ADMIN);
        disableDebug();

        testPermission("admin1", "create-derivate", true,  MIRTestConstants.MIR_ROLES_ADMIN);
    }

    @Test
    public void testCreateEditor(){
        testPermission("editor1", "create-mods", true,  MIRTestConstants.MIR_ROLES_EDITOR);

        testPermission("editor1", "create-derivate", true,  MIRTestConstants.MIR_ROLES_EDITOR);
    }

    @Test
    public void testCreateReader(){
        testPermission("reader1", "create-mods", false,  MIRTestConstants.MIR_ROLES_READER);

        testPermission("reader1", "create-derivate", false,  MIRTestConstants.MIR_ROLES_READER);
    }

    @Test
    public void testCreateSubmitter(){
        testPermission("submitter1", "create-mods", true,  MIRTestConstants.MIR_ROLES_SUBMITTER);

        testPermission("submitter1", "create-derivate", true,  MIRTestConstants.MIR_ROLES_SUBMITTER);
    }

}
