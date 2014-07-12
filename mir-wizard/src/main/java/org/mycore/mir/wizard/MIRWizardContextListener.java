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

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

import javax.servlet.ServletContext;
import javax.servlet.ServletRegistration;

import org.apache.log4j.Logger;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.common.events.MCRShutdownHandler;
import org.mycore.common.events.MCRStartupHandler;

/**
 * Default {@link MCRStartupHandler} for MIR Wizard.
 * 
 * @author René Adler (eagle)
 * 
 */
public class MIRWizardContextListener implements MCRStartupHandler.AutoExecutable, MCRShutdownHandler.Closeable {

    private static final String HANDLER_NAME = MIRWizardContextListener.class.getName();

    private static final String WIZARD_SERVLET_NAME = MIRWizardServlet.class.getSimpleName();

    private static final String WIZARD_SERVLET_CLASS = MIRWizardServlet.class.getName();

    private static final String WIZARD_STYLESHEET = MCRConfiguration.instance().getString(
            "MIR.Wizard.LayoutStylesheet", "xsl/mir-wizard-layout.xsl");

    @Override
    public String getName() {
        return HANDLER_NAME;
    }

    @Override
    public void prepareClose() {
    }

    @Override
    public void close() {
    }

    @Override
    public int getPriority() {
        return Integer.MAX_VALUE;
    }

    @Override
    public void startUp(ServletContext servletContext) {
        if (servletContext != null) {
            File mcrProps = MCRConfigurationDir.getConfigFile("mycore.properties");
            File hibCfg = MCRConfigurationDir.getConfigFile("hibernate.cfg.xml");

            if (mcrProps.canRead() || hibCfg.canRead()) {
                MCRConfiguration.instance().set("MCR.Startup.Class", "%MCR.Startup.Class%");
                return;
            }

            MCRConfiguration.instance().set("MCR.LayoutTransformerFactory.Default.Stylesheets", WIZARD_STYLESHEET);

            servletContext.log("Register " + WIZARD_SERVLET_NAME + "...");
            ServletRegistration sr = servletContext.addServlet(WIZARD_SERVLET_NAME, WIZARD_SERVLET_CLASS);
            if (sr != null) {
                sr.setInitParameter("keyname", WIZARD_SERVLET_NAME);
                sr.addMapping("/servlets/" + WIZARD_SERVLET_NAME + "/*");
                sr.addMapping("/wizard/config/*");
            } else {
                servletContext.log("Couldn't map " + WIZARD_SERVLET_NAME + "!");
            }
        }
    }
}
