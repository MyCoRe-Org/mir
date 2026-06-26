package org.mycore.mir.it.tests;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.After;
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
import org.mycore.mir.it.model.MIRLicense;
import org.mycore.mir.it.model.MIRStatus;
import org.mycore.mir.it.model.MIRTitleType;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

/**
 * Regression test for MIR-1613: the content (files) of a blocked or deleted object must not be
 * accessible to unprivileged users.
 * <p>
 * Scenario: a submitter creates a document, uploads a file and submits it; an administrator publishes
 * it and afterwards blocks it. A guest must then see the "blocked" message on the metadata page and
 * must no longer be able to retrieve the uploaded file via the {@code MCRFileNodeServlet}.
 */
public class MIRBlockedContentITCase extends MIRITBase {

    private static final String SUBMITTER_USER_NAME = "submitter";

    private static final String SUBMITTER_USER_PASSWORD = "tugdriwsella";

    private static final String BLOCKED_MESSAGE = "Das Dokument ist gesperrt!";

    private MIRUploadController uploadController;

    @Before
    public final void init() {
        String appURL = getAPPUrlString();
        userController = new MIRUserController(getDriver(), appURL);
        publishEditorController = new MIRPublishEditorController(getDriver(), appURL);
        editorController = new MIRModsEditorController(getDriver(), appURL);
        uploadController = new MIRUploadController(getDriver(), appURL);
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
        userController.createUser(SUBMITTER_USER_NAME, SUBMITTER_USER_PASSWORD, null, null, "submitter");
        userController.logoutIfLoggedIn();
    }

    @Test
    public void testBlockedDerivateFileForbiddenForGuest() throws IOException, InterruptedException {
        // 1. a submitter creates a document, uploads a file and submits it
        userController.loginAs(SUBMITTER_USER_NAME, SUBMITTER_USER_PASSWORD);
        String fileName = createDocumentWithUploadedFile();
        String receiveURL = driver.getCurrentUrl();
        userController.logOff();

        // 2. an administrator makes the content public and publishes the document
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
        publishAndMakePublicViaAdminEditor(receiveURL);

        String fileURL = getFileNodeServletURL(receiveURL, fileName);

        // sanity check: while published the file is publicly readable
        Assert.assertEquals("Published file should be readable by a guest", 200, guestHttpStatus(fileURL));

        // 3. the administrator blocks the document
        setStatusViaAdminEditor(receiveURL, MIRStatus.gesperrt);

        // 4a. the file must no longer be retrievable via the MCRFileNodeServlet for a guest
        Assert.assertEquals("Blocked file must not be readable by a guest", 403, guestHttpStatus(fileURL));

        // 4b. the metadata page must show the blocked message to a guest
        userController.logOff();
        driver.navigate().to(receiveURL);
        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());
        Assert.assertNotNull("Blocked message should be present on the metadata page",
            driver.waitAndFindElement(MCRBy.partialText(BLOCKED_MESSAGE)));
    }

    private String createDocumentWithUploadedFile() throws IOException, InterruptedException {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.article, null);
        publishEditorController.submit();

        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.setTitle(MIRTestData.TITLE);
        editorController.setClassifications(Stream.of(MIRDNBClassification._004).collect(Collectors.toList()));
        // the mir_access (file access) select is only available in the admin editor, so the document
        // is made public by the administrator later on; here we only set the required license
        editorController.setAccessConditions(MIRLicense.cc_by_40);
        editorController.save();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));

        driver.waitAndFindElement(MCRBy.partialLinkText("Aktionen"),
            ExpectedConditions::elementToBeClickable).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("Hinzufügen eines Dateibereichs"),
            ExpectedConditions::elementToBeClickable).click();

        File upload = uploadController.createTestFile();
        uploadController.uploadFile(upload);

        String fileName = upload.getName();
        Assert.assertNotNull("Uploaded file should be present",
            driver.waitAndFindElement(MCRBy.partialLinkText(fileName)));
        return fileName;
    }

    private void publishAndMakePublicViaAdminEditor(String receiveURL) {
        openAdminEditor(receiveURL);
        editorController.setAccessConditions(MIRAccess.public_);
        editorController.setStatus(MIRStatus.veröffentlicht);
        editorController.save();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));
    }

    private void setStatusViaAdminEditor(String receiveURL, MIRStatus status) {
        openAdminEditor(receiveURL);
        editorController.setStatus(status);
        editorController.save();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));
    }

    private void openAdminEditor(String receiveURL) {
        driver.navigate().to(receiveURL);
        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());
        // once a derivate exists there are several "Aktionen" dropdowns, so open the one whose menu
        // actually contains the admin editor link; select via the "dropdown-toggle" class so the test
        // works regardless of the Bootstrap version (data-toggle in BS4 vs. data-bs-toggle in BS5)
        driver.waitAndFindElement(By.xpath(".//a[contains(@class, 'dropdown-toggle')]"
            + "[following-sibling::ul[.//a[contains(normalize-space(.), 'Bearbeiten im Admin-Editor')]]]"),
            ExpectedConditions::elementToBeClickable).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("Bearbeiten im Admin-Editor"),
            ExpectedConditions::elementToBeClickable).click();
    }

    private String getFileNodeServletURL(String receiveURL, String fileName) {
        driver.navigate().to(receiveURL);
        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());
        WebElement fileBox = driver.waitAndFindElement(By.cssSelector("div.file_box_files"));
        String derivateId = fileBox.getAttribute("data-deriid");
        Assert.assertNotNull("Could not determine derivate id from metadata page", derivateId);
        return getAPPUrlString() + "/servlets/MCRFileNodeServlet/" + derivateId + "/" + fileName;
    }

    private int guestHttpStatus(String url) throws IOException, InterruptedException {
        HttpClient client = HttpClient.newBuilder()
            .followRedirects(HttpClient.Redirect.NEVER)
            .build();
        HttpRequest request = HttpRequest.newBuilder(URI.create(url)).GET().build();
        return client.send(request, HttpResponse.BodyHandlers.discarding()).statusCode();
    }

    @After
    @Override
    public void tearDown() {
        super.tearDown();
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
        userController.deleteUser(SUBMITTER_USER_NAME);
        userController.logoutIfLoggedIn();
    }
}
