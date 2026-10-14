package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.Map;

import org.junit.jupiter.api.Test;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIRDatesXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/metadata/test/mirdates-test.xsl";

    @Test
    void testFormat() throws Exception {
        assertEquals("2017", resultText(XSL, "test-format", Map.of("value", "2017")));
        assertEquals("2017", resultText(XSL, "test-format", Map.of("value", "17")));
        assertEquals("unknown", resultText(XSL, "test-format", Map.of("value", "unknown")));
    }
}
