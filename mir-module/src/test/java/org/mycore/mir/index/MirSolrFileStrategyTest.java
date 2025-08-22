package org.mycore.mir.index;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.junit.jupiter.api.Test;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MirSolrFileStrategyTest {

    private static String testMets = """
        <mets:mets xmlns:mets="http://www.loc.gov/METS/" \
        xmlns:xlink="http://www.w3.org/1999/xlink" >
          <mets:metsHdr LASTMODDATE="2016-08-09T12:12:51.320141-04:00"/>
          <mets:dmdSec ID="dmd1">
          </mets:dmdSec>
          <mets:fileSec>
            <mets:fileGrp USE="MASTER">
              <mets:file MIMETYPE="image/tiff" GROUPID="G1" ID="f0178m">
                <mets:FLocat LOCTYPE="URL" \
                  xlink:href="http://lcweb4.loc.gov/natlib/ihas/warehouse/afc9999005/AFS_300_A-734_B/0178.tif"/>
              </mets:file>
            </mets:fileGrp>
          </mets:fileSec>
          <mets:structMap>
            <mets:div DMDID="dmd1" TYPE="bib:modsBibCard">
              <mets:div TYPE="bib:card">
                <mets:div">
                  <mets:fptr FILEID="f0178m"/>
                </mets:div>
              </mets:div>
            </mets:div>
          </mets:structMap>
        </mets:mets>""";

    private static String simpleXML = "<foo><bar /></foo>";

    private static final String ALTO_XML = "<alto></alto>";

    @Test
    public void check() throws IOException {
        MirSolrFileStrategy strategy = new MirSolrFileStrategy();
        assertFalse(strategy.check(Paths.get("test.mp4"), null), "Should not transmit video files!");
        assertFalse(strategy.check(Paths.get("test.rmvb"), null), "Should not transmit video files!");
        assertFalse(strategy.check(Paths.get("test.jpg"), null), "Should not transmit image files!");
        assertFalse(strategy.check(Paths.get("test.tiff"), null), "Should not transmit image files!");
        assertFalse(strategy.check(Paths.get("test.wav"), null), "Should not transmit audio files!");
        assertFalse(strategy.check(Paths.get("test.mp3"), null), "Should not transmit audio files!");
        assertFalse(strategy.check(Paths.get("test.zip"), null), "Should not transmit ZIP files!");
        assertFalse(strategy.check(Paths.get("test.tar.gz"), null), "Should not transmit TAR.GZ files!");
        assertTrue(strategy.check(Paths.get("test.pdf"), null), "Should transmit PDF files!");
        assertTrue(strategy.check(Paths.get("test.pptx"), null), "Should transmit Powerpoint files!");
        assertTrue(strategy.check(Paths.get("test.doc"), null), "Should transmit Word files!");
        assertTrue(strategy.check(Paths.get("test.docx"), null), "Should transmit Word files!");
        Path baseDir = MCRConfigurationDir.getConfigurationDirectory().toPath();
        Path xmlTest = baseDir.resolve("test.xml");
        try (OutputStream os = Files.newOutputStream(xmlTest);) {
            os.write(testMets.getBytes(StandardCharsets.UTF_8));
        }
        assertTrue(strategy.check(xmlTest, null), "Should transmit METS files!");

        try (OutputStream os = Files.newOutputStream(xmlTest);) {
            os.write(simpleXML.getBytes(StandardCharsets.UTF_8));
        }
        assertTrue(strategy.check(xmlTest, null), "Should transmit XML files!");

        try (OutputStream os = Files.newOutputStream(xmlTest);) {
            os.write(ALTO_XML.getBytes(StandardCharsets.UTF_8));
        }
        assertFalse(strategy.check(xmlTest, null), "Should not transmit ALTO files!");
        Files.deleteIfExists(xmlTest);
    }
}
