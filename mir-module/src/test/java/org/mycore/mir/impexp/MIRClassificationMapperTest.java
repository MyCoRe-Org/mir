package org.mycore.mir.impexp;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MyCoReTest;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
public class MIRClassificationMapperTest {

    /**
     * This Test tests all cases for mapping old SDNB to new SDNB provided by the DNB
     * <p>
     * http://www.dnb.de/SharedDocs/Downloads/DE/DNB/service/ddcSachgruppenDNBKonkordanzNeuAlt.pdf
     * <p>
     * state: 01.01.2011
     */
    @Test
    public void testOldSDNBtoNewSDNBMapping() {
        assertEquals("000", MIRClassificationMapper.getSDNBfromOldSDNB("01"));
        assertEquals("000", MIRClassificationMapper.getSDNBfromOldSDNB("02"));
        assertEquals("000", MIRClassificationMapper.getSDNBfromOldSDNB("03"));
        assertEquals("000", MIRClassificationMapper.getSDNBfromOldSDNB("06"));
        assertEquals("K", MIRClassificationMapper.getSDNBfromOldSDNB("07"));
        assertEquals("741.5", MIRClassificationMapper.getSDNBfromOldSDNB("08"));
        assertEquals("130", MIRClassificationMapper.getSDNBfromOldSDNB("09"));

        assertEquals("100", MIRClassificationMapper.getSDNBfromOldSDNB("10"));
        assertEquals("150", MIRClassificationMapper.getSDNBfromOldSDNB("11"));
        assertEquals("200", MIRClassificationMapper.getSDNBfromOldSDNB("12"));
        assertEquals("200", MIRClassificationMapper.getSDNBfromOldSDNB("13"));
        assertEquals("310", MIRClassificationMapper.getSDNBfromOldSDNB("15"));
        assertEquals("320", MIRClassificationMapper.getSDNBfromOldSDNB("16"));
        assertEquals("300", MIRClassificationMapper.getSDNBfromOldSDNB("17"));
        assertEquals("300", MIRClassificationMapper.getSDNBfromOldSDNB("18"));
        assertEquals("300", MIRClassificationMapper.getSDNBfromOldSDNB("19"));

        assertEquals("350", MIRClassificationMapper.getSDNBfromOldSDNB("20"));
        assertEquals("355", MIRClassificationMapper.getSDNBfromOldSDNB("21"));
        assertEquals("370", MIRClassificationMapper.getSDNBfromOldSDNB("22"));
        assertEquals("S", MIRClassificationMapper.getSDNBfromOldSDNB("23"));
        assertEquals("390", MIRClassificationMapper.getSDNBfromOldSDNB("25"));
        assertEquals("500", MIRClassificationMapper.getSDNBfromOldSDNB("26"));
        assertEquals("510", MIRClassificationMapper.getSDNBfromOldSDNB("27"));
        assertEquals("004", MIRClassificationMapper.getSDNBfromOldSDNB("28"));
        assertEquals("500", MIRClassificationMapper.getSDNBfromOldSDNB("29"));

        assertEquals("540", MIRClassificationMapper.getSDNBfromOldSDNB("30"));
        assertEquals("500", MIRClassificationMapper.getSDNBfromOldSDNB("31"));
        assertEquals("500", MIRClassificationMapper.getSDNBfromOldSDNB("32"));
        assertEquals("610", MIRClassificationMapper.getSDNBfromOldSDNB("33"));
        assertEquals("630", MIRClassificationMapper.getSDNBfromOldSDNB("34"));
        assertEquals("600", MIRClassificationMapper.getSDNBfromOldSDNB("35"));
        assertEquals("600", MIRClassificationMapper.getSDNBfromOldSDNB("36"));
        assertEquals("621.3", MIRClassificationMapper.getSDNBfromOldSDNB("37"));
        assertEquals("600", MIRClassificationMapper.getSDNBfromOldSDNB("38"));
        assertEquals("630", MIRClassificationMapper.getSDNBfromOldSDNB("39"));

        assertEquals("640", MIRClassificationMapper.getSDNBfromOldSDNB("40"));
        assertEquals("760", MIRClassificationMapper.getSDNBfromOldSDNB("41"));
        assertEquals("700", MIRClassificationMapper.getSDNBfromOldSDNB("42"));
        assertEquals("640", MIRClassificationMapper.getSDNBfromOldSDNB("43"));
        assertEquals("710", MIRClassificationMapper.getSDNBfromOldSDNB("44"));
        assertEquals("720", MIRClassificationMapper.getSDNBfromOldSDNB("45"));
        assertEquals("700", MIRClassificationMapper.getSDNBfromOldSDNB("46"));
        assertEquals("770", MIRClassificationMapper.getSDNBfromOldSDNB("47"));
        assertEquals("780", MIRClassificationMapper.getSDNBfromOldSDNB("48"));
        assertEquals("790", MIRClassificationMapper.getSDNBfromOldSDNB("49"));

        assertEquals("790", MIRClassificationMapper.getSDNBfromOldSDNB("50"));
        assertEquals("800", MIRClassificationMapper.getSDNBfromOldSDNB("51"));
        assertEquals("800", MIRClassificationMapper.getSDNBfromOldSDNB("52"));
        assertEquals("830", MIRClassificationMapper.getSDNBfromOldSDNB("53"));
        assertEquals("839", MIRClassificationMapper.getSDNBfromOldSDNB("54"));
        assertEquals("800", MIRClassificationMapper.getSDNBfromOldSDNB("55"));
        assertEquals("800", MIRClassificationMapper.getSDNBfromOldSDNB("56"));
        assertEquals("890", MIRClassificationMapper.getSDNBfromOldSDNB("57"));
        assertEquals("890", MIRClassificationMapper.getSDNBfromOldSDNB("58"));
        assertEquals("800", MIRClassificationMapper.getSDNBfromOldSDNB("59"));

        assertEquals("900", MIRClassificationMapper.getSDNBfromOldSDNB("60"));
        assertEquals("910", MIRClassificationMapper.getSDNBfromOldSDNB("61"));
        assertEquals("910", MIRClassificationMapper.getSDNBfromOldSDNB("62"));
        assertEquals("900", MIRClassificationMapper.getSDNBfromOldSDNB("63"));
        assertEquals("900", MIRClassificationMapper.getSDNBfromOldSDNB("64"));
        assertEquals("800", MIRClassificationMapper.getSDNBfromOldSDNB("65"));

        assertEquals("Y", MIRClassificationMapper.getSDNBfromOldSDNB("78"));
        assertEquals("Z", MIRClassificationMapper.getSDNBfromOldSDNB("79"));

    }

    /**
     * This Test tests all spacial cases for mapping DDC to SDNB provided by the DNB
     * <p>
     * http://www.dnb.de/SharedDocs/Downloads/DE/DNB/service/ddcSachgruppenDNB.html
     * <p>
     * state: 01.01.2011
     */
    @Test
    public void testDDCtoSDNBMapping() {
        assertEquals("000", MIRClassificationMapper.getSDNBfromDDC("000"));
        assertEquals("000", MIRClassificationMapper.getSDNBfromDDC("003"));
        assertEquals("004", MIRClassificationMapper.getSDNBfromDDC("004"));
        assertEquals("004", MIRClassificationMapper.getSDNBfromDDC("006"));
        assertEquals("010", MIRClassificationMapper.getSDNBfromDDC("010"));
        assertEquals("020", MIRClassificationMapper.getSDNBfromDDC("020"));
        assertEquals("030", MIRClassificationMapper.getSDNBfromDDC("030"));
        assertEquals("050", MIRClassificationMapper.getSDNBfromDDC("050"));
        assertEquals("060", MIRClassificationMapper.getSDNBfromDDC("060"));
        assertEquals("070", MIRClassificationMapper.getSDNBfromDDC("070"));
        assertEquals("080", MIRClassificationMapper.getSDNBfromDDC("080"));
        assertEquals("090", MIRClassificationMapper.getSDNBfromDDC("090"));

        assertEquals("100", MIRClassificationMapper.getSDNBfromDDC("100"));
        assertEquals("100", MIRClassificationMapper.getSDNBfromDDC("120"));
        assertEquals("100", MIRClassificationMapper.getSDNBfromDDC("140"));
        assertEquals("100", MIRClassificationMapper.getSDNBfromDDC("160"));
        assertEquals("100", MIRClassificationMapper.getSDNBfromDDC("190"));
        assertEquals("130", MIRClassificationMapper.getSDNBfromDDC("130"));
        assertEquals("150", MIRClassificationMapper.getSDNBfromDDC("150"));

        assertEquals("200", MIRClassificationMapper.getSDNBfromDDC("200"));
        assertEquals("200", MIRClassificationMapper.getSDNBfromDDC("210"));
        assertEquals("220", MIRClassificationMapper.getSDNBfromDDC("220"));
        assertEquals("230", MIRClassificationMapper.getSDNBfromDDC("230"));
        assertEquals("230", MIRClassificationMapper.getSDNBfromDDC("280"));
        assertEquals("290", MIRClassificationMapper.getSDNBfromDDC("290"));

        assertEquals("300", MIRClassificationMapper.getSDNBfromDDC("300"));
        assertEquals("310", MIRClassificationMapper.getSDNBfromDDC("310"));
        assertEquals("320", MIRClassificationMapper.getSDNBfromDDC("320"));
        assertEquals("330", MIRClassificationMapper.getSDNBfromDDC("330"));
        assertEquals("333.7", MIRClassificationMapper.getSDNBfromDDC("333.7"));
        assertEquals("333.7", MIRClassificationMapper.getSDNBfromDDC("333.9"));
        assertEquals("340", MIRClassificationMapper.getSDNBfromDDC("340"));
        assertEquals("350", MIRClassificationMapper.getSDNBfromDDC("350"));
        assertEquals("350", MIRClassificationMapper.getSDNBfromDDC("354"));
        assertEquals("355", MIRClassificationMapper.getSDNBfromDDC("355"));
        assertEquals("355", MIRClassificationMapper.getSDNBfromDDC("359"));
        assertEquals("360", MIRClassificationMapper.getSDNBfromDDC("360"));
        assertEquals("370", MIRClassificationMapper.getSDNBfromDDC("370"));
        assertEquals("380", MIRClassificationMapper.getSDNBfromDDC("380"));
        assertEquals("390", MIRClassificationMapper.getSDNBfromDDC("390"));

        assertEquals("400", MIRClassificationMapper.getSDNBfromDDC("400"));
        assertEquals("400", MIRClassificationMapper.getSDNBfromDDC("410"));
        assertEquals("420", MIRClassificationMapper.getSDNBfromDDC("420"));
        assertEquals("430", MIRClassificationMapper.getSDNBfromDDC("430"));
        assertEquals("439", MIRClassificationMapper.getSDNBfromDDC("439"));
        assertEquals("440", MIRClassificationMapper.getSDNBfromDDC("440"));
        assertEquals("450", MIRClassificationMapper.getSDNBfromDDC("450"));
        assertEquals("460", MIRClassificationMapper.getSDNBfromDDC("460"));
        assertEquals("470", MIRClassificationMapper.getSDNBfromDDC("470"));
        assertEquals("480", MIRClassificationMapper.getSDNBfromDDC("480"));
        assertEquals("490", MIRClassificationMapper.getSDNBfromDDC("490"));
        assertEquals("491.8", MIRClassificationMapper.getSDNBfromDDC("491.7"));
        assertEquals("491.8", MIRClassificationMapper.getSDNBfromDDC("491.8"));

        assertEquals("500", MIRClassificationMapper.getSDNBfromDDC("500"));
        assertEquals("510", MIRClassificationMapper.getSDNBfromDDC("510"));
        assertEquals("520", MIRClassificationMapper.getSDNBfromDDC("520"));
        assertEquals("530", MIRClassificationMapper.getSDNBfromDDC("530"));
        assertEquals("540", MIRClassificationMapper.getSDNBfromDDC("540"));
        assertEquals("550", MIRClassificationMapper.getSDNBfromDDC("550"));
        assertEquals("560", MIRClassificationMapper.getSDNBfromDDC("560"));
        assertEquals("570", MIRClassificationMapper.getSDNBfromDDC("570"));
        assertEquals("580", MIRClassificationMapper.getSDNBfromDDC("580"));
        assertEquals("590", MIRClassificationMapper.getSDNBfromDDC("590"));

        assertEquals("600", MIRClassificationMapper.getSDNBfromDDC("600"));
        assertEquals("610", MIRClassificationMapper.getSDNBfromDDC("610"));
        assertEquals("620", MIRClassificationMapper.getSDNBfromDDC("620"));
        assertEquals("620", MIRClassificationMapper.getSDNBfromDDC("621"));
        assertNotEquals("620", MIRClassificationMapper.getSDNBfromDDC("621.3"));
        assertNotEquals("620", MIRClassificationMapper.getSDNBfromDDC("621.46"));
        assertEquals("620", MIRClassificationMapper.getSDNBfromDDC("623"));
        assertEquals("620", MIRClassificationMapper.getSDNBfromDDC("625.19"));
        assertEquals("620", MIRClassificationMapper.getSDNBfromDDC("625.2"));
        assertEquals("620", MIRClassificationMapper.getSDNBfromDDC("629"));
        assertNotEquals("620", MIRClassificationMapper.getSDNBfromDDC("629.8"));
        assertEquals("621.3", MIRClassificationMapper.getSDNBfromDDC("621.3"));
        assertEquals("621.3", MIRClassificationMapper.getSDNBfromDDC("621.46"));
        assertEquals("621.3", MIRClassificationMapper.getSDNBfromDDC("629.8"));
        assertEquals("624", MIRClassificationMapper.getSDNBfromDDC("622"));
        assertEquals("624", MIRClassificationMapper.getSDNBfromDDC("624"));
        assertEquals("624", MIRClassificationMapper.getSDNBfromDDC("628"));
        assertNotEquals("624", MIRClassificationMapper.getSDNBfromDDC("625.19"));
        assertNotEquals("624", MIRClassificationMapper.getSDNBfromDDC("625.2"));
        assertEquals("630", MIRClassificationMapper.getSDNBfromDDC("630"));
        assertEquals("640", MIRClassificationMapper.getSDNBfromDDC("640"));
        assertEquals("650", MIRClassificationMapper.getSDNBfromDDC("650"));
        assertEquals("660", MIRClassificationMapper.getSDNBfromDDC("660"));
        assertEquals("670", MIRClassificationMapper.getSDNBfromDDC("670"));
        assertEquals("670", MIRClassificationMapper.getSDNBfromDDC("680"));
        assertEquals("690", MIRClassificationMapper.getSDNBfromDDC("690"));

        assertEquals("700", MIRClassificationMapper.getSDNBfromDDC("700"));
        assertEquals("710", MIRClassificationMapper.getSDNBfromDDC("710"));
        assertEquals("720", MIRClassificationMapper.getSDNBfromDDC("720"));
        assertEquals("730", MIRClassificationMapper.getSDNBfromDDC("730"));
        assertEquals("740", MIRClassificationMapper.getSDNBfromDDC("740"));
        assertEquals("741.5", MIRClassificationMapper.getSDNBfromDDC("741.5"));
        assertEquals("750", MIRClassificationMapper.getSDNBfromDDC("750"));
        assertEquals("760", MIRClassificationMapper.getSDNBfromDDC("760"));
        assertEquals("770", MIRClassificationMapper.getSDNBfromDDC("770"));
        assertEquals("780", MIRClassificationMapper.getSDNBfromDDC("780"));
        assertEquals("790", MIRClassificationMapper.getSDNBfromDDC("790"));
        assertEquals("790", MIRClassificationMapper.getSDNBfromDDC("790.2"));
        assertEquals("791", MIRClassificationMapper.getSDNBfromDDC("791"));
        assertEquals("792", MIRClassificationMapper.getSDNBfromDDC("792"));
        assertEquals("793", MIRClassificationMapper.getSDNBfromDDC("793"));
        assertEquals("793", MIRClassificationMapper.getSDNBfromDDC("795"));
        assertEquals("796", MIRClassificationMapper.getSDNBfromDDC("796"));
        assertEquals("796", MIRClassificationMapper.getSDNBfromDDC("799"));

        assertEquals("800", MIRClassificationMapper.getSDNBfromDDC("800"));
        assertEquals("810", MIRClassificationMapper.getSDNBfromDDC("810"));
        assertEquals("820", MIRClassificationMapper.getSDNBfromDDC("820"));
        assertEquals("830", MIRClassificationMapper.getSDNBfromDDC("830"));
        assertEquals("839", MIRClassificationMapper.getSDNBfromDDC("839"));
        assertEquals("840", MIRClassificationMapper.getSDNBfromDDC("840"));
        assertEquals("850", MIRClassificationMapper.getSDNBfromDDC("850"));
        assertEquals("860", MIRClassificationMapper.getSDNBfromDDC("860"));
        assertEquals("870", MIRClassificationMapper.getSDNBfromDDC("870"));
        assertEquals("880", MIRClassificationMapper.getSDNBfromDDC("880"));
        assertEquals("890", MIRClassificationMapper.getSDNBfromDDC("890"));
        assertEquals("891.8", MIRClassificationMapper.getSDNBfromDDC("891.7"));
        assertEquals("891.8", MIRClassificationMapper.getSDNBfromDDC("891.8"));

        assertEquals("900", MIRClassificationMapper.getSDNBfromDDC("900"));
        assertEquals("910", MIRClassificationMapper.getSDNBfromDDC("910"));
        assertEquals("914.3", MIRClassificationMapper.getSDNBfromDDC("914.3"));
        assertEquals("914.3", MIRClassificationMapper.getSDNBfromDDC("914.35"));
        assertEquals("920", MIRClassificationMapper.getSDNBfromDDC("920"));
        assertEquals("930", MIRClassificationMapper.getSDNBfromDDC("930"));
        assertEquals("940", MIRClassificationMapper.getSDNBfromDDC("940"));
        assertEquals("943", MIRClassificationMapper.getSDNBfromDDC("943"));
        assertEquals("943", MIRClassificationMapper.getSDNBfromDDC("943.5"));
        assertEquals("950", MIRClassificationMapper.getSDNBfromDDC("950"));
        assertEquals("960", MIRClassificationMapper.getSDNBfromDDC("960"));
        assertEquals("970", MIRClassificationMapper.getSDNBfromDDC("970"));
        assertEquals("980", MIRClassificationMapper.getSDNBfromDDC("980"));
        assertEquals("990", MIRClassificationMapper.getSDNBfromDDC("990"));

    }
}
