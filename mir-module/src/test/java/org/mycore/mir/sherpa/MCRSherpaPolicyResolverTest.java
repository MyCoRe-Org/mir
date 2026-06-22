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

import java.nio.charset.StandardCharsets;

import org.jdom2.Element;
import org.junit.jupiter.api.Test;

class MCRSherpaPolicyResolverTest {

    @Test
    void parseExtractsPermittedOa() throws Exception {
        String json = new String(
            getClass().getResourceAsStream("/MCRSherpaPolicyResolverTest/example.json").readAllBytes(),
            StandardCharsets.UTF_8);
        Element sherpa = new MCRSherpaPolicyResolver().parse(json, "1178-9905");

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
}
