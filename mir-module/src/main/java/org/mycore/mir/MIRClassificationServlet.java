package org.mycore.mir;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import jakarta.servlet.http.HttpServletRequest;

import org.jdom2.Document;
import org.jdom2.Element;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.classifications2.MCRLabel;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.mycore.user2.MCRUser2Constants;

public class MIRClassificationServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static final String LAYOUT_ELEMENT_KEY = MIRClassificationServlet.class.getName() + ".layoutElement";

    @Override
    public void init() {
        //MIR-220 fixed formatting
    }

    @Override
    protected void think(MCRServletJob job) throws Exception {
        HttpServletRequest request = job.getRequest();
        String action = getProperty(request, "action");
        if ("chooseCategory".equals(action)) {
            chooseCategory(request);
        } else {
            chooseClassiRoot(request);
        }
    }

    private void chooseClassiRoot(HttpServletRequest request) {
        Element rootElement = getRootElement(request);
        rootElement.addContent(getRoleElements());
        request.setAttribute(LAYOUT_ELEMENT_KEY, new Document(rootElement));
    }

    private Collection<Element> getRoleElements() {
        MCRCategoryDAO categoryDao = MCRCategoryDAOFactory.getInstance();
        List<MCRCategory> allClassi = categoryDao.getRootCategories();
        ArrayList<Element> list = new ArrayList<Element>(allClassi.size());
        for (MCRCategory category : allClassi) {
            if (MCRAccessManager.checkPermission(category.getId().toString(), MCRAccessManager.PERMISSION_READ)) {
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
        rootElement.setAttribute("queryParams", request.getQueryString());
        return rootElement;
    }

    private static void chooseCategory(HttpServletRequest request) {
        MCRCategoryID categoryID;
        String categID = getProperty(request, "categID");
        if (MCRAccessManager.checkPermission(categID, MCRAccessManager.PERMISSION_READ)) {
            if (categID != null) {
                categoryID = MCRCategoryID.fromString(categID);
            } else {
                String rootID = getProperty(request, "classID");
                categoryID = (rootID == null) ? MCRCategoryID.rootID(MCRUser2Constants.getRoleRootId())
                    : MCRCategoryID.rootID(rootID);
            }
            Element rootElement = getRootElement(request);
            rootElement.setAttribute("classID", categoryID.getRootID());
            if (!categoryID.isRootID()) {
                rootElement.setAttribute("categID", categoryID.getID());
            }
            request.setAttribute(LAYOUT_ELEMENT_KEY, new Document(rootElement));
        }
    }

    @Override
    protected void render(MCRServletJob job, Exception ex) throws Exception {
        if (ex != null) {
            //do not handle error here
            throw ex;
        }
        getLayoutService().doLayout(job.getRequest(), job.getResponse(),
            new MCRJDOMContent((Document) job.getRequest().getAttribute(LAYOUT_ELEMENT_KEY)));
    }

}
