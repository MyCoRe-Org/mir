package org.mycore.mir.it.controller;

import java.util.List;

import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

/**
 * Drives the object basket UI: the add/remove button on an object page,
 * the basket toggle on the search result page and the basket display page.
 */
public class MIRBasketController extends MIRTestController {

    private static final String BASKET_TYPE = "objects";

    /**
     * Add/remove button on the object detail page. Selects only the toggle button (action=add or
     * action=remove), so the navigation basket menu (action=show) is not matched.
     */
    private static final By OBJECT_PAGE_ADD = By.xpath(
        "//a[contains(@href,'MCRBasketServlet') and contains(@href,'action=add')]");

    private static final By OBJECT_PAGE_REMOVE = By.xpath(
        "//a[contains(@href,'MCRBasketServlet') and contains(@href,'action=remove')]");

    private static final By OBJECT_PAGE_TOGGLE = By.xpath(
        "//a[contains(@href,'MCRBasketServlet') and (contains(@href,'action=add') or contains(@href,'action=remove'))]");

    public MIRBasketController(MCRWebdriverWrapper driver, String baseURL) {
        super(driver, baseURL);
    }

    public void openObjectPage(String objectId) {
        driver.get(baseURL + "/receive/" + objectId);
        // wait until the basket toggle is rendered, so the membership state is decided
        driver.waitAndFindElement(OBJECT_PAGE_TOGGLE);
    }

    /**
     * @return {@code true} if the object page shows the "remove from basket" button,
     *         {@code false} if it shows the "add to basket" button.
     */
    public boolean isObjectInBasketAccordingToObjectPage() {
        driver.waitAndFindElement(OBJECT_PAGE_TOGGLE);
        return !driver.findElements(OBJECT_PAGE_REMOVE).isEmpty();
    }

    public void addToBasketViaObjectPage() {
        driver.waitAndFindElement(OBJECT_PAGE_ADD).click();
        // the add link redirects back to the object page, which then shows the remove button
        driver.waitAndFindElement(OBJECT_PAGE_REMOVE);
    }

    public void addObjectToBasket(String objectId) {
        openObjectPage(objectId);
        addToBasketViaObjectPage();
    }

    public void openBasket() {
        driver.get(baseURL + "/servlets/MCRBasketServlet?type=" + BASKET_TYPE + "&action=show");
        driver.waitAndFindElement(By.id("basket"));
    }

    public void clearBasket() {
        driver.get(baseURL + "/servlets/MCRBasketServlet?type=" + BASKET_TYPE + "&action=clear");
    }

    /**
     * On the basket display page: the formatted title links of all entries. An empty list means the
     * basket content was not rendered by the {@code basketContent} template (raw text fallback).
     */
    public List<WebElement> getBasketEntryTitleLinks() {
        return driver.findElements(By.xpath("//h3[contains(@class,'hit_title')]//a[contains(@href,'/receive/')]"));
    }

    /**
     * On the basket display page: the object IDs of all entries in their current display order.
     */
    public List<String> getBasketEntryOrder() {
        return getBasketEntryTitleLinks().stream()
            .map(link -> {
                String href = link.getDomAttribute("href");
                return href.substring(href.lastIndexOf("/receive/") + "/receive/".length());
            })
            .toList();
    }

    /**
     * Clicks the "down" button of the given basket entry and waits for the basket to reload.
     */
    public void moveDown(String objectId) {
        clickEntryActionAndReload("down", objectId);
    }

    /**
     * Clicks the "up" button of the given basket entry and waits for the basket to reload.
     */
    public void moveUp(String objectId) {
        clickEntryActionAndReload("up", objectId);
    }

    /**
     * The up/down buttons are only links (with action and id) when the move is possible; a disabled
     * button has {@code href="#"} and is therefore not matched here.
     */
    private void clickEntryActionAndReload(String action, String objectId) {
        WebElement button = driver.waitAndFindElement(By.xpath(
            "//a[contains(@href,'action=" + action + "') and contains(@href,'id=" + objectId + "')]"));
        button.click();
        driver.waitFor(ExpectedConditions.stalenessOf(button));
        driver.waitAndFindElement(By.id("basket"));
    }

    public boolean isObjectRenderedInBasket(String objectId) {
        return !driver.findElements(
            By.xpath("//div[contains(@class,'hit_item')]//h3[contains(@class,'hit_title')]"
                + "//a[contains(@href,'" + objectId + "')]"))
            .isEmpty();
    }

    /**
     * @return {@code true} if the search result hit for the given object shows the "remove from basket"
     *         link, i.e. the search page recognizes the object as part of the basket.
     */
    public boolean isObjectInBasketAccordingToSearchHit(String objectId) {
        driver.waitAndFindElement(By.xpath("//*[contains(@href,'" + objectId + "')]"));
        return !driver.findElements(
            By.xpath("//a[contains(@class,'remove_from_basket') and contains(@href,'" + objectId + "')]"))
            .isEmpty();
    }
}
