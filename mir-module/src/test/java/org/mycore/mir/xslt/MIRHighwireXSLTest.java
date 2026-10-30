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

package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.util.Map;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.Namespace;
import org.junit.jupiter.api.Test;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIRHighwireXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/mir/object-page/head/highwire-test.xsl";

    private static final Namespace XLINK = Namespace.getNamespace("xlink", "http://www.w3.org/1999/xlink");

    private static final String FILE_URL = "https://example.org/servlets/MCRFileNodeServlet/mir_derivate_00000001/";

    @Test
    void testPdfMainDocument() throws Exception {
        assertEquals(FILE_URL + "article.pdf", citationPdfUrl("article.pdf"));
    }

    @Test
    void testExtensionIsCaseInsensitive() throws Exception {
        assertEquals(FILE_URL + "article.PDF", citationPdfUrl("article.PDF"));
    }

    @Test
    void testPathIsEncoded() throws Exception {
        assertEquals(FILE_URL + "sub%20dir/my%20article.pdf", citationPdfUrl("/sub dir/my article.pdf"));
    }

    @Test
    void testOtherFileTypeIsIgnored() throws Exception {
        assertNull(citationPdfUrl("index.xml"));
    }

    @Test
    void testMissingMainDocumentIsIgnored() throws Exception {
        assertNull(citationPdfUrl(""));
    }

    private String citationPdfUrl(String maindoc) throws Exception {
        Element derobject = new Element("derobject")
            .setAttribute("href", "mir_derivate_00000001", XLINK)
            .addContent(new Element("maindoc").setText(maindoc));
        Document result = transformDocument(new Document(derobject), XSL,
            Map.of("ServletsBaseURL", "https://example.org/servlets/"));
        Element meta = result.getRootElement().getChild("meta");
        return meta == null ? null : meta.getAttributeValue("content");
    }
}
