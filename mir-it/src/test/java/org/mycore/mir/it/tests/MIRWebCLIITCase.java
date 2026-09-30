package org.mycore.mir.it.tests;

import org.junit.Before;
import org.junit.Test;
import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.mir.it.controller.MIRUserController;
import org.openqa.selenium.By;
import org.openqa.selenium.remote.RemoteWebDriver;

public class MIRWebCLIITCase extends MIRITBase {

    @Before
    public final void init() {
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
    }

    @Test
    public void testWebCLIStartup() {
        MCRWebdriverWrapper driver = getDriver();

        userController.openWebCLI();
        String mainWindowHandle = driver.getWindowHandle();
        driver.waitAndFindElement(By.id("launchButton")).click();

        String webcliWindowHandle = waitForAdditionalWindow(driver, mainWindowHandle);

        MCRWebdriverWrapper cliDriver = new MCRWebdriverWrapper(
            (RemoteWebDriver) driver.switchTo().window(webcliWindowHandle), 3000);

        cliDriver.waitAndFindElement(By.xpath(".//input[contains(@placeholder,'Command')]"))
            .sendKeys(MIRTestData.TEST_COMMAND);
        cliDriver.waitAndFindElement(By.xpath(".//button[contains(text(), 'Execute')]")).click();
        cliDriver.waitAndFindElement(By.xpath(".//*[contains(text(), '" + MIRTestData.TEST_COMMAND + "')]"));
        cliDriver.close();
        driver.switchTo().window(mainWindowHandle);

    }
}
