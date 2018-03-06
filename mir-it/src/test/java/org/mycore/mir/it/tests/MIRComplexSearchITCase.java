package org.mycore.mir.it.tests;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mycore.common.selenium.util.MCRBy;
import org.mycore.common.selenium.util.MCRExpectedConditions;
import org.mycore.mir.it.controller.MIRModsEditorController;
import org.mycore.mir.it.controller.MIRPublishEditorController;
import org.mycore.mir.it.controller.MIRSearchController;
import org.mycore.mir.it.controller.MIRUserController;
import org.mycore.mir.it.model.MIRComplexSearchQuery;
import org.mycore.mir.it.model.MIRDNBClassification;
import org.mycore.mir.it.model.MIRGenre;
import org.mycore.mir.it.model.MIRIdentifier;
import org.mycore.mir.it.model.MIRInstitutes;
import org.mycore.mir.it.model.MIRLanguage;
import org.mycore.mir.it.model.MIRLicense;
import org.mycore.mir.it.model.MIRSearchField;
import org.mycore.mir.it.model.MIRSearchFieldCondition;
import org.mycore.mir.it.model.MIRStatus;
import org.mycore.mir.it.model.MIRTitleInfo;
import org.mycore.mir.it.model.MIRTitleType;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class MIRComplexSearchITCase extends MIRITBase{
    MIRUserController userController;
    MIRSearchController searchController;
    MIRPublishEditorController publishEditorController;
    static boolean created = false;

    @Before
    public final void init() throws InterruptedException, IOException {
        String appURL = getAPPUrlString();
        userController = new MIRUserController(getDriver(), appURL);
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);

        publishEditorController = new MIRPublishEditorController(getDriver(), appURL);
        editorController = new MIRModsEditorController(getDriver(), appURL);
        searchController = new MIRSearchController(driver, appURL);

        if (created == false) {
            createDocument();
            created = true;
        }

    }


    public void createDocument() throws InterruptedException, IOException {
        publishEditorController.open(() -> {
        });
        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.setStatus(MIRStatus.gesperrt);
        editorController.setGenres(Collections.singletonList(MIRGenre.article));
        editorController.setTitleInfo(Stream.of(
            new MIRTitleInfo("Der", MIRLanguage.german, MIRTitleType.mainTitle, MIRTestData.TITLE,
                MIRTestData.SUB_TITLE)).collect(Collectors.toList()));
        editorController.setAuthor(MIRTestData.AUTHOR_2);
        editorController.setInstitution(MIRInstitutes.Universität_in_Deutschland);
        editorController.setPublisher(MIRTestData.SIGNATURE);
        Map.Entry<MIRIdentifier,String> identifierStringMap =
            new AbstractMap.SimpleEntry<MIRIdentifier, String>(MIRIdentifier.doi, "10.1000/182");
        editorController.setIdentifier(Collections.singletonList(identifierStringMap));
        String timeStamp = new SimpleDateFormat("yyyy-MM-dd").format(Calendar.getInstance().getTime());
        editorController.setIssueDate(timeStamp);
        editorController.setClassifications(Collections.singletonList(MIRDNBClassification._000));
        editorController.setAccessConditions(MIRLicense.cc_by_40);
        editorController.save();

        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));
        driver.waitAndFindElement(MCRBy.partialLinkText("Aktionen"),
            ExpectedConditions::elementToBeClickable).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("Hinzufügen eines Datenobjektes"),
            ExpectedConditions::elementToBeClickable).click();

        File upload = File.createTempFile("test", ".txt");
        BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(upload));
        bufferedWriter.write("Test_Text");
        bufferedWriter.close();

        String path = upload.getAbsolutePath();
        getDriver().waitAndFindElement(By.xpath(".//input[@id='fileToUpload']")).sendKeys(path);
        getDriver().waitAndFindElement(MCRBy.partialText("Abschicken")).click();
        WebElement goToMetadata = getDriver()
            .waitAndFindElement(By.xpath(".//button[contains(text(),'Fertig') and not(@disabled)]"));
        goToMetadata.click();
        getDriver().waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        getDriver().waitFor(MCRExpectedConditions.documentReadyState(MCRExpectedConditions.DocumentReadyState.complete));

    }


    @Test
    public final void searchByNone() {
        searchController.complexSearchBy(Collections.EMPTY_LIST, null, null, null, null,
            null, null, null, null);
        driver.waitFor(ExpectedConditions.titleContains("Suchergebnisse"));

        try {
            String noDocumentsFoundText = "Keine Dokumente gefunden";
            driver.findElement(MCRBy.partialText(noDocumentsFoundText));
            Assert.fail(noDocumentsFoundText + " is present!");
        } catch (NoSuchElementException e) {
            // this is good
        }
    }

    @Test
    public final void searchByIdentifier() {
        searchController.complexSearchBy(Collections.EMPTY_LIST, "10.1000/182", null, null, null,
            null, null, null, null);
        driver.waitFor(ExpectedConditions.titleContains("Suchergebnisse"));

        try {
            String noDocumentsFoundText = "Keine Dokumente gefunden";
            driver.findElement(MCRBy.partialText(noDocumentsFoundText));
            Assert.fail(noDocumentsFoundText + " is present!");
        } catch (NoSuchElementException e) {
            // this is good
        }
    }

    @Test
    public final void searchBymirInstitute() {
        searchController.complexSearchBy(Collections.EMPTY_LIST, null, MIRInstitutes.Universität_in_Deutschland,
            null, null, null, null, null, null);
        driver.waitFor(ExpectedConditions.titleContains("Suchergebnisse"));

        try {
            String noDocumentsFoundText = "Keine Dokumente gefunden";
            driver.findElement(MCRBy.partialText(noDocumentsFoundText));
            Assert.fail(noDocumentsFoundText + " is present!");
        } catch (NoSuchElementException e) {
            // this is good
        }
    }

    @Test
    public final void searchByClassification() {
        searchController.complexSearchBy(Collections.EMPTY_LIST, null, null, MIRDNBClassification._000.getValue(),
            null, null, null, null, null);
        driver.waitFor(ExpectedConditions.titleContains("Suchergebnisse"));

        try {
            String noDocumentsFoundText = "Keine Dokumente gefunden";
            driver.findElement(MCRBy.partialText(noDocumentsFoundText));
            Assert.fail(noDocumentsFoundText + " is present!");
        } catch (NoSuchElementException e) {
            // this is good
        }
    }

    @Test
    public final void searchByLicense() {
        searchController.complexSearchBy(Collections.EMPTY_LIST, null, null,
            null, null, MIRLicense.cc_by_40.getValue(), null, null, null);
        driver.waitFor(ExpectedConditions.titleContains("Suchergebnisse"));

        try {
            String noDocumentsFoundText = "Keine Dokumente gefunden";
            driver.findElement(MCRBy.partialText(noDocumentsFoundText));
            Assert.fail(noDocumentsFoundText + " is present!");
        } catch (NoSuchElementException e) {
            // this is good
        }
    }

    @Test
    public final void searchByStatus() {
        searchController.complexSearchBy(Collections.EMPTY_LIST, null, null,
            null, null, null, MIRStatus.gesperrt, null, null);
        driver.waitFor(ExpectedConditions.titleContains("Suchergebnisse"));

        try {
            String noDocumentsFoundText = "Keine Dokumente gefunden";
            driver.findElement(MCRBy.partialText(noDocumentsFoundText));
            Assert.fail(noDocumentsFoundText + " is present!");
        } catch (NoSuchElementException e) {
            // this is good
        }
    }

    @Test
    public final void searchByDate() {
        String timeStamp = new SimpleDateFormat("yyyy-MM-dd").format(Calendar.getInstance().getTime());
        searchController.complexSearchBy(Collections.EMPTY_LIST, null, null,
            null, null, null, null, timeStamp, null);
        driver.waitFor(ExpectedConditions.titleContains("Suchergebnisse"));

        try {
            String noDocumentsFoundText = "Keine Dokumente gefunden";
            driver.findElement(MCRBy.partialText(noDocumentsFoundText));
            Assert.fail(noDocumentsFoundText + " is present!");
        } catch (NoSuchElementException e) {
            // this is good
        }
    }

    @Test
    public final void searchByFullText() {
        searchController.complexSearchBy(Collections.EMPTY_LIST, null, null,
            null, null, null, null, null, "condFullText");
        driver.waitFor(ExpectedConditions.titleContains("Suchergebnisse"));

        try {
            String noDocumentsFoundText = "Keine Dokumente gefunden";
            driver.findElement(MCRBy.partialText(noDocumentsFoundText));
            Assert.fail(noDocumentsFoundText + " is present!");
        } catch (NoSuchElementException e) {
            // this is good
        }
    }


    @Test
    public void searchByComplexQuery()  {
        List<MIRComplexSearchQuery> complexSearchQueries = new ArrayList<>();
        complexSearchQueries.add(new MIRComplexSearchQuery(MIRSearchFieldCondition.enthält, MIRTestData.TITLE,
            MIRSearchField.Titel));
        complexSearchQueries.add(new MIRComplexSearchQuery(MIRSearchFieldCondition.wie_, MIRTestData.AUTHOR_2,
            MIRSearchField.Autor));
        complexSearchQueries.add(new MIRComplexSearchQuery(MIRSearchFieldCondition.Phrase, MIRTestData.SIGNATURE,
            MIRSearchField.Metadaten));

        searchController.complexSearchBy(complexSearchQueries, null, null, null,
            null, null, null, null, null);
        driver.waitFor(ExpectedConditions.titleContains("Suchergebnisse"));

        try {
            String noDocumentsFoundText = "Keine Dokumente gefunden";
            driver.findElement(MCRBy.partialText(noDocumentsFoundText));
            Assert.fail(noDocumentsFoundText + " is present!");
        } catch (NoSuchElementException e) {
            // this is good

        }
    }

}
