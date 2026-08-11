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
 * 
 */
package org.mycore.restapi.v1.mir;

import java.util.Map;
import java.util.Properties;
import java.util.stream.Collectors;

import org.mycore.common.MCRCoreVersion;
import org.mycore.frontend.jersey.MCRStaticContent;
import org.mycore.mir.common.MIRCoreVersion;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

/**
 * @author Thomas Scheffler (yagee)
 *
 */
@Path("/v1/mir")
@MCRStaticContent
public class MIRInfo {

    @GET
    @Path("version")
    @Produces({ MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML })
    public Properties getGitInfos() {
        Properties properties = new Properties();
        properties.putAll(MCRCoreVersion.getVersionProperties().entrySet().stream()
            .collect(Collectors.toMap(e -> "mycore." + e.getKey(), Map.Entry::getValue)));
        properties.putAll(MIRCoreVersion.getVersionProperties().entrySet().stream()
            .collect(Collectors.toMap(e -> "mir." + e.getKey(), Map.Entry::getValue)));
        return properties;
    }
}
