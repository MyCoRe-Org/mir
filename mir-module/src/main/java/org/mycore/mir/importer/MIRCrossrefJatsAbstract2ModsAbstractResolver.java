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

package org.mycore.mir.importer;

import java.io.StringWriter;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.UUID;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.common.config.MCRConfigurationException;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRStringContent;
import org.mycore.common.content.transformer.MCRContentTransformer;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.mir.editor.MIREditorUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * The Crossref JSON API, as used by the default configuration of the metadata enricher in MIR,
 * provides abstracts as JATS XML string embedded in its JSON response, like:
 * <pre><code>
 * {
 *   "status": "ok",
 *   "message-type": "work",
 *   "message-version": "1.0.0",
 *   "message": {
 *     ...
 *     "abstract": "&lt;jats:title&gt;Abstract&lt;/jats:title&gt;\n&lt;jats:p&gt;&lt;jats:bold&gt;Lorem ipsum&lt;/jats:bold&gt; dolor sit &lt;jats:italic&gt;amet&lt;/jats:italic&gt;, 23&lt;jats:sup&gt;42&lt;/jats:sup&gt;.&lt;/jats:p&gt;"
 *   }
 * }
 * </code></pre>
 * This JSON is turned into XML by <code>xslTransform:json2xml</code> and interpreted by
 * <code>xslTransform:crossref2mods</code> using <code>xslt/mir/import/enrichment/crossref2mods.xsl</code>
 * which sends the JATS XML string as an URL encoded string to this URI resolver.
 * <p>
 * This URI resolver processes the JATS XML into MIR specific MODS XML. To do this, it
 * <ol>
 *   <li> reverts the URL encoding;
 *   <li> wraps the JATS XML into a <code>jats:abstract</code>-Element (including the namespace binding);
 *   <li> transforms the JATS document into HTML using the content transformer <code>crossref-jats-abstract2html</code>;
 *   <li> places the HTML into an <code>abstract</code>-element with a random <code>altRepGroup</code>-attribute value;
 *   <li> Base64-encodes the string representation of that <code>abstract</code>-element;
 *   <li> creates a data URL using that Base64 encoded data;
 *   <li> creates a <code>mods:abstract</code>-element with
 *     <ul>
 *       <li> <code>contentType</code>-attribute with value <code>text/xml</code>,
 *       <li> <code>altRepGroup</code>-attribute with same value as above and,
 *       <li> <code>altFormat</code>-attribute with data URL as its value
 *     </ul>
 *     and a <code>mods:abstract</code>-element with
 *     <ul>
 *       <li> no <code>contentType</code>-attribute,
 *       <li> <code>altRepGroup</code>-attribute with same value as above and,
 *       <li> a plain text version of the HTML created with {@link MIREditorUtils#getPlainTextString(String)} as text;
 *     </ul>
 *   <li> places both <code>mods:abstract</code>-elements inside a <code>mods:mods</code>-element and
 *   <li> returns that <code>mods:mods</code>-element.
 * </ol>
 */
public class MIRCrossrefJatsAbstract2ModsAbstractResolver implements URIResolver {

    private static final Logger LOGGER = LogManager.getLogger();

    public static final String JATS_ABSTRACT_OPENING_TAG = "<jats:abstract xmlns:jats=\"http://jats.nlm.nih.gov\">";

    public static final String JATS_ABSTRACT_CLOSING_TAG = "</jats:abstract>";

    public static final String MODS_NAMESPACE = MCRConstants.MODS_NAMESPACE.getURI();

    @Override
    public Source resolve(String href, String base) throws TransformerException {

        DocumentBuilder documentBuilder = getDocumentBuilder();

        try {

            String encodedJatsString = href.substring("crossref-jats-abstract2mods-abstract:".length());
            String jatsString = URLDecoder.decode(encodedJatsString, StandardCharsets.UTF_8);
            String jatsDocumentString = JATS_ABSTRACT_OPENING_TAG + jatsString + JATS_ABSTRACT_CLOSING_TAG;

            if (LOGGER.isDebugEnabled()) {
                LOGGER.debug("JATS document: {}", jatsDocumentString);
            }

            MCRContent jatsDocumentContent = new MCRStringContent(jatsDocumentString);
            Document htmlDocument = transform(jatsDocumentContent, "crossref-jats-abstract2html");

            if (LOGGER.isDebugEnabled()) {
                LOGGER.debug("HTML document: {}", toString(htmlDocument));
            }

            NodeList htmlNodes = htmlDocument.getDocumentElement().getChildNodes();
            String htmlString = toHtmlString(htmlNodes);

            if (LOGGER.isDebugEnabled()) {
                LOGGER.debug("HTML: {}", htmlString);
            }

            String altRepGroup = getRandomRepGroup();

            Document innerAbstractDocument = documentBuilder.newDocument();
            Element innerAbstractElement = innerAbstractDocument.createElement("abstract");
            innerAbstractDocument.appendChild(innerAbstractElement);
            innerAbstractElement.setAttribute("altRepGroup", altRepGroup);
            innerAbstractElement.setTextContent(htmlString);
            String innerAbstractXml = toXmlString(innerAbstractDocument);

            if (LOGGER.isDebugEnabled()) {
                LOGGER.debug("inner abstract document: {}", innerAbstractXml);
            }

            Base64.Encoder encoder = Base64.getEncoder();
            String innerAbstractXmlBase64 = encoder.encodeToString(innerAbstractXml.getBytes(StandardCharsets.UTF_8));
            String innerAbstractDataUrl = "data:text/xml;charset=UTF-8;base64," + innerAbstractXmlBase64;

            if (LOGGER.isDebugEnabled()) {
                LOGGER.debug("inner abstract data URL: {}", innerAbstractDataUrl);
            }

            Document outerModsDocument = documentBuilder.newDocument();
            Element outerModsElement = outerModsDocument.createElementNS(MODS_NAMESPACE, "mods");
            outerModsDocument.appendChild(outerModsElement);
            Element outerHtmlAbstractElement = outerModsDocument.createElementNS(MODS_NAMESPACE, "abstract");
            outerModsElement.appendChild(outerHtmlAbstractElement);
            outerHtmlAbstractElement.setAttribute("altRepGroup", altRepGroup);
            outerHtmlAbstractElement.setAttribute("contentType", "text/xml");
            outerHtmlAbstractElement.setAttribute("altFormat", innerAbstractDataUrl);
            Element outerTextAbstractElement = outerModsDocument.createElementNS(MODS_NAMESPACE, "abstract");
            outerModsElement.appendChild(outerTextAbstractElement);
            outerTextAbstractElement.setAttribute("altRepGroup", altRepGroup);
            outerTextAbstractElement.setTextContent(MIREditorUtils.getPlainTextString(htmlString));

            if (LOGGER.isDebugEnabled()) {
                LOGGER.debug("outer MODS document: {}", toString(outerModsDocument));
            }

            return new DOMSource(outerModsDocument);

        } catch (Exception e) {

            LOGGER.info("Failed to parse JATS XML fragment", e);

            Document outerModsDocument = documentBuilder.newDocument();
            Element outerModsElement = outerModsDocument.createElementNS(MODS_NAMESPACE, "mods");
            outerModsDocument.appendChild(outerModsElement);

            if (LOGGER.isDebugEnabled()) {
                LOGGER.debug("outer MODS document: {}", toString(outerModsDocument));
            }

            return new DOMSource(outerModsDocument);

        }

    }

    private static String toHtmlString(NodeList nodeList) throws Exception {

        StringBuilder builder = new StringBuilder();

        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        Transformer transformer = transformerFactory.newTransformer();
        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
        transformer.setOutputProperty(OutputKeys.METHOD, "xml");

        for (int i = 0; i < nodeList.getLength(); i++) {
            Node node = nodeList.item(i);
            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(node), new StreamResult(writer));
            builder.append(writer);
        }

        String xmlString = builder.toString();

        // fix wrongful double escaping provided by some publishers
        xmlString = xmlString.replace("&amp;lt;", "&lt;");
        xmlString = xmlString.replace("&amp;gt;", "&gt;");
        xmlString = xmlString.replace("&amp;amp;", "&amp;");

        return xmlString;

    }

    private static String toXmlString(Document document) throws Exception {

        StringBuilder builder = new StringBuilder();

        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        Transformer transformer = transformerFactory.newTransformer();
        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
        transformer.setOutputProperty(OutputKeys.METHOD, "xml");

        StringWriter writer = new StringWriter();
        transformer.transform(new DOMSource(document), new StreamResult(writer));
        builder.append(writer);

        return builder.toString();

    }

    public static Document transform(MCRContent content, String transformerId) throws Exception {
        MCRContentTransformer transformer = MCRContentTransformerFactory.getTransformer(transformerId);
        if (transformer == null) {
            throw new MCRConfigurationException("Content transformer " + transformerId + " is not configured, set "
                + "MCR.ContentTransformer." + transformerId + ".Stylesheet or .Class");
        }
        MCRContent result = transformer.transform(content);
        return getDocumentBuilder().parse(result.getInputSource());
    }

    private static DocumentBuilder getDocumentBuilder() {
        try {
            DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
            documentBuilderFactory.setNamespaceAware(true);
            return documentBuilderFactory.newDocumentBuilder();
        } catch (Exception e) {
            throw new MCRException("Failed to create document builder", e);
        }
    }

    private static String getRandomRepGroup() {
        return UUID.randomUUID().toString().substring(16);
    }

    private static String toString(Document document) {
        try {
            Transformer transformer = TransformerFactory.newInstance().newTransformer();
            StreamResult result = new StreamResult(new StringWriter());
            DOMSource source = new DOMSource(document);
            transformer.transform(source, result);
            return result.getWriter().toString();
        } catch (Exception e) {
            throw new MCRException("Failed to create string representation of XML document", e);
        }
    }

}
