package org.mycore.mir.xslt;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.Map;

import org.junit.jupiter.api.Test;
import org.mycore.test.MyCoReTest;

@MyCoReTest
public class MIRDateConverterXSLTest extends MIRXSLTFunctionTestCase {

    private static final String XSL = "/xslt/functions/mirdateconverter-test.xsl";

    @Test
    void testConvertIso8601ToW3CDTF() throws Exception {
        assertConverted("17", "iso8601", "2017");
        assertConverted("2017", "iso8601", "2017");
        assertConverted("2017-01", "iso8601", "2017-01");
        assertConverted("20170130", "iso8601", "2017-01-30");
        assertConverted("2017-01-30", "iso8601", "2017-01-30");

        assertConverted("20170130T13", "iso8601", "2017-01-30T13:00:00");
        assertConverted("2017-01-30T13", "iso8601", "2017-01-30T13:00:00");

        assertConverted("2017-01-30T1315", "iso8601", "2017-01-30T13:15:00");
        assertConverted("2017-01-30T13:15", "iso8601", "2017-01-30T13:15:00");
        assertConverted("20170130T1315", "iso8601", "2017-01-30T13:15:00");
        assertConverted("20170130T13:15", "iso8601", "2017-01-30T13:15:00");

        assertConverted("2017-01-30T131530", "iso8601", "2017-01-30T13:15:30");
        assertConverted("2017-01-30T13:15:30", "iso8601", "2017-01-30T13:15:30");
        assertConverted("20170130T131530", "iso8601", "2017-01-30T13:15:30");
        assertConverted("20170130T13:15:30", "iso8601", "2017-01-30T13:15:30");
    }

    @Test
    void testConvertMarcToW3CDTF() throws Exception {
        assertConverted("17", "marc", "2017");
        assertConverted("2017", "marc", "2017");
        assertConverted("201701", "marc", "2017-01");
        assertConverted("20170130", "marc", "2017-01-30");

        assertConverted("20170130T13", "marc", "2017-01-30T13:00:00");
        assertConverted("2017013013", "marc", "2017-01-30T13:00:00");

        assertConverted("20170130T1315", "marc", "2017-01-30T13:15:00");
        assertConverted("201701301315", "marc", "2017-01-30T13:15:00");

        assertConverted("20170130T131530", "marc", "2017-01-30T13:15:30");
        assertConverted("20170130131530", "marc", "2017-01-30T13:15:30");
    }

    @Test
    void testConvertDateFallsBackForUnknownFormats() throws Exception {
        assertConverted("20uu", "marc", "20uu");
        assertConverted("2017-W01-1", "iso8601", "2017-W01-1");
        assertConverted("unknown/2009", "edtf", "unknown/2009");
        assertConverted("1860~-1872", "temper", "1860~-1872");
    }

    @Test
    void testNormalizeW3CDTFToUTC() throws Exception {
        assertEquals("2017-01-30T11:15:30Z", resultText(XSL, "test-normalize-w3cdtf-to-utc",
            Map.of("value", "2017-01-30T13:15:30+02:00")));
        assertEquals("2017-01-30T13:15:30Z", resultText(XSL, "test-normalize-w3cdtf-to-utc",
            Map.of("value", "2017-01-30T13:15:30Z")));
        assertEquals("invalid", resultText(XSL, "test-normalize-w3cdtf-to-utc", Map.of("value", "invalid")));
    }

    private void assertConverted(String value, String format, String expected) throws Exception {
        assertEquals(expected, resultText(XSL, "test-convert-date", Map.of("date", value, "format", format)));
    }
}
