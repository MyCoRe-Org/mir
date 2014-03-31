/*
 * $Id$
 * $Revision: 5697 $ $Date: Mar 28, 2014 $
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

package org.mycore.mir;

import java.io.File;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.mycore.common.content.MCRContent;
import org.mycore.datamodel.ifs.MCRFile;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.servlets.MCRContentServlet;

/**
 * @author Thomas Scheffler (yagee)
 *
 */
public class MCRPDFThumbnailServlet extends MCRContentServlet {

    private static final long serialVersionUID = 1L;

    private static Logger LOGGER = Logger.getLogger(MCRPDFThumbnailServlet.class);

    private int thumbnailSize = 256;

    static final int MAX_AGE = 60 * 60 * 24 * 365; // one year

    private MCRPDFTools pdfTools;

    /* (non-Javadoc)
     * @see org.mycore.frontend.servlets.MCRContentServlet#getContent(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
     */
    @Override
    public MCRContent getContent(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            ThumnailInfo thumbnailInfo = getThumbnailInfo(req.getPathInfo());
            MCRFile mcrFile = MCRFile.getMCRFile(MCRObjectID.getInstance(thumbnailInfo.derivate),
                thumbnailInfo.filePath);
            if (mcrFile == null) {
                return null;
            }
            File pdfFile = mcrFile.getLocalFile();
            LOGGER.info("PDF file: " + pdfFile.getAbsolutePath());
            if (!pdfFile.exists()) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, MessageFormat.format(
                    "Could not find pdf file for {0}{1}", thumbnailInfo.derivate, thumbnailInfo.filePath));
                return null;
            }
            String centerThumb = req.getParameter("centerThumb");
            String imgSize = req.getParameter("ts");
            //defaults to "yes"
            boolean centered = !"no".equals(centerThumb);
            int thumbnailSize = imgSize == null ? this.thumbnailSize : Integer.parseInt(imgSize);
            MCRContent imageContent = pdfTools.getThumnail(pdfFile, thumbnailSize, centered);
            if (imageContent != null) {
                resp.setHeader("Cache-Control", "max-age=" + MAX_AGE);
                Date expires = new Date(System.currentTimeMillis() + MAX_AGE * 1000);
                LOGGER.debug("Last-Modified: " + new Date(pdfFile.lastModified()) + ", expire on: " + expires);
                resp.setDateHeader("Expires", expires.getTime());
            }
            return imageContent;
        } finally {
            LOGGER.debug("Finished sending " + req.getPathInfo());
        }
    }

    @Override
    public void init() throws ServletException {
        super.init();
        String thSize = getInitParameter("thumbnailSize");
        if (thSize != null) {
            thumbnailSize = Integer.parseInt(thSize);
        }
        pdfTools = new MCRPDFTools();
        LOGGER.info(getServletName() + ": setting thumbnail size to " + thumbnailSize);
    }

    @Override
    public void destroy() {
        try {
            pdfTools.close();
        } catch (Exception e) {
            LOGGER.error("Error while closing PDF tools.", e);
        }
        super.destroy();
    }

    private static ThumnailInfo getThumbnailInfo(String pathInfo) {
        if (pathInfo.startsWith("/")) {
            pathInfo = pathInfo.substring(1);
        }
        final String derivate = pathInfo.substring(0, pathInfo.indexOf('/'));
        String imagePath = pathInfo.substring(derivate.length());
        LOGGER.debug("derivate: " + derivate + ", image: " + imagePath);
        return new ThumnailInfo(derivate, imagePath);
    }

    private static class ThumnailInfo {
        String derivate, filePath;

        public ThumnailInfo(final String derivate, final String imagePath) {
            this.derivate = derivate;
            this.filePath = imagePath;
        }

        @Override
        public String toString() {
            return "TileInfo [derivate=" + derivate + ", filePath=" + filePath + "]";
        }
    }

}
