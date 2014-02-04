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

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;

import junit.framework.TestCase;

import org.apache.commons.codec.binary.Base64;
import org.apache.log4j.Logger;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.junit.rules.TestWatcher;
import org.junit.runner.Description;

import com.thoughtworks.selenium.DefaultSelenium;
import com.thoughtworks.selenium.SeleneseTestBase;

/**
 * @author Thomas Scheffler (yagee)
 *
 */
public class MIRBaseITCase extends SeleneseTestBase {

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
                    fout.write(Base64.decodeBase64(screenShotBase64));
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

    private static int seleniumPort;

    private static String startURL, screenShotBase64, sourceHTML, testURL;

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
        seleniumPort = Integer.parseInt(System.getProperty("selenium.port", "4444"));
    }

    @Before
    public void setup() {
        selenium = new DefaultSelenium("localhost", seleniumPort, "*firefox", startURL);
        selenium.start();
    }

    @After
    public void tearDown() {
        sourceHTML = selenium.getHtmlSource();
        screenShotBase64 = selenium.captureEntirePageScreenshotToString("");
        testURL = selenium.getLocation();
        selenium.stop();
    }

    @Test
    public void succeed() {
        goToStart();
    }

    public void goToStart() {
        selenium.open(startURL + "/content/main/index.xml");
        selenium.waitForPageToLoad("1000");
        TestCase.assertEquals("Title does not match", "Willkommen bei MIR!", selenium.getTitle());
        assertFalse("Access to start page should not be restricted",
            selenium.getBodyText().matches("^[\\s\\S]*Zugriff verweigert[\\s\\S]*$"));
    }

}
