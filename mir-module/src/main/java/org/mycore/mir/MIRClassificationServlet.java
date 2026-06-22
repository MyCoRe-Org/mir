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

import java.io.Serial;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.jdom2.Element;
import org.mycore.access.MCRAccessException;
import org.mycore.access.MCRAccessManager;
import org.mycore.access.MCRMissingPermissionException;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.classifications2.MCRLabel;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.mycore.user2.MCRUser2Constants;

import jakarta.servlet.http.HttpServletRequest;

public class MIRClassificationServlet extends MCRServlet {

    @Serial
    private static final long serialVersionUID = 1L;

    private static final String REQUIRED_PERMISSION = MCRAccessManager.PERMISSION_READ;

    @Override
    protected void doGetPost(MCRServletJob job) throws Exception {
        HttpServletRequest request = job.getRequest();
        String action = getProperty(request, "action");
        try {
            Element result = "chooseCategory".equals(action) ? chooseCategory(request) : chooseClassiRoot(request);
            getLayoutService().doLayout(job.getRequest(), job.getResponse(), new MCRJDOMContent(result));
        } catch (MCRAccessException e) {
            job.getResponse().sendError(403, e.getMessage());
        }
    }

    private Element chooseClassiRoot(HttpServletRequest request) {
        Element rootElement = getRootElement(request);
        rootElement.addContent(getRoleElements());
        return rootElement;
    }

    private Collection<Element> getRoleElements() {
        MCRCategoryDAO categoryDao = MCRCategoryDAO.obtainInstance();
        List<MCRCategory> allClassi = categoryDao.getRootCategories();
        ArrayList<Element> list = new ArrayList<>(allClassi.size());
        for (MCRCategory category : allClassi) {
            if (MCRAccessManager.checkPermission(category.getId().toString(), REQUIRED_PERMISSION)) {
                Element role = new Element("classification");
                role.setAttribute("authority", category.getId().toString());
                category.getCurrentLabel().map(MCRLabel::getText).ifPresent(role::setText);
                list.add(role);
            }
        }
        return list;
    }

    private static Element getRootElement(HttpServletRequest request) {
        Element rootElement = new Element("classifications");
        Optional.ofNullable(request.getQueryString()).ifPresent(s -> rootElement.setAttribute("queryParams", s));
        return rootElement;
    }

    private Element chooseCategory(HttpServletRequest request) throws MCRMissingPermissionException {
        MCRCategoryID categoryID =
            Optional.ofNullable(getProperty(request, "categoryId")).map(MCRCategoryID::ofString).orElseGet(() -> {
                String rootID = getProperty(request, "classID");
                return (rootID == null) ? new MCRCategoryID(MCRUser2Constants.getRoleRootId())
                                        : new MCRCategoryID(rootID);
            });
        if (!MCRAccessManager.checkPermission(categoryID.getId(), REQUIRED_PERMISSION)) {
            throw new MCRMissingPermissionException("chooseCategory", categoryID.toString(), REQUIRED_PERMISSION);
        }
        Element rootElement = getRootElement(request);
        rootElement.setAttribute("classID", categoryID.getRootID());
        if (!categoryID.isRoot()) {
            rootElement.setAttribute("categID", categoryID.getId());
        }
        return rootElement;
    }

}
