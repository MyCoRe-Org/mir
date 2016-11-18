package org.mycore.mir.it.controller;


import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.common.selenium.util.MCRBy;
import org.mycore.mir.it.model.MIRGenre;
import org.mycore.mir.it.model.MIRHost;
import org.openqa.selenium.By;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
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

    public void selectType(MIRGenre genre, MIRHost host){
        Select genreSelect = new Select(driver.waitAndFindElement(By.id("genre")));
        genreSelect.selectByValue(genre.getValue());

        if(host!=null){
            Select hostSelect = new Select(driver.waitAndFindElement(By.id("host")));
            hostSelect.selectByValue(host.getValue());
        }
    }

    public void submit(){
        WebElement submitButton = driver.waitAndFindElement(By.xpath(".//button[@type='submit' and contains(text(), 'Weiter')]"));
        submitButton.click();
    }

    public boolean isPublishOpened() {
        try {
            driver.waitFor(ExpectedConditions.titleContains("Publizieren"));
        }
        catch (TimeoutException e) {
            return false;
        }
        return true;
    }

}
