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

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.mycore.common.MCRMailer;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRUtils;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.xml.MCRXMLFunctions;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.mycore.services.i18n.MCRTranslation;
import org.mycore.user2.MCRPasswordHashType;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;
import org.mycore.user2.utils.MCRUserTransformer;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;

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

    private static final String DEFAULT_REGISTRATION_DISABLED_STATUS = MCRConfiguration2.getString(
            "MIR.SelfRegistration.Registration.setDisabled")
        .orElse(null);

    private static final String DEFAULT_EMAIL_VERIFICATION_DISABLED_STATUS = MCRConfiguration2.getString(
            "MIR.SelfRegistration.EmailVerification.setDisabled")
        .orElse(null);

    private static final String DEFAULT_ADMINISTRATE_USERS_ROLES = MCRConfiguration2.getString(
            "MIR.SelfRegistration.AdministrateUsers.Roles")
        .orElse(null);

    private static final String ROLES = MCRConfiguration2.getString(
            "MIR.SelfRegistration.RoleHierarchy")
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

    public static boolean mailExists(final List<Element> nodes) {
        Element eMail = nodes.get(0).getChild("eMail");
        if(eMail == null){
            return false;
        }

        List<MCRUser> users = MCRUserManager.listUsers(null, null, null, eMail.getText());
        return users.size() != 0;
    }

    public void doGetPost(final MCRServletJob job) throws Exception {
        final HttpServletRequest req = job.getRequest();
        final HttpServletResponse res = job.getResponse();

        final String action = req.getParameter("action");
        if ("verify".equals(action)) {
            verify(req, res);
        } else if ("changeDisableUserStatus".equals(action)) {
            changeDisableUserStatus(req, res);
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

            if (DEFAULT_REGISTRATION_DISABLED_STATUS != null && !DEFAULT_REGISTRATION_DISABLED_STATUS.isEmpty()) {
                user.setDisabled(Boolean.parseBoolean(DEFAULT_REGISTRATION_DISABLED_STATUS));
            }

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
                        // set user disabled or not
                        if (DEFAULT_EMAIL_VERIFICATION_DISABLED_STATUS != null
                            && !DEFAULT_EMAIL_VERIFICATION_DISABLED_STATUS.isEmpty()) {
                            user.setDisabled(Boolean.parseBoolean(DEFAULT_EMAIL_VERIFICATION_DISABLED_STATUS));
                        }

                        if (DEFAULT_ROLE != null && !DEFAULT_ROLE.isEmpty()) {
                            user.assignRole(DEFAULT_ROLE);
                        }

                        if (user.getAttributes().removeIf(ua -> "mailtoken".equalsIgnoreCase(ua.getName()))) {
                            MCRUserManager.updateUser(user);
                        }

                        final Element root = new Element("new-author-verified");
                        final Element u = MCRUserTransformer.buildExportableSafeXML(user).getRootElement();
                        root.addContent(u.clone());

                        getLayoutService().doLayout(req, res, new MCRJDOMContent(root));

                        if (DEFAULT_EMAIL_VERIFICATION_DISABLED_STATUS != null
                                && !DEFAULT_EMAIL_VERIFICATION_DISABLED_STATUS.isEmpty()
                                && Boolean.parseBoolean(DEFAULT_EMAIL_VERIFICATION_DISABLED_STATUS)) {
                            try {
                                MCRMailer.sendMail(MCRUserTransformer.buildExportableSafeXML(user),
                                        "e-mail-new-author-confirmation");
                            } catch (final Exception ex) {
                                LOGGER.error(ex);
                                res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, errorMsg("mailError"));
                                return;
                            }
                        }
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

    /**
     * Change "Disabled user" status
     */
    private void changeDisableUserStatus(final HttpServletRequest req,
        final HttpServletResponse res) throws Exception {
        List<String> roles = getAdministrateUsersRoles();
        final String userName = req.getParameter("user");
        final String realmId = req.getParameter("realm");
        final String disabled = req.getParameter("disabled");
        if (userName != null && realmId != null && disabled != null) {
            final MCRUser user = MCRUserManager.getUser(userName, realmId);
            if (user != null) {
                Map.Entry<Integer, String> usersPermissionToChangeDisableUserStatus =
                    checkUsersPermissionToChangeDisableUserStatus(user, roles);
                if (usersPermissionToChangeDisableUserStatus.getKey() == 0) {
                    boolean userIsDisabled = user.isDisabled();
                    if (userIsDisabled != Boolean.parseBoolean(disabled)) {
                        user.setDisabled(Boolean.parseBoolean(disabled));
                        // check if the user disabled status has changed
                        if (userIsDisabled != user.isDisabled()) {

                            final Element root = new Element("disable-user-status-changed");
                            final Element u = MCRUserTransformer.buildExportableSafeXML(user).getRootElement();
                            root.addContent(u.clone());
                            getLayoutService().doLayout(req, res, new MCRJDOMContent(root));

                            if (user.getEMailAddress() != null && !user.getEMailAddress().trim().isEmpty()) {
                                // email the user about the change of status "Disable user"
                                try {
                                    MCRMailer.sendMail(MCRUserTransformer.buildExportableSafeXML(user),
                                        "e-mail-disable-user-status-changed");
                                } catch (final Exception ex) {
                                    LOGGER.error(ex);
                                    res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, errorMsg("mailError"));
                                }
                            }
                        } else {
                            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                                errorMsg("disabledUserStatusHasNotChanged"));
                        }
                    } else {
                        res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                            errorMsg("userAlreadyHasStatus"));
                    }
                } else {
                    res.sendError(usersPermissionToChangeDisableUserStatus.getKey(),
                        usersPermissionToChangeDisableUserStatus.getValue());
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

    /**
     * Get roles from the MIR.SelfRegistration.AdministrateUsers.Roles property as a list
     * @return list of roles
     */
    private List<String> getAdministrateUsersRoles() {
        List<String> roles = new ArrayList<>();
        if (DEFAULT_ADMINISTRATE_USERS_ROLES != null
            && !DEFAULT_ADMINISTRATE_USERS_ROLES.isEmpty()) {
            roles = Arrays.asList(DEFAULT_ADMINISTRATE_USERS_ROLES
                .replaceAll("\\s+", "").split(","));
        }
        return roles;
    }

    /**
     * Check the user's permission to change the status of a disabled user
     * @param user modifiable user
     * @param roles role List
     * @return returns the key-value pair, where key is the error number and value is the error message as a string.
     * If there is no error, the following pair is returned: key: 0; value: ""
     */
    private Map.Entry<Integer, String> checkUsersPermissionToChangeDisableUserStatus(MCRUser user, List<String> roles) {
        Map.Entry<Integer, String> mapEntry = isCurrentUserInRole(roles);
        if (mapEntry.getKey() != 0) {
            return mapEntry;
        }
        mapEntry = compareUsersPermissionsLevel(user);
        if (mapEntry.getKey() != 0) {
            return mapEntry;
        }
        mapEntry = isCurrentUserEnabled();
        if (mapEntry.getKey() != 0) {
            return mapEntry;
        }
        return areModifiableUserAndCurrentUserIdentical(user);
    }

    /**
     * Checks if the role of the current user is included in the list of roles with which the current user have the
     * right to administer other users
     * @param roles list of roles
     * @return returns the key-value pair, where key is the error number and value is the error message as a string.
     * If there is no error, the following pair is returned: key: 0; value: ""
     */
    private Map.Entry<Integer, String> isCurrentUserInRole(List<String> roles) {
        if (roles != null && !roles.isEmpty()) {
            for (String role : roles) {
                if (MCRXMLFunctions.isCurrentUserInRole(role)) {
                    return Map.entry(0, "");
                }
            }
        }
        return Map.entry(HttpServletResponse.SC_FORBIDDEN, errorMsg("mir.error.headline.403"));
    }

    /**
     * Comparing the level of user permissions. if the permission level of the current user is higher than that of
     * the user being modified, no error is returned, otherwise an error occurs
     * @param user modifiable user
     * @return returns the key-value pair, where key is the error number and value is the error message as a string.
     * If there is no error, the following pair is returned: key: 0; value: ""
     */
    private Map.Entry<Integer, String> compareUsersPermissionsLevel(MCRUser user) {
        if (user != null) {
            if (ROLES != null && !ROLES.isEmpty()) {
                String[] roleHierarchy = ROLES.replaceAll("\\s+", "").split(",");
                Collection<String> modifiableUserRoles = user.getSystemRoleIDs();
                int permissionHighestLevel = 100000000; // roleHierarchy.length;
                int modifiableUserPermissionHighestLevel = permissionHighestLevel;
                for (String role : modifiableUserRoles) {
                    int index = Arrays.asList(roleHierarchy).indexOf(role);
                    if (index != -1 && index < modifiableUserPermissionHighestLevel) {
                        modifiableUserPermissionHighestLevel = index;
                    }
                }
                String currentUserId = MCRSessionMgr.getCurrentSession().getUserInformation().getUserID();
                MCRUser currentUser = MCRUserManager.getUser(currentUserId);
                Collection<String> currentUserRoles = currentUser.getSystemRoleIDs();
                int currentUserPermissionHighestLevel = permissionHighestLevel;
                for (String role : currentUserRoles) {
                    int index = Arrays.asList(roleHierarchy).indexOf(role);
                    if (index != -1 && index < currentUserPermissionHighestLevel) {
                        currentUserPermissionHighestLevel = index;
                    }
                }
                return currentUserPermissionHighestLevel <= modifiableUserPermissionHighestLevel
                       ? Map.entry(0, "")
                       : Map.entry(HttpServletResponse.SC_FORBIDDEN,
                           errorMsg("mir.error.headline.403"));
            } else {
                return Map.entry(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    errorMsg("roleHierarchyNotDefined"));
            }
        } else {
            return Map.entry(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                errorMsg("userNotFound"));
        }
    }

    /**
     * Check if the current user is enabled
     * @return returns the key-value pair, where key is the error number and value is the error message as a string.
     * If there is no error, the following pair is returned: key: 0; value: "".
     */
    private Map.Entry<Integer, String> isCurrentUserEnabled() {
        String currentUserId = MCRSessionMgr.getCurrentSession().getUserInformation().getUserID();
        MCRUser currentUser = MCRUserManager.getUser(currentUserId);
        return !currentUser.isDisabled()
               ? Map.entry(0, "")
               : Map.entry(HttpServletResponse.SC_FORBIDDEN, errorMsg("mir.error.headline.403"));
    }

    /**
     * Check if the user being modified and the current user are identical
     * @param user modifiable user
     * @return returns the key-value pair, where key is the error number and value is the error message as a string.
     * If there is no error, the following pair is returned: key: 0; value: "".
     */
    private Map.Entry<Integer, String> areModifiableUserAndCurrentUserIdentical(MCRUser user) {
        if(user == null){
            return Map.entry(HttpServletResponse.SC_BAD_REQUEST,
                errorMsg("userNotFound"));
        }
        String currentUserId = MCRSessionMgr.getCurrentSession().getUserInformation().getUserID();
        return user.getUserID().equals(currentUserId)
               ? Map.entry(HttpServletResponse.SC_FORBIDDEN,
            errorMsg("modifiableUserIsCurrentUser"))
               : Map.entry(0, "");
    }
}
