package org.mycore.mir.it.tests;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Collections;
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
import org.mycore.mir.it.model.MIRDNBClassification;
import org.mycore.mir.it.model.MIRGenre;
import org.mycore.mir.it.model.MIRInstitutes;
import org.mycore.mir.it.model.MIRLanguage;
import org.mycore.mir.it.model.MIRLicense;
import org.mycore.mir.it.model.MIRStatus;
import org.mycore.mir.it.model.MIRTitleInfo;
import org.mycore.mir.it.model.MIRTitleType;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class MIRSimpleSearchITCase extends MIRITBase {
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
        getDriver()
            .waitFor(MCRExpectedConditions.documentReadyState(MCRExpectedConditions.DocumentReadyState.complete));
    }

    @Test
    public final void searchByNone() {

        searchController.simpleSearchBy(null, null, null, null, null, null);
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
    public void searchByTitle() {
        searchController.simpleSearchBy(MIRTestData.TITLE, null, null, null, null, null);
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
    public void searchByName() {
        searchController.simpleSearchBy(null, MIRTestData.AUTHOR_2, null, null, null, null);
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
    public void searchByMetadata() {
        searchController.simpleSearchBy(null, null, MIRTestData.SIGNATURE, null, null, null);
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
    public void searchByFiles() {
        searchController.simpleSearchBy(null, null, null, MIRTestData.TEXT, null, null);
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
    public void searchByInstitutes() {
        searchController.simpleSearchBy(null, null, null, null, MIRInstitutes.Universität_in_Deutschland, null);
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
    public void searchByStatus() {
        searchController.simpleSearchBy(null, null, null, null, null, MIRStatus.gesperrt);
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
