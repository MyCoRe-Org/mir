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
        String appURL = getAPPUrlString();
        userController = new MIRUserController(getDriver(), appURL);

        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
    }

    @Test
    public void testWebCLIStartup() {
        MCRWebdriverWrapper driver = getDriver();

        driver.waitAndFindElement(By.xpath(".//strong[contains(text(), '" + MIRUserController.ADMIN_REALNAME + "')]"))
            .click();
        driver.waitAndFindElement(By.xpath(".//a[contains(text(), 'WebCLI')]")).click();
        String mainWindowHandle = driver.getWindowHandle();
        driver.waitAndFindElement(By.xpath(".//input[contains(@onclick, 'WebCLI')]")).click();

        String webcliWindowHandle = driver.getWindowHandles()
            .stream()
            .filter(h -> !h.equals(mainWindowHandle))
            .findFirst()
            .orElseThrow(() -> new RuntimeException("Could not find webcli window!"));

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
