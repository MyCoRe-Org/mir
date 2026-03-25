package org.mycore.mir.it.tests;

import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mycore.mir.it.controller.MIRSearchController;
import org.mycore.mir.it.model.MIRComplexSearchQuery;
import org.mycore.mir.it.model.MIRSearchField;
import org.mycore.mir.it.model.MIRSearchFieldCondition;
import org.mycore.mir.it.model.MIRSearchTestDataLoader;
import org.openqa.selenium.By;

/**
 * Integration test for Russian transliteration search via {@code text_ru_latin} field type.
 * <p>
 * The test document {@code mir_mods_00010006} has a Russian title:
 * "Исследования развития современных библиотек"
 * </p>
 * <p>
 * The {@code text_ru_latin} analyzer applies {@code ICUTransformFilterFactory} (Any-Latin) before stemming,
 * so searching with Latin characters should find Cyrillic content.
 * For example, searching for "bibliotek" should match "библиотек" in the title.
 * </p>
 *
 * <p>Requires the MCR ticket (text_ru_latin field type + mods.title.lang.ru.latin field)
 * and the MIR ticket (search form queries ru.latin fields) to be implemented.</p>
 */
public class MIRRussianTransliterationITCase extends MIRITBase {

    private static final String RUSSIAN_DOC_ID = "mir_mods_00010006";

    @Before
    public final void init() throws IOException, InterruptedException {
        MIRSearchTestDataLoader searchTestDataLoader = new MIRSearchTestDataLoader();
        searchTestDataLoader.lazyLoadData(getDriver());
    }

    /**
     * Tests that a Russian title can be found using Latin transliteration.
     * The document title contains "библиотек" (bibliotek in Latin), searching with "bibliotek"
     * should match via the {@code mods.title.lang.ru.latin} field.
     */
    @Test
    public void testTitleSearchWithLatinCharacters() {
        MIRSearchController searchController = new MIRSearchController(getDriver(), getAPPUrlString());
        searchController.setTitle("bibliotek");

        List<String> foundIds = collectResultIds();

        Assert.assertTrue(
            "Searching for 'bibliotek' (Latin) should find Russian document " + RUSSIAN_DOC_ID
                + " via transliteration (found: " + String.join(",", foundIds) + ")",
            foundIds.contains(RUSSIAN_DOC_ID));
    }

    /**
     * Tests that a Russian abstract can be found using Latin transliteration.
     * The document abstract contains "Управление". The ICU Any-Latin transliteration
     * produces "upravlenie". Note: RussianLightStemFilterFactory only operates on Cyrillic,
     * so after transliteration to Latin, no stemming occurs — the search term must be the
     * exact ICU transliteration of a word in the document.
     */
    @Test
    public void testAbstractSearchWithLatinCharacters() {
        MIRSearchController searchController = new MIRSearchController(getDriver(), getAPPUrlString());

        List<MIRComplexSearchQuery> queries = List.of(
            new MIRComplexSearchQuery(MIRSearchFieldCondition.enthält, "upravlenie",
                MIRSearchField.Metadaten));

        searchController.complexSearchBy(queries, null, null, null,
            null, null, null, null, null);

        List<String> foundIds = collectResultIds();

        Assert.assertTrue(
            "Searching for 'upravlenie' (Latin/ICU) should find Russian document " + RUSSIAN_DOC_ID
                + " via transliteration (found: " + String.join(",", foundIds) + ")",
            foundIds.contains(RUSSIAN_DOC_ID));
    }

    private List<String> collectResultIds() {
        return getDriver().waitAndFindElements(By.xpath(".//input[@name='id']"))
            .stream()
            .map(v -> Optional.ofNullable(v.getDomProperty("value"))
                .orElseGet(() -> v.getDomAttribute("value")))
            .collect(Collectors.toList());
    }
}
