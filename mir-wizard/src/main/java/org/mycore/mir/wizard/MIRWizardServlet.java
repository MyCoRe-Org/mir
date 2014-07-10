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

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.output.XMLOutputter;
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

/**
 * @author René Adler
 *
 */
public class MIRWizardServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    public void doGetPost(MCRServletJob job) throws Exception {
        String path = job.getRequest().getPathInfo();

        if (path != null) {
            StringTokenizer st = new StringTokenizer(path, "/");
            String filename = st.nextToken();

            getLayoutService().doLayout(job.getRequest(), job.getResponse(),
                    new MCRJDOMContent(MCRURIResolver.instance().resolve("resource:" + filename)));
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
            chain.addCommand(new MIRWizardInitSuperuser());
            chain.addCommand(new MIRWizardLoadClassifications());
            chain.execute(wizXML);

            for (MIRWizardCommand cmd : chain.getCommands()) {
                results.addContent(cmd.getResult().toElement());
            }

            resXML.addContent(results);

            getLayoutService().doLayout(job.getRequest(), job.getResponse(), new MCRJDOMContent(resXML));
        }
    }
}
