/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
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

package org.mycore.mir.sherpa;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.zip.GZIPOutputStream;

import org.jdom2.Element;
import org.junit.jupiter.api.Test;

class MCRSherpaPolicyResolverTest {

    @Test
    void parseExtractsPermittedOa() throws Exception {
        Element sherpa = new MCRSherpaPolicyResolver().parse(readResource("example.json"), "1178-9905");

        assertEquals("1178-9905", sherpa.getAttributeValue("issn"));
        Element item = sherpa.getChild("item");
        assertEquals("Zoosymposia", item.getChildText("title"));
        assertEquals("Magnolia Press", item.getChildText("publisher"));
        assertEquals("https://v2.sherpa.ac.uk/id/publication/5", item.getChildText("sherpaURL"));

        Element permitted = item.getChild("publisherPolicy").getChild("permittedOA");
        assertEquals("published", permitted.getChild("articleVersion").getChildText("value"));
        assertEquals("non_commercial_website", permitted.getChild("location").getChildText("value"));
        assertEquals("yes", permitted.getChildText("additionalFee"));
        assertEquals("CC BY-NC", permitted.getChild("license").getChildText("value"));
    }

    @Test
    void parseKeepsPolicyWithoutPermittedOa() throws Exception {
        Element sherpa = new MCRSherpaPolicyResolver().parse(readResource("oa-prohibited.json"), "2731-0582");

        Element item = sherpa.getChild("item");
        assertNotNull(item, "policies without permitted OA routes have to be kept");
        assertEquals("Journal of Closed Access", item.getChildText("title"));

        Element policy = item.getChild("publisherPolicy");
        assertEquals("yes", policy.getChildText("openAccessProhibited"));
        assertEquals("Copyright and Permissions", policy.getChildText("policyURL"));
        assertEquals("https://example.org/journal/copyright", policy.getChild("policyURL").getAttributeValue("href"));
        assertTrue(policy.getChildren("permittedOA").isEmpty());
    }

    @Test
    void decodeBodyHandlesGzip() throws Exception {
        String json = readResource("example.json");
        ByteArrayOutputStream compressed = new ByteArrayOutputStream();
        try (GZIPOutputStream gzip = new GZIPOutputStream(compressed)) {
            gzip.write(json.getBytes(StandardCharsets.UTF_8));
        }
        byte[] plain = json.getBytes(StandardCharsets.UTF_8);

        assertEquals(json, MCRSherpaPolicyResolver.decodeBody(compressed.toByteArray(), "gzip"));
        // the API compresses even without an announced Content-Encoding
        assertEquals(json, MCRSherpaPolicyResolver.decodeBody(compressed.toByteArray(), null));
        assertEquals(json, MCRSherpaPolicyResolver.decodeBody(plain, null));
        assertEquals(json, MCRSherpaPolicyResolver.decodeBody(plain, "identity"));
    }

    private static String readResource(String name) throws IOException {
        String path = "/MCRSherpaPolicyResolverTest/" + name;
        try (InputStream resource = MCRSherpaPolicyResolverTest.class.getResourceAsStream(path)) {
            assertNotNull(resource, "Missing test resource " + path);
            return new String(resource.readAllBytes(), StandardCharsets.UTF_8);
        }
    }
}
