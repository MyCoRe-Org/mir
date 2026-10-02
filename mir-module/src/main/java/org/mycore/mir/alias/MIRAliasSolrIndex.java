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
import java.util.List;
import java.util.Optional;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.request.QueryRequest;
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

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String FIELD_ID = "id";

    private static final String FIELD_ALIAS = "alias";

    private static final String FIELD_RELATED_ITEM = "mods.relatedItem";

    private static final int MAX_RELATED_OBJECTS = 1000;

    /**
     * @param alias the alias, compared case-insensitively
     * @return the id of the object with the given alias
     */
    public Optional<String> findObjectId(String alias) {
        // the field query parser analyzes the value with the field type (lowercase), no escaping required
        SolrDocumentList results = query("{!field f=" + FIELD_ALIAS + " v=$value}", alias, 2);
        if (results.getNumFound() > 1) {
            LOGGER.warn("Alias {} is used by {} objects, using {}.", alias, results.getNumFound(),
                results.getFirst().getFieldValue(FIELD_ID));
        }
        return results.stream().findFirst().map(doc -> (String) doc.getFieldValue(FIELD_ID));
    }

    /**
     * @return all objects with an alias that refer to the given object via <code>mods:relatedItem</code>
     */
    public List<AliasedObject> findRelatedObjects(String objectId) {
        return query("{!term f=" + FIELD_RELATED_ITEM + " v=$value}", objectId, MAX_RELATED_OBJECTS).stream()
            .filter(doc -> doc.getFieldValue(FIELD_ALIAS) instanceof String)
            .map(doc -> new AliasedObject((String) doc.getFieldValue(FIELD_ID),
                (String) doc.getFieldValue(FIELD_ALIAS)))
            .toList();
    }

    private static SolrDocumentList query(String query, String value, int rows) {
        ModifiableSolrParams params = new ModifiableSolrParams();
        params.set("q", query);
        params.set("value", value);
        params.set("fq", "objectType:mods", FIELD_ALIAS + ":[* TO *]");
        params.set("fl", FIELD_ID, FIELD_ALIAS);
        params.set("rows", rows);
        QueryRequest request = new QueryRequest(params);
        MCRSolrAuthenticationManager.obtainInstance().applyAuthentication(request, MCRSolrAuthenticationLevel.SEARCH);
        try {
            return request.process(MCRSolrIndexRegistryManager.requireMainIndex().getClient()).getResults();
        } catch (SolrServerException | IOException e) {
            throw new MCRException("Error while looking up alias " + value + " in Solr.", e);
        }
    }

    public record AliasedObject(String objectId, String alias) {
    }
}
