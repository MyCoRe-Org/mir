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

package org.mycore.mir.index;

import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.function.Supplier;

import org.apache.solr.common.params.ModifiableSolrParams;
import org.mycore.common.config.annotation.MCRConfigurationProxy;
import org.mycore.common.config.annotation.MCRPropertyList;
import org.mycore.common.config.annotation.MCRSentinel;
import org.mycore.solr.proxy.MCRSolrQueryParameterFilter;

/**
 * A {@link MIRSolrProxyParamProcessor} is a {@link MCRSolrQueryParameterFilter} that applies
 * {@link MIRPrepareForPersonIndexURIResolver#prepareForPersonIndex(String)} to the <code>regex</code>
 * parameter (and stores the original values as parameter <code>regex.orginal</code>)
 * if the Solr proxy servlet is used for person search.
 * <p>
 * This makes the regex compatible with the stored terms, that start with a version of the indexed person name
 * that has also been processed with {@link MIRPrepareForPersonIndexURIResolver#prepareForPersonIndex(String)}.
 */
@MCRConfigurationProxy(proxyClass = MIRSolrProxyParamProcessor.Factory.class)
public final class MIRSolrProxyParamProcessor implements MCRSolrQueryParameterFilter {

    public static final String QUERY_HANDLER_PATHS_KEY = "QueryHandlerPaths";

    public static final String REGEX = "regex";

    public static final String REGEX_ORIGINAL = "regex.original";

    private final Set<String> queryHandlerPaths;

    public MIRSolrProxyParamProcessor(Set<String> queryHandlerPaths) {
        this.queryHandlerPaths = new HashSet<>(Objects.requireNonNull(
            queryHandlerPaths, "Query handler paths must not be null"));
        this.queryHandlerPaths.forEach(queryHandlerPath -> Objects.requireNonNull(
            queryHandlerPath, "Query handler path must not be null"));
    }

    @Override
    public void filter(String queryHandlerPath, ModifiableSolrParams params) {
        if (queryHandlerPaths.contains(queryHandlerPath)) {
            String termsRegex = params.get(REGEX);
            if (termsRegex != null) {
                params.remove(REGEX);
                params.add(REGEX, MIRPrepareForPersonIndexURIResolver.prepareForPersonIndex(termsRegex));
                params.add(REGEX_ORIGINAL, termsRegex);
            }
        }
    }

    public static final class Factory implements Supplier<MIRSolrProxyParamProcessor> {

        @MCRSentinel
        @MCRPropertyList(name = QUERY_HANDLER_PATHS_KEY, required = false)
        public List<String> queryHandlerPaths;

        @Override
        public MIRSolrProxyParamProcessor get() {
            return new MIRSolrProxyParamProcessor(new HashSet<>(queryHandlerPaths));
        }

    }

}
