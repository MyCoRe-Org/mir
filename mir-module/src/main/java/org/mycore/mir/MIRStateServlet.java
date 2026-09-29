package org.mycore.mir;

import java.util.Arrays;
import java.util.Optional;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.access.MCRAccessManager;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.classifications2.MCRLabel;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class MIRStateServlet extends MCRServlet {

    protected static final String X_NEXT_LANGUAGE = "x-next";

    protected static final String REDIRECT_URL_PARAMETER = "url";

    private static final Logger LOGGER = LogManager.getLogger();

    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {

        final String id = job.getRequest().getParameter("id");
        final String newState = job.getRequest().getParameter("newState");

        if (id == null) {
            job.getResponse().sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameter id");
            return;
        }

        if (newState == null) {
            job.getResponse().sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameter newState");
            return;
        }

        final MCRObjectID objectID = MCRObjectID.getInstance(id);
        final boolean read = MCRAccessManager.checkPermission(objectID, MCRAccessManager.PERMISSION_READ);
        final boolean write = MCRAccessManager.checkPermission(objectID, MCRAccessManager.PERMISSION_WRITE);

        if (!read || !write) {
            job.getResponse().sendError(HttpServletResponse.SC_FORBIDDEN, "No permission to change!");
            return;
        }

        final MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);
        final MCRCategoryID state = object.getService().getState();

        final MCRCategoryDAO instance = MCRCategoryDAOFactory.getInstance();
        final MCRCategory category = instance.getCategory(state, -1);
        final Optional<MCRLabel> label = category.getLabel(X_NEXT_LANGUAGE);
        final boolean present = label
            .map(MCRLabel::getText)
            .filter(l -> Arrays.asList(l.split(",")).contains(newState))
            .isPresent();

        if (!present) {
            job.getResponse()
                .sendError(HttpServletResponse.SC_FORBIDDEN, X_NEXT_LANGUAGE + " doesnt contain " + newState);
            return;
        }

        final MCRCategoryID newStateCategory = new MCRCategoryID("state", newState);
        if (!instance.exist(newStateCategory)) {
            job.getResponse()
                .sendError(HttpServletResponse.SC_BAD_REQUEST, newStateCategory.toString() + " doesnt exist");
            return;
        }

        object.getService().setState(newStateCategory);
        MCRMetadataManager.update(object);
        job.getResponse().sendRedirect(getRedirectURL(job.getRequest(), objectID));
    }

    /**
     * Returns the URL passed by the {@link #REDIRECT_URL_PARAMETER} parameter if it is a safe redirect,
     * or the start page if it is unsafe. Without the parameter, returns the URL of the object, or the start page
     * if the new state revokes the read permission.
     */
    private static String getRedirectURL(HttpServletRequest request, MCRObjectID objectID) {
        String baseURL = MCRFrontendUtil.getBaseURL(request);
        String url = request.getParameter(REDIRECT_URL_PARAMETER);
        if (url != null && !url.isBlank()) {
            if (MCRFrontendUtil.isSafeRedirect(url)) {
                return url;
            }
            LOGGER.warn("Ignoring unsafe redirect url: {}", url);
            return baseURL;
        }
        if (!MCRAccessManager.checkPermission(objectID, MCRAccessManager.PERMISSION_READ)) {
            return baseURL;
        }
        return baseURL + "receive/" + objectID.toString();
    }
}
