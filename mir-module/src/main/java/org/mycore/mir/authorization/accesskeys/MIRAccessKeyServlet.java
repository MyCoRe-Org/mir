/*
 * $Id$ 
 * $Revision$ $Date$
 *
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
package org.mycore.mir.authorization.accesskeys;

import static org.mycore.access.MCRAccessManager.PERMISSION_WRITE;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.jdom2.Document;
import org.jdom2.Element;
import org.mycore.access.MCRAccessException;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.common.MCRUsageException;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;

/**
 * @author Ren\u00E9 Adler (eagle)
 * @since 0.3
 */
public class MIRAccessKeyServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static final String REDIRECT_URL_PARAMETER = "url";

    private static String getReturnURL(HttpServletRequest req) {
        String returnURL = req.getParameter(REDIRECT_URL_PARAMETER);
        if (returnURL == null) {
            String referer = req.getHeader("Referer");
            returnURL = (referer != null) ? referer : req.getContextPath() + "/";
        }
        return returnURL;
    }

    /* (non-Javadoc)
     * @see org.mycore.frontend.servlets.MCRServlet#doGetPost(org.mycore.frontend.servlets.MCRServletJob)
     */
    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        HttpServletRequest req = job.getRequest();
        HttpServletResponse res = job.getResponse();
        final MCRUser user = MCRUserManager.getCurrentUser();
        if (user.getUserID().equals(MCRSystemUserInformation.getGuestInstance().getUserID())) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access can only be granted to personalized users.");
            return;
        }
        final Document doc = (Document) (job.getRequest().getAttribute("MCRXEditorSubmission"));
        if (doc == null) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        final Element xml = doc.getRootElement();
        if (xml == null) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        final MCRObjectID objectId = MCRObjectID.getInstance(xml.getAttributeValue("objId")); //TODO nullcheck?
        final String action = req.getParameter("action");
        if (action == null) {
            final String value = xml.getTextTrim();
            if ((value == null) || (value.length() == 0)) {
                res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing documentID or accessKey parameter.");
            }
            try {
                MIRAccessKeyManager.addAccessKey(user, objectId, value);
            } catch(MCRUsageException e) {
                res.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
                return;
            }
        } else if (action.equals("create") || action.equals("edit")) { //TODO stay on url
            if (!MCRAccessManager.checkPermission(objectId, PERMISSION_WRITE)) {
                throw MCRAccessException.missingPermission("Add access key to object.", objectId.toString(),
                    PERMISSION_WRITE);
            }
            final MIRAccessKeyInformation accessKeyInformation = 
                MIRAccessKeyTransformer.buildAccessKeyInformation(xml);
            if (accessKeyInformation == null || accessKeyInformation.getObjectId() == null) {
                res.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            try {
                MIRAccessKeyManager.storeAccessKeyInformation(accessKeyInformation);
            } catch(MCRUsageException e) {
                res.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
                return;
            }
        } else {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        res.sendRedirect(getReturnURL(req));
    }
}
