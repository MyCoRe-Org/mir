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

package org.mycore.mir.alias;

import java.io.IOException;
import java.util.Collection;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.request.QueryRequest;
import org.apache.solr.client.solrj.util.ClientUtils;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.common.params.ModifiableSolrParams;
import org.mycore.common.MCRException;
import org.mycore.solr.MCRSolrIndexRegistryManager;
import org.mycore.solr.auth.MCRSolrAuthenticationLevel;
import org.mycore.solr.auth.MCRSolrAuthenticationManager;

/**
 * Looks up aliases in the main Solr index. The alias is stored in the field <code>alias</code>,
 * which is indexed lowercase, so lookups are case-insensitive.
 */
public class MIRAliasSolrIndex {

    private static final String FIELD_ID = "id";

    private static final String FIELD_ALIAS = "alias";

    private static final List<String> FIELDS_PARENT = List.of("mods.relatedItem.host", "mods.relatedItem.series");

    private static final int MAX_OBJECTS = 1000;

    /**
     * @param alias the alias, compared case-insensitively
     * @return all objects with the given alias
     */
    public List<AliasedObject> findObjects(String alias) {
        // the field query parser analyzes the value with the field type (lowercase), no escaping required
        return toAliasedObjects(query("{!field f=" + FIELD_ALIAS + " v=$value}", alias, MAX_OBJECTS));
    }

    /**
     * @return all objects with an alias that refer to the given object as host or series
     */
    public List<AliasedObject> findRelatedObjects(String objectId) {
        String escapedId = ClientUtils.escapeQueryChars(objectId);
        String query = FIELDS_PARENT.stream()
            .map(field -> field + ":" + escapedId)
            .collect(Collectors.joining(" OR ", "{!lucene}", ""));
        return toAliasedObjects(query(query, null, MAX_OBJECTS));
    }

    /**
     * @return the ids of the given objects that have an alias
     */
    public Set<String> findIdsWithAlias(Collection<String> objectIds) {
        if (objectIds.isEmpty()) {
            return Set.of();
        }
        return query("{!terms f=" + FIELD_ID + " v=$value}", String.join(",", objectIds), objectIds.size())
            .stream()
            .map(doc -> (String) doc.getFieldValue(FIELD_ID))
            .collect(Collectors.toSet());
    }

    private static List<AliasedObject> toAliasedObjects(SolrDocumentList docs) {
        return docs.stream()
            .filter(doc -> doc.getFieldValue(FIELD_ALIAS) instanceof String)
            .map(doc -> new AliasedObject((String) doc.getFieldValue(FIELD_ID),
                (String) doc.getFieldValue(FIELD_ALIAS), getParentIds(doc)))
            .toList();
    }

    private static List<String> getParentIds(SolrDocument doc) {
        return FIELDS_PARENT.stream()
            .map(doc::getFieldValues)
            .filter(Objects::nonNull)
            .flatMap(Collection::stream)
            .map(Object::toString)
            .toList();
    }

    private static SolrDocumentList query(String query, String value, int rows) {
        ModifiableSolrParams params = new ModifiableSolrParams();
        params.set("q", query);
        if (value != null) {
            params.set("value", value);
        }
        params.set("fq", "objectType:mods", FIELD_ALIAS + ":[* TO *]");
        params.set("fl", Stream.concat(Stream.of(FIELD_ID, FIELD_ALIAS), FIELDS_PARENT.stream())
            .toArray(String[]::new));
        params.set("rows", rows);
        QueryRequest request = new QueryRequest(params);
        MCRSolrAuthenticationManager.obtainInstance().applyAuthentication(request, MCRSolrAuthenticationLevel.SEARCH);
        try {
            return request.process(MCRSolrIndexRegistryManager.requireMainIndex().getClient()).getResults();
        } catch (SolrServerException | IOException e) {
            throw new MCRException("Error while looking up alias " + value + " in Solr.", e);
        }
    }

    public record AliasedObject(String objectId, String alias, List<String> parentIds) {
    }
}
