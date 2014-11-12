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
import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.mycore.common.config.MCRConfigurationDir;

/**
 * @author René Adler (eagle)
 *
 */
@WebFilter(displayName = "MIRWizardRequestFilter", urlPatterns = { "/*" })
public class MIRWizardRequestFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(MIRWizardRequestFilter.class);

    private static boolean needWizardRun = false;

    private static boolean isWizardRunning = false;

    /* (non-Javadoc)
     * @see javax.servlet.Filter#init(javax.servlet.FilterConfig)
     */
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.info("Initialize MIR Wizard request filter...");

        File mcrProps = MCRConfigurationDir.getConfigFile("mycore.properties");
        File hibCfg = MCRConfigurationDir.getConfigFile("hibernate.cfg.xml");

        if (mcrProps == null || hibCfg == null || !mcrProps.canRead() || !hibCfg.canRead()) {
            needWizardRun = true;
            LOGGER.info("...enable Wizard run.");
        } else {
            LOGGER.info("...disable Wizard run.");
        }
    }

    /* (non-Javadoc)
     * @see javax.servlet.Filter#doFilter(javax.servlet.ServletRequest, javax.servlet.ServletResponse, javax.servlet.FilterChain)
     */
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException,
            ServletException {
        if (needWizardRun) {
            HttpServletRequest req = (HttpServletRequest) request;
            HttpServletResponse res = (HttpServletResponse) response;

            String uri = req.getRequestURI();

            if (!isWizardRunning && !uri.contains("wizard")) {
                isWizardRunning = true;
                LOGGER.info("Requested Resource " + uri);
                res.sendRedirect(req.getContextPath() + "/wizard");
                return;
            } else if (!isWizardRunning) {
                isWizardRunning = true;
            }
        }

        chain.doFilter(request, response);
    }

    /* (non-Javadoc)
     * @see javax.servlet.Filter#destroy()
     */
    @Override
    public void destroy() {
        // Nothing to do
    }

}
