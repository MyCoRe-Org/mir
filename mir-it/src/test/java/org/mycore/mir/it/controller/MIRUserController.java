/**
 *
 */
package org.mycore.mir.it.controller;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import org.junit.Test;
import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.common.selenium.util.MCRBy;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.support.ui.ExpectedConditions;

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
        driver.waitAndFindElement(By.id("currentUser")).click();
        driver.waitAndFindElement(By.linkText("Nutzer anlegen")).click();
        for (int i = 0; i < roles.length; i++) {
            if (i > 0) {
                //append a role
                By addRole = By.name("_xed_submit_insert:/user/roles[1]|" + i + "|build|role|rep-" + (i + 1));
                By startRoleSelect = By
                    .xpath("//button[starts-with(@name,'_xed_submit_subselect:/user/roles[1]/role[" + (i + 1) + "]:')]");
                driver.waitAndFindElement(addRole).click();
                driver.waitAndFindElement(startRoleSelect).click();
            } else {
                By startRoleSelect = By.xpath("//button[starts-with(@name,'_xed_submit_subselect:/user/roles[1]/role[1]:')]");
                driver.waitAndFindElement(startRoleSelect).click();
            }
            driver.waitAndFindElement(By.linkText("Systemnutzerrollen")).click();
            driver.waitAndFindElement(By.id("rmcr-roles_" + roles[i])).click();
        }
        driver.waitAndFindElement(By.id("userName")).clear();
        driver.waitAndFindElement(By.id("userName")).sendKeys(user);
        driver.waitAndFindElement(By.id("password")).clear();
        driver.waitAndFindElement(By.id("password")).sendKeys(password);
        driver.waitAndFindElement(By.id("password2")).clear();
        driver.waitAndFindElement(By.id("password2")).sendKeys(password);

        if (name != null) {
            driver.waitAndFindElement(By.id("realNameInput")).sendKeys(name);
        }

        if (mail != null) {
            driver.waitAndFindElement(By.id("emailInput")).sendKeys(mail);
        }

        driver.waitAndFindElement(By.name("_xed_submit_servlet:MCRUserServlet")).click();
        assertion.run();
        driver.get(currentUrl);

    }

    public void deleteUser(String user) {
        String currentUrl = driver.getCurrentUrl();
        driver.waitAndFindElement(By.id("currentUser")).click();
        driver.waitAndFindElement(By.linkText("Nutzerverwaltung")).click();
        By nameSearchField = By.name("search");
        driver.waitAndFindElement(nameSearchField).clear();
        driver.waitAndFindElement(nameSearchField).sendKeys(user);
        driver.waitAndFindElement(By.linkText(user)).click();
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
        driver.waitAndFindElement(By.name("uid")).clear();
        driver.waitAndFindElement(By.name("uid")).sendKeys(user);
        driver.waitAndFindElement(By.name("pwd")).clear();
        driver.waitAndFindElement(By.name("pwd")).sendKeys(password);
        driver.waitAndFindElement(By.name("LoginSubmit")).click();
        assertEqualsIgnoreCase(user, driver.waitAndFindElement(By.xpath("//a[@id='currentUser']")).getText());
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
        assertFalse("Access to start page should not be restricted",
            driver.waitAndFindElement(By.tagName("body")).getText()
                .matches("^[\\s\\S]*Zugriff verweigert[\\s\\S]*$"));
    }

    protected void assertEqualsIgnoreCase(String expected, String actual) {
        assertEqualsIgnoreCase(null, expected, actual);
    }

    protected void assertEqualsIgnoreCase(String message, String expected, String actual) {
        assertEquals(message, expected.toLowerCase(), actual.toLowerCase());
    }

    public void assertUserCreated(String user) {
        driver.waitFor(ExpectedConditions.titleContains("Nutzerdaten anzeigen: " + user));
    }

    public void assertValidationErrorVisible() {
        driver.waitAndFindElement(By.xpath("//input[@name='/user/@name']"));
        driver.waitAndFindElement(By.xpath(".//span[contains(@class,'fa-exclamation-triangle')]"));
    }

    public void logOff() {
        driver.waitAndFindElement(By.xpath("//a[@id='currentUser']")).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("Abmelden")).click();
        assertEqualsIgnoreCase("Anmelden", driver.waitAndFindElement(By.id("loginURL")).getText());
    }

    public boolean isLoggedIn() {
        driver.waitAndFindElement(By.id("logo_modul"));
        try {
            // the header is fully rendered once 'logo_modul' is there, so a missing 'currentUser' means
            // "not logged in" and must not be waited for
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
