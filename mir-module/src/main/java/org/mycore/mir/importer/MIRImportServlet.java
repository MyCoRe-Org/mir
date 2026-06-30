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

package org.mycore.mir.importer;

import java.io.Serial;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.xsl.uriresolver.MCRURIResolver;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.mods.MCRMODSWrapper;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Intercepts the metadata import before the editor is opened and checks whether the object that is
 * about to be imported is a possible duplicate of an already existing object.
 * <p>
 * The import forms (see {@code content/publish/index.xml} and {@code content/publish/importPPN.xml})
 * submit to this servlet instead of opening the editor directly. The servlet
 * <ol>
 *   <li>builds the {@code mycoreobject} from the imported metadata (identifier lookup in external
 *       databases) and stores it in the current session under a generated key,</li>
 *   <li>asks the deduplication component (via {@code dedup:duplicates-for-session:{key}}) for existing
 *       objects sharing a deduplication key,</li>
 *   <li>if none are found, redirects straight to the editor, loading the cached object from the
 *       session ({@code session:{key}}),</li>
 *   <li>otherwise renders a confirmation page listing the possible duplicates. Only when the user
 *       explicitly confirms that none of them is a duplicate the editor is opened.</li>
 * </ol>
 * If no identifier is given (the user only chose a publication type) the servlet transparently
 * forwards to the editor, so the import check only applies to actual imports.
 */
public class MIRImportServlet extends MCRServlet {

    @Serial
    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = LogManager.getLogger();

    /** Prefix of the session key the imported object is cached under. */
    public static final String SESSION_KEY_PREFIX = "mir.import.";

    private static final String DEFAULT_EDITOR = "editor-dynamic";

    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        HttpServletRequest request = job.getRequest();
        HttpServletResponse response = job.getResponse();

        String editor = orDefault(request.getParameter("editor"), DEFAULT_EDITOR);
        String genre = request.getParameter("genre");
        String host = request.getParameter("host");
        String baseURL = MCRFrontendUtil.getBaseURL(request);

        // Phase 2: the user confirmed that none of the possible duplicates is a real duplicate.
        if (Boolean.parseBoolean(request.getParameter("confirmed"))) {
            String sessionKey = request.getParameter("sessionKey");
            if (sessionKey == null || MCRSessionMgr.getCurrentSession().get(sessionKey) == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown or expired import session key");
                return;
            }
            response.sendRedirect(response.encodeRedirectURL(editorURL(baseURL, editor, sessionKey, genre, host)));
            return;
        }

        String modsId = request.getParameter("modsId");
        String type = request.getParameter("type");

        // No identifier given: nothing to import or check, proceed to the editor as before.
        if (modsId == null || modsId.isBlank()) {
            response.sendRedirect(response.encodeRedirectURL(editorURL(baseURL, editor, null, genre, host)));
            return;
        }

        // Phase 1: build the imported object and cache it in the session.
        Element object = buildImportedObject(modsId.trim(), type);
        String sessionKey = SESSION_KEY_PREFIX + UUID.randomUUID();
        MCRSessionMgr.getCurrentSession().put(sessionKey, object);
        LOGGER.info("Cached imported object under session key {}", sessionKey);

        List<Element> duplicates = MCRURIResolver.obtainInstance()
            .resolve("dedup:duplicates-for-session:" + sessionKey)
            .getChildren("duplicate");

        if (duplicates.isEmpty()) {
            response.sendRedirect(response.encodeRedirectURL(editorURL(baseURL, editor, sessionKey, genre, host)));
            return;
        }

        LOGGER.info("Found {} possible duplicate(s) for imported object, asking for confirmation", duplicates.size());
        Element page = buildConfirmationPage(baseURL, editor, sessionKey, genre, host, duplicates);
        getLayoutService().doLayout(request, response, new MCRJDOMContent(page));
    }

    /**
     * Builds a complete {@code mycoreobject} from the imported metadata: the identifier is resolved in
     * the configured external databases (mirroring the import source of the editor form) and the
     * resulting MODS is wrapped into a valid MODS object via {@link MCRMODSWrapper}, so that schema and
     * id are set and the deduplication component can construct an {@link MCRObject} from it.
     */
    private static Element buildImportedObject(String modsId, String type) {
        String uri = "xslStyle:import/remove-genres:"
            + "enrich:import:buildxml:_rootName_=mods:mods"
            + "&mods:identifier=" + modsId
            + "&mods:identifier/@type=" + orDefault(type, "");
        Element mods = MCRURIResolver.obtainInstance().resolve(uri);
        String projectId = MCRConfiguration2.getString("MIR.projectid.default").orElse("mir");
        MCRObject object = MCRMODSWrapper.wrapMODSDocument(mods.clone(), projectId);
        return object.createXML().detachRootElement();
    }

    private static String editorURL(String baseURL, String editor, String sessionKey, String genre, String host) {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("sessionKey", sessionKey);
        params.put("genre", genre);
        params.put("host", host);
        return url(baseURL + "editor/" + editor + ".xed", params);
    }

    private Element buildConfirmationPage(String baseURL, String editor, String sessionKey, String genre, String host,
        List<Element> duplicates) {
        Map<String, String> continueParams = new LinkedHashMap<>();
        continueParams.put("confirmed", "true");
        continueParams.put("sessionKey", sessionKey);
        continueParams.put("editor", editor);
        continueParams.put("genre", genre);
        continueParams.put("host", host);

        // The page is rendered by xslt/duplicatecheck.xsl, which displays every referenced object with
        // the same object display as the search result list (mode "basketContent"). The actual text is
        // resolved via i18n there, so only ids and the navigation urls are passed.
        Element page = new Element("duplicatecheck");
        page.setAttribute("continueURL", url(baseURL + "servlets/MIRImportServlet", continueParams));
        page.setAttribute("cancelURL", baseURL + "content/publish/index.xml");
        duplicates.stream()
            .map(duplicate -> duplicate.getAttributeValue("id"))
            .distinct()
            .forEach(id -> page.addContent(new Element("object").setAttribute("id", id)));
        return page;
    }

    private static String url(String base, Map<String, String> params) {
        String query = params.entrySet().stream()
            .filter(entry -> entry.getValue() != null && !entry.getValue().isBlank())
            .map(entry -> entry.getKey() + '=' + URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8))
            .collect(Collectors.joining("&"));
        return query.isEmpty() ? base : base + '?' + query;
    }

    private static String orDefault(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value;
    }
}
