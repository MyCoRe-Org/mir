package org.mycore.mir.it.tests;

import static org.mycore.mir.it.tests.MIRTestData.TITLE_ABBR;

import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mycore.common.selenium.util.MCRBy;
import org.mycore.mir.it.controller.MIRModsEditorController;
import org.mycore.mir.it.controller.MIRPublishEditorController;
import org.mycore.mir.it.controller.MIRUserController;
import org.mycore.mir.it.model.MIRAbstract;
import org.mycore.mir.it.model.MIRDNBClassification;
import org.mycore.mir.it.model.MIRGenre;
import org.mycore.mir.it.model.MIRHost;
import org.mycore.mir.it.model.MIRIdentifier;
import org.mycore.mir.it.model.MIRInstitutes;
import org.mycore.mir.it.model.MIRLanguage;
import org.mycore.mir.it.model.MIRLicense;
import org.mycore.mir.it.model.MIRTypeOfResource;
import org.openqa.selenium.By;

public class MIRAuthorEditorITCase extends MIRITBase {

    private static final String SUBMITTER_USER_NAME = "submitter";

    private static final String SUBMITTER_USER_PASSWORD = "tugdriwsella";

    @Before
    public final void init() {
        String appURL = getAPPUrlString();
        userController = new MIRUserController(getDriver(), appURL);
        publishEditorController = new MIRPublishEditorController(getDriver(), appURL);
        editorController = new MIRModsEditorController(getDriver(), appURL);
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
        userController.createUser(SUBMITTER_USER_NAME, SUBMITTER_USER_PASSWORD, null, null, "submitter");
        userController.logoutIfLoggedIn();
        userController.loginAs(SUBMITTER_USER_NAME, SUBMITTER_USER_PASSWORD);
    }

    @Test
    public void testBaseValidation() {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.article, null);
        publishEditorController.submit();
        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.save();

        assertBaseValidation();
    }

    @Test
    public void testArticle() throws InterruptedException {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.article, null);
        publishEditorController.submit();

        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        refPublicationCommon(true);

        editorController.save();
        saveSuccessValidation();

        // look for entered metadata
        refPublicationCommonValidation(true);
    }

    @Test
    public void testReport() {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.report, null);
        publishEditorController.submit();

        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        refReportCommon();

        editorController.save();
        saveSuccessValidation();

        refReportCommonValidation();
    }

    @Test
    public void testArticleInJournal() throws InterruptedException {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.article, MIRHost.journal);
        publishEditorController.submit();

        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.setTitle(MIRTestData.TITLE);
        editorController.setSubTitle(MIRTestData.SUB_TITLE);
        editorController.setAuthor(MIRTestData.AUTHOR);
        editorController.setLanguages(Stream.of(MIRLanguage.german).collect(Collectors.toList()));
        editorController.setTopics(Stream.of(MIRTestData.TOPIC1, MIRTestData.TOPIC2).collect(Collectors.toList()));

        refSNDBRepeat();
        editorController.setAccessConditions(MIRLicense.cc_by_40);
        refAbstractSimple();
        refComment();

        editorController.setRelatedTitle(MIRTestData.RELATED_TITLE);
        editorController.setISBN(MIRTestData.ISSN);
        refShelfMark();
        editorController.setIssueDate(MIRTestData.ISSUE_DATE);
        editorController.setVolume(MIRTestData.VOLUME);
        editorController.setNumber(MIRTestData.NUMBER);
        editorController.setExtend(MIRTestData.EXTEND_START, MIRTestData.EXTEND_END);

        // wrong test data
        List<AbstractMap.Entry<MIRIdentifier, String>> identifierList = new ArrayList<>();
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, MIRTestData.WRONG_DOI));
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.urn, MIRTestData.WRONG_URN));
        editorController.setISSNValueXpath(MIRTestData.WRONG_ISSN);
        editorController.setIdentifier(identifierList);
        editorController.save();

        // check for validation message
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_DOI));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_ISSN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_URN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EXTEND_START));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EXTEND_END));

        // correct test data
        identifierList.clear();
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, MIRTestData.DOI));
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.urn, MIRTestData.URN));
        editorController.setISSNValueXpath(MIRTestData.ISSN);
        editorController.setIdentifier(identifierList, 2, 0);

        editorController.save();
        saveSuccessValidation();

        // look for entered metadata
        driver.findElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.findElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        driver.findElement(MCRBy.partialText(MIRTestData.AUTHOR));
        driver.findElement(MCRBy.partialText(MIRTestData.ABSTRACT));
        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.NOTE));
        driver.findElement(MCRBy.partialText(MIRTestData.ISSUE_DATE));
        driver.findElement(MCRBy.partialText(MIRTestData.VOLUME));
        driver.findElement(MCRBy.partialText(MIRTestData.NUMBER));
        // TODO: enable validation for license
        //driver.waitAndFindElement(MCRBy.partialText(MIRLicense.cc_by_40.getValue()));

        driver.findElement(MCRBy.partialText(MIRTestData.URN));
        driver.findElement(MCRBy.partialText(MIRTestData.DOI));

        editorController.clickAndWaitForPageLoad(MCRBy.partialLinkText(MIRTestData.RELATED_TITLE));

        // look for parent article
        driver.findElement(MCRBy.partialText(MIRTestData.RELATED_TITLE));
        driver.findElement(MCRBy.partialText(MIRTestData.SIGNATURE));
        driver.findElement(MCRBy.partialText(MIRTestData.ISSN));
    }

    @Test
    public void testCollection() throws InterruptedException {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.collection, null);
        publishEditorController.submit();

        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.setTitle(MIRTestData.TITLE);
        editorController.setSubTitle(MIRTestData.SUB_TITLE);
        refAuthorRepeated();
        refBookCommon();

        editorController.save();
        saveSuccessValidation();

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        refAuthorRepeatedValidation();
        refBookCommonValidation();
    }

    @Test
    public void testProceedings() {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.proceedings, null);
        publishEditorController.submit();

        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.setTitle(MIRTestData.TITLE);
        editorController.setSubTitle(MIRTestData.SUB_TITLE);
        refConference();
        editorController.setAuthors(Stream.of(MIRTestData.AUTHOR, MIRTestData.AUTHOR_2).collect(Collectors.toList()),
            1);
        refBookCommon();

        editorController.save();
        saveSuccessValidation();

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        refAuthorRepeatedValidation();
        refBookCommonValidation();
    }

    @Test
    public void testTeachingMaterial() throws InterruptedException {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.teaching_material, null);
        publishEditorController.submit();

        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.setTitleAndTranslation(MIRTestData.TITLE, MIRTestData.SUB_TITLE, MIRTestData.EN_TITLE,
            MIRTestData.EN_SUB_TITLE, MIRLanguage.english);
        refAuthorRepeated();
        editorController.setDateCreated(MIRTestData.CREATION_DATE);
        editorController.setTypeOfResources(
            Stream.of(MIRTypeOfResource.text, MIRTypeOfResource.moving_image).collect(Collectors.toList()));
        editorController.setInstitution(MIRInstitutes.Universität_in_Deutschland);
        editorController.setLanguages(Stream.of(MIRLanguage.german, MIRLanguage.english).collect(Collectors.toList()));
        refSNDBRepeat();
        editorController.setTopics(Stream.of(MIRTestData.TOPIC1, MIRTestData.TOPIC2).collect(Collectors.toList()));
        editorController.setAbstracts(Stream.of(new MIRAbstract(true, MIRTestData.TEXT, MIRLanguage.german),
            new MIRAbstract(false, MIRTestData.URL3, MIRLanguage.english)).collect(Collectors.toList()));
        editorController.setAccessConditions(MIRLicense.cc_by_40);

        editorController.save();
        saveSuccessValidation();

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EN_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EN_SUB_TITLE));
        refAuthorRepeatedValidation();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_CREATION_DATE));

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_UNI_GER));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_INFORMATIK));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_BIBLIOGRAPHIEN));
        driver.waitAndFindElement(
            By.xpath(".//*[contains(@class, 'topic-element') and contains(text(), " + MIRTestData.TOPIC1 + ")]"));
        driver.waitAndFindElement(
            By.xpath(".//*[contains(@class, 'topic-element') and contains(text(), " + MIRTestData.TOPIC2 + ")]"));

        // TODO: enable validation for license
        //driver.waitAndFindElement(MCRBy.partialText(MIRLicense.cc_by_40.getValue()));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_RESOURCE_TEXT));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_RESOURCE_MOVING_IMAGE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_LANGUAGE_GERMAN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_LANGUAGE_ENGLISH));
        // abstract
    }

    @Test
    public void testJournal() {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.journal, null);
        publishEditorController.submit();

        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.setTitle(MIRTestData.TITLE);
        refJournalCommon();
        editorController.save();

        saveSuccessValidation();

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        refJournalValidation();
    }

    protected void refJournalValidation() {
        refAuthorRepeatedValidation();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE_ABBR));
        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ISSUE_DATE_FROM));
        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ISSUE_DATE_TO));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.PLACE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.PUBLISHER));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SIGNATURE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ABSTRACT));
    }

    protected void refJournalCommon() {
        editorController.setTitleAbbreviated(TITLE_ABBR);
        refAuthorRepeated();
        editorController.setPlaceTerm(MIRTestData.PLACE);
        editorController.setPublisher(MIRTestData.PUBLISHER);
        refDateOnlyrangeIssuedDatetimepicker();
        editorController.setLanguages(Stream.of(MIRLanguage.german).collect(Collectors.toList()));
        refSNDBRepeat();

        refShelfMark();
        refAbstractSimple();
        refComment();
    }

    protected void refDateOnlyrangeIssuedDatetimepicker() {
        editorController.setIssueDate(MIRTestData.ISSUE_DATE_FROM, MIRTestData.ISSUE_DATE_TO);
    }

    private void refReportCommonValidation() {
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ISSUE_DATE));

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_UNI_GER));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.URN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.DOI));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ABSTRACT));
        // TODO: enable validation for license
        // driver.waitAndFindElement(MCRBy.partialText(MIRLicense.cc_by_40.getValue()));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_INFORMATIK));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_BIBLIOGRAPHIEN));
    }

    private void refPublicationCommonValidation(boolean standAlone) {
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR));
        if (standAlone) {
            driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ISSUE_DATE));
            driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EXTEND_SOLO));
        }
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.NUMBER));

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.URN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.DOI));

        driver.waitAndFindElement(
                By.xpath(".//*[contains(@class, 'topic-element') and contains(text(), " + MIRTestData.TOPIC1 + ")]"));
        driver.waitAndFindElement(
                By.xpath(".//*[contains(@class, 'topic-element') and contains(text(), " + MIRTestData.TOPIC2 + ")]"));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ABSTRACT));
    }

    private void refPublicationCommon(boolean standAlone) {
        editorController.setTitle(MIRTestData.TITLE);
        editorController.setSubTitle(MIRTestData.SUB_TITLE);
        refAuthorRepeated();

        if (standAlone) {
            editorController.setIssueDate(MIRTestData.ISSUE_DATE);
            editorController.setExtend(MIRTestData.EXTEND_SOLO);
        }

        editorController.setLanguages(Stream.of(MIRLanguage.german).collect(Collectors.toList()));
        List<AbstractMap.Entry<MIRIdentifier, String>> identifierList = new ArrayList<>();

        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, MIRTestData.DOI));
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.urn, MIRTestData.URN));

        editorController.setIdentifier(identifierList);
        editorController.setClassifications(
            Stream.of(MIRDNBClassification._000, MIRDNBClassification._010, MIRDNBClassification._020)
                .collect(Collectors.toList()));
        editorController.setTopics(Stream.of(MIRTestData.TOPIC1, MIRTestData.TOPIC2).collect(Collectors.toList()));
        refAbstractSimple();
        editorController.setAccessConditions(MIRLicense.cc_by_40);
        refComment();
    }

    private void refAuthorRepeated() {
        editorController.setAuthors(Stream.of(MIRTestData.AUTHOR, MIRTestData.AUTHOR_2).collect(Collectors.toList()));
    }

    private void saveSuccessValidation() {
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));
    }

    private void refConference() {
        editorController.setConference(MIRTestData.CONFERENCE);
    }

    private void refBookCommonValidation() {
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ISSUE_DATE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.PLACE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.PUBLISHER));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EDITION));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EXTEND_SOLO));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.URN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.DOI));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SIGNATURE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ABSTRACT));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_UNI_GER));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_INFORMATIK));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_BIBLIOGRAPHIEN));

        // TODO: enable validation for license
        //driver.waitAndFindElement(MCRBy.partialText(MIRLicense.cc_by_40.getValue()));

        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.NOTE));
    }

    private void refBookCommon() {
        editorController.setIssueDate(MIRTestData.ISSUE_DATE);
        editorController.setPlaceTerm(MIRTestData.PLACE);
        editorController.setPublisher(MIRTestData.PUBLISHER);
        editorController.setEdition(MIRTestData.EDITION);
        editorController.setExtend(MIRTestData.EXTEND_SOLO);
        editorController.setLanguages(Stream.of(MIRLanguage.german).collect(Collectors.toList()));

        refSNDBRepeat();
        refISBN();

        List<AbstractMap.Entry<MIRIdentifier, String>> identifierList = new ArrayList<>();

        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, MIRTestData.DOI));
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.urn, MIRTestData.URN));

        editorController.setIdentifier(identifierList, 1, 1);
        refShelfMark();
        refAbstractSimple();
        editorController.setAccessConditions(MIRLicense.cc_by_40);
        editorController.setInstitution(MIRInstitutes.Universität_in_Deutschland);
        refComment();
    }

    private void refComment() {
        editorController.setNote(MIRTestData.NOTE);
    }

    private void refShelfMark() {
        editorController.setShelfLocator(MIRTestData.SIGNATURE);
    }

    private void refISBN() {
        editorController.setISBN(MIRTestData.ISBN);
    }

    private void refSNDBRepeat() {
        editorController.setClassifications(
            Stream.of(MIRDNBClassification._004, MIRDNBClassification._010).collect(Collectors.toList()));
    }

    private void refAbstractSimple() {
        editorController.setAbstract(MIRTestData.ABSTRACT);
    }

    private void refReportCommon() {
        editorController.setTitle(MIRTestData.TITLE);
        editorController.setSubTitle(MIRTestData.SUB_TITLE);
        refAuthorRepeated();
        editorController.setIssueDate(MIRTestData.ISSUE_DATE);

        editorController.setLanguages(Stream.of(MIRLanguage.german).collect(Collectors.toList()));

        List<AbstractMap.Entry<MIRIdentifier, String>> identifierList = new ArrayList<>();

        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, MIRTestData.DOI));
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.urn, MIRTestData.URN));

        editorController.setIdentifier(identifierList);
        refSNDBRepeat();
        refAbstractSimple();
        editorController.setAccessConditions(MIRLicense.cc_by_40);
        editorController.setInstitution(MIRInstitutes.Universität_in_Deutschland);
        refComment();
    }

    private void refAuthorRepeatedValidation() {
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR_2));
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
