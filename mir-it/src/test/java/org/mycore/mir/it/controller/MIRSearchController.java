package org.mycore.mir.it.controller;

import java.util.List;
import java.util.stream.IntStream;

import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.common.selenium.util.MCRBy;
import org.mycore.mir.it.model.MIRComplexSearchQuery;
import org.mycore.mir.it.model.MIRInstitutes;
import org.mycore.mir.it.model.MIRSearchField;
import org.mycore.mir.it.model.MIRSearchFieldCondition;
import org.mycore.mir.it.model.MIRStatus;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.Select;

public class MIRSearchController extends MIRTestController {
    public MIRSearchController(MCRWebdriverWrapper driver, String baseURL) {
        super(driver, baseURL);
    }

    public void simpleSearchBy(String title, String name, String metadata, String files, MIRInstitutes mirInstitute) {
        simpleSearchBy(title, name, metadata, files, mirInstitute, null);
    }

    public void simpleSearchBy(String title, String name, String metadata, String files,
        MIRInstitutes mirInstitute, MIRStatus status) {
        driver.waitAndFindElement(MCRBy.partialLinkText("Suche")).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("einfach")).click();

        if (title != null) {
            driver.waitAndFindElement(By.id("inputTitle1")).sendKeys(title);
        }

        if (name != null) {
            driver.waitAndFindElement(By.id("inputName1")).sendKeys(name);
        }

        if (metadata != null) {
            driver.waitAndFindElement(By.id("inputMeta1")).sendKeys(metadata);
        }

        if (files != null) {
            driver.waitAndFindElement(By.id("inputContent1")).sendKeys(files);
        }

        if (mirInstitute != null) {
            new Select(driver.waitAndFindElement(By.id("inputInst1")))
                .selectByValue("mir_institutes:" + mirInstitute.getValue());
        }

        if (status != null) {
            new Select(driver.waitAndFindElement(By.id("inputStatus1"))).selectByValue(status.getValue());
        }

        driver.waitAndFindElement(By.xpath(".//button[contains(text(), 'Suchen')]")).click();
    }

    public void complexSearchBy(List<MIRComplexSearchQuery> complexSearchQueries, String identifier, MIRInstitutes mirInstitute,
        String classification, String type, String license, MIRStatus status, String date, String content){
        driver.waitAndFindElement(MCRBy.partialLinkText("Suche")).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("komplex")).click();

        if (complexSearchQueries.size() > 0 && complexSearchQueries.size() > 1) {
                IntStream.range(1, complexSearchQueries.size()).forEach((n) -> clickRepeaterAndWait("boolean",
                    ".//input[contains(@name, 'boolean/boolean/condition[" + (n + 1) + "]/')]"));
            }


        IntStream.range(0, complexSearchQueries.size()).forEach(i -> {
            String baseXP = i == 0 ? "boolean/condition/" : "boolean/condition[" + (i + 1) + "]/";
            MIRComplexSearchQuery complexSearchQuery = complexSearchQueries.get(i);

            MIRSearchField field = complexSearchQuery.getSearchField();
            if (field != null) {
                new Select(driver.waitAndFindElement(By.xpath(".//select[contains(@name, '" + baseXP + "@field" + "')]")))
                    .selectByValue(field.getValue());
            }

            MIRSearchFieldCondition operator = complexSearchQuery.getSearchFieldConditions();
            if (operator != null) {
                new Select(driver.waitAndFindElement(By.xpath(".//select[contains(@name, '" + baseXP + "@operator" + "')]")))
                    .selectByValue(operator.getValue());
            }

            String  value = complexSearchQuery.getText();
            if (value != null) {
                driver.waitAndFindElement(By.xpath(".//input[contains(@name, '" + baseXP + "@value" + "')]")).sendKeys(value);
            }
        });


        if (identifier != null) {
            driver.waitAndFindElement(By.id("inputIdentifier1")).sendKeys(identifier);
        }

        if (mirInstitute != null) {
            new Select(driver.waitAndFindElement(By.id("inputInst1")))
                .selectByValue("mir_institutes:" + mirInstitute.getValue());
        }

        if (classification != null) {
            new Select(driver.waitAndFindElement(By.id("inputSDNB1")))
                .selectByValue("SDNB:" + classification);
        }

        if (type != null) {
            new Select(driver.waitAndFindElement(By.id("inputGenre1")))
                .selectByValue("mir_genres:" + type);
        }

        if (license != null) {
            new Select(driver.waitAndFindElement(By.id("inputLicense1")))
                .selectByValue("mir_licenses:" + license);
        }

        if (status != null) {
            new Select(driver.waitAndFindElement(By.id("inputStatus1"))).selectByValue(status.getValue());
        }

        if (date != null) {
            driver.waitAndFindElement(By.id("inputDate1")).sendKeys(date);
        }

        if (content != null) {
            new Select(driver.waitAndFindElement(By.id("inputFulltext1"))).selectByValue(content);
        }

        driver.waitAndFindElement(By.xpath(".//button[contains(text(), 'Suchen')]")).click();
    }

    public void searchBy(String title) throws InterruptedException {

        if (title != null) {
            driver.waitAndFindElement(By.id("searchInput")).sendKeys(title);
        }
        Thread.sleep(1000);
        driver.waitAndFindElement(By.xpath(".//button[contains(@class, 'btn btn-primary')]")).click();

    }

    public void searchByPublication(String title, String subTitle, String author, String name, String nameIdentifier, String metadata, String content) {

        if(title != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Alles")).click();
            qry(title);
        }

        if(subTitle != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Titel")).click();
            qry(subTitle);
        }

        if(author != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Autor")).click();
            qry(author);
        }

        if(name != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Name")).click();
            qry(name);
        }

        if(nameIdentifier != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Namens Identifikator")).click();
            qry(nameIdentifier);
        }

        if(metadata != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Alle Metadaten")).click();
            qry(metadata);
        }

        if(content != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Volltext")).click();
            qry(content);
        }

        driver.waitAndFindElement(By.xpath(".//span/button")).click();

    }

    protected void qry(String input) {
        driver.waitAndFindElement(By.xpath(".//input[contains(@name, 'qry')]")).clear(); //removes the value from the input
        driver.waitAndFindElement(By.xpath(".//input[contains(@name, 'qry')]")).sendKeys(input);
    }

    protected void clickRepeater (String field) {
        driver
            .waitAndFindElement(
                By.xpath(".//button[contains(@name, '" + field + "') and contains(@name, '_xed_submit_insert')]"))
            .click();
    }

    protected void clickRepeaterAndWait(String field, String fieldToWaitFor) {
        clickRepeater(field);
        driver.waitAndFindElement(By.xpath(fieldToWaitFor));
    }

}
