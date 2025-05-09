package org.mycore.mir.mimetype;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.config.MCRConfigurationException;
import org.mycore.frontend.jersey.MCRStaticContent;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.stream.Collectors;

/**
 * Jersey resource that provides MIME type mappings as a JSON object.
 * The mapping file path is configured via the property key {@code MIR.Mimetype.Mapping.List.Filename}.
 *
 * <p>
 * Example usage:
 * <pre>
 *   GET /rsc/mimetypeMappingList/get
 *   Accept: application/json
 * </pre>
 * </p>
 *
 * @see <a href="https://mycore.de">MyCoRe Documentation</a>
 */
@Path("mimetypeMappingList")
@MCRStaticContent
public class MimetypeMappingResource {

    // Path to the MIME type mapping file, loaded from mycore.properties
    private static final String MAPPING_FILE_PATH = MCRConfiguration2.getString("MIR.Mimetype.Mapping.List.Filename")
        .orElseThrow(() -> new MCRConfigurationException("MIR.Mimetype.Mapping.List.Filename not set"));

    /**
     * Serves the MIME type mapping JSON file as a response.
     *
     * @return HTTP 200 with JSON content if successful, 404 if not found, or 500 on error.
     */
    @GET
    @Path("get")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getMimetypeMapping() {
        try (InputStream inputStream = getClass().getResourceAsStream(MAPPING_FILE_PATH)) {

            if (inputStream == null) {
                return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\":\"Mapping file not found at " + MAPPING_FILE_PATH + "\"}")
                    .build();
            }

            String jsonContent = new BufferedReader(
                new InputStreamReader(inputStream, StandardCharsets.UTF_8))
                .lines()
                .collect(Collectors.joining("\n"));

            return Response.ok(jsonContent, MediaType.APPLICATION_JSON).build();

        } catch (IOException e) {
            return Response.serverError()
                .entity("{\"error\":\"Could not read mapping file: " + e.getMessage() + "\"}")
                .build();
        }
    }
}
