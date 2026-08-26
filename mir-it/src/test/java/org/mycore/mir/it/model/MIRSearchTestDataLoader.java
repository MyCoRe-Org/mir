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
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class MIRSearchTestDataLoader {

    private static boolean loaded = false;

    private static final String TEST_FOLDER_NAME = "testFiles/";

    /**
     * Solr query matching all objects of {@link #FILE_NAMES}.
     */
    private static final String TEST_DATA_QUERY = "id:mir_mods_0001000*";

    /**
     * An entry of the WebCLI command menu; it is rendered from the list of known commands the WebCLI requests
     * after connecting.
     */
    private static final String COMMAND_MENU_ENTRY_XPATH =
        ".//div[@webcli-commands]//li[contains(@class, 'dropdown-submenu')]";

    /**
     * Timeout of the WebCLI driver, in seconds.
     */
    private static final int CLI_TIMEOUT_SECONDS = 30;

    // TODO: read from property
    private static final List<String> FILE_NAMES = Stream.of("mir_mods_00010000.xml").collect(Collectors.toList());

    public void lazyLoadData(MCRWebdriverWrapper webDriverWrapper) throws IOException {
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

            String webcliWindowHandle = MIRITBase.waitForAdditionalWindow(webDriverWrapper, mainWindowHandle);

            MCRWebdriverWrapper cliDriver = new MCRWebdriverWrapper(
                (RemoteWebDriver) webDriverWrapper.switchTo().window(webcliWindowHandle), CLI_TIMEOUT_SECONDS);

            execute(cliDriver, "load all objects from directory " + extractTestData());
            execute(cliDriver, "optimize solr index in core main");

            // the WebCLI runs its command queue on the server, so the documents showing up in the index is the
            // post condition the search tests depend on - not anything the WebCLI page renders
            MIRITBase.waitForMainIndexDocuments(TEST_DATA_QUERY, FILE_NAMES.size());

            cliDriver.close();
            webDriverWrapper.switchTo().window(mainWindowHandle);

        }
    }

    /**
     * Enters a command into the WebCLI input and executes it.
     * <p>
     * Two conditions have to hold before the command may be submitted:
     * <ul>
     *   <li>the WebCLI must have received its list of known commands. It requests that list only after its
     *       WebSocket opened, and the server initializes <code>MCRWebCLIContainer.knownCommands</code> while
     *       answering. A command submitted earlier fails server side with a <code>NullPointerException</code> and
     *       the session is closed, so the rendered command menu is a precondition for executing anything.</li>
     *   <li>the input must reflect the command, because the WebCLI keeps its own model of the input and only
     *       queues what that model holds.</li>
     * </ul>
     */
    private static void execute(MCRWebdriverWrapper cliDriver, String command) {
        cliDriver.waitAndFindElement(By.xpath(COMMAND_MENU_ENTRY_XPATH));

        WebElement commandInput = cliDriver
            .waitAndFindElement(By.xpath(".//input[contains(@placeholder,'Command')]"),
                ExpectedConditions::elementToBeClickable);
        commandInput.clear();
        commandInput.sendKeys(command);
        cliDriver.waitFor(webDriver -> command.equals(commandInput.getDomProperty("value")));
        cliDriver.waitAndFindElement(By.xpath(".//button[contains(text(), 'Execute')]"),
            ExpectedConditions::elementToBeClickable).click();
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
