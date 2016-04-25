package org.mycore.mir.it.controller;


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.common.selenium.util.MCRBy;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public abstract class MIREditorController extends MIRTestController {

    private static final Logger LOGGER = LogManager.getLogger();

    public MIREditorController(MCRWebdriverWrapper driver, String baseURL) {
        super(driver, baseURL);
    }

    protected void setInputText(String childElementName, String text) {
        WebElement webElement = driver.waitAndFindElement(By.xpath(".//input[contains(@name,'" + childElementName + "')]"));
        webElement.clear();
        webElement.sendKeys(text);

    }

    protected void setTextAreaText(String childElementName, String text) {
        driver.waitAndFindElement(By.xpath(".//textarea[contains(@name,'" + childElementName + "')]")).sendKeys(text);
    }

    protected void clickRepeater(String field) {
        driver.waitAndFindElement(By.xpath(".//button[contains(@name, '" + field + "') and contains(@name, '_xed_submit_insert')]")).click();
    }

    protected boolean hasInputTextError(String childElementName) {
        try {
            WebDriverWait wait = new WebDriverWait(driver, 2);
            By selector = By.xpath(".//div[contains(@class, 'has-error')  and contains(@class, 'form-group')]//*[contains(@name,'" + childElementName + "')]");
            wait.until(ExpectedConditions.presenceOfAllElementsLocatedBy(selector));
        } catch (NoSuchElementException|TimeoutException e) {
            LOGGER.error("Could not find red validation border !", e);
            return false;
        }
        return true;
    }

    protected boolean hasValidationText(String text) {
        try{
            WebDriverWait driverWait = new WebDriverWait(driver, 2);
            driverWait.until(ExpectedConditions.presenceOfAllElementsLocatedBy(MCRBy.partialText(text)));
        } catch (NoSuchElementException |TimeoutException e){
            LOGGER.error("Could not find validation text !", e);
            return false;
        }

        return true;
    }

}
