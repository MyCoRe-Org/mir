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
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.common.MCRUserInformation;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;

/**
 * @author Ren\u00E9 Adler (eagle)
 * @since 0.3
 */
public class MIRAccessKeyServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static final String REDIRECT_URL_PARAMETER = "url";

    /* (non-Javadoc)
     * @see org.mycore.frontend.servlets.MCRServlet#doGetPost(org.mycore.frontend.servlets.MCRServletJob)
     */
    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        HttpServletRequest req = job.getRequest();
        HttpServletResponse res = job.getResponse();

        final MCRUserInformation userInfo = MCRSessionMgr.getCurrentSession().getUserInformation();

        if (userInfo.equals(MCRSystemUserInformation.getGuestInstance())) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access can only be granted to personalized users");
            return;
        }

        final Document doc = (Document) (job.getRequest().getAttribute("MCRXEditorSubmission"));

        if (doc == null) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        final String action = req.getParameter("action");
        final Element xml = doc.getRootElement();
        final String objId = xml.getAttributeValue("objId");
        final MCRObjectID mcrObjId = MCRObjectID.getInstance(objId);

        if (action == null) {
            final String accessKey = xml.getTextTrim();

            String message = checkAccessKey(mcrObjId, accessKey);
            if (message != null) {
                res.sendError(HttpServletResponse.SC_BAD_REQUEST, message);
                return;
            }

            final MIRAccessKeyPair accKP = MIRAccessKeyManager.getKeyPair(mcrObjId);

            if (accessKey.equals(accKP.getReadKey()))
                MIRAccessKeyManager.addAccessKey(mcrObjId, accessKey);
            else if (accessKey.equals(accKP.getWriteKey()))
                MIRAccessKeyManager.addAccessKey(mcrObjId, accessKey);
        } else if ("create".equals(action)) {
            if (!MCRAccessManager.checkPermission(mcrObjId, PERMISSION_WRITE)) {
                throw MCRAccessException.missingPermission("Add access key to object.", mcrObjId.toString(),
                    PERMISSION_WRITE);
            }

            final MIRAccessKeyPair accKP = MIRAccessKeyPairTransformer.buildAccessKeyPair(xml);

            MIRAccessKeyManager.createKeyPair(accKP);
        } else if ("edit".equals(action)) {
            if (!MCRAccessManager.checkPermission(mcrObjId, PERMISSION_WRITE)) {
                throw MCRAccessException.missingPermission("Update access key on object.", mcrObjId.toString(),
                    PERMISSION_WRITE);
            }

            final MIRAccessKeyPair accKP = MIRAccessKeyPairTransformer.buildAccessKeyPair(xml);

            MIRAccessKeyManager.updateKeyPair(accKP);
        } else if ("delete".equals(action)) {
            if (!MCRAccessManager.checkPermission(mcrObjId, PERMISSION_WRITE)) {
                throw MCRAccessException.missingPermission("Delete access key on object.", mcrObjId.toString(),
                    PERMISSION_WRITE);
            }

            MIRAccessKeyManager.deleteKeyPair(mcrObjId);
        } else {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        res.sendRedirect(getReturnURL(req));
    }

    /**
     * Checks if the access key is correct and returns an error message, if not.
     * 
     * @param objId the {@link MCRObjectID} of the {@link MCRObject} the key belongs to
     * @param accessKey the read or write key stored for the given {@link MCRObject}
     * @return <code>null</code>, if the given key matches either the read key or the write key. Returns an error message otherwise.
     */
    private static String checkAccessKey(final MCRObjectID objId, final String accessKey) {
        if ((accessKey == null) || (accessKey.length() == 0))
            return "Missing documentID or accessKey parameter";

        MIRAccessKeyPair accKP = MIRAccessKeyManager.getKeyPair(objId);
        if (accKP == null)
            return "No access keys defined for MCRObject " + objId;

        if (accessKey.equals(accKP.getReadKey()) || accessKey.equals(accKP.getWriteKey()))
            return null;
        else
            return "Access key does not match";
    }

    private static String getReturnURL(HttpServletRequest req) {
        String returnURL = req.getParameter(REDIRECT_URL_PARAMETER);
        if (returnURL == null) {
            String referer = req.getHeader("Referer");
            returnURL = (referer != null) ? referer : req.getContextPath() + "/";
        }
        return returnURL;
    }
}
