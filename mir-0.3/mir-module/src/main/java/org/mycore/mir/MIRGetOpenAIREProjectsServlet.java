package org.mycore.mir;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;

import org.apache.commons.io.IOUtils;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.log4j.Logger;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;

public class MIRGetOpenAIREProjectsServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static Logger LOGGER = Logger.getLogger(MIRGetOpenAIREProjectsServlet.class);

    private CloseableHttpClient client;

    @Override
    public void init() throws ServletException {
        PoolingHttpClientConnectionManager connectManager = new PoolingHttpClientConnectionManager();
        client = HttpClients.custom().setConnectionManager(connectManager).build();
    }

    @Override
    protected void think(MCRServletJob job) throws Exception {
        HttpServletResponse response = job.getResponse();
        HttpServletRequest request = job.getRequest();

        String name = getProperty(request, "name");
        String acronym = getProperty(request, "acronym");
        String suffix = name != null && !name.isEmpty() ? "name=" + URLEncoder.encode(name, "UTF-8") : "acronym="
                + URLEncoder.encode(acronym, "UTF-8");
        String urlString = "http://api.openaire.eu/search/projects?" + suffix;

        try {
            HttpGet method = new HttpGet(urlString);
            HttpResponse httpRes = client.execute(method);
            response.setStatus(httpRes.getStatusLine().getStatusCode());

            HttpEntity entity = httpRes.getEntity();
            IOUtils.copy(entity.getContent(), response.getOutputStream());
        } catch (IOException e) {
            LOGGER.error("Failed to load " + urlString, e);
        }
    }

    @Override
    protected void render(MCRServletJob job, Exception ex) throws Exception {
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