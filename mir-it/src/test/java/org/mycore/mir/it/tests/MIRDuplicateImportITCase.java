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

package org.mycore.mir.it.tests;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mycore.common.selenium.util.MCRBy;
import org.mycore.mir.it.controller.MIRImportController.Result;
import org.mycore.mir.it.controller.MIRUserController;
import org.mycore.mir.it.model.MIRAccess;
import org.mycore.mir.it.model.MIRDNBClassification;
import org.mycore.mir.it.model.MIRGenre;
import org.mycore.mir.it.model.MIRIdentifier;
import org.mycore.mir.it.model.MIRLanguage;
import org.mycore.mir.it.model.MIRLicense;
import org.mycore.mir.it.model.MIRStatus;
import org.mycore.mir.it.model.MIRTitleInfo;
import org.mycore.mir.it.model.MIRTitleType;
import org.openqa.selenium.WebElement;

import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

/**
 * Tests the duplicate check of the identifier import: possible duplicates are shown on a confirmation page before the
 * editor opens, objects in the states configured by {@code MIR.Dedup.FilterDocumentsInStates} (default
 * {@code blocked,deleted}) are not.
 * <p>
 * Every test uses its own synthetic DOI and deletes the documents it created, so the tests do not depend on each
 * other. The application under test is configured without data sources for DOIs (see
 * {@code MCR.MODS.EnrichmentResolver.DataSources.import} in the integration test properties), so the import does not
 * query external databases. The imported object then only contains the identifier, which is all the duplicate check
 * needs.
 */
public class MIRDuplicateImportITCase extends MIRITBase {

    private static final String DOI_NO_DUPLICATE = "10.1002/mir.it.no-duplicate";

    private static final String DOI_PUBLISHED = "10.1002/mir.it.published";

    private static final String DOI_BLOCKED = "10.1002/mir.it.blocked";

    private static final String DOI_DELETED = "10.1002/mir.it.deleted";

    private static final String TITLE_PUBLISHED = "Duplicate import IT published";

    private static final String TITLE_BLOCKED = "Duplicate import IT blocked";

    private static final String TITLE_DELETED = "Duplicate import IT deleted";

    private static final String TITLE_PUBLISHED_NEXT_TO_BLOCKED = "Duplicate import IT published, same DOI as blocked";

    private static final String TITLE_PUBLISHED_NEXT_TO_DELETED = "Duplicate import IT published, same DOI as deleted";

    private static final Pattern OBJECT_ID_IN_URL = Pattern.compile("/receive/([^/?;#]+)");

    private final List<String> createdObjectIds = new ArrayList<>();

    @Before
    public final void init() {
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
    }

    @After
    @Override
    public void tearDown() {
        super.tearDown();
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
        createdObjectIds.forEach(id -> driver.get(getAPPUrlString() + "/servlets/object/delete?id=" + id));
        createdObjectIds.clear();
        userController.logoutIfLoggedIn();
    }

    @Test
    public void testImportWithoutDuplicateOpensEditor() {
        Assert.assertEquals("Without existing objects the editor should open directly.", Result.EDITOR,
            importIdentifier(DOI_NO_DUPLICATE));
    }

    @Test
    public void testDuplicateIsListedBeforeEditorOpens() {
        createDocument(TITLE_PUBLISHED, DOI_PUBLISHED, MIRStatus.veröffentlicht);
        Assert.assertEquals("The duplicate check should be shown.", Result.DUPLICATE_CHECK,
            importIdentifier(DOI_PUBLISHED));
        List<WebElement> duplicates = importController.getListedDuplicates();
        Assert.assertEquals("Exactly the existing document should be listed.", 1, duplicates.size());
        Assert.assertTrue("The existing document should be listed.",
            duplicates.get(0).getText().contains(TITLE_PUBLISHED));
    }

    @Test
    public void testBlockedDuplicateIsNotListed() throws IOException, InterruptedException {
        assertOnlyPublishedDuplicateIsListed(DOI_BLOCKED, MIRStatus.gesperrt, TITLE_BLOCKED,
            TITLE_PUBLISHED_NEXT_TO_BLOCKED);
    }

    @Test
    public void testDeletedDuplicateIsNotListed() throws IOException, InterruptedException {
        assertOnlyPublishedDuplicateIsListed(DOI_DELETED, MIRStatus.gelöscht, TITLE_DELETED,
            TITLE_PUBLISHED_NEXT_TO_DELETED);
    }

    /**
     * Creates a document in a filtered state and a published document with the same DOI. The deduplication API
     * has to report them as a pair, which proves that a deduplication key was written for the filtered document.
     * The import of that DOI must then only list the published document.
     */
    private void assertOnlyPublishedDuplicateIsListed(String doi, MIRStatus filteredStatus, String filteredTitle,
        String publishedTitle) throws IOException, InterruptedException {
        String filteredId = createDocument(filteredTitle, doi, filteredStatus);
        String publishedId = createDocument(publishedTitle, doi, MIRStatus.veröffentlicht);
        Assert.assertTrue("The deduplication API should report the " + filteredStatus.getValue()
            + " document as possible duplicate of the published one.",
            getPossibleDuplicates(filteredId).contains(publishedId));

        Assert.assertEquals("The duplicate check should be shown for the published document.",
            Result.DUPLICATE_CHECK, importIdentifier(doi));
        List<WebElement> duplicates = importController.getListedDuplicates();
        Assert.assertEquals("Only the published document should be listed, not the "
            + filteredStatus.getValue() + " one.", 1, duplicates.size());
        Assert.assertTrue("The published document should be listed.",
            duplicates.get(0).getText().contains(publishedTitle));
    }

    /**
     * Asks the deduplication API, as administrator, for the possible duplicates of an object. Unlike the import
     * dialog, the API does not filter by object state.
     *
     * @param objectId the id of the object
     * @return the ids of the objects that share a deduplication key with the given object
     */
    private List<String> getPossibleDuplicates(String objectId) throws IOException, InterruptedException {
        String credentials = MIRUserController.ADMIN_LOGIN + ":" + MIRUserController.ADMIN_PASSWD;
        HttpRequest request = HttpRequest
            .newBuilder(URI.create(getAPPUrlString() + "/api/dedup/duplicates/" + objectId))
            .header("Accept", "application/json")
            .header("Authorization",
                "Basic " + Base64.getEncoder().encodeToString(credentials.getBytes(StandardCharsets.UTF_8)))
            .GET()
            .build();
        HttpResponse<String> response = HttpClient.newHttpClient()
            .send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        Assert.assertEquals("The deduplication API should answer: " + response.body(), 200,
            response.statusCode());
        List<String> otherIds = new ArrayList<>();
        for (JsonElement pair : JsonParser.parseString(response.body()).getAsJsonArray()) {
            String objectId1 = pair.getAsJsonObject().get("objectId1").getAsString();
            String objectId2 = pair.getAsJsonObject().get("objectId2").getAsString();
            otherIds.add(objectId.equals(objectId1) ? objectId2 : objectId1);
        }
        return otherIds;
    }

    private Result importIdentifier(String doi) {
        importController.open();
        publishEditorController.selectType(MIRGenre.article, null);
        importController.setIdentifier("doi", doi);
        publishEditorController.submit();
        return importController.waitForResult();
    }

    /**
     * Creates a document in the admin editor and returns its id.
     */
    private String createDocument(String title, String doi, MIRStatus status) {
        publishEditorController.openAdmin(null);
        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.setGenres(Stream.of(MIRGenre.article).collect(Collectors.toList()));
        editorController.setTitleInfo(Stream
            .of(new MIRTitleInfo(null, MIRLanguage.german, MIRTitleType.mainTitle, title, null))
            .collect(Collectors.toList()));
        editorController.setIdentifier(
            Stream.of(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, doi)).collect(Collectors.toList()));
        editorController.setAccessConditions(MIRAccess.public_);
        editorController.setAccessConditions(MIRLicense.cc_by_40);
        editorController.setClassifications(Stream.of(MIRDNBClassification._004).collect(Collectors.toList()));
        editorController.setStatus(status);
        editorController.save();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));
        Matcher matcher = OBJECT_ID_IN_URL.matcher(driver.getCurrentUrl());
        Assert.assertTrue("The saved document should be shown: " + driver.getCurrentUrl(), matcher.find());
        String objectId = matcher.group(1);
        createdObjectIds.add(objectId);
        return objectId;
    }
}
