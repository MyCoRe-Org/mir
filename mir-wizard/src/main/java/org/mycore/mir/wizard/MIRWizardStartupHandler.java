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
import java.util.EnumSet;
import java.util.UUID;

import javax.servlet.DispatcherType;
import javax.servlet.FilterRegistration.Dynamic;
import javax.servlet.ServletContext;
import javax.servlet.ServletRegistration;

import org.apache.log4j.Logger;
import org.mycore.access.MCRAccessBaseImpl;
import org.mycore.access.strategies.MCRObjectIDStrategy;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.common.events.MCRShutdownHandler;
import org.mycore.common.events.MCRStartupHandler;

/**
 * Default {@link MCRStartupHandler} for MIR Wizard.
 * 
 * @author René Adler (eagle)
 */
public class MIRWizardStartupHandler implements MCRStartupHandler.AutoExecutable, MCRShutdownHandler.Closeable {

    static final String ACCESS_CLASS = "MCR.Access.Class";

    static final String ACCESS_STRATEGY_CLASS = "MCR.Access.Strategy.Class";

    static final String LOGIN_TOKEN = "MCR.Wizard.LoginToken";

    private static final Logger LOGGER = Logger.getLogger(MIRWizardStartupHandler.class);

    private static final String HANDLER_NAME = MIRWizardStartupHandler.class.getName();

    private static final String WIZARD_SERVLET_NAME = MIRWizardServlet.class.getSimpleName();

    private static final String WIZARD_SERVLET_CLASS = MIRWizardServlet.class.getName();

    private static final String WIZARD_FILTER_NAME = MIRWizardRequestFilter.class.getSimpleName();

    private static final String WIZARD_FILTER_CLASS = MIRWizardRequestFilter.class.getName();

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
            File baseDir = MCRConfigurationDir.getConfigurationDirectory();

            MCRConfiguration config = MCRConfiguration.instance();

            if (!baseDir.exists()) {
                LOGGER.info("Create missing MCR.basedir (" + baseDir.getAbsolutePath() + ")...");
                baseDir.mkdirs();
                config.set("MCR.basedir", convertToNixPath(baseDir));
            } else {
                File mcrProps = MCRConfigurationDir.getConfigFile("mycore.properties");
                File hibCfg = MCRConfigurationDir.getConfigFile("hibernate.cfg.xml");

                if ((mcrProps != null && mcrProps.canRead()) || (hibCfg != null && hibCfg.canRead())) {
                    return;
                }
            }

            servletContext.setAttribute(MCRStartupHandler.HALT_ON_ERROR, Boolean.toString(false));

            LOGGER.info("Register " + WIZARD_FILTER_NAME + "...");

            Dynamic ft = servletContext.addFilter(WIZARD_FILTER_NAME, WIZARD_FILTER_CLASS);
            if (ft != null) {
                ft.addMappingForUrlPatterns(EnumSet.of(DispatcherType.REQUEST), true, "/*");
            } else {
                LOGGER.info("Couldn't map " + WIZARD_FILTER_NAME + "!");
            }

            LOGGER.info("Register " + WIZARD_SERVLET_NAME + "...");

            ServletRegistration sr = servletContext.addServlet(WIZARD_SERVLET_NAME, WIZARD_SERVLET_CLASS);
            if (sr != null) {
                sr.setInitParameter("keyname", WIZARD_SERVLET_NAME);
                sr.addMapping("/servlets/" + WIZARD_SERVLET_NAME + "/*");
                sr.addMapping("/wizard/config/*");
            } else {
                LOGGER.info("Couldn't map " + WIZARD_SERVLET_NAME + "!");
            }

            String wizStylesheet = config.getString("MIR.Wizard.LayoutStylesheet", "xsl/mir-wizard-layout.xsl");
            config.set("MCR.LayoutTransformerFactory.Default.Stylesheets", wizStylesheet);
            //disable ACL system
            //store for later use...
            servletContext.setAttribute(ACCESS_CLASS, config.getString(ACCESS_CLASS, null));
            servletContext.setAttribute(ACCESS_STRATEGY_CLASS, config.getString(ACCESS_STRATEGY_CLASS, null));
            config.set(ACCESS_CLASS, MCRAccessBaseImpl.class.getName());
            config.set(ACCESS_STRATEGY_CLASS, MCRObjectIDStrategy.class.getName());

            //generate UUID as login token
            final String token = UUID.randomUUID().toString();
            servletContext.setAttribute(LOGIN_TOKEN, token);

            outputLoginToken(servletContext);
        }
    }

    private String convertToNixPath(final File file) {
        String path = file.getAbsolutePath();

        if (File.separatorChar != '/') {
            path = path.replace(File.separatorChar, '/');
        }

        return path;
    }

    static void outputLoginToken(ServletContext servletContext) {
        final StringBuffer sb = new StringBuffer();

        sb.append("\n\n" + String.format(String.format("%%0%dd", 80), 0).replace("0", "=") + "\n");
        sb.append(" MIR Wizard");
        sb.append("\n" + String.format(String.format("%%0%dd", 80), 0).replace("0", "=") + "\n\n");

        if (System.getProperty("os.name").toLowerCase().contains("win"))
            sb.append(" Login token: " + servletContext.getAttribute(LOGIN_TOKEN));
        else
            sb.append(" \u001b[41m\u001b[1;37mLogin token: " + servletContext.getAttribute(LOGIN_TOKEN) + "\u001b[m");

        sb.append("\n\n" + String.format(String.format("%%0%dd", 80), 0).replace("0", "="));

        LOGGER.info(sb.toString());
    }
}
