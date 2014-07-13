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

import java.util.StringTokenizer;

import org.apache.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.output.XMLOutputter;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.mycore.mir.wizard.command.MIRWizardDownloadDBLib;
import org.mycore.mir.wizard.command.MIRWizardGenerateHibernateCfg;
import org.mycore.mir.wizard.command.MIRWizardGenerateProperties;
import org.mycore.mir.wizard.command.MIRWizardInitHibernate;
import org.mycore.mir.wizard.command.MIRWizardInitSuperuser;
import org.mycore.mir.wizard.command.MIRWizardLoadClassifications;
import org.mycore.mir.wizard.command.MIRWizardMCRCommand;

/**
 * @author René Adler
 *
 */
public class MIRWizardServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = Logger.getLogger(MIRWizardServlet.class);

    public void doGetPost(MCRServletJob job) throws Exception {
        String path = job.getRequest().getPathInfo();

        if (path != null) {
            StringTokenizer st = new StringTokenizer(path, "/");
            String request = st.nextToken();

            if ("shutdown".equals(request)) {
                LOGGER.info("Shutdown System....");
                MCRConfiguration.instance().set("MCR.LayoutTransformerFactory.Default.Stylesheets", "");
                MCRConfiguration.instance().set("MCR.Startup.Class", "%MCR.Startup.Class%");
                System.exit(0);
            } else {
                LOGGER.info("Request file \"" + request + "\"...");
                getLayoutService().doLayout(job.getRequest(), job.getResponse(),
                        new MCRJDOMContent(MCRURIResolver.instance().resolve("resource:" + request)));
            }
        } else {
            Document doc = (Document) (job.getRequest().getAttribute("MCRXEditorSubmission"));
            Element wizXML = doc.getRootElement();

            System.out.println((new XMLOutputter()).outputString(wizXML));

            Element resXML = new Element("wizard");
            Element results = new Element("results");

            MIRWizardCommandChain chain = new MIRWizardCommandChain();
            chain.addCommand(new MIRWizardGenerateProperties());
            chain.addCommand(new MIRWizardGenerateHibernateCfg());
            chain.addCommand(new MIRWizardDownloadDBLib());
            chain.addCommand(new MIRWizardInitHibernate());
            chain.addCommand(new MIRWizardLoadClassifications());
            chain.addCommand(new MIRWizardInitSuperuser());

            MIRWizardMCRCommand importACLs = new MIRWizardMCRCommand("import.acls");
            importACLs.setInputXML(MCRURIResolver.instance().resolve(
                    "resource:config/mir-wizard/acl/defaultrules-command.xml"));
            chain.addCommand(importACLs);

            MIRWizardMCRCommand importWebACLs = new MIRWizardMCRCommand("import.webacls");
            importWebACLs.setInputXML(MCRURIResolver.instance().resolve(
                    "resource:config/mir-wizard/acl/webacl-command.xml"));
            chain.addCommand(importWebACLs);

            LOGGER.info("Execute Wizard Commands...");
            chain.execute(wizXML);
            LOGGER.info("done.");

            for (MIRWizardCommand cmd : chain.getCommands()) {
                results.addContent(cmd.getResult().toElement());
            }

            results.setAttribute("success", Boolean.toString(chain.isSuccess()));

            resXML.addContent(results);

            getLayoutService().doLayout(job.getRequest(), job.getResponse(), new MCRJDOMContent(resXML));
        }
    }
}
