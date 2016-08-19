package org.mycore.mir.impexp;

import org.apache.log4j.Logger;
import org.jdom2.Element;
import org.jdom2.filter.Filters;

import org.jdom2.input.DOMBuilder;
import org.jdom2.xpath.XPathFactory;
import org.jdom2.xpath.XPathExpression;
import org.mycore.common.MCRConstants;
import org.mycore.solr.MCRXMLFunctions;
import org.w3c.dom.NodeList;

/**
 * @author Michel Buechner (mcrmibue)
 */
public class MIRRelatedItemFinder {

    private static final Logger LOGGER = Logger.getLogger(MIRRelatedItemFinder.class);

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
            if (identifierElement != null){
                mcrID = MCRXMLFunctions.getIdentifierOfFirst("mods.identifier:\"" + identifierElement.getText() + "\"");
            }
            if (identifierElement == null || mcrID == null){
                XPathExpression<Element> xpathTitle = XPathFactory.instance().compile("mods:titleInfo/mods:title",
                        Filters.element(), null, MCRConstants.MODS_NAMESPACE, MCRConstants.XLINK_NAMESPACE);
                Element titleElement = xpathTitle.evaluateFirst(relatedItem);
                if (titleElement != null) {
                    mcrID = MCRXMLFunctions.getIdentifierOfFirst("mods.title.main:\"" + titleElement.getText() + "\"");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
        return mcrID != null ? mcrID : "";
    }
}
