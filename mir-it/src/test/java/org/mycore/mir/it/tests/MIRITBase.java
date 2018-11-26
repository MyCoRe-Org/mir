package org.mycore.mir.it.tests;

import org.junit.After;
import org.junit.Assert;
import org.mycore.common.selenium.MCRSeleniumTestBase;
import org.mycore.mir.it.controller.MIRModsEditorController;
import org.mycore.mir.it.controller.MIRPublishEditorController;
import org.mycore.mir.it.controller.MIRUserController;

public class MIRITBase extends MCRSeleniumTestBase {
    MIRUserController userController;

    MIRPublishEditorController publishEditorController;

    MIRModsEditorController editorController;

    protected void assertBaseValidation() {
        Assert.assertTrue("Title validation message should be visible!",
            this.editorController.isTitleValidationMessageVisible());
        Assert.assertTrue("Rights validation message should be visible!",
            this.editorController.isRightsValidationMessageVisible());
        Assert.assertTrue("Classification validation message should be visible!",
            this.editorController.isClassificationValidationMessageVisible());
    }

    public static String getAPPUrlString() {
        return getBaseUrl(System.getProperty("it.port", "8080")) + "/" + System.getProperty("it.context");
    }

    @After
    public void tearDown() {
        takeScreenshot();
    }
}
