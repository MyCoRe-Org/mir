package org.mycore.mir.viewer;

import java.util.Locale;

import jakarta.servlet.http.HttpServletRequest;

import org.mycore.common.xml.MCRXMLFunctions;
import org.mycore.common.xsl.MCRParameterCollector;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.viewer.configuration.MCRViewerConfiguration;
import org.mycore.viewer.configuration.MCRViewerDefaultConfigurationStrategy;

public class MIRViewerConfigurationStrategy extends MCRViewerDefaultConfigurationStrategy {

    @Override
    public MCRViewerConfiguration get(HttpServletRequest request) {
        MCRViewerConfiguration mcrViewerConfiguration = super.get(request);
        String baseURL = MCRFrontendUtil.getBaseURL(request);
        MCRParameterCollector params = new MCRParameterCollector(request);

        if (!MCRXMLFunctions.isMobileDevice(request.getHeader("User-Agent"))) {
            // Default Stylesheet
            String theme = params.getParameter("MIR.Layout.Theme", null);
            String file = params.getParameter("MIR.DefaultLayout.CSS", null);
            String mirBootstrapCSSURL = String.format(Locale.ROOT, "%srsc/sass/mir-layout/scss/%s-%s.css", baseURL,
                theme, file);
            mcrViewerConfiguration.addCSS(mirBootstrapCSSURL);

            // customLayout Stylesheet
            String customLayout = params.getParameter("MIR.CustomLayout.CSS", "");
            if (customLayout.length() > 0) {
                String customLayoutURL = String.format(Locale.ROOT, "%scss/%s", baseURL, customLayout);
                mcrViewerConfiguration.addCSS(customLayoutURL);
            }

            String customJS = params.getParameter("MIR.CustomLayout.JS", "");
            if (customJS.length() > 0) {
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
