/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * This program is free software; you can use it, redistribute it
 * and / or modify it under the terms of the GNU General Public License
 * (GPL) as published by the Free Software Foundation; either version 2
 * of the License or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program, in a file called gpl.txt or license.txt.
 * If not, write to the Free Software Foundation Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 */

package org.mycore.mir.authorization.accesskeys.frontend.servlet;

import java.io.Serial;

import org.jdom2.Document;
import org.jdom2.Element;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.mycore.mcr.acl.accesskey.config.MCRAccessKeyConfig;
import org.mycore.mcr.acl.accesskey.exception.MCRAccessKeyException;
import org.mycore.mcr.acl.accesskey.service.MCRAccessKeyServiceFactory;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class MIRAccessKeyServlet extends MCRServlet {

    @Serial
    private static final long serialVersionUID = 1L;

    private static final String QUERY_PARAM_ACTION = "action";

    private static final String QUERY_PARAM_OBJ_ID = "objId";

    private static final String QUERY_PARAM_REDIRECT_URL = "url";

    /* (non-Javadoc)
     * @see org.mycore.frontend.servlets.MCRServlet#doGetPost(org.mycore.frontend.servlets.MCRServletJob)
     */
    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        final HttpServletRequest req = job.getRequest();
        final HttpServletResponse res = job.getResponse();
        final boolean isGuest = checkCurrentUserIsGuest();
        if (isGuest && MCRAccessKeyConfig.getAllowedSessionPermissionTypes().isEmpty()) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access can only be granted to personalized users");
            return;
        }
        final Document doc = (Document) (job.getRequest().getAttribute("MCRXEditorSubmission"));
        if (doc == null || req.getParameter(QUERY_PARAM_ACTION) != null) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        final Element xml = doc.getRootElement();
        final String objId = xml.getAttributeValue(QUERY_PARAM_OBJ_ID);
        if (objId == null || !MCRObjectID.isValid(objId)) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        final String value = xml.getTextTrim();
        if (value.isEmpty()) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing documentID or accessKey parameter");
            return;
        }
        try {
            if (isGuest) {
                MCRAccessKeyServiceFactory.getAccessKeySessionService().activateAccessKey(objId, value);
            } else {
                MCRAccessKeyServiceFactory.getAccessKeyUserService().activateAccessKey(objId, value);
            }
        } catch (MCRAccessKeyException e) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Access key is unknown or not allowed.");
            return;
        }
        res.sendRedirect(getReturnURL(req));
    }

    private static boolean checkCurrentUserIsGuest() {
        return MCRSessionMgr.getCurrentSession().getUserInformation().getUserID()
            .equals(MCRSystemUserInformation.GUEST.getUserID());
    }

    private static String getReturnURL(HttpServletRequest req) {
        String returnURL = req.getParameter(QUERY_PARAM_REDIRECT_URL);
        if (returnURL == null) {
            String referer = req.getHeader("Referer");
            returnURL = (referer != null) ? referer : req.getContextPath() + "/";
        }
        return returnURL;
    }
}
