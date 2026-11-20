package org.mycore.mir.it.controller;

import java.util.List;

import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

/**
 * Drives the identifier import of the publish page ({@code content/publish/index.xml}) and the duplicate check that
 * the {@code MIRImportServlet} puts in front of the editor.
 */
public class MIRImportController {

    /**
     * What the user gets to see after submitting the import form.
     */
    public enum Result {
        /** the confirmation page listing the possible duplicates */
        DUPLICATE_CHECK,
        /** the editor, i.e. no (visible) possible duplicate was found */
        EDITOR
    }

    private static final By DUPLICATE_CHECK = By.id("duplicate-check");

    private static final By DUPLICATE_HITS = By.cssSelector("#duplicate-check .hit_item");

    private static final String EDITOR_URL_PART = "/editor/editor-dynamic.xed";

    protected String baseURL;

    protected MCRWebdriverWrapper driver;

    public MIRImportController(MCRWebdriverWrapper driver, String baseURL) {
        this.driver = driver;
        this.baseURL = baseURL;
    }

    public void open() {
        driver.get(baseURL + "/content/publish/index.xml");
        driver.waitUntilPageIsLoaded("Publizieren");
    }

    /**
     * Fills the import part of the form, the publication type has to be selected separately.
     *
     * @param type the identifier type, the value of the option in the form, e.g. {@code doi}
     * @param identifier the identifier to import
     */
    public void setIdentifier(String type, String identifier) {
        new Select(driver.waitAndFindElement(By.name("type"))).selectByValue(type);
        WebElement input = driver.waitAndFindElement(By.name("modsId"));
        input.clear();
        input.sendKeys(identifier);
    }

    /**
     * Waits until the import servlet either showed the duplicate check or redirected to the editor.
     */
    public Result waitForResult() {
        return driver.waitFor(() -> {
            if (!driver.findElements(DUPLICATE_CHECK).isEmpty()) {
                return Result.DUPLICATE_CHECK;
            }
            if (driver.getCurrentUrl().contains(EDITOR_URL_PART)) {
                return Result.EDITOR;
            }
            return null;
        });
    }

    public List<WebElement> getListedDuplicates() {
        return driver.waitAndFindElements(DUPLICATE_HITS);
    }
}
