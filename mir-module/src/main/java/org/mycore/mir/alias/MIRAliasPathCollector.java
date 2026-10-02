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

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Stream;

import org.mycore.access.MCRAccessManager;
import org.mycore.common.MCRConstants;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mods.MCRMODSWrapper;

/**
 * Collects the alias paths of objects along their <code>mods:relatedItem</code>, e.g.
 * <code>oa/journal/volume-1</code> for a volume with the alias <code>volume-1</code> in a journal with the
 * alias <code>oa/journal</code>. This is the reverse of {@link MIRAliasResolver}.
 */
public class MIRAliasPathCollector {

    /**
     * @param objectIds the objects to start with, e.g. the related items selected in the editor
     * @return the distinct, non-empty alias paths from the root objects down to the given objects
     */
    public List<String> collect(List<String> objectIds) {
        return objectIds.stream()
            .flatMap(objectId -> collect(objectId, Set.of()).stream())
            .filter(path -> !path.isEmpty())
            .distinct()
            .toList();
    }

    private List<String> collect(String objectId, Set<String> visited) {
        if (visited.contains(objectId)) {
            return List.of();
        }
        Optional<AliasInfo> info = getAliasInfo(objectId);
        if (info.isEmpty()) {
            return List.of();
        }
        String alias = info.get().alias();
        if (info.get().relatedIds().isEmpty()) {
            return List.of(alias);
        }
        Set<String> visitedNow = new HashSet<>(visited);
        visitedNow.add(objectId);
        List<String> paths = new ArrayList<>();
        for (String relatedId : info.get().relatedIds()) {
            for (String parentPath : collect(relatedId, visitedNow)) {
                paths.add(join(parentPath, alias));
            }
        }
        return paths;
    }

    /**
     * @return the alias and the related objects of the given object, or empty if it is no MODS object, does not
     *     exist or the current user is not allowed to read it
     */
    Optional<AliasInfo> getAliasInfo(String objectId) {
        if (!MCRObjectID.isValid(objectId)) {
            return Optional.empty();
        }
        MCRObjectID id = MCRObjectID.getInstance(objectId);
        // only objects with MODS have related items, e.g. not derivates
        if (!MCRMODSWrapper.isSupported(id) || !MCRMetadataManager.exists(id)
            || !MCRAccessManager.checkPermission(id, MCRAccessManager.PERMISSION_READ)) {
            return Optional.empty();
        }
        MCRObject object = MCRMetadataManager.retrieveMCRObject(id);
        String alias = object.getService().getFlags("alias").stream().findFirst().orElse("").trim();
        List<String> relatedIds = new MCRMODSWrapper(object).getLinkedRelatedItems().stream()
            .map(relatedItem -> relatedItem.getAttributeValue("href", MCRConstants.XLINK_NAMESPACE))
            .filter(MCRObjectID::isValid)
            .toList();
        return Optional.of(new AliasInfo(alias, relatedIds));
    }

    private static String join(String... parts) {
        return String.join("/", Stream.of(parts).filter(part -> !part.isEmpty()).toList());
    }

    record AliasInfo(String alias, List<String> relatedIds) {
    }
}
