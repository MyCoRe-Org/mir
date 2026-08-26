package org.mycore.mir.it.controller;

import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.common.selenium.util.MCRBy;
import org.mycore.mir.it.model.MIRGenre;
import org.mycore.mir.it.model.MIRHost;
import org.openqa.selenium.By;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

public class MIRPublishEditorController {

    String baseURL;

    MCRWebdriverWrapper driver;

    public MIRPublishEditorController(MCRWebdriverWrapper driver, String baseURL) {
        this.driver = driver;
        this.baseURL = baseURL;
    }

    public void open(Runnable assertion) {
        driver.waitAndFindElement(MCRBy.partialLinkText("Dokumente einreichen")).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("Publizieren")).click();
        if (assertion != null) {
            assertion.run();
        }
    }

    public void openAdmin(Runnable assertion) {
        driver.waitAndFindElement(MCRBy.partialLinkText("Dokumente einreichen")).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("Publizieren (Admin)")).click();
        if (assertion != null) {
            assertion.run();
        }
    }

    public void selectType(MIRGenre genre, MIRHost host) {
        selectByValue("genre", genre.getValue());

        if (host != null) {
            selectByValue("host", host.getValue());
        }
    }

    /**
     * Selects the option with the given value in the select with the given id.
     * <p>
     * Waits for the option and not only for the select: both are part of the page currently being loaded, so the
     * select element can already be present while its options have not been parsed yet.
     */
    private void selectByValue(String selectId, String value) {
        driver.waitAndFindElement(By.xpath(".//select[@id='" + selectId + "']/option[@value='" + value + "']"));
        new Select(driver.waitAndFindElement(By.id(selectId))).selectByValue(value);
    }

    public void submit() {
        WebElement submitButton = driver
            .waitAndFindElement(By.xpath(".//button[@type='submit' and contains(text(), 'Weiter')]"));
        submitButton.click();
    }

    public boolean isPublishOpened() {
        try {
            // the title alone is set long before the form is parsed, so the ready state is part of the condition
            driver.waitUntilPageIsLoaded("Publizieren");
        } catch (TimeoutException e) {
            return false;
        }
        return true;
    }

}
