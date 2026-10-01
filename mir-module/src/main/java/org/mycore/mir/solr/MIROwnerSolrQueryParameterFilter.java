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

import java.util.List;
import java.util.Objects;
import java.util.function.Supplier;

import org.apache.solr.client.solrj.util.ClientUtils;
import org.apache.solr.common.params.ModifiableSolrParams;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.common.MCRUserInformation;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.config.annotation.MCRConfigurationProxy;
import org.mycore.common.config.annotation.MCRProperty;
import org.mycore.solr.proxy.MCRSolrQueryParameterFilter;

/**
 * A {@link MIROwnerSolrQueryParameterFilter} is a {@link MCRSolrQueryParameterFilter} that provides the owner
 * of unpublished objects the current user is allowed to find, so that request handlers can restrict user supplied
 * Solr queries to published objects and these unpublished objects.
 * <p>
 * The Solr parameter <code>owner</code> is always set on the server side and replaces any value supplied by the
 * client. Request handlers can use it in a filter query, e.g. <code>state:published OR {!v=$owner}</code>. It is set
 * to
 * <ul>
 * <li><code>*:*</code> for users with one of the roles in {@link #ALLOWED_ROLES_KEY},
 * <li><code>-*:*</code> for the guest user,
 * <li><code>createdby:{user ID}</code> for all other users.
 * </ul>
 * Example:
 * <pre><code>
 * [...].Class=org.mycore.mir.solr.MIROwnerSolrQueryParameterFilter
 * [...].AllowedRoles=admin,editor
 * </code></pre>
 */
@MCRConfigurationProxy(proxyClass = MIROwnerSolrQueryParameterFilter.Factory.class)
public class MIROwnerSolrQueryParameterFilter implements MCRSolrQueryParameterFilter {

    public static final String OWNER_PARAMETER = "owner";

    public static final String ALLOWED_ROLES_KEY = "AllowedRoles";

    private static final String ALL_OWNERS_QUERY = "*:*";

    private static final String NO_OWNER_QUERY = "-*:*";

    private final List<String> allowedRoles;

    public MIROwnerSolrQueryParameterFilter(List<String> allowedRoles) {
        this.allowedRoles = List.copyOf(Objects.requireNonNull(allowedRoles, "Allowed roles must not be null"));
    }

    @Override
    public void filter(String queryHandlerPath, ModifiableSolrParams params) {
        MCRUserInformation user = MCRSessionMgr.getCurrentSession().getUserInformation();
        boolean allowedToSeeAll = allowedRoles.stream().anyMatch(user::isUserInRole);

        params.set(OWNER_PARAMETER, getOwnerQuery(user, allowedToSeeAll));
    }

    private static String getOwnerQuery(MCRUserInformation user, boolean allowedToSeeAll) {
        if (allowedToSeeAll) {
            return ALL_OWNERS_QUERY;
        }
        if (MCRSystemUserInformation.GUEST.equals(user)) {
            return NO_OWNER_QUERY;
        }
        return "createdby:" + ClientUtils.escapeQueryChars(user.getUserID());
    }

    public static class Factory implements Supplier<MIROwnerSolrQueryParameterFilter> {

        @MCRProperty(name = ALLOWED_ROLES_KEY, defaultName = "MIR.OwnerStrategy.AllowedRolesForSearch")
        public String allowedRoles;

        @Override
        public MIROwnerSolrQueryParameterFilter get() {
            return new MIROwnerSolrQueryParameterFilter(MCRConfiguration2.splitValue(allowedRoles).toList());
        }

    }

}
