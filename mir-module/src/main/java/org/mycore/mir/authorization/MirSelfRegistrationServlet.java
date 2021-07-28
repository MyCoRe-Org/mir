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
package org.mycore.mir.authorization;

import java.util.List;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.mycore.common.MCRMailer;
import org.mycore.common.MCRUtils;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.mycore.services.i18n.MCRTranslation;
import org.mycore.user2.MCRPasswordHashType;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;
import org.mycore.user2.utils.MCRUserTransformer;

/**
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class MirSelfRegistrationServlet extends MCRServlet {

    private static final long serialVersionUID = -7105234919911900795L;

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String I18N_ERROR_PREFIX = "selfRegistration.error";

    private static final String DEFAULT_ROLE = MCRConfiguration2.getString("MIR.SelfRegistration.DefaultRole")
        .orElse(null);

    /**
     * Checks if given user is exists.
     *
     * @param nodes the user element
     * @return true on exists or false if not
     */
    public static boolean userExists(final List<Element> nodes) {
        final Element user = nodes.get(0);
        final String userName = user.getAttributeValue("name");
        final String realmId = user.getAttribute("realm").getValue();

        LOGGER.debug("check user exists " + userName + " " + realmId);
        return MCRUserManager.exists(userName, realmId);
    }

    public void doGetPost(final MCRServletJob job) throws Exception {
        final HttpServletRequest req = job.getRequest();
        final HttpServletResponse res = job.getResponse();

        final String action = req.getParameter("action");
        if ("verify".equals(action)) {
            verify(req, res);
        } else {
            register(req, res);
        }
    }

    private void register(final HttpServletRequest req, final HttpServletResponse res) throws Exception {
        final Document doc = (Document) (req.getAttribute("MCRXEditorSubmission"));

        if (doc == null) {
            res.sendRedirect(MCRFrontendUtil.getBaseURL() + "authorization/new-author.xed");
            return;
        }

        final Element u = doc.getRootElement();

        final MCRUser user = MCRUserTransformer.buildMCRUser(u);

        final boolean userExists = MCRUserManager.exists(user.getUserID(), user.getRealm().getID());
        if (!userExists) {
            try {
                MCRMailer.sendMail(MCRUserTransformer.buildExportableSafeXML(user), "e-mail-new-author");
                MCRMailer.sendMail(MCRUserTransformer.buildExportableSafeXML(user), "e-mail-new-author-registered");
            } catch (final Exception ex) {
                LOGGER.error(ex);
                res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, errorMsg("mailError"));
                return;
            }

            LOGGER.info("create new user " + user.getUserID() + " " + user.getRealm().getID());

            final String password = doc.getRootElement().getChildText("password");

            user.setDisabled(true);

            // remove all roles set by editor
            user.getSystemRoleIDs().clear();

            user.setHashType(MCRPasswordHashType.md5);
            user.setPassword(MCRUtils.asMD5String(1, null, password));

            MCRUserManager.createUser(user);

            final Element root = new Element("new-author-created");
            root.addContent(u.clone());

            getLayoutService().doLayout(req, res, new MCRJDOMContent(root));
        } else {
            LOGGER.error("User " + user.getUserID() + " already exists!");
            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, errorMsg("userExists"));
        }
    }

    private void verify(final HttpServletRequest req, final HttpServletResponse res) throws Exception {
        final String userName = req.getParameter("user");
        final String realmId = req.getParameter("realm");
        final String mailToken = req.getParameter("token");

        if (userName != null && realmId != null && mailToken != null) {
            final MCRUser user = MCRUserManager.getUser(userName, realmId);
            if (user != null) {
                final String umt = user.getUserAttribute("mailtoken");
                if (umt != null) {
                    if (umt.equals(mailToken)) {
                        user.setDisabled(false);

                        if (DEFAULT_ROLE != null && !DEFAULT_ROLE.isEmpty()) {
                            user.assignRole(DEFAULT_ROLE);
                        }

                        if (user.getAttributes().removeIf(ua -> ua.getName().equalsIgnoreCase("mailtoken"))) {
                            MCRUserManager.updateUser(user);
                        }

                        final Element root = new Element("new-author-verified");
                        final Element u = MCRUserTransformer.buildExportableSafeXML(user).getRootElement();
                        root.addContent(u.clone());

                        getLayoutService().doLayout(req, res, new MCRJDOMContent(root));
                    } else {
                        res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, errorMsg("missingParameter"));
                    }
                } else {
                    LOGGER.warn("No \"mailtoken\" attribute for user " + user.getUserID() + ".");
                    res.sendRedirect(MCRFrontendUtil.getBaseURL());
                }
            } else {
                res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, errorMsg("userNotFound"));
            }
        } else {
            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, errorMsg("missingParameter"));
        }
    }

    private String errorMsg(final String subIdentifier, final Object... args) {
        final String key = I18N_ERROR_PREFIX + "." + subIdentifier;
        return MCRTranslation.translate(key, args);
    }
}
