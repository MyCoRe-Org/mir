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

import java.util.List;
import java.util.regex.Pattern;

import org.mycore.common.config.MCRConfiguration2;

/**
 * Configuration of the alias feature.
 */
public final class MIRAliasConfig {

    private static final String PROPERTY_PREFIX = "MIR.Alias.";

    private static final String ENABLED_PROPERTY = PROPERTY_PREFIX + "Enabled";

    private static final String PREFIX_PROPERTY = PROPERTY_PREFIX + "Prefix";

    private static final String LAYOUT_FILE_PATTERN_PROPERTY = PROPERTY_PREFIX + "LayoutFilePattern";

    private static final boolean ENABLED = MCRConfiguration2.getOrThrow(ENABLED_PROPERTY, Boolean::parseBoolean);

    private static final List<String> PREFIXES =
        MCRConfiguration2.getString(PREFIX_PROPERTY).stream().flatMap(MCRConfiguration2::splitValue).toList();

    private static final Pattern LAYOUT_FILE_PATTERN =
        MCRConfiguration2.getOrThrow(LAYOUT_FILE_PATTERN_PROPERTY, Pattern::compile);

    private MIRAliasConfig() {
    }

    /**
     * @return whether the alias feature is enabled
     */
    public static boolean isEnabled() {
        return ENABLED;
    }

    /**
     * @return the URL prefixes the alias servlet is mapped to, e.g. <code>go</code>
     */
    public static List<String> getPrefixes() {
        return PREFIXES;
    }

    /**
     * @return the pattern of file names that are rendered via the layout service
     */
    public static Pattern getLayoutFilePattern() {
        return LAYOUT_FILE_PATTERN;
    }
}
