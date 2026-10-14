/*
 * This file is part of ***  M y C o R e  ***
 * See https://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.mycore.mir.solr;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.util.List;
import java.util.Set;

import org.apache.solr.common.params.ModifiableSolrParams;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.common.MCRUserInformation;
import org.mycore.solr.proxy.MCRSolrQueryParameterFilter;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIROwnerSolrQueryParameterFilterTest {

    private final MIROwnerSolrQueryParameterFilter filter = new MIROwnerSolrQueryParameterFilter(
        List.of("admin", "editor"));

    @AfterEach
    public void tearDown() {
        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.GUEST);
    }

    @Test
    public void testGuest() {
        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.GUEST);

        ModifiableSolrParams params = filterUserParams("/find");

        assertArrayEquals(new String[] { "-*:*" }, params.getParams("owner"));
        assertArrayEquals(new String[] { "createdby:bob" }, params.getParams("fq"));
    }

    @Test
    public void testUser() {
        setUser("anna");

        ModifiableSolrParams params = filterUserParams("/find");

        assertArrayEquals(new String[] { "createdby:anna" }, params.getParams("owner"));
        assertArrayEquals(new String[] { "createdby:bob" }, params.getParams("fq"));
    }

    @Test
    public void testUserIdIsEscaped() {
        setUser("anna OR *:*");

        ModifiableSolrParams params = filterUserParams("/find");

        assertArrayEquals(new String[] { "createdby:anna\\ OR\\ \\*\\:\\*" }, params.getParams("owner"));
    }

    @Test
    public void testEditor() {
        setUser("eddi", "editor");

        ModifiableSolrParams params = filterUserParams("/find");

        assertArrayEquals(new String[] { "*:*" }, params.getParams("owner"));
        assertArrayEquals(new String[] { "createdby:bob" }, params.getParams("fq"));
    }

    @Test
    public void testSuperUser() {
        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.SUPER_USER);

        ModifiableSolrParams params = filterUserParams("/find");

        assertArrayEquals(new String[] { "*:*" }, params.getParams("owner"));
        assertArrayEquals(new String[] { "createdby:bob" }, params.getParams("fq"));
    }

    @Test
    public void testConfiguredFilter() {
        setUser("anna");

        ModifiableSolrParams params = new ModifiableSolrParams();
        params.add("owner", "*:*");
        MCRSolrQueryParameterFilter.obtainInstance().filter("/find", params);

        assertArrayEquals(new String[] { "createdby:anna" }, params.getParams("owner"));
        assertNull(params.getParams("fq"));
    }

    @Test
    public void testConfiguredFilterUsesAllowedRolesForSearch() {
        setUser("eddi", "editor");

        ModifiableSolrParams params = new ModifiableSolrParams();
        MCRSolrQueryParameterFilter.obtainInstance().filter("/find", params);

        assertArrayEquals(new String[] { "*:*" }, params.getParams("owner"));
        assertNull(params.getParams("fq"));
    }

    private ModifiableSolrParams filterUserParams(String queryHandlerPath) {
        ModifiableSolrParams params = new ModifiableSolrParams();
        params.add("owner", "*:*");
        params.add("fq", "createdby:bob");
        filter.filter(queryHandlerPath, params);
        return params;
    }

    private static void setUser(String userId, String... roles) {
        Set<String> roleSet = Set.of(roles);
        MCRSessionMgr.getCurrentSession().setUserInformation(new MCRUserInformation() {
            @Override
            public String getUserID() {
                return userId;
            }

            @Override
            public boolean isUserInRole(String role) {
                return roleSet.contains(role);
            }

            @Override
            public String getUserAttribute(String attribute) {
                return null;
            }
        });
    }

}
