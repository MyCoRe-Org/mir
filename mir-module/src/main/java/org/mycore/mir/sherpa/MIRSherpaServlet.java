package org.mycore.mir.sherpa;

import static org.mycore.solr.MCRSolrConstants.SOLR_CONFIG_PREFIX;

import java.io.IOException;
import java.io.InputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.core.Response;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathFactory;

import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.protocol.HTTP;
import org.apache.log4j.Logger;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.mycore.services.http.MCRHttpUtils;
import org.mycore.services.http.MCRIdleConnectionMonitorThread;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class MIRSherpaServlet extends MCRServlet {

    static final Logger LOGGER = Logger.getLogger(MIRSherpaServlet.class);

    private static final long serialVersionUID = 1L;

    private static final String SERVER_URL = "http://www.sherpa.ac.uk/romeo/api29.php";

    private static final int MAX_CONNECTIONS = MCRConfiguration2.getOrThrow(
        SOLR_CONFIG_PREFIX + "SelectProxy.MaxConnections",
        Integer::parseInt);

    private HttpHost sherpaHost;

    private PoolingHttpClientConnectionManager httpClientConnectionManager;

    private CloseableHttpClient httpClient;

    private MCRIdleConnectionMonitorThread idleConnectionMonitorThread;

    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        HttpServletRequest req = job.getRequest();
        HttpServletResponse res = job.getResponse();

        String issn = req.getParameter("issn");
        String apiKey = MCRConfiguration2.getString("MCR.Mods.SherpaRomeo.ApiKey").orElse("");
        HttpGet httpGet;
        if (apiKey.equals("")) {
            httpGet = new HttpGet(SERVER_URL + "?issn=" + issn);
        } else {
            httpGet = new HttpGet(SERVER_URL + "?issn=" + issn + "&ak=" + apiKey);
        }
        try {
            CloseableHttpResponse response = httpClient.execute(sherpaHost, httpGet);
            int statusCode = response.getStatusLine().getStatusCode();
            if (statusCode == Response.Status.OK.getStatusCode()) {
                boolean isXML = response.getFirstHeader(HTTP.CONTENT_TYPE).getValue().contains("/xml");
                if (isXML) {
                    HttpEntity responseEntity = response.getEntity();
                    if (responseEntity != null) {
                        InputStream responseStream = responseEntity.getContent();
                        Document doc = getDocumentFromInputStream(responseStream);
                        XPath xpath = XPathFactory.newInstance().newXPath();
                        String outcome = (String) xpath.evaluate("//outcome", doc, XPathConstants.STRING);
                        if (!outcome.equals("failed")) {
                            String romeocolour = (String) xpath.evaluate("//romeocolour", doc, XPathConstants.STRING);
                            res.setStatus(HttpServletResponse.SC_OK);
                            res.getWriter().write(romeocolour);
                            res.getWriter().flush();
                            res.getWriter().close();
                            return;
                        }
                    }
                }
                res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                return;
            }
            res.setStatus(statusCode);
        } catch (IOException ex) {
            ex.printStackTrace();
            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private Document getDocumentFromInputStream(InputStream in)
        throws ParserConfigurationException, IOException, SAXException {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        return builder.parse(new InputSource(in));
    }

    @Override
    public void init() throws ServletException {
        super.init();
        LOGGER.info("Initializing Sherpa connection to \"" + SERVER_URL + "\"");

        sherpaHost = MCRHttpUtils.getHttpHost(SERVER_URL);
        if (sherpaHost == null) {
            throw new ServletException("URI does not specify a valid host name: " + SERVER_URL);
        }
        httpClientConnectionManager = MCRHttpUtils.getConnectionManager(MAX_CONNECTIONS);
        httpClient = MCRHttpUtils.getHttpClient(httpClientConnectionManager, MAX_CONNECTIONS);

        // start thread to monitor stalled connections
        idleConnectionMonitorThread = new MCRIdleConnectionMonitorThread(httpClientConnectionManager);
        idleConnectionMonitorThread.start();
    }

    @Override
    public void destroy() {
        idleConnectionMonitorThread.shutdown();
        try {
            httpClient.close();
        } catch (IOException e) {
            LOGGER.info("Could not close HTTP client to Sherpa server.", e);
        }
        httpClientConnectionManager.shutdown();
        super.destroy();
    }
}
