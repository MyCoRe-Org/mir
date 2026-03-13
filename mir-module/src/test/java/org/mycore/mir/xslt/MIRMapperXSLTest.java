package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.common.util.MCRTestCaseClassificationUtil;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
public class MIRMapperXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/functions/mirmapper-test.xsl";

    @BeforeEach
    void setUp() throws Exception {
        MCRTestCaseClassificationUtil.addClassification("/classification/MIRTestClassification.xml");
    }

    @Test
    void testSplitClassificationReference() throws Exception {
        assertEquals("mir_genres", resultText(XSL, "test-classid", Map.of("value", "mir_genres:article")));
        assertEquals("article", resultText(XSL, "test-categid", Map.of("value", "mir_genres:article")));
    }

    @Test
    void testClassUri() throws Exception {
        assertEquals("http://www.mycore.org/classifications/MIRTestClassification",
            resultText(XSL, "test-class-uri", Map.of("value", "MIRTestClassification")));
        assertEquals("", resultText(XSL, "test-class-uri", Map.of("value", "")));
    }

    @Test
    void testOldSdnbMapping() throws Exception {
        String[][] cases = {
            { "01", "000" },
            { "07", "K" },
            { "08", "741.5" },
            { "10", "100" },
            { "21", "355" },
            { "37", "621.3" },
            { "54", "839" },
            { "79", "Z" },
            { "XX", "XX" }
        };
        assertMappings("test-old-sdnb", cases);
    }

    @Test
    void testDdcMapping() throws Exception {
        String[][] cases = {
            { "000", "000" },
            { "004", "004" },
            { "100", "100" },
            { "130", "130" },
            { "210", "200" },
            { "230", "230" },
            { "333.9", "333.7" },
            { "410", "400" },
            { "491.7", "491.8" },
            { "621", "620" },
            { "621.3", "621.3" },
            { "625.19", "620" },
            { "622", "624" },
            { "680", "670" },
            { "741.5", "741.5" },
            { "791", "791" },
            { "795", "793" },
            { "839", "839" },
            { "891.7", "891.8" },
            { "914.35", "914.3" },
            { "943.5", "943" },
            { "abc", "" }
        };
        assertMappings("test-ddc", cases);
    }

    private void assertMappings(String rootName, String[][] cases) throws Exception {
        for (String[] testCase : cases) {
            assertEquals(testCase[1], resultText(XSL, rootName, Map.of("value", testCase[0])), testCase[0]);
        }
    }
}
