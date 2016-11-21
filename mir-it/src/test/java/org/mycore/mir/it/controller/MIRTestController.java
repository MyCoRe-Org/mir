package org.mycore.mir.it.controller;


import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.common.selenium.util.MCRExpectedConditions;
import org.mycore.common.selenium.util.MCRExpectedConditions.DocumentReadyState;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class MIRTestController {

    protected final MCRWebdriverWrapper driver;
    protected final String baseURL;

    public MIRTestController(MCRWebdriverWrapper driver, String baseURL) {
        this.driver = driver;
        this.baseURL = baseURL;
    }
    
    public void clickAndWaitForPageLoad(By linkRef) {
        WebElement link = driver.findElement(linkRef);
        link.click();
        driver.waitFor(ExpectedConditions.and(
            ExpectedConditions.stalenessOf(link),
            MCRExpectedConditions.documentReadyState(DocumentReadyState.complete)));
    }

}
