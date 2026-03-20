package org.mycore.mir.impexp;

import java.io.IOException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.request.QueryRequest;
import org.apache.solr.client.solrj.request.SolrQuery;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.input.DOMBuilder;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.common.MCRConstants;
import org.mycore.solr.MCRSolrIndexRegistryManager;
import org.mycore.solr.auth.MCRSolrAuthenticationLevel;
import org.mycore.solr.auth.MCRSolrAuthenticationManager;
import org.w3c.dom.NodeList;

/**
 * @author Michel Buechner (mcrmibue)
 */
public class MIRRelatedItemFinderUtils {

    private static final Logger LOGGER = LogManager.getLogger();

    private static String getIdentifierOfFirst(String q) throws SolrServerException, IOException {
        if (q == null || q.isEmpty()) {
            throw new IllegalArgumentException("The query string must not be null");
        }
        SolrQuery solrQuery = new SolrQuery(q);
        solrQuery.set("rows", 1);
        QueryResponse queryResponse;
        QueryRequest queryRequest = new QueryRequest(solrQuery);
        MCRSolrAuthenticationManager.obtainInstance().applyAuthentication(queryRequest,
            MCRSolrAuthenticationLevel.SEARCH);
        queryResponse = queryRequest.process(MCRSolrIndexRegistryManager.obtainRegistry()
            .requireMainIndex().getClient());

        if (queryResponse.getResults().getNumFound() == 0) {
            return null;
        }

        return queryResponse.getResults().getFirst().get("id").toString();
    }

    public static String findRelatedItem(final NodeList sources) {
        if (sources.getLength() == 0) {
            LOGGER.warn("Cannot get first element of node list 'sources'.");
            return "";
        }
        org.w3c.dom.Element relatedItemW3C = (org.w3c.dom.Element) sources.item(0).getParentNode();
        DOMBuilder domBuilder = new DOMBuilder();
        Element relatedItem = domBuilder.build(relatedItemW3C);
        XPathExpression<Element> xpathIdentifier = XPathFactory.instance().compile("mods:identifier",
            Filters.element(), null, MCRConstants.MODS_NAMESPACE, MCRConstants.XLINK_NAMESPACE);
        Element identifierElement = xpathIdentifier.evaluateFirst(relatedItem);
        String mcrID = "";
        try {
            if (identifierElement != null) {
                mcrID = getIdentifierOfFirst("mods.identifier:\"" + identifierElement.getText() + "\"");
            }
            if (identifierElement == null || mcrID == null) {
                XPathExpression<Element> xpathTitle = XPathFactory.instance().compile("mods:titleInfo/mods:title",
                    Filters.element(), null, MCRConstants.MODS_NAMESPACE, MCRConstants.XLINK_NAMESPACE);
                Element titleElement = xpathTitle.evaluateFirst(relatedItem);
                if (titleElement != null) {
                    mcrID = getIdentifierOfFirst("mods.title.main:\"" + titleElement.getText() + "\"");
                }
            }
        } catch (Exception e) {
            LOGGER.error("Exception while finding related item.", e);
            return "";
        }
        return mcrID != null ? mcrID : "";
    }
}
