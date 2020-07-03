package org.mycore.mir.index;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.junit.Test;
import org.mycore.common.MCRTestCase;
import org.mycore.common.config.MCRConfigurationDir;

public class MirSolrFileStrategyTest extends MCRTestCase {

    private static String testMets = "<mets:mets xmlns:mets=\"http://www.loc.gov/METS/\" "
        + "xmlns:xlink=\"http://www.w3.org/1999/xlink\" >\n"
        + "  <mets:metsHdr LASTMODDATE=\"2016-08-09T12:12:51.320141-04:00\"/>\n"
        + "  <mets:dmdSec ID=\"dmd1\">\n"
        + "  </mets:dmdSec>\n"
        + "  <mets:fileSec>\n"
        + "    <mets:fileGrp USE=\"MASTER\">\n"
        + "      <mets:file MIMETYPE=\"image/tiff\" GROUPID=\"G1\" ID=\"f0178m\">\n"
        + "\t<mets:FLocat LOCTYPE=\"URL\" "
        + "xlink:href=\"http://lcweb4.loc.gov/natlib/ihas/warehouse/afc9999005/AFS_300_A-734_B/0178.tif\"/>\n"
        + "      </mets:file>\n"
        + "    </mets:fileGrp>\n"
        + "  </mets:fileSec>\n"
        + "  <mets:structMap>\n"
        + "    <mets:div DMDID=\"dmd1\" TYPE=\"bib:modsBibCard\">\n"
        + "      <mets:div TYPE=\"bib:card\">\n"
        + "\t<mets:div\">\n"
        + "\t  <mets:fptr FILEID=\"f0178m\"/>\n"
        + "\t</mets:div>\n"
        + "      </mets:div>\n"
        + "    </mets:div>\n"
        + "  </mets:structMap>\n"
        + "</mets:mets>";

    private static String simpleXML = "<foo><bar /></foo>";

    private static final String ALTO_XML = "<alto></alto>";

    @Test
    public void check() throws IOException {
        MirSolrFileStrategy strategy = new MirSolrFileStrategy();
        assertFalse("Should not transmit video files!", strategy.check(Paths.get("test.mp4"), null));
        assertFalse("Should not transmit video files!", strategy.check(Paths.get("test.rmvb"), null));
        assertFalse("Should not transmit image files!", strategy.check(Paths.get("test.jpg"), null));
        assertFalse("Should not transmit image files!", strategy.check(Paths.get("test.tiff"), null));
        assertFalse("Should not transmit audio files!", strategy.check(Paths.get("test.wav"), null));
        assertFalse("Should not transmit audio files!", strategy.check(Paths.get("test.mp3"), null));
        assertFalse("Should not transmit ZIP files!", strategy.check(Paths.get("test.zip"), null));
        assertFalse("Should not transmit TAR.GZ files!", strategy.check(Paths.get("test.tar.gz"), null));
        assertTrue("Should transmit PDF files!", strategy.check(Paths.get("test.pdf"), null));
        assertTrue("Should transmit Powerpoint files!", strategy.check(Paths.get("test.pptx"), null));
        assertTrue("Should transmit Word files!", strategy.check(Paths.get("test.doc"), null));
        assertTrue("Should transmit Word files!", strategy.check(Paths.get("test.docx"), null));
        Path baseDir = MCRConfigurationDir.getConfigurationDirectory().toPath();
        Path xmlTest = baseDir.resolve("test.xml");
        try (OutputStream os = Files.newOutputStream(xmlTest);) {
            os.write(testMets.getBytes(StandardCharsets.UTF_8));
        }
        assertTrue("Should transmit METS files!", strategy.check(xmlTest, null));

        try (OutputStream os = Files.newOutputStream(xmlTest);) {
            os.write(simpleXML.getBytes(StandardCharsets.UTF_8));
        }
        assertTrue("Should transmit XML files!", strategy.check(xmlTest, null));

        try (OutputStream os = Files.newOutputStream(xmlTest);) {
            os.write(ALTO_XML.getBytes(StandardCharsets.UTF_8));
        }
        assertFalse("Should not transmit ALTO files!", strategy.check(xmlTest, null));
        Files.deleteIfExists(xmlTest);
    }
}
