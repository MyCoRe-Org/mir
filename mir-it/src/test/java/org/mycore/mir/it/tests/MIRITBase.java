package org.mycore.mir.it.tests;


import org.junit.After;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.Rule;
import org.junit.rules.TestName;
import org.mycore.common.selenium.MCRSeleniumTestBase;
import org.mycore.mir.it.controller.MIRModsEditorController;
import org.mycore.mir.it.controller.MIRPublishEditorController;
import org.mycore.mir.it.controller.MIRUserController;

public class MIRITBase extends MCRSeleniumTestBase {
    MIRUserController userController;
    MIRPublishEditorController publishEditorController;
    MIRModsEditorController editorController;
    @Rule public static TestName name = new TestName();


    protected void assertBaseValidation() {
        Assert.assertTrue("Title validation message should be visible!", this.editorController.isTitleValidationMessageVisible());
        Assert.assertTrue("Rights validation message should be visible!", this.editorController.isRightsValidationMessageVisible());
        Assert.assertTrue("Classification validation message should be visible!", this.editorController.isClassificationValidationMessageVisible());
    }

    protected String getAPPUrlString() {
        return getBaseUrl(System.getProperty("it.port", "8080")) + "/" + System.getProperty("it.context");
    }
    
    @After
    public void tearDown(){
        takeScreenshot();
    }

    @AfterClass
    public static void tearDownClass() {
        String message = String.format("SauceOnDemandSessionID=%1$s job-name=%2$s",
                ((driver.getDelegate()).getSessionId()).toString(), name.getClass().getName());
        System.out.println(message);
        driver.quit();
    }
}
