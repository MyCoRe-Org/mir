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

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

public class MIRAliasResolverTest {

    private static final String JOURNAL = "mir_mods_00000001";

    private static final String VOLUME = "mir_mods_00000002";

    private static final String ARTICLE = "mir_mods_00000003";

    private static final String DERIVATE = "mir_derivate_00000001";

    private final Map<String, String> aliases = new HashMap<>();

    private final Map<String, List<String>> relatedObjects = new HashMap<>();

    private MIRAliasResolver resolver;

    @BeforeEach
    public void setUp() {
        addObject(JOURNAL, "oa/Journal", null);
        addObject(VOLUME, "Volume-1", JOURNAL);
        addObject(ARTICLE, "article", VOLUME);

        MIRAliasSolrIndex index = mock(MIRAliasSolrIndex.class);
        // Solr indexes the alias lowercase, so the lookup is case-insensitive
        when(index.findObjectId(anyString())).thenAnswer(invocation -> aliases.entrySet().stream()
            .filter(entry -> entry.getValue().equalsIgnoreCase(invocation.getArgument(0)))
            .map(Map.Entry::getKey)
            .findFirst());
        when(index.findRelatedObjects(anyString())).thenAnswer(invocation -> relatedObjects
            .getOrDefault(invocation.<String>getArgument(0), List.of()).stream()
            .map(id -> new MIRAliasSolrIndex.AliasedObject(id, aliases.get(id)))
            .toList());

        resolver = spy(new MIRAliasResolver(index));
        doReturn(Optional.empty()).when(resolver).findDerivate(anyString(), anyString());
        doReturn(Optional.of(DERIVATE)).when(resolver).findDerivate(ARTICLE, "Article.PDF");
    }

    private void addObject(String objectId, String alias, String relatedTo) {
        aliases.put(objectId, alias);
        if (relatedTo != null) {
            relatedObjects.computeIfAbsent(relatedTo, id -> new ArrayList<>()).add(objectId);
        }
    }

    private static Optional<MIRAliasTarget> object(String objectId) {
        return Optional.of(MIRAliasTarget.object(objectId));
    }

    private static Optional<MIRAliasTarget> file(String objectId, String derivateId, String fileName) {
        return Optional.of(MIRAliasTarget.file(objectId, derivateId, fileName));
    }

    @Test
    public void resolveRootAliasWithSlash() {
        assertEquals(object(JOURNAL), resolver.resolve("/oa/Journal"));
        assertEquals(object(JOURNAL), resolver.resolve("oa/Journal/"));
        assertEquals(object(JOURNAL), resolver.resolve("//oa//Journal//"));
    }

    @Test
    public void resolveAliasCaseInsensitive() {
        assertEquals(object(JOURNAL), resolver.resolve("/OA/journal"));
        assertEquals(object(VOLUME), resolver.resolve("/oa/journal/VOLUME-1"));
        assertEquals(object(ARTICLE), resolver.resolve("/Oa/Journal/volume-1/Article"));
    }

    @Test
    public void resolveFileKeepsCase() {
        assertEquals(file(ARTICLE, DERIVATE, "Article.PDF"),
            resolver.resolve("/oa/journal/volume-1/article/Article.PDF"));
        assertEquals(Optional.empty(), resolver.resolve("/oa/journal/volume-1/article/article.pdf"));
    }

    @Test
    public void resolveOnlyCompleteSegments() {
        assertEquals(Optional.empty(), resolver.resolve("/oa/journal/volume-10"));
        assertEquals(Optional.empty(), resolver.resolve("/oa/journ"));
    }

    @Test
    public void resolveLongestRelatedAlias() {
        String special = "mir_mods_00000004";
        addObject(special, "volume-1/special", JOURNAL);
        assertEquals(object(special), resolver.resolve("/oa/journal/volume-1/special"));
        assertEquals(object(VOLUME), resolver.resolve("/oa/journal/volume-1"));
    }

    @Test
    public void resolveShorterRootAlias() {
        String oa = "mir_mods_00000005";
        addObject(oa, "oa", null);
        String other = "mir_mods_00000006";
        addObject(other, "other", oa);
        assertEquals(object(other), resolver.resolve("/oa/other"));
        assertEquals(object(JOURNAL), resolver.resolve("/oa/journal"));
    }

    @Test
    public void resolveCyclicRelations() {
        relatedObjects.computeIfAbsent(ARTICLE, id -> new ArrayList<>()).add(JOURNAL);
        assertEquals(Optional.empty(), resolver.resolve("/oa/journal/volume-1/article/unknown"));
    }

    @Test
    public void resolveUnknownAlias() {
        assertEquals(Optional.empty(), resolver.resolve(""));
        assertEquals(Optional.empty(), resolver.resolve("/"));
        assertEquals(Optional.empty(), resolver.resolve("/unknown"));
    }
}
