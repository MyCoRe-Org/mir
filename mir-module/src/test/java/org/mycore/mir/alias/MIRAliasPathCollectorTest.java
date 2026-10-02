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
import static org.mockito.Mockito.spy;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

public class MIRAliasPathCollectorTest {

    private static final String JOURNAL = "mir_mods_00000001";

    private static final String VOLUME = "mir_mods_00000002";

    private static final String SERIES = "mir_mods_00000003";

    private static final String UNKNOWN = "mir_mods_00000099";

    private MIRAliasPathCollector collector;

    @BeforeEach
    public void setUp() {
        collector = spy(new MIRAliasPathCollector());
        // objects that do not exist or are not readable
        doReturn(Optional.empty()).when(collector).getAliasInfo(anyString());
        addObject(JOURNAL, "oa/journal");
        addObject(SERIES, "series");
        addObject(VOLUME, "volume-1", JOURNAL);
    }

    private void addObject(String objectId, String alias, String... relatedIds) {
        doReturn(Optional.of(new MIRAliasPathCollector.AliasInfo(alias, List.of(relatedIds))))
            .when(collector).getAliasInfo(objectId);
    }

    @Test
    public void collectRootObject() {
        assertEquals(List.of("oa/journal"), collector.collect(List.of(JOURNAL)));
    }

    @Test
    public void collectAlongRelatedItems() {
        assertEquals(List.of("oa/journal/volume-1"), collector.collect(List.of(VOLUME)));
    }

    @Test
    public void collectMultiplePaths() {
        addObject(VOLUME, "volume-1", JOURNAL, SERIES);
        assertEquals(List.of("oa/journal/volume-1", "series/volume-1"), collector.collect(List.of(VOLUME)));
        assertEquals(List.of("oa/journal/volume-1", "series/volume-1", "oa/journal"),
            collector.collect(List.of(VOLUME, JOURNAL, VOLUME)));
    }

    @Test
    public void collectSkipsObjectsWithoutAlias() {
        String article = "mir_mods_00000004";
        addObject(article, "", VOLUME);
        assertEquals(List.of("oa/journal/volume-1"), collector.collect(List.of(article)));
        addObject(VOLUME, "", JOURNAL);
        assertEquals(List.of("oa/journal"), collector.collect(List.of(article)));
    }

    @Test
    public void collectSkipsUnknownObjects() {
        assertEquals(List.of(), collector.collect(List.of(UNKNOWN)));
        addObject(VOLUME, "volume-1", UNKNOWN);
        assertEquals(List.of(), collector.collect(List.of(VOLUME)));
    }

    @Test
    public void collectCyclicRelations() {
        addObject(JOURNAL, "oa/journal", VOLUME);
        assertEquals(List.of(), collector.collect(List.of(VOLUME)));
    }
}
