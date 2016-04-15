package org.mycore.mir.impexp;

import org.mycore.common.MCRHibTestCase;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotEquals;

/**
 * Created by michel on 14.04.16.
 *
 * This Test tests all spacial cases for mapping DDC to SNDB provided by the DNB
 *
 * http://www.dnb.de/SharedDocs/Downloads/DE/DNB/service/ddcSachgruppenDNB.html
 *
 * state: 01.01.2011
 *
 */
public class DDCtoSNDBMapperTest extends MCRHibTestCase {

    @Test
    public void testDDCtoSNDBMapping() {
        assertEquals("000", MIRDDCtoSNDBMapper.getSNDBfromDDC("000"));
        assertEquals("000", MIRDDCtoSNDBMapper.getSNDBfromDDC("003"));
        assertEquals("004", MIRDDCtoSNDBMapper.getSNDBfromDDC("004"));
        assertEquals("004", MIRDDCtoSNDBMapper.getSNDBfromDDC("006"));
        assertEquals("010", MIRDDCtoSNDBMapper.getSNDBfromDDC("010"));
        assertEquals("020", MIRDDCtoSNDBMapper.getSNDBfromDDC("020"));
        assertEquals("030", MIRDDCtoSNDBMapper.getSNDBfromDDC("030"));
        assertEquals("050", MIRDDCtoSNDBMapper.getSNDBfromDDC("050"));
        assertEquals("060", MIRDDCtoSNDBMapper.getSNDBfromDDC("060"));
        assertEquals("070", MIRDDCtoSNDBMapper.getSNDBfromDDC("070"));
        assertEquals("080", MIRDDCtoSNDBMapper.getSNDBfromDDC("080"));
        assertEquals("090", MIRDDCtoSNDBMapper.getSNDBfromDDC("090"));

        assertEquals("100", MIRDDCtoSNDBMapper.getSNDBfromDDC("100"));
        assertEquals("100", MIRDDCtoSNDBMapper.getSNDBfromDDC("120"));
        assertEquals("100", MIRDDCtoSNDBMapper.getSNDBfromDDC("140"));
        assertEquals("100", MIRDDCtoSNDBMapper.getSNDBfromDDC("160"));
        assertEquals("100", MIRDDCtoSNDBMapper.getSNDBfromDDC("190"));
        assertEquals("130", MIRDDCtoSNDBMapper.getSNDBfromDDC("130"));
        assertEquals("150", MIRDDCtoSNDBMapper.getSNDBfromDDC("150"));

        assertEquals("200", MIRDDCtoSNDBMapper.getSNDBfromDDC("200"));
        assertEquals("200", MIRDDCtoSNDBMapper.getSNDBfromDDC("210"));
        assertEquals("220", MIRDDCtoSNDBMapper.getSNDBfromDDC("220"));
        assertEquals("230", MIRDDCtoSNDBMapper.getSNDBfromDDC("230"));
        assertEquals("230", MIRDDCtoSNDBMapper.getSNDBfromDDC("280"));
        assertEquals("290", MIRDDCtoSNDBMapper.getSNDBfromDDC("290"));

        assertEquals("300", MIRDDCtoSNDBMapper.getSNDBfromDDC("300"));
        assertEquals("310", MIRDDCtoSNDBMapper.getSNDBfromDDC("310"));
        assertEquals("320", MIRDDCtoSNDBMapper.getSNDBfromDDC("320"));
        assertEquals("330", MIRDDCtoSNDBMapper.getSNDBfromDDC("330"));
        assertEquals("333.7", MIRDDCtoSNDBMapper.getSNDBfromDDC("333.7"));
        assertEquals("333.7", MIRDDCtoSNDBMapper.getSNDBfromDDC("333.9"));
        assertEquals("340", MIRDDCtoSNDBMapper.getSNDBfromDDC("340"));
        assertEquals("350", MIRDDCtoSNDBMapper.getSNDBfromDDC("350"));
        assertEquals("350", MIRDDCtoSNDBMapper.getSNDBfromDDC("354"));
        assertEquals("355", MIRDDCtoSNDBMapper.getSNDBfromDDC("355"));
        assertEquals("355", MIRDDCtoSNDBMapper.getSNDBfromDDC("359"));
        assertEquals("360", MIRDDCtoSNDBMapper.getSNDBfromDDC("360"));
        assertEquals("370", MIRDDCtoSNDBMapper.getSNDBfromDDC("370"));
        assertEquals("380", MIRDDCtoSNDBMapper.getSNDBfromDDC("380"));
        assertEquals("390", MIRDDCtoSNDBMapper.getSNDBfromDDC("390"));

        assertEquals("400", MIRDDCtoSNDBMapper.getSNDBfromDDC("400"));
        assertEquals("400", MIRDDCtoSNDBMapper.getSNDBfromDDC("410"));
        assertEquals("420", MIRDDCtoSNDBMapper.getSNDBfromDDC("420"));
        assertEquals("430", MIRDDCtoSNDBMapper.getSNDBfromDDC("430"));
        assertEquals("439", MIRDDCtoSNDBMapper.getSNDBfromDDC("439"));
        assertEquals("440", MIRDDCtoSNDBMapper.getSNDBfromDDC("440"));
        assertEquals("450", MIRDDCtoSNDBMapper.getSNDBfromDDC("450"));
        assertEquals("460", MIRDDCtoSNDBMapper.getSNDBfromDDC("460"));
        assertEquals("470", MIRDDCtoSNDBMapper.getSNDBfromDDC("470"));
        assertEquals("480", MIRDDCtoSNDBMapper.getSNDBfromDDC("480"));
        assertEquals("490", MIRDDCtoSNDBMapper.getSNDBfromDDC("490"));
        assertEquals("491.8", MIRDDCtoSNDBMapper.getSNDBfromDDC("491.7"));
        assertEquals("491.8", MIRDDCtoSNDBMapper.getSNDBfromDDC("491.8"));

        assertEquals("500", MIRDDCtoSNDBMapper.getSNDBfromDDC("500"));
        assertEquals("510", MIRDDCtoSNDBMapper.getSNDBfromDDC("510"));
        assertEquals("520", MIRDDCtoSNDBMapper.getSNDBfromDDC("520"));
        assertEquals("530", MIRDDCtoSNDBMapper.getSNDBfromDDC("530"));
        assertEquals("540", MIRDDCtoSNDBMapper.getSNDBfromDDC("540"));
        assertEquals("550", MIRDDCtoSNDBMapper.getSNDBfromDDC("550"));
        assertEquals("560", MIRDDCtoSNDBMapper.getSNDBfromDDC("560"));
        assertEquals("570", MIRDDCtoSNDBMapper.getSNDBfromDDC("570"));
        assertEquals("580", MIRDDCtoSNDBMapper.getSNDBfromDDC("580"));
        assertEquals("590", MIRDDCtoSNDBMapper.getSNDBfromDDC("590"));

        assertEquals("600", MIRDDCtoSNDBMapper.getSNDBfromDDC("600"));
        assertEquals("610", MIRDDCtoSNDBMapper.getSNDBfromDDC("610"));
        assertEquals("620", MIRDDCtoSNDBMapper.getSNDBfromDDC("620"));
        assertEquals("620", MIRDDCtoSNDBMapper.getSNDBfromDDC("621"));
        assertNotEquals("620", MIRDDCtoSNDBMapper.getSNDBfromDDC("621.3"));
        assertNotEquals("620", MIRDDCtoSNDBMapper.getSNDBfromDDC("621.46"));
        assertEquals("620", MIRDDCtoSNDBMapper.getSNDBfromDDC("623"));
        assertEquals("620", MIRDDCtoSNDBMapper.getSNDBfromDDC("625.19"));
        assertEquals("620", MIRDDCtoSNDBMapper.getSNDBfromDDC("625.2"));
        assertEquals("620", MIRDDCtoSNDBMapper.getSNDBfromDDC("629"));
        assertNotEquals("620", MIRDDCtoSNDBMapper.getSNDBfromDDC("629.8"));
        assertEquals("621.3", MIRDDCtoSNDBMapper.getSNDBfromDDC("621.3"));
        assertEquals("621.3", MIRDDCtoSNDBMapper.getSNDBfromDDC("621.46"));
        assertEquals("621.3", MIRDDCtoSNDBMapper.getSNDBfromDDC("629.8"));
        assertEquals("624", MIRDDCtoSNDBMapper.getSNDBfromDDC("622"));
        assertEquals("624", MIRDDCtoSNDBMapper.getSNDBfromDDC("624"));
        assertEquals("624", MIRDDCtoSNDBMapper.getSNDBfromDDC("628"));
        assertNotEquals("624", MIRDDCtoSNDBMapper.getSNDBfromDDC("625.19"));
        assertNotEquals("624", MIRDDCtoSNDBMapper.getSNDBfromDDC("625.2"));
        assertEquals("630", MIRDDCtoSNDBMapper.getSNDBfromDDC("630"));
        assertEquals("640", MIRDDCtoSNDBMapper.getSNDBfromDDC("640"));
        assertEquals("650", MIRDDCtoSNDBMapper.getSNDBfromDDC("650"));
        assertEquals("660", MIRDDCtoSNDBMapper.getSNDBfromDDC("660"));
        assertEquals("670", MIRDDCtoSNDBMapper.getSNDBfromDDC("670"));
        assertEquals("670", MIRDDCtoSNDBMapper.getSNDBfromDDC("680"));
        assertEquals("690", MIRDDCtoSNDBMapper.getSNDBfromDDC("690"));

        assertEquals("700", MIRDDCtoSNDBMapper.getSNDBfromDDC("700"));
        assertEquals("710", MIRDDCtoSNDBMapper.getSNDBfromDDC("710"));
        assertEquals("720", MIRDDCtoSNDBMapper.getSNDBfromDDC("720"));
        assertEquals("730", MIRDDCtoSNDBMapper.getSNDBfromDDC("730"));
        assertEquals("740", MIRDDCtoSNDBMapper.getSNDBfromDDC("740"));
        assertEquals("741.5", MIRDDCtoSNDBMapper.getSNDBfromDDC("741.5"));
        assertEquals("750", MIRDDCtoSNDBMapper.getSNDBfromDDC("750"));
        assertEquals("760", MIRDDCtoSNDBMapper.getSNDBfromDDC("760"));
        assertEquals("770", MIRDDCtoSNDBMapper.getSNDBfromDDC("770"));
        assertEquals("780", MIRDDCtoSNDBMapper.getSNDBfromDDC("780"));
        assertEquals("790", MIRDDCtoSNDBMapper.getSNDBfromDDC("790"));
        assertEquals("790", MIRDDCtoSNDBMapper.getSNDBfromDDC("790.2"));
        assertEquals("791", MIRDDCtoSNDBMapper.getSNDBfromDDC("791"));
        assertEquals("792", MIRDDCtoSNDBMapper.getSNDBfromDDC("792"));
        assertEquals("793", MIRDDCtoSNDBMapper.getSNDBfromDDC("793"));
        assertEquals("793", MIRDDCtoSNDBMapper.getSNDBfromDDC("795"));
        assertEquals("796", MIRDDCtoSNDBMapper.getSNDBfromDDC("796"));
        assertEquals("796", MIRDDCtoSNDBMapper.getSNDBfromDDC("799"));

        assertEquals("800", MIRDDCtoSNDBMapper.getSNDBfromDDC("800"));
        assertEquals("810", MIRDDCtoSNDBMapper.getSNDBfromDDC("810"));
        assertEquals("820", MIRDDCtoSNDBMapper.getSNDBfromDDC("820"));
        assertEquals("830", MIRDDCtoSNDBMapper.getSNDBfromDDC("830"));
        assertEquals("839", MIRDDCtoSNDBMapper.getSNDBfromDDC("839"));
        assertEquals("840", MIRDDCtoSNDBMapper.getSNDBfromDDC("840"));
        assertEquals("850", MIRDDCtoSNDBMapper.getSNDBfromDDC("850"));
        assertEquals("860", MIRDDCtoSNDBMapper.getSNDBfromDDC("860"));
        assertEquals("870", MIRDDCtoSNDBMapper.getSNDBfromDDC("870"));
        assertEquals("880", MIRDDCtoSNDBMapper.getSNDBfromDDC("880"));
        assertEquals("890", MIRDDCtoSNDBMapper.getSNDBfromDDC("890"));
        assertEquals("891.8", MIRDDCtoSNDBMapper.getSNDBfromDDC("891.7"));
        assertEquals("891.8", MIRDDCtoSNDBMapper.getSNDBfromDDC("891.8"));

        assertEquals("900", MIRDDCtoSNDBMapper.getSNDBfromDDC("900"));
        assertEquals("910", MIRDDCtoSNDBMapper.getSNDBfromDDC("910"));
        assertEquals("914.3", MIRDDCtoSNDBMapper.getSNDBfromDDC("914.3"));
        assertEquals("914.3", MIRDDCtoSNDBMapper.getSNDBfromDDC("914.35"));
        assertEquals("920", MIRDDCtoSNDBMapper.getSNDBfromDDC("920"));
        assertEquals("930", MIRDDCtoSNDBMapper.getSNDBfromDDC("930"));
        assertEquals("940", MIRDDCtoSNDBMapper.getSNDBfromDDC("940"));
        assertEquals("943", MIRDDCtoSNDBMapper.getSNDBfromDDC("943"));
        assertEquals("943", MIRDDCtoSNDBMapper.getSNDBfromDDC("943.5"));
        assertEquals("950", MIRDDCtoSNDBMapper.getSNDBfromDDC("950"));
        assertEquals("960", MIRDDCtoSNDBMapper.getSNDBfromDDC("960"));
        assertEquals("970", MIRDDCtoSNDBMapper.getSNDBfromDDC("970"));
        assertEquals("980", MIRDDCtoSNDBMapper.getSNDBfromDDC("980"));
        assertEquals("990", MIRDDCtoSNDBMapper.getSNDBfromDDC("990"));

    }
}
