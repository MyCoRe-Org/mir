/**
 * 
 */
package org.mycore.mir;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.glxn.qrgen.QRCode;

import org.mycore.common.content.MCRByteContent;
import org.mycore.common.content.MCRContent;
import org.mycore.frontend.servlets.MCRContentServlet;

/**
 * @author Thomas Scheffler(yagee)
 *
 */
public class MCRQRCodeServlet extends MCRContentServlet {

    private static final int CACHE_TIME = (int) TimeUnit.SECONDS.convert(1000L, TimeUnit.DAYS);

    @Override
    public MCRContent getContent(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String pathInfo = req.getPathInfo().substring(1);
        String queryString = req.getQueryString();
        String url = getBaseURL() + pathInfo;
        if (queryString != null) {
            url += '?' + queryString;
        }
        byte[] byteArray = QRCode.from(url).stream().toByteArray();
        MCRByteContent content = new MCRByteContent(byteArray);
        content.setMimeType("image/png");
        content.setLastModified(0);
        if (!"HEAD".equals(req.getMethod())) {
            writeCacheHeaders(resp, CACHE_TIME, 0, true);
        }
        return content;
    }
}
