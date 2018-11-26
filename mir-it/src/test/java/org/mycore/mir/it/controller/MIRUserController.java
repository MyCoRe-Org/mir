/**
 *
 */
package org.mycore.mir.it.controller;

import org.junit.Test;
import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.common.selenium.util.MCRBy;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;

import com.ibm.icu.impl.Assert;
import org.openqa.selenium.support.ui.ExpectedConditions;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

/**
 * @author Thomas Scheffler (yagee)
 */
public class MIRUserController {

    public static final String ADMIN_PASSWD = "alleswirdgut";

    public static final String ADMIN_LOGIN = "administrator";

    String baseURL;

    MCRWebdriverWrapper driver;

    public MIRUserController(MCRWebdriverWrapper driver, String baseURL) {
        this.driver = driver;
        this.baseURL = baseURL;
    }

    public void createUser(String user, String password, String name, String mail, String... roles) {
        this.createUser(user, password, name, mail, () -> assertUserCreated(user), roles);
    }

    public void createUser(String user, String password, String name, String mail, Runnable assertion,
        String... roles) {
        String currentUrl = driver.getCurrentUrl();
        driver.findElement(By.id("currentUser")).click();
        driver.findElement(By.linkText("Nutzer anlegen")).click();
        for (int i = 0; i < roles.length; i++) {
            if (i > 0) {
                //append a role
                By addRole = By.name("_xed_submit_insert:/user/roles|" + i + "|build|role|rep-" + (i + 1));
                By startRoleSelect = By
                    .xpath("//button[starts-with(@name,'_xed_submit_subselect:/user/roles/role[" + (i + 1) + "]:')]");
                driver.waitAndFindElement(addRole).click();
                driver.waitAndFindElement(startRoleSelect).click();
            } else {
                By startRoleSelect = By.xpath("//button[starts-with(@name,'_xed_submit_subselect:/user/roles/role:')]");
                driver.waitAndFindElement(startRoleSelect).click();
            }
            driver.waitAndFindElement(By.linkText("Systemnutzerrollen")).click();
            driver.waitAndFindElement(By.id("rmcr-roles_" + roles[i])).click();
        }
        driver.waitAndFindElement(By.id("userName")).clear();
        driver.findElement(By.id("userName")).sendKeys(user);
        driver.findElement(By.id("password")).clear();
        driver.findElement(By.id("password")).sendKeys(password);
        driver.findElement(By.id("password2")).clear();
        driver.findElement(By.id("password2")).sendKeys(password);

        if (name != null) {
            driver.findElement(By.id("realName")).sendKeys(name);
        }

        if (mail != null) {
            driver.findElement(By.id("email")).sendKeys(mail);
        }

        driver.waitAndFindElement(By.name("_xed_submit_servlet:MCRUserServlet")).click();
        assertion.run();
        driver.get(currentUrl);

    }

    public void deleteUser(String user) {
        String currentUrl = driver.getCurrentUrl();
        driver.findElement(By.id("currentUser")).click();
        driver.findElement(By.linkText("Nutzerverwaltung")).click();
        By nameSearchField = By.name("search");
        driver.waitAndFindElement(nameSearchField).clear();
        driver.findElement(nameSearchField).sendKeys(user);
        driver.findElement(By.linkText(user)).click();
        driver.waitAndFindElement(By.linkText("Nutzer löschen")).click();
        driver.waitAndFindElement(By.cssSelector("input.btn.btn-danger")).click();
        assertEquals("Die Nutzerkennung wurde mitsamt allen Rollenzugehörigkeiten gelöscht.",
            driver.waitAndFindElement(By.cssSelector("div.section.alert-success p")).getText());
        driver.get(currentUrl);
    }

    public void loginAs(String user, String password) {
        // waits up to 30 seconds before throwing a TimeoutException or goes on if login is displayed and enabled
        driver.waitAndFindElement(By.id("loginURL")).click();

        driver.waitFor(ExpectedConditions.titleContains("Anmelden mit lokaler Nutzerkennung"));
        driver.findElement(By.name("uid")).clear();
        driver.findElement(By.name("uid")).sendKeys(user);
        driver.findElement(By.name("pwd")).clear();
        driver.findElement(By.name("pwd")).sendKeys(password);
        driver.findElement(By.name("LoginSubmit")).click();
        assertEqualsIgnoreCase(user, driver.findElement(By.xpath("//a[@id='currentUser']")).getText());
    }

    @Test
    public void logOnLogOff() {
        goToStart();
        loginAs(ADMIN_LOGIN, ADMIN_PASSWD);
        logOff();
    }

    @Test
    public void goToStart() {
        driver.get(baseURL + "/content/index.xml");
        driver.waitFor(ExpectedConditions.titleContains("Willkommen bei MIR!"));
        assertFalse("Access to start page should not be restricted", driver.findElement(By.tagName("body")).getText()
            .matches("^[\\s\\S]*Zugriff verweigert[\\s\\S]*$"));
    }

    protected void assertEqualsIgnoreCase(String expected, String actual) {
        assertEqualsIgnoreCase(null, expected, actual);
    }

    protected void assertEqualsIgnoreCase(String message, String expected, String actual) {
        assertEquals(message, expected.toLowerCase(), actual.toLowerCase());
    }

    public void assertUserCreated(String user) {
        driver.waitFor(ExpectedConditions.titleContains("Nutzerdaten anzeigen:" + user));
    }

    public void assertValidationErrorVisible() {
        driver.waitAndFindElement(By.xpath("//input[@name='/user/@name']"));
        try {
            driver.findElement(By.xpath(".//span[contains(@class,'glyphicon-warning-sign')]"));
        } catch (NoSuchElementException e) {
            Assert.fail(e);
        }
    }

    public void logOff() {
        driver.waitAndFindElement(By.xpath("//a[@id='currentUser']")).click();
        driver.findElement(MCRBy.partialLinkText("Abmelden")).click();
        assertEqualsIgnoreCase("Anmelden", driver.waitAndFindElement(By.id("loginURL")).getText());
    }

    public boolean isLoggedIn() {
        driver.waitAndFindElement(By.id("logo_modul"));
        try {
            driver.findElement(By.id("currentUser"));
        } catch (NoSuchElementException e) {
            return false;
        }
        return true;
    }

    public void logoutIfLoggedIn() {
        goToStart();
        if (isLoggedIn()) {
            logOff();
        }
    }
}
