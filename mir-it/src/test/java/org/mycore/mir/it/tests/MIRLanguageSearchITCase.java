package org.mycore.mir.it.tests;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.mycore.mir.it.controller.MIRSearchController;
import org.mycore.mir.it.model.MIRComplexSearchQuery;
import org.mycore.mir.it.model.MIRSearchField;
import org.mycore.mir.it.model.MIRSearchFieldCondition;
import org.mycore.mir.it.model.MIRSearchTestDataLoader;
import org.openqa.selenium.By;

/**
 * Integration tests for language-specific Solr fields.
 * <p>
 * Each test document contains a title and abstract in a specific language using a <b>plural or inflected</b>
 * word form. The test searches with the <b>singular or base</b> form. A match proves that the language-specific
 * stemmer is working correctly, since {@code text_general} (without stemming) would not match.
 * </p>
 * <p>
 * Stemming proof per language:
 * </p>
 * <ul>
 *   <li><b>de:</b> "Bibliotheken" (plural) vs. search "Bibliothek" (singular) — GermanLightStemFilterFactory</li>
 *   <li><b>en:</b> "Libraries" (plural) vs. search "Library" (singular) — PorterStemFilterFactory</li>
 *   <li><b>es:</b> "bibliotecas" (plural) vs. search "biblioteca" (singular) — SpanishLightStemFilterFactory</li>
 *   <li><b>fr:</b> "bibliothèques" (plural) vs. search "bibliothèque" (singular) — FrenchLightStemFilterFactory</li>
 *   <li><b>it:</b> "biblioteche" (plural) vs. search "biblioteca" (singular) — ItalianLightStemFilterFactory</li>
 *   <li><b>ru:</b> "библиотек" (genitive plural) vs. search "библиотека" (nominative) — RussianLightStemFilterFactory</li>
 *   <li><b>tr:</b> "araştırmalar" (plural) vs. search "araştırma" (singular) — SnowballPorterFilterFactory (Turkish)</li>
 * </ul>
 *
 * <p>These tests require both the MCR and MIR tickets to be implemented:</p>
 * <ul>
 *   <li>MCR: Language-specific Solr field types and MODS indexing XSLT</li>
 *   <li>MIR: Search forms updated to query language-specific fields</li>
 * </ul>
 */
@RunWith(Parameterized.class)
public class MIRLanguageSearchITCase extends MIRITBase {

    private final String language;

    private final String expectedDocId;

    private final String titleSearchTerm;

    private final String abstractSearchTerm;

    public MIRLanguageSearchITCase(String language, String expectedDocId,
        String titleSearchTerm, String abstractSearchTerm) {
        this.language = language;
        this.expectedDocId = expectedDocId;
        this.titleSearchTerm = titleSearchTerm;
        this.abstractSearchTerm = abstractSearchTerm;
    }

    /**
     * Test parameters: language, document ID, stemmed title search term, stemmed abstract search term.
     * The search term is always a different word form than what is stored in the document.
     */
    @Parameterized.Parameters(name = "{0}")
    public static Collection<Object[]> data() {
        return Arrays.asList(new Object[][] {
            // { language, docId, title search (singular/base), abstract search (singular/base) }
            { "de", "mir_mods_00010001", "Bibliothek", "Publikation" },
            { "en", "mir_mods_00010002", "Library", "publication" },
            { "es", "mir_mods_00010003", "biblioteca", "publicación" },
            { "fr", "mir_mods_00010004", "bibliothèque", "publication" },
            { "it", "mir_mods_00010005", "biblioteca", "pubblicazione" },
            { "ru", "mir_mods_00010006", "\u0431\u0438\u0431\u043b\u0438\u043e\u0442\u0435\u043a\u0430",
                "\u043f\u0443\u0431\u043b\u0438\u043a\u0430\u0446\u0438\u044f" },
            { "tr", "mir_mods_00010007", "araştırma", "araç" },
        });
    }

    @Before
    public final void init() throws IOException, InterruptedException {
        MIRSearchTestDataLoader searchTestDataLoader = new MIRSearchTestDataLoader();
        searchTestDataLoader.lazyLoadData(getDriver());
        // navigate to start page so the "Suche" nav link is available
        getDriver().get(getAPPUrlString());
    }

    /**
     * Tests that language-specific title stemming works via the simple search form.
     * Searches with the base/singular form of a word that appears in plural/inflected form in the title.
     */
    @Test
    public void testTitleStemming() {
        MIRSearchController searchController = new MIRSearchController(getDriver(), getAPPUrlString());
        searchController.setTitle(titleSearchTerm);

        List<String> foundIds = collectResultIds();

        Assert.assertTrue(
            "Language [" + language + "]: title search for '" + titleSearchTerm
                + "' should find " + expectedDocId + " (found: " + String.join(",", foundIds) + ")",
            foundIds.contains(expectedDocId));
    }

    /**
     * Tests that language-specific abstract stemming works via the complex search form.
     * Uses the "Metadaten" (allMeta) field since there is no dedicated abstract field in the current form.
     * Searches with the base/singular form of a word that appears in plural/inflected form in the abstract.
     */
    @Test
    public void testAbstractStemming() {
        MIRSearchController searchController = new MIRSearchController(getDriver(), getAPPUrlString());

        List<MIRComplexSearchQuery> queries = List.of(
            new MIRComplexSearchQuery(MIRSearchFieldCondition.enthält, abstractSearchTerm,
                MIRSearchField.Metadaten));

        searchController.complexSearchBy(queries, null, null, null,
            null, null, null, null, null);

        List<String> foundIds = collectResultIds();

        Assert.assertTrue(
            "Language [" + language + "]: abstract search for '" + abstractSearchTerm
                + "' should find " + expectedDocId + " (found: " + String.join(",", foundIds) + ")",
            foundIds.contains(expectedDocId));
    }

    private List<String> collectResultIds() {
        return getDriver().waitAndFindElements(By.xpath(".//input[@name='id']"))
            .stream()
            .map(v -> Optional.ofNullable(v.getDomProperty("value"))
                .orElseGet(() -> v.getDomAttribute("value")))
            .collect(Collectors.toList());
    }
}
