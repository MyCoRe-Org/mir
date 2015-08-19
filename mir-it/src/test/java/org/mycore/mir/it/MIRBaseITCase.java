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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import junit.framework.TestCase;

import org.apache.log4j.Logger;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.junit.rules.TestWatcher;
import org.junit.runner.Description;
import org.mycore.mir.it.selenium.MIRBy;
import org.openqa.selenium.By;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;

/**
 * @author Thomas Scheffler (yagee) Before doing integration test <a
 *         href="https://code.google.com/p/selenium/issues/detail?id=6950">selenium issue #6950</a> has to be fixed.
 */
public class MIRBaseITCase {

    protected static final String ADMIN_PASSWD = "alleswirdgut";

    protected static final String ADMIN_LOGIN = "administrator";

    private static final Logger LOGGER = Logger.getLogger(MIRBaseITCase.class);

    @ClassRule
    public static TemporaryFolder alternateDirectory = new TemporaryFolder();

    @Rule
    public TestWatcher errorLogger = new TestWatcher() {

        @Override
        protected void failed(Throwable e, Description description) {
            if (description.isTest()) {
                String className = description.getClassName();
                String method = description.getMethodName();
                File failedTestClassDirectory = new File(mavenOutputDirectory, className);
                File failedTestDirectory = new File(failedTestClassDirectory, method);
                failedTestDirectory.mkdirs();
                if (e != null) {
                    File error = new File(failedTestDirectory, "error.txt");
                    try (FileOutputStream fout = new FileOutputStream(error);
                        OutputStreamWriter osw = new OutputStreamWriter(fout, "UTF-8");
                        PrintWriter pw = new PrintWriter(osw)) {
                        pw.println(testURL);
                        e.printStackTrace(pw);
                    } catch (IOException e1) {
                        throw new RuntimeException(e1);
                    }
                }
                File screenshot = new File(failedTestDirectory, "screenshot.png");
                try (FileOutputStream fout = new FileOutputStream(screenshot);) {
                    System.out.println("Saving screenshot to " + screenshot.getAbsolutePath());
                    fout.write(screenShot);
                } catch (IOException e1) {
                    throw new RuntimeException(e1);
                }
                File html = new File(failedTestDirectory, "dom.html");
                try (FileOutputStream fout = new FileOutputStream(html);
                    OutputStreamWriter osw = new OutputStreamWriter(fout, "UTF-8")) {
                    System.out.println("Saving DOM to " + html.getAbsolutePath());
                    osw.write(sourceHTML);
                } catch (IOException e1) {
                    throw new RuntimeException(e1);
                }
            }
            super.failed(e, description);
        }
    };

    private static File mavenOutputDirectory;

    private static int localPort;

    private static String testApp;

    private static String startURL, sourceHTML, testURL;

    private byte[] screenShot;

    private static WebDriver driver;

    @BeforeClass
    public static void setupClass() {
        String buildDirectory = System.getProperty("project.build.directory");
        if (buildDirectory == null) {
            LOGGER.warn("Did not get System property 'project.build.directory'");
            File targetDirectory = new File("target");
            mavenOutputDirectory = targetDirectory.isDirectory() ? targetDirectory : alternateDirectory.getRoot();
        } else {
            mavenOutputDirectory = new File(buildDirectory);
        }
        mavenOutputDirectory = new File(mavenOutputDirectory, "failed-it");
        LOGGER.info("Using " + mavenOutputDirectory.getAbsolutePath() + " as replacement.");
        String port = System.getProperty("it.port", "8080");
        localPort = Integer.parseInt(port);
        testApp = System.getProperty("it.context", "");
        startURL = "http://localhost:" + localPort + "/" + testApp;
        LOGGER.info("Server running on '" + startURL + "'");
        driver = new FirefoxDriver();
    }

    protected static WebDriver getDriver() {
        return driver;
    }

    @Before
    public void setup() {
    }

    @After
    public void tearDown() {
        sourceHTML = driver.getPageSource();
        if (driver instanceof TakesScreenshot) {
            screenShot = ((TakesScreenshot) driver).getScreenshotAs(OutputType.BYTES);
        }
        testURL = driver.getCurrentUrl();
    }

    @Test
    public void goToStart() {
        driver.get(startURL + "/content/index.xml");
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
        driver.findElement(By.xpath("//a[@id='currentUser']")).click();
        driver.findElement(MIRBy.partialLinkText("Abmelden")).click();
        assertEqualsIgnoreCase("Anmelden", driver.findElement(By.xpath("//a[@id='loginURL']")).getText());
    }

    public void loginAs(String user, String password) {
        driver.findElement(By.xpath("//a[@id='loginURL']")).click();
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

    @AfterClass
    public static void tearDownClass() {
        if (driver != null) {
            driver.quit();
        }
    }

    protected boolean isElementPresent(By by) {
        return !driver.findElements(by).isEmpty();
    }

}
