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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.Normalizer;
import java.util.HashMap;
import java.util.Map;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import org.mycore.common.MCRException;
import org.mycore.common.xsl.uriresolver.MCRDecodeFromURIURIResolver;
import org.mycore.common.xsl.uriresolver.MCRURIResolverResponse;
import org.mycore.resource.MCRResourceHelper;

/**
 * A {@link MIRPrepareForPersonIndexURIResolver} is a {@link URIResolver} that accepts an URL-encoded
 * string, reverses what the built-in XSLT-function <code>encode-for-uri</code> does,
 * creates a simplified version of that string (lowercase, without accents and diacritics), to be used
 * for search terms of the person index, and returns it as a <code>string</code>-element using
 * {@link MCRURIResolverResponse#ofString(String)}.
 */
public final class MIRPrepareForPersonIndexURIResolver implements URIResolver {

    private static final String REPLACEMENTS_PATH = "personIndexPreparationReplacements";

    private static final Map<Character, String> REPLACEMENTS = new HashMap<>();

    static {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(
            MCRResourceHelper.getResourceAsStream(REPLACEMENTS_PATH)))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.isEmpty()) {
                    if (line.length() < 2 || line.charAt(1) != ':') {
                        throw new MCRException("Invalid replacement in resource " + REPLACEMENTS_PATH + ": " + line);
                    }
                    REPLACEMENTS.put(line.charAt(0), line.substring(2));
                }
            }
        } catch (IOException e) {
            throw new MCRException("Failed to load replacements", e);
        }
    }

    /**
     * Resolves the given URI by URL-decoding and simplifying the provided value
     * <p>URI Syntax:
     * <pre>
     *   &lt;scheme&gt;:&lt;url-encoded-value&gt;
     * </pre>
     * <p>Example request:
     * <pre>
     *   decodeFromUri:%E1%B8%BEustermann%2C%20%E1%B8%BEax
     * </pre>
     * <p>Example response:
     * <pre>{@code
     *   <string>
     *     mustermann, max
     *   </string>
     * }</pre>
     *
     * @param href the URI in the syntax above to resolve
     * @param base the base URI of the calling stylesheet (unused)
     * @return a {@link Source} wrapping the URL-decoded value
     */
    @Override
    public Source resolve(String href, String base) throws TransformerException {

        String encodedValue = href.substring(href.indexOf(':') + 1);
        String string = MCRDecodeFromURIURIResolver.decode(encodedValue, false);

        return MCRURIResolverResponse.ofString(prepareForPersonIndex(string));

    }

    /**
     * Creates a simplified version of a string (lowercase, without accents and diacritics), to be used
     * for search terms of the person index.
     * @param string the string
     * @return the simplified string
     */
    public static String prepareForPersonIndex(String string) {

        if (string == null) {
            return null;
        }

        StringBuilder builder = new StringBuilder();
        String normalizedString = Normalizer.normalize(string, Normalizer.Form.NFKD);
        for (final char character : normalizedString.toCharArray()) {
            Character.UnicodeBlock block = Character.UnicodeBlock.of(character);
            if (block == Character.UnicodeBlock.COMBINING_DIACRITICAL_MARKS) {
                continue;
            }
            Character lowerCaseCharacter = Character.toLowerCase(character);
            String replacement = REPLACEMENTS.get(lowerCaseCharacter);
            if (replacement != null) {
                builder.append(replacement);
            } else {
                builder.append(lowerCaseCharacter);
            }
        }

        return builder.toString();

    }

}
