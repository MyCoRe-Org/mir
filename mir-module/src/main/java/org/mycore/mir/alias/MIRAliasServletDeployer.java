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

package org.mycore.mir.alias;

import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.events.MCRStartupHandler.AutoExecutable;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletRegistration;

/**
 * Registers the {@link MIRAliasContentServlet} for every configured prefix, see {@link MIRAliasConfig#getPrefixes()}.
 * <p>
 * The servlet is only registered if the alias feature is enabled, see {@link MIRAliasConfig#isEnabled()}.
 * A dynamic registration is required because the servlet mappings are configurable.
 */
public class MIRAliasServletDeployer implements AutoExecutable {

    private static final String SERVLET_NAME = "MIRAliasContentServlet";

    private static final Logger LOGGER = LogManager.getLogger();

    @Override
    public String getName() {
        return SERVLET_NAME + " Deployer";
    }

    @Override
    public int getPriority() {
        return 0;
    }

    @Override
    public void startUp(ServletContext servletContext) {
        if (servletContext == null) {
            return;
        }
        if (!MIRAliasConfig.isEnabled()) {
            LOGGER.info("Alias resolving is disabled. Set MIR.Alias.Enabled=true to enable it.");
            return;
        }
        List<String> prefixes = MIRAliasConfig.getPrefixes();
        if (prefixes.isEmpty()) {
            LOGGER.warn("Alias resolving is enabled, but no prefix is configured in MIR.Alias.Prefix.");
            return;
        }
        ServletRegistration.Dynamic registration =
            servletContext.addServlet(SERVLET_NAME, MIRAliasContentServlet.class);
        if (registration == null) {
            LOGGER.warn("Servlet {} is already registered.", SERVLET_NAME);
            return;
        }
        String[] mappings = prefixes.stream().map(prefix -> "/" + prefix + "/*").toArray(String[]::new);
        registration.addMapping(mappings).forEach(
            conflict -> LOGGER.error("Could not map {} to {}: mapping already in use.", conflict, SERVLET_NAME));
        LOGGER.info("Registered {} for {}", SERVLET_NAME, String.join(", ", mappings));
    }
}
