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

import java.io.IOException;
import java.io.Serial;
import java.util.Objects;
import java.util.Optional;

import javax.xml.transform.TransformerException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRPathContent;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.frontend.servlets.MCRContentServlet;
import org.xml.sax.SAXException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Delivers objects and derivate files addressed by an alias path, see {@link MIRAliasResolver}.
 * <p>
 * Objects are rendered via the layout service. Files are delivered as they are, unless their name matches
 * {@link MIRAliasConfig#getLayoutFilePattern()}, then they are rendered via the layout service too.
 */
public class MIRAliasContentServlet extends MCRContentServlet {

    @Serial
    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = LogManager.getLogger();

    private transient MIRAliasResolver resolver;

    @Override
    public void init() throws ServletException {
        super.init();
        resolver = new MIRAliasResolver(new MIRAliasSolrIndex());
    }

    @Override
    public MCRContent getContent(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String path = Objects.requireNonNullElse(request.getPathInfo(), "");
        Optional<MIRAliasTarget> target = resolver.resolve(path);
        if (target.isEmpty()) {
            LOGGER.debug("Alias path {} could not be resolved.", path);
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Alias could not be resolved: " + path);
            return null;
        }
        LOGGER.debug("Alias path {} resolved to {}", path, target.get());
        MCRObjectID objectId = MCRObjectID.getInstance(target.get().objectId());
        if (target.get().file().isPresent()) {
            return getFileContent(objectId, target.get().file().get(), request, response);
        }
        return getObjectContent(objectId, request, response);
    }

    private MCRContent getObjectContent(MCRObjectID objectId, HttpServletRequest request,
        HttpServletResponse response) throws IOException {
        if (!MCRAccessManager.checkPermission(objectId, MCRAccessManager.PERMISSION_READ)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        if (!MCRMetadataManager.exists(objectId)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Object " + objectId + " does not exist.");
            return null;
        }
        return transform(MCRXMLMetadataManager.obtainInstance().retrieveContent(objectId), request, response);
    }

    private MCRContent getFileContent(MCRObjectID objectId, MIRAliasTarget.File file, HttpServletRequest request,
        HttpServletResponse response) throws IOException {
        MCRObjectID derivateId = MCRObjectID.getInstance(file.derivateId());
        if (!MCRAccessManager.checkDerivateContentPermission(derivateId, MCRAccessManager.PERMISSION_READ)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        MCRContent content = new MCRPathContent(MCRPath.getPath(file.derivateId(), file.fileName()));
        if (!MIRAliasConfig.getLayoutFilePattern().matcher(file.fileName()).matches()) {
            return content;
        }
        request.setAttribute("XSL.MCRObjectID", objectId.toString());
        request.setAttribute("XSL.MCRDerivateID", derivateId.toString());
        return transform(content, request, response);
    }

    private static MCRContent transform(MCRContent content, HttpServletRequest request,
        HttpServletResponse response) throws IOException {
        try {
            return getLayoutService().getTransformedContent(request, response, content);
        } catch (TransformerException | SAXException e) {
            throw new IOException("Could not transform content.", e);
        }
    }
}
