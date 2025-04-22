package org.mycore.mir;

import java.io.IOException;
import java.io.InputStream;
import java.io.Serial;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.services.http.MCRHttpUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class MIRGetOpenAIREProjectsServlet extends HttpServlet {

    @Serial
    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = LogManager.getLogger();

    private HttpClient client;

    @Override
    public void init() throws ServletException {
        client = MCRHttpUtils.getHttpClient();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String name = MCRFrontendUtil.getProperty(request, "name").orElse(null);
        String acronym = MCRFrontendUtil.getProperty(request, "acronym").orElse(null);
        String suffix = name != null && !name.isEmpty() ? "name=" + URLEncoder.encode(name, "UTF-8")
            : "acronym=" + URLEncoder.encode(acronym, "UTF-8");
        String urlString = "http://api.openaire.eu/search/projects?" + suffix;

        HttpRequest openaireRequest = MCRHttpUtils.getRequestBuilder()
            .uri(URI.create(urlString))
            .build();
        boolean transmitted = false;
        try {
            HttpResponse<InputStream> openaireResponse = client
                .send(openaireRequest, HttpResponse.BodyHandlers.ofInputStream());
            response.setStatus(openaireResponse.statusCode());
            try (InputStream contentStream = openaireResponse.body()) {
                contentStream.transferTo(response.getOutputStream());
                transmitted = true;
            }
        } catch (InterruptedException e) {
            throw new ServletException(e);
        } finally {
            if (!transmitted) {
                LOGGER.error("Error while loading eternal resource: " + openaireRequest.uri());
            }
        }
    }

    @Override
    public void destroy() {
        client.close();
    }
}
