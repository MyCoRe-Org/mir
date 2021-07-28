package org.mycore.mir;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.frontend.MCRFrontendUtil;

public class MIRGetOpenAIREProjectsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static Logger LOGGER = LogManager.getLogger();

    private CloseableHttpClient client;

    @Override
    public void init() throws ServletException {
        PoolingHttpClientConnectionManager connectManager = new PoolingHttpClientConnectionManager();
        connectManager.setDefaultMaxPerRoute(20);
        client = HttpClients.custom().setConnectionManager(connectManager).build();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String name = MCRFrontendUtil.getProperty(request, "name").orElse(null);
        String acronym = MCRFrontendUtil.getProperty(request, "acronym").orElse(null);
        String suffix = name != null && !name.isEmpty() ? "name=" + URLEncoder.encode(name, "UTF-8")
            : "acronym=" + URLEncoder.encode(acronym, "UTF-8");
        String urlString = "http://api.openaire.eu/search/projects?" + suffix;

        HttpGet method = new HttpGet(urlString);
        try (CloseableHttpResponse httpRes = client.execute(method)) {
            response.setStatus(httpRes.getStatusLine().getStatusCode());
            HttpEntity entity = httpRes.getEntity();
            try (InputStream contentStream = entity.getContent()) {
                IOUtils.copy(contentStream, response.getOutputStream());
            }
        } catch (IOException e) {
            LOGGER.error("Failed to load " + urlString, e);
        }
    }

    @Override
    public void destroy() {
        try {
            client.close();
        } catch (IOException e) {
            LOGGER.error("Could not close HttpClient!", e);
        }
    }
}
