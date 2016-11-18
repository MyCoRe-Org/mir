package org.mycore.mir.it.tests;


import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.imageio.ImageIO;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mycore.common.selenium.util.MCRBy;
import org.mycore.mir.it.controller.MIRModsEditorController;
import org.mycore.mir.it.controller.MIRPublishEditorController;
import org.mycore.mir.it.controller.MIRUserController;
import org.mycore.mir.it.model.MIRDNBClassification;
import org.mycore.mir.it.model.MIRGenre;
import org.mycore.mir.it.model.MIRLanguage;
import org.mycore.mir.it.model.MIRLicense;
import org.mycore.mir.it.model.MIRTitleInfo;
import org.mycore.mir.it.model.MIRTitleType;
import org.openqa.selenium.By;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class MIRUploadITCase extends MIRITBase {

    private static final java.util.List<Color> UNIQUE_COLOR_LIST = Stream.of(
            new Color(116, 207, 248),
            new Color(203, 112, 83),
            new Color(231, 115, 159),
            new Color(191, 231, 1),
            new Color(231, 0, 217)
    ).collect(Collectors.toList());

    @Before
    public final void init() {
        String appURL = getAPPUrlString();
        userController = new MIRUserController(getDriver(), appURL);
        publishEditorController = new MIRPublishEditorController(getDriver(), appURL);
        editorController = new MIRModsEditorController(getDriver(), appURL);
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
        publishEditorController.open(() -> {
        });
    }

    @Test
    public final void testUpload() throws IOException, InterruptedException {
        driver.waitUntilPageIsLoaded("MODS-Dokument erstellen");
        editorController.setGenres(Stream.of(MIRGenre.article, MIRGenre.collection).collect(Collectors.toList()));
        editorController.setTitleInfo(Stream.of(
                new MIRTitleInfo("Der", MIRLanguage.german, MIRTitleType.mainTitle, MIRTestData.TITLE, MIRTestData.SUB_TITLE),
                new MIRTitleInfo("The", MIRLanguage.english, MIRTitleType.alternative, MIRTestData.EN_TITLE, MIRTestData.EN_SUB_TITLE)
        ).collect(Collectors.toList()));
        editorController.setClassifications(Stream.of(MIRDNBClassification._004, MIRDNBClassification._010).collect(Collectors.toList()));
        editorController.setAccessConditions(MIRLicense.cc_by_40);
        editorController.save();

        driver.waitUntilPageIsLoaded(MIRTitleType.mainTitle.getValue());
        driver.waitAndFindElement(MCRBy.partialText(MIRTestData.SAVE_SUCCESS));
        driver.waitAndFindElement(MCRBy.partialLinkText("Aktionen"),
                ExpectedConditions::visibilityOfElementLocated,
                ExpectedConditions::elementToBeClickable).click();
        driver.waitAndFindElement(MCRBy.partialLinkText("Hinzufügen eines Datenobjektes"),
                ExpectedConditions::visibilityOfElementLocated,
                ExpectedConditions::elementToBeClickable).click();

        File upload = File.createTempFile("upload", "mir_test.tiff");

        BufferedImage testImage = new BufferedImage(1024, 1024, BufferedImage.TYPE_INT_RGB);
        Graphics graphics = testImage.getGraphics();
        graphics.setFont(Font.decode("Arial-BOLD-30"));
        graphics.drawString("Test-Image", 100, 300);

        for (int i = 0; i < UNIQUE_COLOR_LIST.size(); i++) {
            Color color = UNIQUE_COLOR_LIST.get(i);
            graphics.setColor(color);
            graphics.fillRect((i + 1) * 124, 124, 124, 124);
        }
        ImageIO.write(testImage, "tiff", upload);

        String path = upload.getAbsolutePath();
        getDriver().waitAndFindElement(By.xpath(".//input[@id='fileToUpload']")).sendKeys(path);
        getDriver().waitAndFindElement(MCRBy.partialText("Abschicken")).click();
        getDriver().waitAndFindElement(By.xpath(".//button[contains(text(),'Fertig') and not(@disabled)]")).click();
        getDriver().waitAndFindElement(MCRBy.partialText(MIRTestData.TITLE));

        // TODO: find workarround is viewer loaded instead of wait 3 seconds
        Thread.sleep(5000);

        byte[] screenshotAsBytes = getDriver().getScreenshotAs(OutputType.BYTES);

        BufferedImage read = ImageIO.read(new ByteArrayInputStream(screenshotAsBytes));

        java.util.List<Color> colorList = UNIQUE_COLOR_LIST.stream().collect(Collectors.toList());
        for (int x = 0; x < read.getWidth() - 1; x++) {
            for (int y = 0; y < read.getHeight() - 1; y++) {
                Color rgb = new Color(read.getRGB(x, y));
                colorList.stream().filter(c -> {
                    // compression kills exact colors :(
                    return Math.abs(rgb.getRed()-c.getRed())<10 && Math.abs(rgb.getBlue()-c.getBlue())<10 && Math.abs(rgb.getGreen()-c.getGreen())<10 ;
                }).collect(Collectors.toList()).forEach(colorList::remove);
            }
        }
        String colorsInList = colorList.stream().map(c -> c.toString()).collect(Collectors.joining(";"));
        Assert.assertTrue("RGBList should be empty (every pixel should be found in screenshot) but list is: " + colorsInList, colorList.isEmpty());
    }
}
