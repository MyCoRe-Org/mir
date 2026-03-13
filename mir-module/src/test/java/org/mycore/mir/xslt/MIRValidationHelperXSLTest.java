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
public class MIRValidationHelperXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/functions/mirvalidationhelper-test.xsl";

    @BeforeEach
    void setUp() throws Exception {
        MCRTestCaseClassificationUtil.addClassification("/classification/MIRTestClassification.xml");
        MCRTestCaseClassificationUtil.addClassification("/classification/SDNB.xml");
    }

    @Test
    void testClassificationExists() throws Exception {
        assertEquals("true", resultText(XSL, "test-classification-exists",
            Map.of("classid", "MIRTestClassification", "categid", "alpha")));
        assertEquals("false", resultText(XSL, "test-classification-exists",
            Map.of("classid", "MIRTestClassification", "categid", "missing")));
    }

    @Test
    void testValidateSdnb() throws Exception {
        assertEquals("000", resultText(XSL, "test-validate-sdnb", Map.of("value", "000")));
        assertEquals("000", resultText(XSL, "test-validate-sdnb", Map.of("value", "01")));
        assertEquals("621.3", resultText(XSL, "test-validate-sdnb", Map.of("value", "37")));
        assertEquals("", resultText(XSL, "test-validate-sdnb", Map.of("value", "999")));
        assertEquals("", resultText(XSL, "test-validate-sdnb", Map.of("value", "")));
    }
}
