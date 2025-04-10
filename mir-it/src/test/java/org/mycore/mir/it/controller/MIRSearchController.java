package org.mycore.mir.it.controller;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.common.selenium.util.MCRBy;
import org.mycore.mir.it.model.MIRComplexSearchQuery;
import org.mycore.mir.it.model.MIRInstitutes;
import org.mycore.mir.it.model.MIRSearchField;
import org.mycore.mir.it.model.MIRSearchFieldCondition;
import org.mycore.mir.it.model.MIRStatus;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.support.ui.Select;

public class MIRSearchController extends MIRTestController {
    /**
     * Default Solr request handlers to use when configuration is not available.
     */
    private static final List<String> DEFAULT_SOLR_HANDLERS = List.of("find");

    public MIRSearchController(MCRWebdriverWrapper driver, String baseURL) {
        super(driver, baseURL);
    }

    public void simpleSearchBy(String title, String name, String metadata, String files, MIRInstitutes mirInstitute) {
        simpleSearchBy(title, name, metadata, files, mirInstitute, null);
    }

    public void simpleSearchBy(String title, String author, String metadata, String files,
        MIRInstitutes mirInstitute, MIRStatus status) {
        driver.waitAndFindElement(MCRBy.partialLinkText("Suche")).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("einfach")).click();

        setTitle(title);

        setAuthor(author);

        setMetadata(metadata);

        setFiles(files);

        setInstitute(mirInstitute);

        setStatus(status);

        search();
    }

    public void setStatus(MIRStatus status) {
        if (status != null) {
            new Select(driver.waitAndFindElement(By.id("inputStatus1"))).selectByValue(status.getValue());
        }
    }

    public void setInstitute(MIRInstitutes mirInstitute) {
        if (mirInstitute != null) {
            new Select(driver.waitAndFindElement(By.id("inputInst1")))
                .selectByValue("mir_institutes:" + mirInstitute.getValue());
        }
    }

    public void setFiles(String files) {
        if (files != null) {
            driver.waitAndFindElement(By.id("inputContent1")).sendKeys(files);
        }
    }

    public void setMetadata(String metadata) {
        if (metadata != null) {
            driver.waitAndFindElement(By.id("inputMeta1")).sendKeys(metadata);
        }
    }

    /**
     * Performs a search operation if the current URL matches valid search criteria.
     *
     * @throws TimeoutException if the search results page fails to load
     * @throws NoSuchElementException if the search button cannot be found
     */
    public void search() throws TimeoutException, NoSuchElementException {

        String currentUrl = driver.getCurrentUrl();
        if (shouldProceedWithSearch(currentUrl)) {
            driver.waitAndFindElement(By.xpath(".//button[contains(text(), 'Suchen')]")).click();
            driver.waitUntilPageIsLoaded("Suchergebnisse");
        }
    }

    /**
     * Determines whether search should proceed based on the current URL.
     * <p>
     * The URL must match one of these patterns to proceed:
     * <ul>
     *   <li>/servlets/solr/[handler]</li>
     *   <li>/servlets/solr/[handler]?[params]</li>
     *   <li>/servlets/solr/[handler]&[params]</li>
     * </ul>
     * where [handler] is one of the configured request handlers.
     *
     * @param url the current URL to check
     * @return true if search should proceed, false otherwise
     * @throws NullPointerException if url is null
     */
    private boolean shouldProceedWithSearch(String url) {
        if (url == null) {
            throw new NullPointerException("URL must not be null");
        }

        List<String> requestHandlers = getSolrHandlersForTest();

        for (String handler : requestHandlers) {
            String handlerPath = "/servlets/solr/" + handler;
            if (url.contains(handlerPath)) {
                String remaining = url.substring(url.indexOf(handlerPath) + handlerPath.length());
                return remaining.isEmpty() || remaining.startsWith("?") || remaining.startsWith("&");
            }
        }

        return !url.contains("/servlets/solr/");
    }

    /**
     * Gets the list of Solr request handlers to check against URLs.
     * <p>
     * This implementation:
     * <ol>
     *   <li>Tries to read from MCRConfiguration2</li>
     *   <li>Falls back to DEFAULT_SOLR_HANDLERS if configuration is unavailable</li>
     *   <li>Returns empty list if no handlers are configured</li>
     * </ol>
     *
     * @return list of valid Solr request handlers
     */
    protected List<String> getSolrHandlersForTest() {
        try {
            List<String> configuredHandlers = MCRConfiguration2
                .getString("MIR.Solr.Secondary.Search.RequestHandler.List")
                .stream()
                .flatMap(MCRConfiguration2::splitValue)
                .filter(s -> !s.isEmpty())
                .toList();

            if (!configuredHandlers.isEmpty()) {
                return configuredHandlers;
            }
        } catch (Exception e) {
            // Configuration not available - fall through to default
        }

        return DEFAULT_SOLR_HANDLERS;
    }

    public void setTitle(String title) {
        if (title != null) {
            driver.waitAndFindElement(MCRBy.partialLinkText("Suche")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("einfach")).click();
            driver.waitAndFindElement(By.id("inputTitle1")).sendKeys(title);
            search();
        }
    }

    public void setAuthor(String author) {
        if (author != null) {
            driver.waitAndFindElement(MCRBy.partialLinkText("Suche")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("einfach")).click();
            driver.waitAndFindElement(By.id("inputName1")).sendKeys(author);
            search();
        }
    }

    public void complexSearchBy(List<MIRComplexSearchQuery> complexSearchQueries, String identifier,
        MIRInstitutes mirInstitute,
        String classification, String type, String license, MIRStatus status, String date, String content) {
        driver.waitAndFindElement(MCRBy.partialLinkText("Suche")).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("komplex")).click();

        if (complexSearchQueries.size() > 0 && complexSearchQueries.size() > 1) {
            IntStream.range(1, complexSearchQueries.size()).forEach((n) -> clickRepeaterAndWait(
                ".//input[contains(@name, 'boolean[1]/boolean[1]/condition[" + (n + 1) + "]/')]"));
        }

        IntStream.range(0, complexSearchQueries.size()).forEach(i -> {
            String baseXP = "boolean[1]/condition[" + (i + 1) + "]/";
            MIRComplexSearchQuery complexSearchQuery = complexSearchQueries.get(i);

            MIRSearchField field = complexSearchQuery.searchField();
            if (field != null) {
                new Select(
                    driver.waitAndFindElement(By.xpath(".//select[contains(@name, '" + baseXP + "@field" + "')]")))
                        .selectByValue(field.getValue());
            }

            MIRSearchFieldCondition operator = complexSearchQuery.searchFieldConditions();
            if (operator != null) {
                new Select(
                    driver.waitAndFindElement(By.xpath(".//select[contains(@name, '" + baseXP + "@operator" + "')]")))
                        .selectByValue(operator.getValue());
            }

            String value = complexSearchQuery.text();
            if (value != null) {
                driver.waitAndFindElement(By.xpath(".//input[contains(@name, '" + baseXP + "@value" + "')]"))
                    .sendKeys(value);
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

        search();
    }

    public void searchBy(String title) {

        if (title != null) {
            driver.waitAndFindElement(By.id("searchInput")).sendKeys(title);
        }
        driver.waitAndFindElement(By.xpath(".//button[contains(@class, 'btn btn-primary')]")).click();

    }

    public void searchByPublication(String title, String subTitle, String author, String name, String nameIdentifier,
        String metadata, String content) {

        // select mods (filter query) is 'all'
        if (title != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Alles")).click();
            qry(title);
        }

        // select mods (filter query) is 'mods.title'
        if (subTitle != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Titel")).click();
            qry(subTitle);
        }

        // select mods (filter query) is 'mods.author'
        if (author != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Autor")).click();
            qry(author);
        }

        // select mods (filter query) is 'mods.name.top'
        if (name != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Name")).click();
            qry(name);
        }

        // select mods (filter query) is 'mods.nameIdentifier'
        if (nameIdentifier != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Namens Identifikator")).click();
            qry(nameIdentifier);
        }

        // select mods (filter query) is 'allMeta'
        if (metadata != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Alle Metadaten")).click();
            qry(metadata);
        }

        // select mods (filter query) is 'content'
        if (content != null) {
            driver.waitAndFindElement(By.id("search_type_label")).click();
            driver.waitAndFindElement(MCRBy.partialLinkText("Volltext")).click();
            qry(content);
        }

        driver.waitAndFindElement(By.xpath(".//span/button")).click();

    }

    private void qry(String input) {
        driver.waitAndFindElement(By.xpath(".//input[contains(@name, 'qry')]"))
            .clear(); //removes the value from the input
        driver.waitAndFindElement(By.xpath(".//input[contains(@name, 'qry')]")).sendKeys(input);
    }

    private void clickRepeater() {
        driver
            .waitAndFindElement(
                By.xpath(".//button[contains(@name, 'boolean') and contains(@name, '_xed_submit_insert')]"))
            .click();
    }

    private void clickRepeaterAndWait(String fieldToWaitFor) {
        clickRepeater();
        driver.waitAndFindElement(By.xpath(fieldToWaitFor));
    }

}
