package org.mycore.mir.it.controller;

import java.util.Optional;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.common.selenium.util.MCRBy;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.StaleElementReferenceException;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

public abstract class MIREditorController extends MIRTestController {

    private static final Logger LOGGER = LogManager.getLogger();

    public MIREditorController(MCRWebdriverWrapper driver, String baseURL) {
        super(driver, baseURL);
    }

    protected void setInputText(String childElementName, String text) {
        driver.waitAndFindElement(
            By.xpath(".//input[contains(@name,'" + childElementName + "') and contains(@type, 'text')]")).clear();
        driver
            .waitAndFindElement(
                By.xpath(".//input[contains(@name,'" + childElementName + "') and contains(@type, 'text')]"))
            .sendKeys(text);
    }

    protected void setTextAreaText(String childElementName, String text) {
        driver.waitAndFindElement(By.xpath(".//textarea[contains(@name,'" + childElementName + "')]")).sendKeys(text);
    }

    protected void setHTMLAreaText(String childElementName, String text) {
        // get text area and corresponding iframe
        WebElement textArea = driver.waitAndFindElement(
            By.xpath(".//textarea[contains(@name, '" + childElementName + "') and contains(@class, 'tinymce')]")
        );
        String iframeId = Optional
            .ofNullable(textArea.getDomProperty("id"))
            .orElseGet(() -> textArea.getDomAttribute("id")) + "_ifr";
        WebElement iframe = driver.waitAndFindElement(By.id(iframeId));

        // Switch to the iframe, click on the body, and send the text
        driver.switchTo().frame(iframe);
        WebElement body = driver.findElement(By.tagName("body"));
        body.click();
        body.clear();
        body.sendKeys(text);

        // Switch back
        driver.switchTo().defaultContent();
    }

    protected void clickRepeater(String field) {
        driver
            .waitAndFindElement(
                By.xpath(".//button[contains(@name, '" + field + "') and contains(@name, '_xed_submit_insert')]"),
                ExpectedConditions::elementToBeClickable)
            .click();
    }

    protected void clickRepeaterAndWait(String field, String fieldToWaitFor) {
        clickRepeater(field);
        driver.waitAndFindElement(By.xpath(fieldToWaitFor));
    }

    protected boolean hasInputTextError(String childElementName) {
        try {
            driver.waitAndFindElement(
                By.xpath(
                    ".//div[contains(@class, 'mcr-invalid')  and contains(@class, 'mir-form-group')]//*[contains(@name,'"
                        + childElementName + "')]"));
        } catch (NoSuchElementException | TimeoutException e) {
            LOGGER.error("Could not find red validation border !", e);
            return false;
        }
        return true;
    }

    protected boolean hasValidationText(String text) {
        try {
            driver.waitAndFindElement(MCRBy.partialText(text));
        } catch (NoSuchElementException | TimeoutException e) {
            LOGGER.error("Could not find validation text !", e);
            return false;
        }

        return true;
    }

    protected void setLang(String baseXP, String lang) {
        driver.waitAndFindElement(By.xpath(".//span[contains(@id, '"
            + baseXP.replace(":", "")
                .replace("[", "")
                .replace("]", "")
            + "@xmllang" + "')]"))
            .click();
        driver.waitAndFindElement(By.className("select2-search__field")).clear();
        driver.waitAndFindElement(By.className("select2-search__field")).sendKeys(lang);
        StaleElementReferenceException e;
        do {
            try {
                e = null;
                driver.waitAndFindElement(By.xpath(
                    ".//li[contains(@class, 'select2-results__option') and contains(normalize-space(text()),'"
                        + lang + "')]"))
                    .click();
            } catch (StaleElementReferenceException e2) {
                e = e2;
            }
        } while (e != null);
    }

}
