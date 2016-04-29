package org.mycore.mir.it.tests;

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

public class MIRAuthorEditorITCase extends MIREditorITBase {

    public static final String SUBMITTER_USER_NAME = "submitter";
    public static final String SUBMITTER_USER_PASSWORD = "tugdriwsella";

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
        userController.loginAs(SUBMITTER_USER_NAME, "tugdriwsella");
    }

    @Test
    public void testBaseValidation() {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.article, null);
        publishEditorController.submit();
        editorController.save();

        assertBaseValidation();
    }

    @Test
    public void testArticle() throws InterruptedException {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.article, null);
        publishEditorController.submit();

        editorController.setTitle(MIRTestData.TITLE);
        editorController.setSubTitle(MIRTestData.SUB_TITLE);
        editorController.setAuthor(MIRTestData.AUTHOR);
        editorController.setIssueDate(MIRTestData.ISSUE_DATE);
        editorController.setExtend(MIRTestData.EXTEND_SOLO);
        editorController.setLanguages(Stream.of(MIRLanguage.german).collect(Collectors.toList()));

        List<AbstractMap.Entry<MIRIdentifier, String>> identifierList = new ArrayList<>();

        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, MIRTestData.DOI));
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.urn, MIRTestData.URN));

        editorController.setIdentifier(identifierList);
        editorController.setClassifications(Stream.of(MIRDNBClassification._000, MIRDNBClassification._010, MIRDNBClassification._020).collect(Collectors.toList()));
        editorController.setTopics(Stream.of(MIRTestData.TOPIC1, MIRTestData.TOPIC2).collect(Collectors.toList()));
        editorController.setAccessConditions(MIRLicense.cc_30);
        editorController.setAbstract(MIRTestData.ABSTRACT);
        editorController.setNote(MIRTestData.NOTE);

        editorController.save();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));


        // look for entered metadata
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ISSUE_DATE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EXTEND_SOLO));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.NUMBER));

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.URN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.DOI));


        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TOPIC1));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TOPIC2));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ABSTRACT));
    }

    @Test
    public void testArticleInJournal() throws InterruptedException {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.article, MIRHost.journal);
        publishEditorController.submit();

        editorController.setTitle(MIRTestData.TITLE);
        editorController.setSubTitle(MIRTestData.SUB_TITLE);
        editorController.setAuthor(MIRTestData.AUTHOR);
        editorController.setLanguages(Stream.of(MIRLanguage.german).collect(Collectors.toList()));

        editorController.setClassifications(Stream.of(MIRDNBClassification._004, MIRDNBClassification._010).collect(Collectors.toList()));
        editorController.setTopics(Stream.of(MIRTestData.TOPIC1, MIRTestData.TOPIC2).collect(Collectors.toList()));
        editorController.setAccessConditions(MIRLicense.cc_30);
        editorController.setAbstract(MIRTestData.ABSTRACT);
        editorController.setNote(MIRTestData.NOTE);

        editorController.setRelatedTitle(MIRTestData.RELATED_TITLE);
        editorController.setISSNValueXpath(MIRTestData.ISSN);
        editorController.setShelfLocator(MIRTestData.SIGNATURE);
        editorController.setIssueDate(MIRTestData.ISSUE_DATE);
        editorController.setVolume(MIRTestData.VOLUME);
        editorController.setNumber(MIRTestData.NUMBER);
        editorController.setISBNValueXpath(MIRTestData.ISBN);
        editorController.setExtend(MIRTestData.EXTEND_START, MIRTestData.EXTEND_END);

        // wrong test data
        List<AbstractMap.Entry<MIRIdentifier, String>> identifierList = new ArrayList<>();
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, MIRTestData.WRONG_DOI));
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.urn, MIRTestData.WRONG_URN));
        editorController.setISBNValueXpath(MIRTestData.WRONG_ISBN);
        editorController.setISSNValueXpath(MIRTestData.WRONG_ISSN);
        editorController.setIdentifier(identifierList);
        editorController.save();

        // check for validation message
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_DOI));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_ISBN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_ISSN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_URN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EXTEND_START));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EXTEND_END));

        // correct test data
        identifierList.clear();
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, MIRTestData.DOI));
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.urn, MIRTestData.URN));
        editorController.setISSNValueXpath(MIRTestData.ISSN);
        editorController.setISBNValueXpath(MIRTestData.ISBN);
        editorController.setIdentifier(identifierList, 2, 0);

        editorController.save();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));


        // look for entered metadata
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ABSTRACT));
        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.NOTE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ISSUE_DATE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VOLUME));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.NUMBER));
        // TODO: enable validation for license
        //driver.waitAndFindElement(MCRBy.partialText(MIRLicense.cc_30.getValue()));


        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.URN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.DOI));


        driver.waitAndFindElement(MCRBy.partialLinkText(MIRTestData.RELATED_TITLE)).click();

        // look for parent article
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.RELATED_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SIGNATURE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ISBN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ISSN));
    }


    @Test
    public void testCollection() throws InterruptedException {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.collection, null);
        publishEditorController.submit();

        editorController.setTitle(MIRTestData.TITLE);
        editorController.setSubTitle(MIRTestData.SUB_TITLE);
        editorController.setAuthor(MIRTestData.AUTHOR);

        editorController.setIssueDate(MIRTestData.ISSUE_DATE);
        editorController.setPlaceTerm(MIRTestData.PLACE);
        editorController.setPublisher(MIRTestData.PUBLISHER);
        editorController.setEdition(MIRTestData.EDITION);
        editorController.setExtend(MIRTestData.EXTEND_SOLO);
        editorController.setLanguages(Stream.of(MIRLanguage.german).collect(Collectors.toList()));

        editorController.setClassifications(Stream.of(MIRDNBClassification._004, MIRDNBClassification._010).collect(Collectors.toList()));
        editorController.setISBN(MIRTestData.ISBN);

        List<AbstractMap.Entry<MIRIdentifier, String>> identifierList = new ArrayList<>();

        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, MIRTestData.DOI));
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.urn, MIRTestData.URN));

        editorController.setIdentifier(identifierList, 1, 1);
        editorController.setShelfLocator(MIRTestData.SIGNATURE);
        editorController.setAbstract(MIRTestData.ABSTRACT);
        editorController.setAccessConditions(MIRLicense.cc_30);
        editorController.setInstitution(MIRInstitutes.Universität_in_Deutschland);
        editorController.setNote(MIRTestData.NOTE);


        editorController.save();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));


        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR));
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
        //driver.waitAndFindElement(MCRBy.partialText(MIRLicense.cc_30.getValue()));

        //driver.waitAndFindElement(MCRBy.partialText(MIRTestData.NOTE));
    }

    @Test
    public void testReport() {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.report, null);
        publishEditorController.submit();

        editorController.setTitle(MIRTestData.TITLE);
        editorController.setSubTitle(MIRTestData.SUB_TITLE);
        editorController.setAuthors(Stream.of(MIRTestData.AUTHOR, MIRTestData.AUTHOR_2).collect(Collectors.toList()));
        editorController.setIssueDate(MIRTestData.ISSUE_DATE);

        editorController.setLanguages(Stream.of(MIRLanguage.german).collect(Collectors.toList()));

        List<AbstractMap.Entry<MIRIdentifier, String>> identifierList = new ArrayList<>();

        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, MIRTestData.DOI));
        identifierList.add(new AbstractMap.SimpleEntry<>(MIRIdentifier.urn, MIRTestData.URN));

        editorController.setIdentifier(identifierList);
        editorController.setClassifications(Stream.of(MIRDNBClassification._004, MIRDNBClassification._010).collect(Collectors.toList()));
        editorController.setAbstract(MIRTestData.ABSTRACT);
        editorController.setAccessConditions(MIRLicense.cc_30);
        editorController.setInstitution(MIRInstitutes.Universität_in_Deutschland);
        editorController.setNote(MIRTestData.NOTE);

        editorController.save();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ISSUE_DATE));

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_UNI_GER));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.URN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.DOI));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.ABSTRACT));
        // TODO: enable validation for license
        // driver.waitAndFindElement(MCRBy.partialText(MIRLicense.cc_30.getValue()));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_INFORMATIK));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_BIBLIOGRAPHIEN));
    }

    @Test
    public void testTeachingMaterial() throws InterruptedException {
        publishEditorController.open(() -> Assert.assertTrue(publishEditorController.isPublishOpened()));
        publishEditorController.selectType(MIRGenre.teaching_material, null);
        publishEditorController.submit();

        editorController.setTitleAndTranslation(MIRTestData.TITLE, MIRTestData.SUB_TITLE, MIRTestData.EN_TITLE, MIRTestData.EN_SUB_TITLE, MIRLanguage.english);
        editorController.setAuthors(Stream.of(MIRTestData.AUTHOR, MIRTestData.AUTHOR_2).collect(Collectors.toList()));
        editorController.setDateCreated(MIRTestData.CREATION_DATE);
        editorController.setTypeOfResources(Stream.of(MIRTypeOfResource.text, MIRTypeOfResource.moving_image).collect(Collectors.toList()));
        editorController.setInstitution(MIRInstitutes.Universität_in_Deutschland);
        editorController.setLanguages(Stream.of(MIRLanguage.german,MIRLanguage.english).collect(Collectors.toList()));
        editorController.setClassifications(Stream.of(MIRDNBClassification._004,MIRDNBClassification._010).collect(Collectors.toList()));
        editorController.setTopics(Stream.of(MIRTestData.TOPIC1,MIRTestData.TOPIC2).collect(Collectors.toList()));
        editorController.setAbstracts(Stream.of(new MIRAbstract(true, MIRTestData.TEXT, MIRLanguage.german), new MIRAbstract(false, MIRTestData.URL3, MIRLanguage.english)).collect(Collectors.toList()));
        editorController.setAccessConditions(MIRLicense.cc_30);


        editorController.save();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SUB_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EN_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.EN_SUB_TITLE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.AUTHOR_2));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_CREATION_DATE));

        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_UNI_GER));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_INFORMATIK));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_BIBLIOGRAPHIEN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TOPIC1));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.TOPIC2));
        // TODO: enable validation for license
        //driver.waitAndFindElement(MCRBy.partialText(MIRLicense.cc_30.getValue()));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_RESOURCE_TEXT));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_RESOURCE_MOVING_IMAGE));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_LANGUAGE_GERMAN));
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.VALIDATION_LANGUAGE_ENGLISH));
        // abstract
    }

    @After
    public void tearDown() throws Exception {
        this.takeScreenshot();

        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
        userController.deleteUser(SUBMITTER_USER_NAME);
        userController.logoutIfLoggedIn();
    }
}
