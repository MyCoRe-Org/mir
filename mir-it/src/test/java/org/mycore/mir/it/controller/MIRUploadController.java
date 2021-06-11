/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.mycore.mir.it.controller;

import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class MIRUploadController extends MIRTestController {

    public MIRUploadController(MCRWebdriverWrapper driver, String baseURL) {
        super(driver, baseURL);
    }

    private static final java.util.List<Color> UNIQUE_COLOR_LIST = Stream.of(
            new Color(116, 207, 248),
            new Color(203, 112, 83),
            new Color(231, 115, 159),
            new Color(191, 231, 1),
            new Color(231, 0, 217)).collect(Collectors.toList());

    public File createTestFile() throws IOException {
        File testFile = File.createTempFile("upload", "mir_test.tiff");
        BufferedImage testImage = new BufferedImage(1024, 1024, BufferedImage.TYPE_INT_RGB);
        Graphics graphics = testImage.getGraphics();
        graphics.setFont(Font.decode("Arial-BOLD-30"));
        graphics.drawString("Test-Image", 100, 300);

        for (int i = 0; i < UNIQUE_COLOR_LIST.size(); i++) {
            Color color = UNIQUE_COLOR_LIST.get(i);
            graphics.setColor(color);
            graphics.fillRect((i + 1) * 124, 124, 124, 124);
        }
        ImageIO.write(testImage, "tiff", testFile);
        return testFile;
    }

    public void uploadFile(File upload) throws InterruptedException {
        String path = upload.getAbsolutePath();

        JavascriptExecutor js = driver;
        js.executeScript("window['mcr-testing']=true;");
        driver.waitAndFindElement(By.xpath(".//a[@class='mcr-upload-show']")).click();
        driver.waitAndFindElement(By.xpath(".//input[@id='mcr-testing-file-input']")).sendKeys(path);
        Thread.sleep(10000);
        driver.navigate().refresh();
    }

}
