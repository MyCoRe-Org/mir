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

package org.mycore.mir.migration;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;
import java.util.List;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.junit.jupiter.api.Test;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRStreamContent;
import org.mycore.common.content.transformer.MCRContentTransformer;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.common.xml.MCRXMLHelper;
import org.mycore.resource.MCRResourceHelper;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIRFundingMigrationTest {

    private static final Namespace DATACITE_NAMESPACE
        = Namespace.getNamespace("datacite", "http://datacite.org/schema/kernel-4");

    private static final String XPATH_DATACITE_FUNDING_EXTENSION
        = "//mods:mods/mods:extension[@type='datacite-funding']";

    @Test
    public void shouldTransformValidInputToExpectedOutput() throws IOException, JDOMException {
        MCRContent input = loadContent("input.xml");
        MCRContentTransformer transformer = MCRContentTransformerFactory.getTransformer("migrate-openaire");
        Document result = transformer.transform(input).asXML();
        Document expected = loadContent("expected.xml").asXML();

        assertTrue(MCRXMLHelper.deepEqual(expected, result));
        assertTrue(isCleanDataciteFundingExtension(result));
    }

    @Test
    public void shouldThrowExceptionForInvalidInput() {
        final MCRContent input = loadContent("fail.xml");
        final MCRContentTransformer transformer = MCRContentTransformerFactory.getTransformer("migrate-openaire");
        assertThrows(MCRException.class, () -> transformer.transform(input).asXML());
    }

    private static MCRContent loadContent(String name) {
        return new MCRStreamContent(MCRResourceHelper.getResourceAsStream("/migration/funding/" + name));
    }

    private boolean isCleanDataciteFundingExtension(Document element) {
        List<Element> extensions = getElements(element.getRootElement(), XPATH_DATACITE_FUNDING_EXTENSION);
        if (extensions.size() != 1) {
            return false;
        }
        return extensions.getFirst().getAdditionalNamespaces().isEmpty();
    }

    public List<Element> getElements(Element element, String xPath) {
        return buildXPath(xPath).evaluate(element);
    }

    private XPathExpression<Element> buildXPath(String xPath) {
        return XPathFactory.instance().compile(xPath, Filters.element(), null, MCRConstants.MODS_NAMESPACE,
            MCRConstants.XLINK_NAMESPACE, DATACITE_NAMESPACE);
    }

}
