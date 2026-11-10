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

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import javax.xml.transform.TransformerException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.junit.jupiter.api.Test;
import org.mycore.common.util.MCRTestCaseXSLTUtil;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIRPrepareForPersonIndexURIResolverTest {

    private static final Logger LOGGER = LogManager.getLogger();

    public static final String COMBINING_TILDE = "\u0303";

    // Latin characters should be mapped to lowercase Latin base characters
    private static final Replacement LATIN_LETTER_A = new Replacement("A", "a");
    private static final Replacement LATIN_LETTER_A_WITH_TILDE = new Replacement("A" + COMBINING_TILDE, "a");
    private static final Replacement LATIN_LETTER_AE = new Replacement("Æ", "ae");
    private static final Replacement LATIN_LETTER_C_CEDILLA = new Replacement("Ç", "c");
    private static final Replacement LATIN_LETTER_D_WITH_STROKE = new Replacement("Đ", "d");
    private static final Replacement LATIN_LETTER_DZ = new Replacement("Ǳ", "dz");
    private static final Replacement LATIN_LETTER_I_WITH_STROKE = new Replacement("Ɨ", "i");
    private static final Replacement LATIN_LIGATURE_IJ = new Replacement("Ĳ", "ij");
    private static final Replacement LATIN_LETTER_L_WITH_STROKE = new Replacement("Ł", "l");
    private static final Replacement LATIN_LETTER_M_WITH_ACUTE = new Replacement("Ḿ", "m");
    private static final Replacement LATIN_LETTER_NJ = new Replacement("Ǌ", "nj");
    private static final Replacement LATIN_LETTER_O_WITH_STROKE = new Replacement("Ø", "o");
    private static final Replacement LATIN_LETTER_O_WITH_DIAERESIS = new Replacement("Ö", "o");
    private static final Replacement LATIN_LIGATURE_OE = new Replacement("Œ", "oe");
    private static final Replacement LATIN_LETTER_T_WITH_STROKE = new Replacement("Ŧ", "t");
    private static final Replacement LATIN_LETTER_U_WITH_BAR = new Replacement("Ʉ", "u");

    // Cyrillic characters should be mapped to lowercase Cyrillic base characters
    private static final Replacement CYRILLIC_LETTER_A = new Replacement("А", "а");
    private static final Replacement CYRILLIC_LETTER_A_WITH_TILDE = new Replacement("А" + COMBINING_TILDE, "а");
    private static final Replacement CYRILLIC_LETTER_ES_WITH_DESCENDER = new Replacement("Ҫ", "c");
    private static final Replacement CYRILLIC_LETTER_O_WITH_DIAERESIS = new Replacement("Ӧ", "о");

    // Greek characters should be mapped to lowercase Greek base characters
    private static final Replacement GREEK_LETTER_ALPHA = new Replacement("Α", "α");
    private static final Replacement GREEK_LETTER_ALPHA_WITH_TILDE = new Replacement("Α" + COMBINING_TILDE, "α");

    private static final List<Replacement> REPLACEMENTS = List.of(
        LATIN_LETTER_A,
        LATIN_LETTER_A_WITH_TILDE,
        LATIN_LETTER_AE,
        LATIN_LETTER_C_CEDILLA,
        LATIN_LETTER_D_WITH_STROKE,
        LATIN_LETTER_DZ,
        LATIN_LETTER_I_WITH_STROKE,
        LATIN_LIGATURE_IJ,
        LATIN_LETTER_L_WITH_STROKE,
        LATIN_LETTER_M_WITH_ACUTE,
        LATIN_LETTER_NJ,
        LATIN_LETTER_O_WITH_STROKE,
        LATIN_LETTER_O_WITH_DIAERESIS,
        LATIN_LIGATURE_OE,
        LATIN_LETTER_T_WITH_STROKE,
        LATIN_LETTER_U_WITH_BAR,
        CYRILLIC_LETTER_A,
        CYRILLIC_LETTER_A_WITH_TILDE,
        CYRILLIC_LETTER_ES_WITH_DESCENDER,
        CYRILLIC_LETTER_O_WITH_DIAERESIS,
        GREEK_LETTER_ALPHA,
        GREEK_LETTER_ALPHA_WITH_TILDE);

    @Test
    public void prepareForPersonIndex() throws TransformerException {

        String value = REPLACEMENTS.stream().map(Replacement::character).collect(Collectors.joining(" "));
        String expected = REPLACEMENTS.stream().map(Replacement::replacement).collect(Collectors.joining(" "));

        Map<String, Object> parameters = new HashMap<>();
        parameters.put("value", value);
        String stylesheet = "/xslt/mir/index/prepare-for-person-index.xsl";
        Element resultElement = MCRTestCaseXSLTUtil.transform(stylesheet, parameters).getRootElement();

        String prepared = resultElement.getChildText("prepared");

        LOGGER.info("{} -> {}", value, prepared);

        assertEquals(expected, prepared, "Wrong preparation");

    }

    private record Replacement(String character, String replacement) {
    }

}
