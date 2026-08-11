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

package org.mycore.mir.viewer;

import java.util.Locale;

import org.mycore.common.xml.MCRXMLFunctions;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.viewer.configuration.MCRViewerConfiguration;
import org.mycore.viewer.configuration.MCRViewerDefaultConfigurationStrategy;

import jakarta.servlet.http.HttpServletRequest;

public class MIRViewerConfigurationStrategy extends MCRViewerDefaultConfigurationStrategy {

    @Override
    public MCRViewerConfiguration get(HttpServletRequest request) {
        MCRViewerConfiguration configuration = super.get(request);
        String baseURL = MCRFrontendUtil.getBaseURL(request);

        if (!MCRXMLFunctions.isMobileDevice(request.getHeader("User-Agent"))) {
            // Default Stylesheet
            MCRConfiguration2.getString("MIR.Layout.Theme").ifPresent(theme ->
                    MCRConfiguration2.getString("MIR.DefaultLayout.CSS").ifPresent(file -> {
                        String defaultCssUrl = String.format(Locale.ROOT, "%srsc/sass/mir-layout/scss/%s-%s.css",
                                baseURL, theme, file);
                        configuration.addCSS(defaultCssUrl);
                    }));

            // custom Stylesheet
            MCRConfiguration2.getString("MIR.CustomLayout.CSS").ifPresent(customCss -> {
                String customCssUrl = String.format(Locale.ROOT, "%scss/%s", baseURL, customCss);
                configuration.addCSS(customCssUrl);
            });

            // custom Script
            MCRConfiguration2.getString("MIR.CustomLayout.JS").ifPresent(customJs -> {
                String customJsUrl = String.format(Locale.ROOT, "%sjs/%s", baseURL, customJs);
                configuration.addScript(customJsUrl, false);
            });

            if (request.getParameter("embedded") != null) {
                configuration.setProperty("permalink.updateHistory", false);
                configuration.setProperty("chapter.showOnStart", false);
            } else {
                // Default JS
                String defaultJsUrl = MCRFrontendUtil.getBaseURL() + "assets/bootstrap/js/bootstrap.bundle.min.js";
                configuration.addScript(defaultJsUrl, false);

                configuration.addCSS(MCRFrontendUtil.getBaseURL() + "assets/font-awesome/css/all.min.css");
            }
        }

        return configuration;
    }
}
