/*
 * $Id$
 * $Revision: 5697 $ $Date: Feb 3, 2014 $
 *
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * This program is free software; you can use it, redistribute it
 * and / or modify it under the terms of the GNU General Public License
 * (GPL) as published by the Free Software Foundation; either version 2
 * of the License or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program, in a file called gpl.txt or license.txt.
 * If not, write to the Free Software Foundation Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 */

package org.mycore.mir.it;

import junit.framework.TestCase;

import org.apache.log4j.Logger;
import org.junit.Test;
import org.mycore.common.selenium.MCRSeleniumTestBase;
import org.mycore.common.selenium.util.MCRBy;
import org.openqa.selenium.By;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

/**
 * @author Thomas Scheffler (yagee) Before doing integration test <a
 *         href="https://code.google.com/p/selenium/issues/detail?id=6950">selenium issue #6950</a> has to be fixed.
 */
public class MIRBaseITCase extends MCRSeleniumTestBase {

    protected static final String ADMIN_PASSWD = "alleswirdgut";

    protected static final String ADMIN_LOGIN = "administrator";

    private static final Logger LOGGER = Logger.getLogger(MIRBaseITCase.class);

    protected static final int DEFAULT_PAGE_TIMEOUT = 30;



    @Test
    public void goToStart() {
        driver.get(getBaseUrl(System.getProperty("it.port", "8080")) + "/" + System.getProperty("it.context") + "/content/index.xml");
        TestCase.assertEquals("Title does not match", "Willkommen bei MIR!", driver.getTitle());
        assertFalse("Access to start page should not be restricted", driver.findElement(By.tagName("body")).getText()
            .matches("^[\\s\\S]*Zugriff verweigert[\\s\\S]*$"));
    }

    @Test
    public void logOnLogOff() {
        goToStart();
        loginAs(ADMIN_LOGIN, ADMIN_PASSWD);
        logOff();
    }

    public void logOff() {
        driver.waitAndFindElement(By.xpath("//a[@id='currentUser']")).click();
        driver.findElement(MCRBy.partialLinkText("Abmelden")).click();
        assertEqualsIgnoreCase("Anmelden", driver.waitAndFindElement(By.id("loginURL")).getText());
    }

    public void loginAs(String user, String password) {

        // waits up to 30 seconds before throwing a TimeoutException or goes on if login is displayed and enabled
        driver.waitAndFindElement(By.id("loginURL")).click();

        assertEquals("Anmelden mit lokaler Nutzerkennung", driver.getTitle());
        driver.findElement(By.name("uid")).clear();
        driver.findElement(By.name("uid")).sendKeys(user);
        driver.findElement(By.name("pwd")).clear();
        driver.findElement(By.name("pwd")).sendKeys(password);
        driver.findElement(By.name("LoginSubmit")).click();
        assertEqualsIgnoreCase(user, driver.findElement(By.xpath("//a[@id='currentUser']")).getText());
    }

    protected void assertEqualsIgnoreCase(String expected, String actual) {
        assertEqualsIgnoreCase(null, expected, actual);
    }

    protected void assertEqualsIgnoreCase(String message, String expected, String actual) {
        assertEquals(message, expected.toLowerCase(), actual.toLowerCase());
    }


    protected boolean isElementPresent(By by) {
        return !driver.findElements(by).isEmpty();
    }

}
