package org.mycore.mir.viewer;

import java.util.Locale;

import javax.servlet.http.HttpServletRequest;

import org.mycore.common.xml.MCRXMLFunctions;
import org.mycore.common.xsl.MCRParameterCollector;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.iview2.frontend.configuration.MCRViewerConfiguration;
import org.mycore.iview2.frontend.configuration.MCRViewerDefaultConfigurationStrategy;

public class MIRViewerConfigurationStrategy extends MCRViewerDefaultConfigurationStrategy {


    public static final String BOOTSTRAP_VERSION = "3.3.4";

    @Override
    public MCRViewerConfiguration get(HttpServletRequest request) {
        MCRViewerConfiguration mcrViewerConfiguration = super.get(request);
        String baseURL = MCRFrontendUtil.getBaseURL(request);
        MCRParameterCollector params = new MCRParameterCollector(request);

        if (!MCRXMLFunctions.isMobileDevice(request.getHeader("User-Agent"))) {
            // Default Stylesheet
            String theme = params.getParameter("MIR.Layout.Theme", "flatmir");
            String file = params.getParameter("MIR.DefaultLayout.CSS", "flatly.min");
            String mirBootstrapCSSURL = String.format(Locale.ROOT, "%smir-layout/css/%s/%s.css", MCRFrontendUtil.getBaseURL(), theme, file);
            mcrViewerConfiguration.addCSS(mirBootstrapCSSURL);

            // customLayout Stylesheet
            String customLayout = params.getParameter("MIR.CustomLayout.CSS", "");
            if (customLayout.length() > 0) {
                String customLayoutURL = String.format(Locale.ROOT, "%scss/%s", MCRFrontendUtil.getBaseURL(), customLayout);
                mcrViewerConfiguration.addCSS(customLayoutURL);
            }

            // Default JS
            mcrViewerConfiguration.addScript(String.format(Locale.ROOT, "//netdna.bootstrapcdn.com/bootstrap/%s/js/bootstrap.min.js", BOOTSTRAP_VERSION));
            String customJS = params.getParameter("MIR.CustomLayout.JS", "");
            if (customJS.length() > 0) {
                mcrViewerConfiguration.addScript(String.format(Locale.ROOT, "%sjs/%s", customJS));
            }

        }

        return mcrViewerConfiguration;
    }
}