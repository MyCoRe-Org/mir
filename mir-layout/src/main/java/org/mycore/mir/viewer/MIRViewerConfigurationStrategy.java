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
        MCRViewerConfiguration mcrViewerConfiguration = super.get(request);
        String baseURL = MCRFrontendUtil.getBaseURL(request);

        if (!MCRXMLFunctions.isMobileDevice(request.getHeader("User-Agent"))) {
            // Default Stylesheet
            String theme = MCRConfiguration2.getString("MIR.Layout.Theme").orElse(null);
            String file = MCRConfiguration2.getString("MIR.DefaultLayout.CSS").orElse(null);
            if(theme != null && file != null) {
                String mirBootstrapCSSURL = String.format(Locale.ROOT, "%srsc/sass/mir-layout/scss/%s-%s.css",
                    baseURL, theme, file);
                mcrViewerConfiguration.addCSS(mirBootstrapCSSURL);
            }

            // customLayout Stylesheet
            String customLayout = MCRConfiguration2.getString("MIR.CustomLayout.CSS").orElse("");
            if (!customLayout.isEmpty()) {
                String customLayoutURL = String.format(Locale.ROOT, "%scss/%s", baseURL, customLayout);
                mcrViewerConfiguration.addCSS(customLayoutURL);
            }

            String customJS = MCRConfiguration2.getString("MIR.CustomLayout.JS").orElse("");
            if (!customJS.isEmpty()) {
                mcrViewerConfiguration.addScript(String.format(Locale.ROOT, "%sjs/%s", baseURL, customJS));
            }

            if (request.getParameter("embedded") != null) {
                mcrViewerConfiguration.setProperty("permalink.updateHistory", false);
                mcrViewerConfiguration.setProperty("chapter.showOnStart", false);
            } else {
                // Default JS
                mcrViewerConfiguration
                    .addScript(MCRFrontendUtil.getBaseURL() + "assets/bootstrap/js/bootstrap.min.js");
            }
        }

        return mcrViewerConfiguration;
    }
}
