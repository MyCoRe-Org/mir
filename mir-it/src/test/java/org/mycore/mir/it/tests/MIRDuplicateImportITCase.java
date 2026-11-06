package org.mycore.mir.it.tests;

import java.util.AbstractMap;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.Assert;
import org.junit.Before;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;
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

/**
 * Tests the duplicate check of the identifier import: possible duplicates are shown on a confirmation page before the
 * editor opens, objects in the states configured by {@code MIR.Dedup.FilterDocumentsInStates} (default
 * {@code blocked,deleted}) are not.
 * <p>
 * The identifier is looked up in external databases during the import. That only enriches the imported object, the
 * identifier itself is always part of it, so the check does not depend on the answer of those databases.
 */
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class MIRDuplicateImportITCase extends MIRITBase {

    private static final String DOI_PUBLISHED = "10.1002/aqc.70449";

    private static final String DOI_BLOCKED = "10.1002/mir.it.blocked";

    private static final String DOI_DELETED = "10.1002/mir.it.deleted";

    private static final String TITLE_PUBLISHED = "Duplicate import IT published";

    private static final String TITLE_BLOCKED = "Duplicate import IT blocked";

    private static final String TITLE_DELETED = "Duplicate import IT deleted";

    @Before
    public final void init() {
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
    }

    @Test
    public void test1ImportWithoutDuplicateOpensEditor() {
        Assert.assertEquals("Without existing objects the editor should open directly.", Result.EDITOR,
            importIdentifier(DOI_PUBLISHED));
    }

    @Test
    public void test2CreatePublishedDocument() {
        createDocument(TITLE_PUBLISHED, DOI_PUBLISHED, MIRStatus.veröffentlicht);
    }

    @Test
    public void test3DuplicateIsListedBeforeEditorOpens() {
        Assert.assertEquals("The duplicate check should be shown.", Result.DUPLICATE_CHECK,
            importIdentifier(DOI_PUBLISHED));
        List<WebElement> duplicates = importController.getListedDuplicates();
        Assert.assertEquals("Exactly the existing document should be listed.", 1, duplicates.size());
        Assert.assertTrue("The existing document should be listed.",
            duplicates.get(0).getText().contains(TITLE_PUBLISHED));
    }

    @Test
    public void test4CreateBlockedAndDeletedDocuments() {
        createDocument(TITLE_BLOCKED, DOI_BLOCKED, MIRStatus.gesperrt);
        createDocument(TITLE_DELETED, DOI_DELETED, MIRStatus.gelöscht);
    }

    @Test
    public void test5BlockedDuplicateIsNotListed() {
        Assert.assertEquals("A blocked document should not count as duplicate.", Result.EDITOR,
            importIdentifier(DOI_BLOCKED));
    }

    @Test
    public void test6DeletedDuplicateIsNotListed() {
        Assert.assertEquals("A deleted document should not count as duplicate.", Result.EDITOR,
            importIdentifier(DOI_DELETED));
    }

    private Result importIdentifier(String doi) {
        importController.open();
        publishEditorController.selectType(MIRGenre.article, null);
        importController.setIdentifier("doi", doi);
        publishEditorController.submit();
        return importController.waitForResult();
    }

    private void createDocument(String title, String doi, MIRStatus status) {
        publishEditorController.openAdmin(null);
        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.setGenres(Stream.of(MIRGenre.article).collect(Collectors.toList()));
        editorController.setTitleInfo(Stream.of(new MIRTitleInfo(null, MIRLanguage.german, MIRTitleType.mainTitle, title,
            null)).collect(Collectors.toList()));
        editorController.setIdentifier(
            Stream.of(new AbstractMap.SimpleEntry<>(MIRIdentifier.doi, doi)).collect(Collectors.toList()));
        editorController.setAccessConditions(MIRAccess.public_);
        editorController.setAccessConditions(MIRLicense.cc_by_40);
        editorController.setClassifications(Stream.of(MIRDNBClassification._004).collect(Collectors.toList()));
        editorController.setStatus(status);
        editorController.save();
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));
    }
}
