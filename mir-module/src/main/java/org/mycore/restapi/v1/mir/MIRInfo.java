/**
 * 
 */
package org.mycore.restapi.v1.mir;

import java.util.Map;
import java.util.Properties;
import java.util.stream.Collectors;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import org.mycore.common.MCRCoreVersion;
import org.mycore.frontend.jersey.MCRStaticContent;
import org.mycore.mir.common.MIRCoreVersion;

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
