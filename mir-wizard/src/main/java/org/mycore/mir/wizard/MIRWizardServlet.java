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
package org.mycore.mir.wizard;

import java.io.IOException;
import java.io.Serial;
import java.util.StringTokenizer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.output.XMLOutputter;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * @author René Adler
 */
public class MIRWizardServlet extends MCRServlet {

    @Serial
    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = LogManager.getLogger();

    @SuppressWarnings({"PMD.DoNotTerminateVM", "PMD.DoNotCallSystemExit"})
    public void doGetPost(final MCRServletJob job) throws Exception {
        final HttpServletRequest req = job.getRequest();

        final String path = req.getPathInfo();

        if (path != null) {
            final StringTokenizer st = new StringTokenizer(path, "/");
            final String request = st.nextToken();

            if ("shutdown".equals(request)) {
                LOGGER.info("Shutdown System....");
                MCRConfiguration2.set("MCR.LayoutTransformerFactory.Default.Stylesheets", "");
                MCRConfiguration2.set("MCR.Startup.Class", "%MCR.Startup.Class%");
                System.exit(0);
            } else {
                LOGGER.info("Request file \"" + request + "\"...");
                getLayoutService().doLayout(job.getRequest(), job.getResponse(),
                    new MCRJDOMContent(MCRURIResolver.instance().resolve("resource:setup/" + request)));
            }
        } else {
            final Element resXML = getResult(job);
            if (resXML == null) {
                //response is already send
                return;
            }

            getLayoutService().doLayout(job.getRequest(), job.getResponse(), new MCRJDOMContent(resXML));
        }
    }

    private Element getResult(MCRServletJob job) throws IOException {
        HttpServletRequest req = job.getRequest();
        HttpServletResponse res = job.getResponse();
        final Document doc = (Document) (job.getRequest().getAttribute("MCRXEditorSubmission"));
        final Element wizXML = doc.getRootElement();

        LOGGER.debug(new XMLOutputter().outputString(wizXML));

        final Element resXML = new Element("wizard");

        if (!MIRWizardRequestFilter.isAuthenticated(req)) {
            final String loginToken = wizXML.getChildTextTrim("login");
            String url = "wizard/";

            if (loginToken != null && MIRWizardRequestFilter.getLoginToken(req).equals(loginToken)) {
                LOGGER.info("Authenticate with token \"" + loginToken + "\"...");
                MCRSessionMgr.getCurrentSession().put(MIRWizardStartupHandler.LOGIN_TOKEN, loginToken);
                MCRSessionMgr.getCurrentSession().put("ServerBaseURL",
                    req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort());
            } else {
                LOGGER.info("Redirect to login...");
                url += "?action=login"
                    + (!MIRWizardRequestFilter.getLoginToken(req).equals(loginToken) ? "&token=invalid" : "");

                // output login token again
                MIRWizardStartupHandler.outputLoginToken(req.getServletContext());
            }
            res.sendRedirect(res.encodeRedirectURL(MCRFrontendUtil.getBaseURL() + url));
            return null;
        }

        initializeApplication(job);

        resXML.addContent(new MIRWizard().doMagic(wizXML));

        return resXML;
    }

    private void initializeApplication(MCRServletJob job) {
        restoreProperty(job, MIRWizardStartupHandler.ACCESS_CLASS);
        restoreProperty(job, MIRWizardStartupHandler.ACCESS_STRATEGY_CLASS);
    }

    private void restoreProperty(MCRServletJob job, String property) {
        String value = (String) job.getRequest().getServletContext().getAttribute(property);
        if (value != null) {
            LOGGER.info("Restoring " + property + "=" + value);
            MCRConfiguration2.set(property, value);
        }
    }
}
