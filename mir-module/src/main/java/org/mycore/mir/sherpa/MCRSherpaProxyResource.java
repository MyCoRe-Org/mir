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

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Optional;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.config.MCRConfiguration2;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("sherpa/")
public class MCRSherpaProxyResource {

    private static final Logger LOGGER = LogManager.getLogger();
    public static final String MIR_SHERPA_CONFIG_KEY = "MIR.Sherpa";

    @Path("retrieve/{type}/")
    @Produces(MediaType.APPLICATION_JSON)
    @GET
    public Response retrieve(@PathParam("type") String type, @QueryParam("filter") String filter){
        Optional<MCRSherpaConfig> configOpt
            = MCRConfiguration2.getSingleInstanceOf(MCRSherpaConfig.class, MIR_SHERPA_CONFIG_KEY);

        if(configOpt.isEmpty()){
            LOGGER.error("MIR.Sherpa property is not set!");
            return Response.serverError().build();
        }

        MCRSherpaConfig sherpaConfig = configOpt.get();

        String apiKey = sherpaConfig.getApiKey();
        String apiUrl = sherpaConfig.getApiUrl();

        String urlStr = apiUrl + "cgi/retrieve/?item-type=" + type + "&api-key=" + apiKey + "&format=Json";
        if(filter!=null){
            urlStr+="&filter="+filter;
        }
        try {
            URL url = new URI(urlStr).toURL();
            try (InputStream is = url.openStream(); ByteArrayOutputStream bos = new ByteArrayOutputStream()) {
                is.transferTo(bos);
                return Response.ok(bos.toByteArray()).build();
            } catch (IOException e) {
                LOGGER.error("Error while performing request!", e);
                return Response.serverError().build();
            }
        } catch (MalformedURLException | URISyntaxException e) {
            LOGGER.error("Error while building URL " + urlStr, e);
            return Response.serverError().build();
        }
    }

}
