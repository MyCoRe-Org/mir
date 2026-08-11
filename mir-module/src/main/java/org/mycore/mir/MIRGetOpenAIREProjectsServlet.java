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
