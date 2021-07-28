package org.mycore.mir.orcid;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.stream.Collectors;

import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletResponse;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.filter.Filters;
import org.jdom2.input.SAXBuilder;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.common.MCRException;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;

import com.google.gson.Gson;

public class MIROrcidServlet extends MCRServlet {

    private static final String ORCID_URL = "https://orcid.org/";

    private static final String ORCID_API_URL = "https://pub.orcid.org/";

    private static final String ORCID_REQUEST_BASE = ORCID_API_URL + "v2.0/";

    private static final int ORCID_FETCH_SIZE = 5;

    private static final int TIMEOUT_IN_SECONDS = 5;

    private static final Namespace ORCID_SEARCH_NAMESPACE = Namespace.getNamespace("search",
        "http://www.orcid.org/ns/search");

    private static final Namespace ORCID_PERSONAL_DETAILS_NAMESPACE = Namespace
        .getNamespace("personal-details", "http://www.orcid.org/ns/personal-details");

    private static final Namespace ORCID_COMMON_NAMESPACE = Namespace.getNamespace("common",
        "http://www.orcid.org/ns/common");

    private static final String SEARCH_ORCID_XPATH = "/search:search/search:result/common:orcid-identifier/common:path";

    private static List<MIROrcidPersonEntry> getPersonList(String query)
        throws MalformedURLException, UnsupportedEncodingException {
        String encodedQuery = URLEncoder.encode(query, "UTF-8");

        URL url = new URL(ORCID_REQUEST_BASE + "search/?q=" + encodedQuery + "&rows=" + ORCID_FETCH_SIZE * 2);

        try {
            Document document = new SAXBuilder().build(url);
            List<String> orcids = getOrcidsFromDocument(document);
            return orcids.stream()
                .parallel()
                .map((orcid) -> CompletableFuture.supplyAsync(() -> getEntry(orcid)))
                .map(MIROrcidServlet::getWithTimeout)
                .filter(Objects::nonNull)
                .limit(ORCID_FETCH_SIZE)
                .collect(Collectors.toList());
        } catch (IOException | JDOMException e) {

            throw new MCRException(e);
        }
    }

    private static List<String> getOrcidsFromDocument(Document document) {
        XPathExpression<Element> orchidXpath = XPathFactory.instance()
            .compile(SEARCH_ORCID_XPATH, Filters.element(), null, ORCID_SEARCH_NAMESPACE, ORCID_COMMON_NAMESPACE);
        return orchidXpath
            .evaluate(document)
            .stream()
            .map(Element::getTextTrim)
            .collect(Collectors.toList());
    }

    private static MIROrcidPersonEntry getEntry(String orcid) {
        try {
            URL url = new URL(ORCID_REQUEST_BASE + orcid + "/personal-details");
            Document document = new SAXBuilder().build(url);
            Element element = document.getRootElement();

            Element name = element.getChild("name", ORCID_PERSONAL_DETAILS_NAMESPACE);
            if (name == null) {
                return null;
            }

            Element givenName = name.getChild("given-names", ORCID_PERSONAL_DETAILS_NAMESPACE);
            Element familyName = name.getChild("family-name", ORCID_PERSONAL_DETAILS_NAMESPACE);

            if (givenName == null || familyName == null) {
                return null;
            }

            return new MIROrcidPersonEntry(givenName.getTextTrim(), familyName.getTextTrim(), ORCID_URL + orcid);
        } catch (JDOMException | IOException e) {
            throw new MCRException(e);
        }
    }

    private static MIROrcidPersonEntry getWithTimeout(CompletableFuture<MIROrcidPersonEntry> future) {
        try {
            return future.get(TIMEOUT_IN_SECONDS, TimeUnit.SECONDS);
        } catch (InterruptedException | ExecutionException | TimeoutException e) {
            throw new MCRException(e);
        }
    }

    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        String query = job.getRequest().getParameter("q");
        List<MIROrcidPersonEntry> personList = getPersonList(query);

        String json = new Gson().toJson(personList);

        HttpServletResponse resp = job.getResponse();
        ServletOutputStream outputStream = resp.getOutputStream();
        resp.setContentType("application/json");
        outputStream.print(json);
        outputStream.flush();
        outputStream.close();
    }

    public static class MIROrcidPersonEntry {
        public String term;

        public String value;

        public String forename;

        public String sureName;

        public String label;

        public String type;

        public MIROrcidPersonEntry(String givenName, String familyName, String value) {
            this.forename = givenName;
            this.sureName = familyName;
            this.term = familyName + ", " + givenName;
            this.value = value;
            this.label = this.term;
            this.type = "personal";
        }
    }
}
