package org.mycore.mir.it.tests;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Locale;
import java.util.Optional;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

/**
 * Minimal stand in for the Lobid GND search (<code>https://lobid.org/gnd/search</code>), so the integration tests
 * do not depend on the availability of lobid.org.
 * <p>
 * The application under test is configured to send its GND searches to this stub via the property
 * <code>MIR.Lobid.GND.Search.URL</code>. The stub answers every request on <code>/gnd/search</code> with the
 * fixture <code>lobid/gnd/{slug}.json</code> from the test classpath, where <code>{slug}</code> is the value of the
 * query parameter <code>q</code> in lower case with every run of other characters than letters and digits replaced by
 * a single <code>-</code> (e.g. <code>Neumann, Kathleen</code> becomes <code>neumann-kathleen</code>). Unknown
 * queries get an empty result. All other query parameters like <code>filter</code> or <code>size</code> are ignored.
 */
public final class MIRLobidStub {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String CONTEXT = "/gnd/search";

    private static final String FIXTURE_FOLDER = "/lobid/gnd/";

    private static final byte[] EMPTY_RESULT = "{\"totalItems\":0,\"member\":[]}".getBytes(StandardCharsets.UTF_8);

    private final HttpServer server;

    private MIRLobidStub(HttpServer server) {
        this.server = server;
    }

    /**
     * Starts the stub on the given host and port.
     *
     * @param host the host name or address to bind to
     * @param port the port to bind to
     * @return the running stub
     * @throws IOException if the port can not be bound
     */
    public static MIRLobidStub start(String host, int port) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(host, port), 0);
        server.createContext(CONTEXT, MIRLobidStub::handle);
        server.start();
        LOGGER.info("Lobid stub listening on http://{}:{}{}", host, port, CONTEXT);
        return new MIRLobidStub(server);
    }

    /**
     * Stops the stub immediately.
     */
    public void stop() {
        server.stop(0);
    }

    private static void handle(HttpExchange exchange) throws IOException {
        try (exchange) {
            String query = getQueryParameter(exchange.getRequestURI().getRawQuery(), "q").orElse("");
            String fixture = FIXTURE_FOLDER + toSlug(query) + ".json";
            byte[] body;
            try (InputStream fixtureStream = MIRLobidStub.class.getResourceAsStream(fixture)) {
                if (query.isBlank()) {
                    // the editor tools already search with an empty term when their search options are set on mount
                    body = EMPTY_RESULT;
                } else if (fixtureStream == null) {
                    LOGGER.warn("No Lobid fixture {} for query '{}', returning empty result.", fixture, query);
                    body = EMPTY_RESULT;
                } else {
                    LOGGER.info("Answering Lobid query '{}' with fixture {}.", query, fixture);
                    body = fixtureStream.readAllBytes();
                }
            }
            // the browser calls the stub from the origin of the application under test
            exchange.getResponseHeaders().add("Access-Control-Allow-Origin", "*");
            exchange.getResponseHeaders().add("Content-Type", "application/json; charset=UTF-8");
            exchange.sendResponseHeaders(200, body.length);
            try (OutputStream responseBody = exchange.getResponseBody()) {
                responseBody.write(body);
            }
        }
    }

    private static Optional<String> getQueryParameter(String rawQuery, String name) {
        if (rawQuery == null) {
            return Optional.empty();
        }
        return Arrays.stream(rawQuery.split("&"))
            .map(parameter -> parameter.split("=", 2))
            .filter(parameter -> parameter.length == 2 && name.equals(parameter[0]))
            .map(parameter -> URLDecoder.decode(parameter[1], StandardCharsets.UTF_8))
            .findFirst();
    }

    private static String toSlug(String query) {
        return query.toLowerCase(Locale.ROOT)
            .replaceAll("[^\\p{L}\\p{N}]+", "-")
            .replaceAll("^-|-$", "");
    }
}
