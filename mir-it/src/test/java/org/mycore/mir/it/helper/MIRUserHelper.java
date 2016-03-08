/**
 *
 */
package org.mycore.mir.it.helper;

import static org.junit.Assert.assertEquals;

import org.openqa.selenium.By;

/**
 * @author Thomas Scheffler (yagee)
 */
public class MIRUserHelper {

    public static void createUser(MCRRemoteWebDriverFacade driver, String user, String password, String... roles) {
        String currentUrl = driver.getCurrentUrl();
        driver.findElement(By.id("currentUser")).click();
        driver.findElement(By.linkText("Nutzer anlegen")).click();
        for (int i = 0; i < roles.length; i++) {
            if (i > 0) {
                //append a role
                By addRole = By.name("_xed_submit_insert:/user/roles|" + i + "|build|role|rep-" + (i + 1));
                By startRoleSelect = By.xpath("//button[starts-with(@name,'_xed_submit_subselect:/user/roles/role[" + (i + 1) + "]:')]");
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
        driver.findElement(By.name("_xed_submit_servlet:MCRUserServlet")).click();
        assertEquals("Nutzerdaten anzeigen:" + user, driver.getTitle());
        driver.get(currentUrl);
    }

    public static void deleteUser(MCRRemoteWebDriverFacade driver, String user) {
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
            driver.waitAndFindElement(By.cssSelector("div.section.alert p")).getText());
        driver.get(currentUrl);
    }
}
