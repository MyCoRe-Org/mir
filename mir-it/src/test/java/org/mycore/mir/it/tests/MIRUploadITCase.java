package org.mycore.mir.it.tests;

import java.io.File;
import java.io.IOException;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mycore.common.selenium.util.MCRBy;
import org.mycore.mir.it.controller.MIRModsEditorController;
import org.mycore.mir.it.controller.MIRPublishEditorController;
import org.mycore.mir.it.controller.MIRUploadController;
import org.mycore.mir.it.controller.MIRUserController;
import org.mycore.mir.it.model.MIRAccess;
import org.mycore.mir.it.model.MIRDNBClassification;
import org.mycore.mir.it.model.MIRGenre;
import org.mycore.mir.it.model.MIRLanguage;
import org.mycore.mir.it.model.MIRLicense;
import org.mycore.mir.it.model.MIRTitleInfo;
import org.mycore.mir.it.model.MIRTitleType;
import org.openqa.selenium.By;
import org.openqa.selenium.Point;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;

public class MIRUploadITCase extends MIRITBase {

    private MIRUploadController uploadController;

    @Before
    public final void init() {
        String appURL = getAPPUrlString();
        userController = new MIRUserController(getDriver(), appURL);
        publishEditorController = new MIRPublishEditorController(getDriver(), appURL);
        uploadController = new MIRUploadController(getDriver(), appURL);
        editorController = new MIRModsEditorController(getDriver(), appURL);
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
        publishEditorController.openAdmin(() -> {
        });
    }

    @Test
    public final void testUnlimitedUpload() throws IOException, InterruptedException {
        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        fillEditorDefault();
        editorController.setAccessConditions(MIRAccess.public_);
        editorController.save();

        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));
        driver.waitAndFindElement(MCRBy.partialLinkText("Aktionen"),
            ExpectedConditions::elementToBeClickable).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("Hinzufügen eines Dateibereichs"),
            ExpectedConditions::elementToBeClickable).click();

        File upload = uploadController.createTestFile();
        uploadController.uploadFile(upload);

        String fileName = upload.getName();
        requireFileLinkPresent(fileName);

        String receiveURL = driver.getCurrentUrl();
        userController.logOff();
        driver.navigate().to(receiveURL);
        requireFileLinkPresent(fileName);

    }

    @Test
    public final void testInternUpload() throws IOException, InterruptedException {
        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        fillEditorDefault();
        editorController.setAccessConditions(MIRAccess.intern);
        editorController.save();

        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));
        driver.waitAndFindElement(MCRBy.partialLinkText("Aktionen"),
            ExpectedConditions::elementToBeClickable).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("Hinzufügen eines Dateibereichs"),
            ExpectedConditions::elementToBeClickable).click();

        File upload = uploadController.createTestFile();
        uploadController.uploadFile(upload);

        String fileName = upload.getName();
        requireFileLinkPresent(fileName);
        String receiveURL = driver.getCurrentUrl();
        userController.logOff();
        driver.navigate().to(receiveURL);
        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());

        Assert.assertNotNull("Forbidden Text should be present",
            driver.waitAndFindElement(MCRBy.partialText("Um die angehangenen Dateien")));
    }

    @Test
    public final void testInternUploadButFileAllowed() throws IOException, InterruptedException {
        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        fillEditorDefault();
        editorController.setAccessConditions(MIRAccess.intern);
        editorController.save();

        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));
        String receiveURL = driver.getCurrentUrl();
        driver.waitAndFindElement(MCRBy.partialLinkText("Aktionen"),
            ExpectedConditions::elementToBeClickable).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("Hinzufügen eines Dateibereichs"),
            ExpectedConditions::elementToBeClickable).click();

        File upload = uploadController.createTestFile();
        uploadController.uploadFile(upload);

        String fileName = upload.getName();
        openFileEditor(fileName);
        selectAccess(MIRAccess.public_);
        driver.waitAndFindElement(MCRBy.partialText("Speichern")).click();
        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());

        Assert.assertEquals(receiveURL, driver.getCurrentUrl());
        userController.logOff();
        driver.navigate().to(receiveURL);
        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());

        requireFileLinkPresent(fileName);
    }

    @Test
    public final void testUnlimitedUploadButFileForbidden() throws IOException, InterruptedException {
        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        fillEditorDefault();
        editorController.setAccessConditions(MIRAccess.public_);
        editorController.save();

        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));
        String receiveURL = driver.getCurrentUrl();
        driver.waitAndFindElement(MCRBy.partialLinkText("Aktionen"),
                ExpectedConditions::elementToBeClickable).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("Hinzufügen eines Dateibereichs"),
                ExpectedConditions::elementToBeClickable).click();

        File upload = uploadController.createTestFile();
        uploadController.uploadFile(upload);

        String fileName = upload.getName();
        openFileEditor(fileName);
        selectAccess(MIRAccess.intern);
        driver.waitAndFindElement(MCRBy.partialText("Speichern")).click();
        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());

        Assert.assertEquals(receiveURL, driver.getCurrentUrl());

        userController.logOff();
        driver.navigate().to(receiveURL);
        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());

        Assert.assertNotNull("Forbidden Text should be present",
                driver.waitAndFindElement(MCRBy.partialText("Sie haben nicht die nötigen Rechte, um die angehängten Dateien zu sehen.")));
    }

    private void selectAccess(MIRAccess access) {
        getDriver().waitAndFindElement(MCRBy.partialLinkText("Dateibereich verwalten")).click();
        String xpath =".//select[option/@value='mir_access:"+access.getValue()+"']";
        new Select(getDriver().waitAndFindElement(By.xpath(xpath))).selectByValue("mir_access:"+access.getValue());
    }

    private void openFileEditor(String fileName) {
        WebElement element = requireFileLinkPresent(fileName);

        List<WebElement> elements = driver.waitAndFindElements(MCRBy.partialLinkText("Aktionen"));

        int x = element.getLocation().getX();
        int y = element.getLocation().getY();

        WebElement nearestElement = elements.stream()
            .min(Comparator.comparingDouble(k -> {
                Point loc = k.getLocation();
                return java.awt.Point.distance(x, y, loc.x, loc.y);
            })).get();
        nearestElement.click();
    }

    private WebElement requireFileLinkPresent(String fileName) {
        WebElement element = driver.waitAndFindElement(MCRBy.partialLinkText(fileName));
        Assert.assertNotNull("Element should be Present!", element);
        return element;
    }

    private void fillEditorDefault() {
        editorController.setGenres(Stream.of(MIRGenre.article, MIRGenre.collection).collect(Collectors.toList()));
        editorController.setTitleInfo(Stream.of(
            new MIRTitleInfo("Der", MIRLanguage.german, MIRTitleType.mainTitle, MIRTestData.TITLE,
                MIRTestData.SUB_TITLE),
            new MIRTitleInfo("The", MIRLanguage.english, MIRTitleType.alternative, MIRTestData.EN_TITLE,
                MIRTestData.EN_SUB_TITLE))
            .collect(Collectors.toList()));
        editorController.setClassifications(
            Stream.of(MIRDNBClassification._004, MIRDNBClassification._010).collect(Collectors.toList()));
        editorController.setAccessConditions(MIRLicense.cc_by_40);
    }
}
