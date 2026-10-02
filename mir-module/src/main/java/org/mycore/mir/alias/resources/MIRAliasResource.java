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

package org.mycore.mir.alias.resources;

import java.util.List;
import java.util.stream.Stream;

import org.mycore.mir.alias.MIRAliasConfig;
import org.mycore.mir.alias.MIRAliasPathCollector;

import com.google.gson.Gson;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;

/**
 * Provides the alias paths for the URL preview in the editor.
 * <p>
 * The resource is always registered, but answers with 404 if the alias feature is disabled.
 */
@Path("mir/alias")
public class MIRAliasResource {

    /**
     * Returns the paths below the web application base URL an object with the given related items is reachable
     * with, without the alias of the object itself, e.g. <code>["go/oa/journal/volume-1"]</code>.
     *
     * @param relatedItems the ids of the related items currently selected in the editor
     */
    @GET
    @Path("paths")
    @Produces(MediaType.APPLICATION_JSON)
    public String getPaths(@QueryParam("relatedItem") List<String> relatedItems) {
        if (!MIRAliasConfig.isEnabled()) {
            throw new NotFoundException();
        }
        List<String> parentPaths = new MIRAliasPathCollector().collect(relatedItems);
        List<String> paths = MIRAliasConfig.getPrefixes().stream()
            .flatMap(prefix -> parentPaths.isEmpty()
                ? Stream.of(prefix)   : parentPaths.stream().map(parentPath -> prefix + "/" + parentPath))
            .toList();
        return new Gson().toJson(paths);
    }
}
