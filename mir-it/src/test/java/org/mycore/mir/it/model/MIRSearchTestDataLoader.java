package org.mycore.mir.it.model;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.mycore.common.config.MCRConfigurationException;
import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.mir.it.controller.MIRUserController;
import org.mycore.mir.it.tests.MIRITBase;
import org.openqa.selenium.By;
import org.openqa.selenium.remote.RemoteWebDriver;

public class MIRSearchTestDataLoader {

    private static boolean loaded = false;

    private static final String TEST_FOLDER_NAME = "testFiles/";

    // TODO: read from property
    private static final List<String> FILE_NAMES = Stream.of("mir_mods_00010000.xml").collect(Collectors.toList());

    public void lazyLoadData(MCRWebdriverWrapper webDriverWrapper) throws IOException, InterruptedException {
        if (!loaded) {

            loaded = true;

            String appURL = MIRITBase.getAPPUrlString();
            MIRUserController userController = new MIRUserController(webDriverWrapper, appURL);

            userController.logoutIfLoggedIn();
            userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);

            webDriverWrapper.waitAndFindElement(By.xpath(".//strong[contains(text(), 'administrator')]")).click();
            webDriverWrapper.waitAndFindElement(By.xpath(".//a[contains(text(), 'WebCLI')]")).click();
            String mainWindowHandle = webDriverWrapper.getWindowHandle();
            webDriverWrapper.waitAndFindElement(By.xpath(".//input[contains(@onclick, 'WebCLI')]")).click();
            //webDriverWrapper.waitAndFindElement(By.xpath(".//input[contains(@onclick, 'window.open')]")).click();

            String webcliWindowHandle = webDriverWrapper.getWindowHandles()
                .stream()
                .filter(h -> !h.equals(mainWindowHandle))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Could not find webcli window!"));

            MCRWebdriverWrapper cliDriver = new MCRWebdriverWrapper(
                (RemoteWebDriver) webDriverWrapper.switchTo().window(webcliWindowHandle), 3000);


            cliDriver.waitAndFindElement(By.xpath(".//input[contains(@placeholder,'Command')]"))
                .sendKeys("load all objects from directory " + extractTestData());
            Thread.sleep(2000);
            cliDriver.waitAndFindElement(By.xpath(".//button[contains(text(), 'Execute')]")).click();
            Thread.sleep(5000);
            /*cliDriver.waitAndFindElement(By.xpath(".//input[contains(@placeholder,'Command)]"))
                .sendKeys("optimize solr index");
            Thread.sleep(1000);
            cliDriver.waitAndFindElement(By.xpath(".//button[contains(text(), 'Execute')]")).click();*/
            /*cliDriver.waitAndFindElement(
                By.xpath(".//*[contains(text(), '" + "load all objects from directory " + extractTestData() + "')]"));*/
            cliDriver.close();
            webDriverWrapper.switchTo().window(mainWindowHandle);

        }
    }

    private static String extractTestData() throws IOException {
        Path testFolder = Files.createTempDirectory("test_mods");

        FILE_NAMES.forEach((fileName) -> {
            try (InputStream stream = MIRUserController.class.getClassLoader()
                .getResourceAsStream(TEST_FOLDER_NAME + fileName)) {
                Path targetPath = testFolder.resolve(fileName);
                Files.copy(stream, targetPath, StandardCopyOption.REPLACE_EXISTING);
            } catch (IOException e) {
                throw new MCRConfigurationException("Could not open " + fileName, e);
            }

        });

        return testFolder.toAbsolutePath().toString();
    }
}
