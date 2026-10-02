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

import java.nio.file.Files;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRPath;

/**
 * Resolves an alias path to an object or to a file of one of its derivates.
 * <p>
 * An alias path consists of
 * <ol>
 *   <li>the alias of a root object, which may contain slashes itself,</li>
 *   <li>any number of aliases of objects that refer to the previous object via <code>mods:relatedItem</code>,</li>
 *   <li>optionally the name of a file in a derivate of the last object.</li>
 * </ol>
 * Aliases are compared case-insensitively, file names case-sensitively.
 * The aliases are looked up via {@link MIRAliasSolrIndex}.
 */
public class MIRAliasResolver {

    private final MIRAliasSolrIndex index;

    public MIRAliasResolver(MIRAliasSolrIndex index) {
        this.index = index;
    }

    /**
     * @param path the alias path, e.g. <code>oa/journal/volume-1/article.pdf</code>
     * @return the resolved target or empty if the path cannot be resolved
     */
    public Optional<MIRAliasTarget> resolve(String path) {
        List<String> segments = split(path);
        // the root alias may contain slashes, so try the longest candidate first: "a/b/c", "a/b", "a"
        for (int length = segments.size(); length > 0; length--) {
            String rootAlias = String.join("/", segments.subList(0, length));
            Optional<String> rootObjectId = index.findObjectId(rootAlias);
            if (rootObjectId.isEmpty()) {
                continue;
            }
            List<String> remaining = segments.subList(length, segments.size());
            Optional<MIRAliasTarget> target = resolveFrom(rootObjectId.get(), remaining);
            if (target.isPresent()) {
                return target;
            }
        }
        return Optional.empty();
    }

    /**
     * Walks down from the given object along the related objects until the path is consumed.
     */
    private Optional<MIRAliasTarget> resolveFrom(String objectId, List<String> path) {
        String currentObjectId = objectId;
        List<String> remaining = path;
        while (!remaining.isEmpty()) {
            if (remaining.size() == 1) {
                String fileName = remaining.getFirst();
                Optional<String> derivateId = findDerivate(currentObjectId, fileName);
                if (derivateId.isPresent()) {
                    return Optional.of(MIRAliasTarget.file(currentObjectId, derivateId.get(), fileName));
                }
            }
            Optional<MIRAliasSolrIndex.AliasedObject> related = findRelatedObject(currentObjectId, remaining);
            if (related.isEmpty()) {
                return Optional.empty();
            }
            // aliases are never empty, so every step consumes at least one segment
            currentObjectId = related.get().objectId();
            remaining = remaining.subList(split(related.get().alias()).size(), remaining.size());
        }
        return Optional.of(MIRAliasTarget.object(currentObjectId));
    }

    /**
     * @return the related object whose alias is the beginning of the path, the longest alias wins
     */
    private Optional<MIRAliasSolrIndex.AliasedObject> findRelatedObject(String objectId, List<String> path) {
        MIRAliasSolrIndex.AliasedObject bestMatch = null;
        int bestMatchLength = 0;
        for (MIRAliasSolrIndex.AliasedObject related : index.findRelatedObjects(objectId)) {
            List<String> alias = split(related.alias());
            if (alias.size() > bestMatchLength && startsWithIgnoreCase(path, alias)) {
                bestMatch = related;
                bestMatchLength = alias.size();
            }
        }
        return Optional.ofNullable(bestMatch);
    }

    /**
     * @return the id of the first derivate of the object that contains a file with the given name
     */
    Optional<String> findDerivate(String objectId, String fileName) {
        return MCRMetadataManager.getDerivateIds(MCRObjectID.getInstance(objectId)).stream()
            .map(MCRObjectID::toString)
            .filter(derivateId -> Files.isRegularFile(MCRPath.getPath(derivateId, fileName)))
            .findFirst();
    }

    private static boolean startsWithIgnoreCase(List<String> segments, List<String> prefix) {
        if (prefix.size() > segments.size()) {
            return false;
        }
        for (int i = 0; i < prefix.size(); i++) {
            if (!segments.get(i).equalsIgnoreCase(prefix.get(i))) {
                return false;
            }
        }
        return true;
    }
    
    private static List<String> split(String path) {
        return Arrays.stream(path.split("/"))
            .filter(segment -> !segment.isEmpty())
            .toList();
    }

}
