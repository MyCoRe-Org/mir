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

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
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

/**
 * @author René Adler
 */
public class MIRWizardServlet extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = Logger.getLogger(MIRWizardServlet.class);

    public void doGetPost(final MCRServletJob job) throws Exception {
        final String path = job.getRequest().getPathInfo();

        if (path != null) {
            final StringTokenizer st = new StringTokenizer(path, "/");
            final String request = st.nextToken();

            if ("shutdown".equals(request)) {
                LOGGER.info("Shutdown System....");
                MCRConfiguration.instance().set("MCR.LayoutTransformerFactory.Default.Stylesheets", "");
                MCRConfiguration.instance().set("MCR.Startup.Class", "%MCR.Startup.Class%");
                System.exit(0);
            } else {
                LOGGER.info("Request file \"" + request + "\"...");
                getLayoutService().doLayout(job.getRequest(), job.getResponse(),
                    new MCRJDOMContent(MCRURIResolver.instance().resolve("resource:setup/" + request)));
            }
        } else {
            final Document doc = (Document) (job.getRequest().getAttribute("MCRXEditorSubmission"));
            final Element wizXML = doc.getRootElement();

            LOGGER.debug(new XMLOutputter().outputString(wizXML));

            final Element resXML = new Element("wizard");
            final Element results = new Element("results");

            final Element commands = MCRURIResolver.instance().resolve("resource:setup/install.xml");

            final MIRWizardCommandChain chain = new MIRWizardCommandChain();

            for (Element command : commands.getChildren("command")) {
                final String cls = command.getAttributeValue("class");
                final String name = command.getAttributeValue("name");
                final String src = command.getAttributeValue("src");

                try {
                    final Class<?> cmdCls = Class.forName(cls);
                    MIRWizardCommand cmd = null;

                    if (name != null) {
                        final Constructor<?> cmdC = cmdCls.getConstructor(String.class);
                        cmd = (MIRWizardCommand) cmdC.newInstance(name);
                    } else {
                        final Constructor<?> cmdC = cmdCls.getConstructor();
                        cmd = (MIRWizardCommand) cmdC.newInstance();
                    }

                    if (src != null) {
                        cmd.setInputXML(MCRURIResolver.instance().resolve(src));
                    }

                    if (cmd != null) {
                        chain.addCommand(cmd);
                    }
                } catch (final ClassNotFoundException | NoSuchMethodException | SecurityException
                    | InstantiationException | IllegalAccessException | IllegalArgumentException
                    | InvocationTargetException e) {
                    LOGGER.error(e);
                }
            }

            LOGGER.info("Execute Wizard Commands...");
            chain.execute(wizXML);
            LOGGER.info("done.");

            for (MIRWizardCommand cmd : chain.getCommands()) {
                results.addContent(cmd.getResult().toElement());
            }

            results.setAttribute("success", Boolean.toString(chain.isSuccess()));

            resXML.addContent(results);

            initializeApplication(job);

            getLayoutService().doLayout(job.getRequest(), job.getResponse(), new MCRJDOMContent(resXML));
        }
    }

    private void initializeApplication(MCRServletJob job) {
        String accessSystem = (String) job.getRequest().getServletContext()
            .getAttribute(MIRWizardStartupHandler.ACCESS_CLASS);
        if (accessSystem != null) {
            LOGGER.info("Restoring access control system: " + accessSystem);
            MCRConfiguration.instance().set(MIRWizardStartupHandler.ACCESS_CLASS, accessSystem);
        }
    }
}
