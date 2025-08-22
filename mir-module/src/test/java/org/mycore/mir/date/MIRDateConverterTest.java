package org.mycore.mir.date;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
public class MIRDateConverterTest {

    @Test
    public void testISO8601toW3CDTF() {
        assertEquals("2017", MIRDateConverter.convertDate("17", "iso8601"));
        assertEquals("2017", MIRDateConverter.convertDate("2017", "iso8601"));
        assertEquals("2017-01", MIRDateConverter.convertDate("2017-01", "iso8601"));
        assertEquals("2017-01-30", MIRDateConverter.convertDate("20170130", "iso8601"));
        assertEquals("2017-01-30", MIRDateConverter.convertDate("2017-01-30", "iso8601"));

        assertEquals("2017-01-30T13:00:00", MIRDateConverter.convertDate("20170130T13", "iso8601"));
        assertEquals("2017-01-30T13:00:00", MIRDateConverter.convertDate("2017-01-30T13", "iso8601"));

        assertEquals("2017-01-30T13:15:00", MIRDateConverter.convertDate("2017-01-30T1315", "iso8601"));
        assertEquals("2017-01-30T13:15:00", MIRDateConverter.convertDate("2017-01-30T13:15", "iso8601"));
        assertEquals("2017-01-30T13:15:00", MIRDateConverter.convertDate("20170130T1315", "iso8601"));
        assertEquals("2017-01-30T13:15:00", MIRDateConverter.convertDate("20170130T13:15", "iso8601"));

        assertEquals("2017-01-30T13:15:30", MIRDateConverter.convertDate("2017-01-30T131530", "iso8601"));
        assertEquals("2017-01-30T13:15:30", MIRDateConverter.convertDate("2017-01-30T13:15:30", "iso8601"));
        assertEquals("2017-01-30T13:15:30", MIRDateConverter.convertDate("20170130T131530", "iso8601"));
        assertEquals("2017-01-30T13:15:30", MIRDateConverter.convertDate("20170130T13:15:30", "iso8601"));
    }

    @Test
    public void testMARC1toW3CDTF() {
        assertEquals("2017", MIRDateConverter.convertDate("17", "marc"));
        assertEquals("2017", MIRDateConverter.convertDate("2017", "marc"));
        assertEquals("2017-01", MIRDateConverter.convertDate("201701", "marc"));
        assertEquals("2017-01-30", MIRDateConverter.convertDate("20170130", "marc"));

        assertEquals("2017-01-30T13:00:00", MIRDateConverter.convertDate("20170130T13", "marc"));
        assertEquals("2017-01-30T13:00:00", MIRDateConverter.convertDate("2017013013", "marc"));

        assertEquals("2017-01-30T13:15:00", MIRDateConverter.convertDate("20170130T1315", "marc"));
        assertEquals("2017-01-30T13:15:00", MIRDateConverter.convertDate("201701301315", "marc"));

        assertEquals("2017-01-30T13:15:30", MIRDateConverter.convertDate("20170130T131530", "marc"));
        assertEquals("2017-01-30T13:15:30", MIRDateConverter.convertDate("20170130131530", "marc"));
    }

    @Test
    public void testUnConvertible() {
        assertEquals("20uu", MIRDateConverter.convertDate("20uu", "marc"));
        assertEquals("2017-W01-1", MIRDateConverter.convertDate("2017-W01-1", "iso8601"));
        assertEquals("unknown/2009", MIRDateConverter.convertDate("unknown/2009", "edtf"));
        assertEquals("1860~-1872", MIRDateConverter.convertDate("1860~-1872", "temper"));
    }
}
