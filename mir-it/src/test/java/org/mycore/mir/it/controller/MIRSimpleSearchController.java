package org.mycore.mir.it.controller;

import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.common.selenium.util.MCRBy;
import org.mycore.mir.it.model.MIRInstitutes;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.Select;


public class MIRSimpleSearchController extends MIRTestController {
    public MIRSimpleSearchController(MCRWebdriverWrapper driver, String baseURL) {
        super(driver, baseURL);
    }

    public void searchBy(String title, String name, String metadata, String files, MIRInstitutes mirInstitute){
        driver.waitAndFindElement(MCRBy.partialLinkText("Suche")).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("einfach")).click();

        if(title!=null){
            driver.waitAndFindElement(By.id("inputTitle1")).sendKeys(title);
        }

        if (name!=null){
            driver.waitAndFindElement(By.id("inputName1")).sendKeys(name);
        }

        if(metadata!=null){
            driver.waitAndFindElement(By.id("inputMeta1")).sendKeys(metadata);
        }

        if(files!=null){
            driver.waitAndFindElement(By.id("inputContent1")).sendKeys(files);
        }

        if(mirInstitute!=null){
            new Select(driver.waitAndFindElement(By.id("inputInst1"))).selectByValue(mirInstitute.getValue());
        }

        driver.waitAndFindElement(By.xpath(".//button[contains(text(), 'Suchen')]")).click();
    }

}
