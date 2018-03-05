package org.mycore.mir.it.controller;

import java.util.AbstractMap;
import java.util.List;
import java.util.stream.IntStream;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.mir.it.model.MIRAbstract;
import org.mycore.mir.it.model.MIRAccess;
import org.mycore.mir.it.model.MIRDNBClassification;
import org.mycore.mir.it.model.MIRGenre;
import org.mycore.mir.it.model.MIRIdentifier;
import org.mycore.mir.it.model.MIRInstitutes;
import org.mycore.mir.it.model.MIRLanguage;
import org.mycore.mir.it.model.MIRLicense;
import org.mycore.mir.it.model.MIRStatus;
import org.mycore.mir.it.model.MIRTitleInfo;
import org.mycore.mir.it.model.MIRTypeOfResource;
import org.mycore.mir.it.tests.MIRTestData;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

public class MIRModsEditorController extends MIREditorController {

    private static final Logger LOGGER = LogManager.getLogger();

    public MIRModsEditorController(MCRWebdriverWrapper driver, String baseURL) {
        super(driver, baseURL);
    }

    public void setTitleInfo(List<MIRTitleInfo> titleInfos) {
        if (titleInfos.size() > 0) {
            if (titleInfos.size() > 1) {
                IntStream.range(1, titleInfos.size()).forEach((n) -> clickRepeaterAndWait("mods:titleInfo",
                    ".//textarea[contains(@name, 'mods:titleInfo[" + (n + 1) + "]/mods:title')]"));
            }

            IntStream.range(0, titleInfos.size()).forEach(i -> {
                String baseXP = i == 0 ? "mods:titleInfo/" : "mods:titleInfo[" + (i + 1) + "]/";
                MIRTitleInfo titleInfo = titleInfos.get(i);

                String nonSort = titleInfo.getNonSort();
                if (nonSort != null) {
                    setInputText(baseXP + "mods:nonSort", nonSort);
                }

                WebElement langSelectElement = driver
                    .waitAndFindElement(By.xpath(".//select[contains(@name, '" + baseXP + "@xml:lang" + "')]"));
                new Select(langSelectElement).selectByValue(titleInfo.getLang().getValue());

                WebElement selectTypeElement = driver
                    .waitAndFindElement(By.xpath(".//select[contains(@name, '" + baseXP + "@type" + "')]"));
                new Select(selectTypeElement).selectByValue(titleInfo.getTitleType().getValue());

                String title = titleInfo.getTitle();
                if (title != null) {
                    setTextAreaText(baseXP + "mods:title", title);
                }

                String subTitle = titleInfo.getSubTitle();
                if (subTitle != null) {
                    setTextAreaText(baseXP + "mods:subTitle", subTitle);
                }
            });
        }
    }

    public void setTitleAndTranslation(String title, String subTitle, String translatedTitle, String translatedSubTitle,
        MIRLanguage language) {
        setInputText("mods:titleInfo/mods:title", title);
        setInputText("mods:titleInfo/mods:subTitle", subTitle);
        setInputText("mods:titleInfo[2]/mods:title", translatedTitle);
        setInputText("mods:titleInfo[2]/mods:subTitle", translatedSubTitle);
        new Select(driver.waitAndFindElement(By.xpath(".//select[contains(@name, 'mods:titleInfo[2]/@xml:lang')]")))
            .selectByValue(language.getValue());

    }

    public void setOpenAIRE(String searchTrigger, String fullName) {
        WebElement nameElement = driver.waitAndFindElement(By.id("name"));// name should be changed in future
        try { /// fixme: get it to work without sleep
            Thread.sleep(2000);
            nameElement.clear();
            Thread.sleep(2000);
            nameElement.click();
            Thread.sleep(2000);
            nameElement.sendKeys(searchTrigger);
            Thread.sleep(2000);
            nameElement.sendKeys(Keys.SPACE);
            Thread.sleep(2000);
        } catch (InterruptedException e) {
        }
        nameElement.click();

        driver.waitAndFindElements(By.xpath(".//ul[contains(@class,'typeahead')]/li/a")).stream()
            .filter(e -> e.getText().contains(fullName)).limit(1).forEach(e -> e.click());
    }

    public void setTitle(String title) {
        setInputText("mods:title", title);
    }

    public void setTitleAbbreviated(String title) {
        setInputText("mods:titleInfo[2]/mods:title", title);
    }

    public void setSubTitle(String subTitle) {
        setInputText("mods:subTitle", subTitle);
    }

    public void setPlaceTerm(String placeTerm) {
        setInputText("mods:placeTerm", placeTerm);
    }

    public void setPublisher(String publisher) {
        setInputText("mods:publisher", publisher);
    }

    public void setEdition(String edition) {
        setInputText("mods:edition", edition);
    }

    public void setAbstract(String _abstract) {
        setTextAreaText("mods:abstract", _abstract);
    }

    public void setAbstracts(List<MIRAbstract> abstracts) {
        if (abstracts.size() > 0) {
            if (abstracts.size() > 1) {
                IntStream.range(1, abstracts.size()).forEach((n) -> clickRepeaterAndWait("mods:abstract",
                    ".//input[contains(@name, 'mods:abstract[" + (n + 1) + "]')]"));
            }

            IntStream.range(0, abstracts.size()).forEach(i -> {
                String xp = i == 0 ? "mods:abstract" : "mods:abstract[" + (i + 1) + "]";
                MIRAbstract anAbstract = abstracts.get(i);
                new Select(driver.waitAndFindElement(By.xpath(".//select[contains(@name, '" + xp + "/@xml:lang')]")))
                    .selectByValue(anAbstract.getLanguage().getValue());
                if (anAbstract.isText()) {
                    setTextAreaText(xp, anAbstract.getTextOrLink());
                } else {
                    setInputText(xp + "/@xlink:href", anAbstract.getTextOrLink());
                }
            });
        }
    }

    public void setTypeOfResource(MIRTypeOfResource typeOfResource) {
        Select resourceSelect = new Select(
            driver.waitAndFindElement(By.xpath(".//select[contains(@name, 'mods:typeOfResource/@mcr:categId')]")));
        resourceSelect.selectByValue(typeOfResource.getValue());
    }

    public void setTypeOfResources(List<MIRTypeOfResource> typeOfResources) {
        if (typeOfResources.size() > 0) {
            if (typeOfResources.size() > 1) {
                IntStream.range(1, typeOfResources.size()).forEach((n) -> clickRepeaterAndWait("mods:typeOfResource",
                    ".//select[contains(@name, 'mods:typeOfResource[" + (n + 1) + "]/@mcr:categId')]"));
            }

            IntStream.range(0, typeOfResources.size()).forEach(i -> {
                String xp = i == 0 ? "mods:typeOfResource/@mcr:categId"
                    : "mods:typeOfResource[" + (i + 1) + "]/@mcr:categId";
                MIRTypeOfResource typeOfResource = typeOfResources.get(i);
                new Select(driver.waitAndFindElement(By.xpath(".//select[contains(@name, '" + xp + "')]")))
                    .selectByValue(typeOfResource.getValue());
            });

        }
    }

    public void setConference(String conference) {
        String xpath = ".//input[contains(@placeholder, 'Titel der Konferenz ggf. mit Ort und Jahr oder Datum') and contains(@name,'mods:namePart')]";
        WebElement inputElement = driver.waitAndFindElement(By.xpath(xpath));
        inputElement.clear();
        inputElement.sendKeys(conference);
    }

    public void setGenres(List<MIRGenre> genres) {
        if (genres.size() > 0) {
            if (genres.size() > 1) {
                IntStream.range(1, genres.size()).forEach((n) -> clickRepeaterAndWait("mods:genre",
                    ".//select[contains(@name, 'mods:genre[" + (n + 1) + "]/@valueURIxEditor')]"));
            }

            IntStream.range(0, genres.size()).forEach(i -> {
                String xp = i == 0 ? "mods:genre/@valueURIxEditor" : "mods:genre[" + (i + 1) + "]/@valueURIxEditor";
                MIRGenre currentLang = genres.get(i);
                new Select(driver.waitAndFindElement(By.xpath(".//select[contains(@name, '" + xp + "')]")))
                    .selectByValue(currentLang.getValue());
            });

        }
    }

    public void setLanguages(List<MIRLanguage> langs) {
        if (langs.size() > 0) {
            if (langs.size() > 1) {
                IntStream.range(1, langs.size()).forEach((n) -> clickRepeaterAndWait("mods:language",
                    ".//select[contains(@name, 'mods:language[" + (n + 1) + "]/mods:languageTerm')]"));
            }

            IntStream.range(0, langs.size()).forEach(i -> {
                String xp = i == 0 ? "mods:language/mods:languageTerm"
                    : "mods:language[" + (i + 1) + "]/mods:languageTerm";
                MIRLanguage currentLang = langs.get(i);
                new Select(driver.waitAndFindElement(By.xpath(".//select[contains(@name, '" + xp + "')]")))
                    .selectByValue(currentLang.getValue());
            });
        }
    }

    public void setInstitution(MIRInstitutes institution) {
        new Select(driver.waitAndFindElement(
            By.xpath(".//select[contains(@name, 'mods:name') and option/@value='" + institution.getValue() + "']")))
                .selectByValue(institution.getValue());
    }

    public void setStatus(MIRStatus status) {
        new Select(driver.waitAndFindElement(
            By.xpath(".//select[contains(@name, 'servstates/servstate') and option/@value='" + status.getValue() + "']")))
            .selectByValue(status.getValue());
    }

    public void setIdentifier(List<AbstractMap.Entry<MIRIdentifier, String>> typeIdentifierList) {
        setIdentifier(typeIdentifierList, 1, 0);
    }

    public void setIdentifier(List<AbstractMap.Entry<MIRIdentifier, String>> typeIdentifierList, int existing,
        int nonRepeaterExisting) {
        if (typeIdentifierList.size() > 0) {
            if (typeIdentifierList.size() > (existing)) {
                IntStream.range(1, typeIdentifierList.size()).forEach(n -> clickRepeaterAndWait("mods:identifier",
                    ".//input[contains(@name, 'mods:identifier[" + (n + existing + nonRepeaterExisting) + "]')]"));
            }

            IntStream.range(nonRepeaterExisting, nonRepeaterExisting + typeIdentifierList.size()).forEach(i -> {
                String selectXP = i == 0 ? "mods:identifier/@type" : "mods:identifier[" + (i + 1) + "]/@type";
                String inputXP = i == 0 ? "mods:mods/mods:identifier" : "mods:mods/mods:identifier[" + (i + 1) + "]";
                MIRIdentifier mirIdentifier = typeIdentifierList.get(i - nonRepeaterExisting).getKey();
                String identifierValue = typeIdentifierList.get(i - nonRepeaterExisting).getValue();
                new Select(driver.waitAndFindElement(By.xpath(".//select[contains(@name, '" + selectXP + "')]")))
                    .selectByValue(mirIdentifier.toString());
                setInputText(inputXP, identifierValue);
            });
        }
    }

    public void setTopics(List<String> topics) {
        if (topics.size() > 0) {
            if (topics.size() > 1) {
                IntStream.range(1, topics.size()).forEach((n) -> clickRepeaterAndWait("mods:topic",
                    ".//input[contains(@name, 'mods:topic[" + (n + 1) + "]')]"));
            }

            IntStream.range(0, topics.size()).forEach(i -> {
                String xp = i == 0 ? "mods:topic" : "mods:topic[" + (i + 1) + "]";
                String topic = topics.get(i);
                setInputText(xp, topic);
            });
        }
    }

    public void setClassifications(List<MIRDNBClassification> classifications) {
        if (classifications.size() > 0) {
            if (classifications.size() > 1) {
                IntStream.range(1, classifications.size()).forEach((n) -> clickRepeaterAndWait("mods:classification",
                    ".//select[contains(@name, 'mods:classification[" + (n + 1) + "]')]"));
            }

            IntStream.range(0, classifications.size()).forEach(i -> {
                String xp = i == 0 ? "mods:classification" : "mods:classification[" + (i + 1) + "]";
                MIRDNBClassification classification = classifications.get(i);
                new Select(driver.waitAndFindElement(By.xpath(".//select[contains(@name, '" + xp + "')]")))
                    .selectByValue(classification.getValue());
            });
        }
    }

    public void setGeograhicPlace(String place) {
        setInputText("mods:geographic", place);
    }

    public void setCoordinates(String coordinates) {
        setInputText("mods:coordinates", coordinates);
    }

    public void setAuthors(List<String> names) {
        setAuthors(names, 0);
    }

    public void setAuthors(List<String> names, int fieldOffset) {
        if (names.size() > 0) {
            if (names.size() > 1) {
                IntStream.range(1, names.size()).forEach((n) -> clickRepeaterAndWait("mods:name",
                    ".//input[contains(@name, 'mods:name[" + (n + 1 + fieldOffset) + "]/mods:displayForm')]"));
            }

            IntStream.range(0, names.size()).forEach(i -> {
                String xp = i + fieldOffset == 0 ? "mods:name/mods:displayForm"
                    : "mods:name[" + (i + 1 + fieldOffset) + "]/mods:displayForm";
                String name = names.get(i);
                driver.waitAndFindElement(By.xpath("//button[contains(@name,'_xed_submit_servlet')]"));
                setInputText(xp, name);
                String inputPath = ".//input[contains(@name,'" + xp + "')]";
                driver.waitAndFindElement(By.xpath(inputPath + "/.././/button[contains(text(), 'Suchen...')]")).click();
                driver.waitAndFindElement(By.xpath(".//a[@data-type='personal' and contains(text(),'" + name + "')]"))
                    .click();
            });
        }
    }

    public void setAuthor(String name) {
        setInputText("mods:displayForm", name);
        driver.waitAndFindElement(By.xpath(".//button[contains(text(), 'Suchen...')]")).click();
        driver.waitAndFindElement(By.xpath(".//a[@data-type='personal' and contains(text(),'" + name + "')]")).click();
    }

    public void setAccessConditions(MIRLicense ac) {
        new Select(
            driver.waitAndFindElement(By.xpath(".//select[contains(@name, 'mods:accessCondition') and (option/@value='"
                + ac.getValue() + "' or optgroup/option/@value='" + ac.getValue() + "')]")))
                    .selectByValue(ac.getValue());
    }

    public void setAccessConditions(MIRAccess ac) {
        new Select(
            driver.waitAndFindElement(By.xpath(".//select[contains(@name, 'mods:accessCondition') and (option/@value='"
                + ac.getValue() + "' or optgroup/option/@value='" + ac.getValue() + "')]")))
                    .selectByValue(ac.getValue());
    }

    public void setRightsHolder(String rightsHolder) {
        setInputText("cmd:rights.holder/cmd:name", rightsHolder);
    }

    public void setNote(String note) {
        setTextAreaText("mods:note", note);
    }

    public void setNotes(List<String> notes) {
        // TODO: maybe add type
        if (notes.size() > 0) {
            if (notes.size() > 1) {
                IntStream.range(1, notes.size()).forEach(n -> clickRepeaterAndWait("mods:note",
                    ".//textarea[contains(@name, 'mods:note[" + (n + 1) + "]')]"));
            }

            IntStream.range(0, notes.size()).forEach(i -> {
                String inputXP = i == 0 ? "mods:note" : "mods:note[" + (i + 1) + "]";
                String note = notes.get(i);
                setTextAreaText(inputXP, note);
            });
        }
    }

    public void setExtend(String extend) {
        setInputText("mods:physicalDescription/mods:extent", extend);
    }

    public void setIssueDate(String issueDate) {
        setInputText("mods:originInfo/mods:dateIssued", issueDate);
    }

    public void setIssueDate(String from, String to) {
        // TODO: fixme element not found
        //setInputText("mods:originInfo/mods:dateIssued", from);
        //setInputText("mods:originInfo/mods:dateIssued[2]", to);
    }

    public void save() {
        clickAndWaitForPageLoad(By.xpath(".//button[@type='submit' and contains(text(), 'Speichern')]"));
    }

    public void setRelatedTitle(String title) {
        setInputText("mods:relatedItem/mods:titleInfo/mods:title", title);
    }

    private void setByValueXpath(String valueXpath, String value) {
        WebElement webElement = driver
            .waitAndFindElement(By.xpath(".//input[contains(@data-valuexpath, \"" + valueXpath + "\")]"));
        webElement.clear();
        webElement.sendKeys(value);
    }

    public void setISSNValueXpath(String issn) {
        setByValueXpath("mods:mods/mods:identifier[@type='issn']", issn);
    }

    public void setISBNValueXpath(String isbn) {
        setByValueXpath("mods:mods/mods:identifier[@type='isbn']", isbn);
    }

    public void setISBN(String isbn) {
        setInputText("mods:mods/mods:identifier", isbn);
    }

    public void setShelfLocator(String shelfLocator) {
        setInputText("mods:location/mods:shelfLocator", shelfLocator);
    }

    public void setVolume(String volume) {
        setInputText("mods:relatedItem/mods:part/mods:detail/mods:number", volume);
    }

    public void setExtend(String start, String end) {
        setInputText("mods:relatedItem/mods:part/mods:extent/mods:list", start + " - " + end);
    }

    public void setLinks(List<String> links) {
        if (links.size() > 0) {
            if (links.size() > 1) {
                IntStream.range(1, links.size()).forEach((n) -> clickRepeaterAndWait("mods:url",
                    ".//input[contains(@name, 'mods:location/mods:url[" + (n + 1) + "]')]"));
            }

            IntStream.range(0, links.size()).forEach(i -> {
                String xp = i == 0 ? "mods:location/mods:url" : "mods:location/mods:url[" + (i + 1) + "]";
                String link = links.get(i);
                setInputText(xp, link);
            });
        }
    }

    public void setNumber(String number) {
        setInputText("mods:relatedItem/mods:part/mods:detail[2]/mods:number", number);
    }

    public boolean isTitleValidationMessageVisible() {
        return hasValidationText(MIRTestData.VALIDATION_TITLE) && this.hasInputTextError("mods:title");
    }

    public boolean isClassificationValidationMessageVisible() {
        return hasValidationText(MIRTestData.VALIDATION_CLASSIFICATION)
            && this.hasInputTextError("mods:classification");
    }

    public boolean isRightsValidationMessageVisible() {
        return hasValidationText(MIRTestData.VALIDATION_RIGHTS) && this.hasInputTextError("mods:accessCondition");
    }

    public boolean isGenreValidationMessageVisible() {
        return hasValidationText(MIRTestData.VALIDATION_GENRE) && this.hasInputTextError("mods:genre");
    }

    public void setDateCreated(String dateCreated) {
        setInputText("mods:dateCreated", dateCreated);
    }

}
