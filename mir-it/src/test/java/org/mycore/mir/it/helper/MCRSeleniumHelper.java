/**
 * 
 */
package org.mycore.mir.it.helper;

import java.util.function.Consumer;
import java.util.function.Function;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

/**
 * @author Thomas Scheffler
 *
 */
public class MCRSeleniumHelper {

    public static void waitForClickAfterPageLoad(WebDriver driver, By selector, int timeout) {
        waitForActionAfterPageLoad(driver, selector, ExpectedConditions::elementToBeClickable, WebElement::click,
            timeout);
    }

    public static void waitForActionAfterPageLoad(WebDriver driver, By selector, Consumer<WebElement> action,
        int timeout) {
        waitForActionAfterPageLoad(driver, selector, ExpectedConditions::elementToBeClickable, action, timeout);
    }

    public static void waitForActionAfterPageLoad(WebDriver driver, By selector,
        Function<By, ExpectedCondition<WebElement>> condition, Consumer<WebElement> action, int timeout) {
        WebDriverWait wait = new WebDriverWait(driver, timeout);
        WebElement element = wait.until(condition.apply(selector));
        action.accept(element);
    }

}
