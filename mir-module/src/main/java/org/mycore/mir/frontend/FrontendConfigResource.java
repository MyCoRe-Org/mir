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

/**
 * Provides access to selected  configuration properties for use in the frontend.
 * <p>
 * The properties made available to the frontend are defined by the comma-separated
 * list of property keys in {@code MIR.Frontend.Config.Keys}. For each key, the
 * corresponding property value is retrieved from the MIR configuration and returned
 * as a JSON object containing the property keys and their values.
 * <p>
 * This allows frontend code, such as TypeScript modules, to access configuration
 * properties directly at runtime instead of having to pass them through XSL
 * transformations.
 */

package org.mycore.mir.frontend;

import java.util.LinkedHashMap;
import java.util.Map;

import org.mycore.common.config.MCRConfiguration2;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/frontend-config")
public class FrontendConfigResource {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Map<String, String> get() {
        Map<String, String> result = new LinkedHashMap<>();
        MCRConfiguration2.getString("MIR.Frontend.Config.Keys").ifPresent(keys -> {
            for (String key : keys.split(",")) {
                String k = key.trim();
                MCRConfiguration2.getString(k).ifPresent(v -> result.put(k, v));
            }
        });
        return result;
    }
}
