package org.mycore.mir.it.tests;

import java.util.AbstractMap;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mycore.common.selenium.util.MCRBy;
import org.mycore.mir.it.controller.MIRModsEditorController;
import org.mycore.mir.it.controller.MIRPublishEditorController;
import org.mycore.mir.it.controller.MIRSearchController;
import org.mycore.mir.it.controller.MIRUserController;
import org.mycore.mir.it.model.MIRAbstract;
import org.mycore.mir.it.model.MIRAccess;
import org.mycore.mir.it.model.MIRDNBClassification;
import org.mycore.mir.it.model.MIRGenre;
import org.mycore.mir.it.model.MIRIdentifier;
import org.mycore.mir.it.model.MIRLanguage;
import org.mycore.mir.it.model.MIRLicense;
import org.mycore.mir.it.model.MIRTitleInfo;
import org.mycore.mir.it.model.MIRTitleType;
import org.mycore.mir.it.model.MIRTypeOfResource;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public class MIRAdminEditorITCase extends MIRITBase {

    private MIRSearchController simpleSearchController;

    @Before
    public final void init() {
        String appURL = getAPPUrlString();
        userController = new MIRUserController(getDriver(), appURL);
        publishEditorController = new MIRPublishEditorController(getDriver(), appURL);
        editorController = new MIRModsEditorController(getDriver(), appURL);
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
        publishEditorController.open(() -> {
        });
        simpleSearchController = new MIRSearchController(driver, appURL);
    }

    @Test
    public void testBaseValidation() {
        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.save();
        assertBaseValidation();
        Assert.assertTrue("Genre validation should be visible!", editorController.isGenreValidationMessageVisible());
    }

    @Test
    public void testFullDocument() throws InterruptedException {
        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.setGenres(Stream.of(MIRGenre.article, MIRGenre.collection).collect(Collectors.toList()));
        editorController.setTitleInfo(Stream.of(
            new MIRTitleInfo("Der", MIRLanguage.german, MIRTitleType.mainTitle, MIRTestData.TITLE,
                MIRTestData.SUB_TITLE),
            new MIRTitleInfo("The", MIRLanguage.english, MIRTitleType.alternative, MIRTestData.EN_TITLE,
                MIRTestData.EN_SUB_TITLE))
            .collect(Collectors.toList()));

        editorController.setAuthors(Stream.of(MIRTestData.AUTHOR, MIRTestData.AUTHOR_2).collect(Collectors.toList()));
        editorController.setConference(MIRTestData.CONFERENCE);
        // editorController.setOpenAIRE(MIRTestData.AIRE_AUTOCOMPLE, MIRTestData.AIRE_PROJECT_NAME);
        List identifierList = Stream.of(new AbstractMap.SimpleEntry(MIRIdentifier.doi, MIRTestData.DOI),
            new AbstractMap.SimpleEntry(MIRIdentifier.urn, MIRTestData.URN),
            new AbstractMap.SimpleEntry(MIRIdentifier.ppn, MIRTestData.PPN)).collect(Collectors.toList());
        editorController.setIdentifier(identifierList);
        editorController.setShelfLocator(MIRTestData.SIGNATURE);
        editorController.setLinks(Stream.of(MIRTestData.URL1, MIRTestData.URL2).collect(Collectors.toList()));
        editorController.setAccessConditions(MIRAccess.public_);
        editorController.setAccessConditions(MIRLicense.cc_by_40);
        editorController.setTopics(Stream.of(MIRTestData.TOPIC1, MIRTestData.TOPIC2).collect(Collectors.toList()));
        editorController.setAbstracts(Stream.of(new MIRAbstract(true, MIRTestData.TEXT, MIRLanguage.german),
            new MIRAbstract(false, MIRTestData.URL3, MIRLanguage.english)).collect(Collectors.toList()));

        editorController.setNotes(Stream.of(MIRTestData.NOTE, MIRTestData.NOTE2).collect(Collectors.toList()));
        editorController.setPlaceTerm(MIRTestData.PLACE);
        editorController.setPublisher(MIRTestData.PUBLISHER);
        editorController.setEdition(MIRTestData.EDITION);
        editorController.setExtend(MIRTestData.EXTEND_SOLO);
        editorController.setTypeOfResource(MIRTypeOfResource.still_image);
        editorController.setCoordinates(MIRTestData.COORDINATES);
        editorController.setGeograhicPlace(MIRTestData.GEOGRAPHIC_PLACE);
        editorController.setClassifications(
            Stream.of(MIRDNBClassification._004, MIRDNBClassification._010).collect(Collectors.toList()));

        editorController.save();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EN_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EN_SUB_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR_2));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.CONFERENCE));

        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AIRE_PROJECT_NAME));
        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AIRE_ACRONYM));
        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AIRE_ACRONYM));
        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AIRE_GRANT_ID));
        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AIRE_PROGRAMM_ID));
        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AIRE_ORGANISATION_ID));

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SIGNATURE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.URL1));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.URL2));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TEXT));
        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.URL3));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.NOTE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.NOTE2));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.PLACE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.PUBLISHER));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EDITION));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EXTEND_SOLO));
        driver.waitAndFindElement(MCRBy.partialText("Bild (Standbild)"));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.COORDINATES));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.GEOGRAPHIC_PLACE));

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_INFORMATIK));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_BIBLIOGRAPHIEN));
    }

    @Test
    /**
     * FIXME: put all search methods in extra test cases and find a ways to run methods in a defined order
     */
    public void searchByTitle() {
        simpleSearchController.simpleSearchBy(MIRTestData.TITLE, null, null, null, null);
        final ExpectedCondition<Boolean> condition = ExpectedConditions.titleContains("Suchergebnisse");
        driver.waitFor(condition);

        String noDocumentsFoundText = "Keine Dokumente gefunden";
       WebDriverWait wait =  new WebDriverWait(driver, 30);
        wait.until((driver)->{
            try {
                driver.findElement(MCRBy.partialText(noDocumentsFoundText));
                return false;
            } catch (NoSuchElementException e) {
                return true;
            }
        });

    }
}
