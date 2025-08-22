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
 * Check if a specific user can open the right search form and use solr-request handler
 */
@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
@ExtendWith(MCRMetadataExtension.class)
public class MIRSearchACLTest extends MIRACLTest {

    @Override
    @BeforeEach
    public void setUp() {
        super.setUp();
    }

    @Test
    public void testSearchGuest() {
        checkWebpage( "/content/search/simple.xed", true, "");
        checkWebpage( "/content/search/complex.xed", true, "");
        checkWebpage( "/content/browse/institutes.xml", true, "");
        checkWebpage( "/content/browse/genres.xml", true, "");

        checkWebpage( "/content/search/simple_intern.xed", false, "");
        checkWebpage( "/content/search/complex_intern.xed", false, "");
        checkWebpage( "/search/search-expert.xed", false, "");

        checkReadId("solr:/select", false, "");
        checkReadId("solr:/find", false, "");

        checkReadId("solr:/selectPublic", true, "");
        checkReadId("solr:/findPublic", true, "");
    }

    @Test
    public void testSearchAdmin(){
        checkWebpage( "/content/search/simple.xed", false, MIRTestConstants.MIR_ROLES_ADMIN);
        checkWebpage( "/content/search/complex.xed", false, MIRTestConstants.MIR_ROLES_ADMIN);
        checkWebpage( "/content/browse/institutes.xml", true, MIRTestConstants.MIR_ROLES_ADMIN);
        checkWebpage( "/content/browse/genres.xml", true, MIRTestConstants.MIR_ROLES_ADMIN);

        checkWebpage( "/content/search/simple_intern.xed", true, MIRTestConstants.MIR_ROLES_ADMIN);
        checkWebpage( "/content/search/complex_intern.xed", true, MIRTestConstants.MIR_ROLES_ADMIN);
        checkWebpage( "/search/search-expert.xed", true, MIRTestConstants.MIR_ROLES_ADMIN);

        checkReadId("solr:/select", true, MIRTestConstants.MIR_ROLES_ADMIN);
        checkReadId("solr:/find", true, MIRTestConstants.MIR_ROLES_ADMIN);

        checkReadId("solr:/selectPublic", true, MIRTestConstants.MIR_ROLES_ADMIN);
        checkReadId("solr:/findPublic", true, MIRTestConstants.MIR_ROLES_ADMIN);
    }

    @Test
    public void testSearchEditor(){
        String role = MIRTestConstants.MIR_ROLES_EDITOR;
        checkWebpage( "/content/search/simple.xed", false, role);
        checkWebpage( "/content/search/complex.xed", false, role);
        checkWebpage( "/content/browse/institutes.xml", true, role);
        checkWebpage( "/content/browse/genres.xml", true, role);

        checkWebpage( "/content/search/simple_intern.xed", true, role);
        checkWebpage( "/content/search/complex_intern.xed", true, role);
        checkWebpage( "/search/search-expert.xed", true, role);

        checkReadId("solr:/select", true, role);
        checkReadId("solr:/find", true, role);

        checkReadId("solr:/selectPublic", true, role);
        checkReadId("solr:/findPublic", true, role);
    }

    @Test
    public void testSearchReader(){
        String role = MIRTestConstants.MIR_ROLES_READER;
        checkWebpage( "/content/search/simple.xed", true, role);
        checkWebpage( "/content/search/complex.xed", true, role);
        checkWebpage( "/content/browse/institutes.xml", true, role);
        checkWebpage( "/content/browse/genres.xml", true, role);

        checkWebpage( "/content/search/simple_intern.xed", false, role);
        checkWebpage( "/content/search/complex_intern.xed", false, role);
        checkWebpage( "/search/search-expert.xed", false, role);

        checkReadId("solr:/select", true, role);
        checkReadId("solr:/find", true, role);

        checkReadId("solr:/selectPublic", true, role);
        checkReadId("solr:/findPublic", true, role);
    }

    @Test
    public void testSearchSubmitter(){
        String role = MIRTestConstants.MIR_ROLES_SUBMITTER;
        checkWebpage( "/content/search/simple.xed", true, role);
        checkWebpage( "/content/search/complex.xed", true, role);
        checkWebpage( "/content/browse/institutes.xml", true, role);
        checkWebpage( "/content/browse/genres.xml", true, role);

        checkWebpage( "/content/search/simple_intern.xed", false, role);
        checkWebpage( "/content/search/complex_intern.xed", false, role);
        checkWebpage( "/search/search-expert.xed", false, role);

        checkReadId("solr:/select", true, role);
        checkReadId("solr:/find", true, role);

        checkReadId("solr:/selectPublic", true, role);
        checkReadId("solr:/findPublic", true, role);
    }
}
