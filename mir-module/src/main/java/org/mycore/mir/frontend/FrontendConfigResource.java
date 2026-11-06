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
