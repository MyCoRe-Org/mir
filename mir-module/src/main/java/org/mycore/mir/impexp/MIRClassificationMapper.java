package org.mycore.mir.impexp;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class MIRClassificationMapper {

    /**
     * This Method maps the old SDNB Classification, pre 2003, to the new SDNB Classification using the DNB provided PDF
     * <p>
     * http://www.dnb.de/SharedDocs/Downloads/DE/DNB/service/ddcSachgruppenDNBKonkordanzNeuAlt.pdf
     * <p>
     * state: 01.01.2011
     *
     */
    @SuppressWarnings({ "PMD.ExcessiveMethodLength", "PMD.NPathComplexity", "PMD.NcssCount" }) //todo: fix this
    public static String getSDNBfromOldSDNB(String sdnbString) {
        BigDecimal sdnb = new BigDecimal(sdnbString.replaceAll("[^0-9.]+", ""));

        switch (sdnbString.charAt(0)) {
            case '0': {
                if (betweenInc(sdnb, toBigDecimal("01"), toBigDecimal("03"))) {
                    return "000";
                }

                if (sdnb.equals(toBigDecimal("06"))) {
                    return "000";
                }

                if (sdnb.equals(toBigDecimal("07"))) {
                    return "K";
                }

                if (sdnb.equals(toBigDecimal("08"))) {
                    return "741.5";
                }

                if (sdnb.equals(toBigDecimal("09"))) {
                    return "130";
                }
                break;
            }

            case '1': {
                if (sdnb.equals(toBigDecimal("10"))) {
                    return "100";
                }

                if (sdnb.equals(toBigDecimal("11"))) {
                    return "150";
                }

                if (betweenInc(sdnb, toBigDecimal("12"), toBigDecimal("13"))) {
                    return "200";
                }

                if (sdnb.equals(toBigDecimal("15"))) {
                    return "310";
                }

                if (sdnb.equals(toBigDecimal("16"))) {
                    return "320";
                }

                if (betweenInc(sdnb, toBigDecimal("17"), toBigDecimal("19"))) {
                    return "300";
                }
                break;
            }

            case '2': {
                if (sdnb.equals(toBigDecimal("20"))) {
                    return "350";
                }

                if (sdnb.equals(toBigDecimal("21"))) {
                    return "355";
                }

                if (sdnb.equals(toBigDecimal("22"))) {
                    return "370";
                }

                if (sdnb.equals(toBigDecimal("23"))) {
                    return "S";
                }

                if (sdnb.equals(toBigDecimal("25"))) {
                    return "390";
                }

                if (sdnb.equals(toBigDecimal("26"))) {
                    return "500";
                }

                if (sdnb.equals(toBigDecimal("27"))) {
                    return "510";
                }

                if (sdnb.equals(toBigDecimal("28"))) {
                    return "004";
                }

                if (sdnb.equals(toBigDecimal("29"))) {
                    return "500";
                }
                break;
            }

            case '3': {
                if (sdnb.equals(toBigDecimal("30"))) {
                    return "540";
                }

                if (betweenInc(sdnb, toBigDecimal("31"), toBigDecimal("32"))) {
                    return "500";
                }

                if (sdnb.equals(toBigDecimal("33"))) {
                    return "610";
                }

                if (sdnb.equals(toBigDecimal("34"))) {
                    return "630";
                }

                if (betweenInc(sdnb, toBigDecimal("35"), toBigDecimal("36"))) {
                    return "600";
                }

                if (sdnb.equals(toBigDecimal("37"))) {
                    return "621.3";
                }

                if (sdnb.equals(toBigDecimal("38"))) {
                    return "600";
                }

                if (sdnb.equals(toBigDecimal("39"))) {
                    return "630";
                }
                break;
            }

            case '4': {
                if (sdnb.equals(toBigDecimal("40"))) {
                    return "640";
                }

                if (sdnb.equals(toBigDecimal("41"))) {
                    return "760";
                }

                if (sdnb.equals(toBigDecimal("42"))) {
                    return "700";
                }

                if (sdnb.equals(toBigDecimal("43"))) {
                    return "640";
                }

                if (sdnb.equals(toBigDecimal("44"))) {
                    return "710";
                }

                if (sdnb.equals(toBigDecimal("45"))) {
                    return "720";
                }

                if (sdnb.equals(toBigDecimal("46"))) {
                    return "700";
                }

                if (sdnb.equals(toBigDecimal("47"))) {
                    return "770";
                }

                if (sdnb.equals(toBigDecimal("48"))) {
                    return "780";
                }

                if (sdnb.equals(toBigDecimal("49"))) {
                    return "790";
                }
                break;
            }

            case '5': {
                if (sdnb.equals(toBigDecimal("50"))) {
                    return "790";
                }

                if (betweenInc(sdnb, toBigDecimal("51"), toBigDecimal("52"))) {
                    return "800";
                }

                if (sdnb.equals(toBigDecimal("53"))) {
                    return "830";
                }

                if (sdnb.equals(toBigDecimal("54"))) {
                    return "839";
                }

                if (betweenInc(sdnb, toBigDecimal("55"), toBigDecimal("56"))) {
                    return "800";
                }

                if (betweenInc(sdnb, toBigDecimal("57"), toBigDecimal("58"))) {
                    return "890";
                }

                if (sdnb.equals(toBigDecimal("59"))) {
                    return "800";
                }
                break;
            }

            case '6': {
                if (sdnb.equals(toBigDecimal("60"))) {
                    return "900";
                }

                if (betweenInc(sdnb, toBigDecimal("61"), toBigDecimal("62"))) {
                    return "910";
                }

                if (betweenInc(sdnb, toBigDecimal("63"), toBigDecimal("64"))) {
                    return "900";
                }

                if (sdnb.equals(toBigDecimal("65"))) {
                    return "800";
                }
                break;
            }

            case '7': {
                if (sdnb.equals(toBigDecimal("78"))) {
                    return "Y";
                }

                if (sdnb.equals(toBigDecimal("79"))) {
                    return "Z";
                }
                break;
            }

            default:
                break;
        }

        return sdnbString;
    }

    /**
     *
     * This Class maps the DDC Classification to the SDNB Classification using the DNB provided PDF
     * <p>
     * http://www.dnb.de/SharedDocs/Downloads/DE/DNB/service/ddcSachgruppenDNB.html
     * <p>
     * state: 01.01.2011
     *
     */
    @SuppressWarnings({ "PMD.ExcessiveMethodLength", "PMD.NPathComplexity", "PMD.NcssCount" }) //todo: fix this
    public static String getSDNBfromDDC(String ddcString) {
        BigDecimal ddc = new BigDecimal(ddcString.replaceAll("[^0-9.]+", ""));

        switch (ddcString.charAt(0)) {
            case '0' -> {
                if (between(ddc, toBigDecimal("000"), toBigDecimal("004"))) {
                    return "000";
                }

                if (between(ddc, toBigDecimal("004"), toBigDecimal("007"))) {
                    return "004";
                }
            }
            case '1' -> {
                if (between(ddc, toBigDecimal("100"), toBigDecimal("130"))) {
                    return "100";
                }

                if (between(ddc, toBigDecimal("140"), toBigDecimal("150"))) {
                    return "100";
                }

                if (between(ddc, toBigDecimal("160"), toBigDecimal("200"))) {
                    return "100";
                }
            }
            case '2' -> {
                if (between(ddc, toBigDecimal("210"), toBigDecimal("220"))) {
                    return "200";
                }

                if (between(ddc, toBigDecimal("230"), toBigDecimal("290"))) {
                    return "230";
                }
            }
            case '3' -> {
                if (between(ddc, toBigDecimal("333.7"), toBigDecimal("334"))) {
                    return "333.7";
                }

                if (between(ddc, toBigDecimal("350"), toBigDecimal("355"))) {
                    return "350";
                }

                if (between(ddc, toBigDecimal("355"), toBigDecimal("360"))) {
                    return "355";
                }
            }
            case '4' -> {
                if (between(ddc, toBigDecimal("410"), toBigDecimal("420"))) {
                    return "400";
                }

                if (between(ddc, toBigDecimal("439"), toBigDecimal("440"))) {
                    return "439";
                }

                if (between(ddc, toBigDecimal("491.7"), toBigDecimal("491.9"))) {
                    return "491.8";
                }
            }
            case '6' -> {
                if (between(ddc, toBigDecimal("621"), toBigDecimal("622")) && !equal(ddc, toBigDecimal("621.3"))
                    && !equal(ddc, toBigDecimal("621.46"))) {
                    return "620";
                }

                if (between(ddc, toBigDecimal("623"), toBigDecimal("624"))) {
                    return "620";
                }

                if (equal(ddc, toBigDecimal("625.19")) || equal(ddc, toBigDecimal("625.2"))) {
                    return "620";
                }

                if (between(ddc, toBigDecimal("229"), toBigDecimal("230")) && !equal(ddc, toBigDecimal("629.8"))) {
                    return "620";
                }

                if (equal(ddc, toBigDecimal("621.3")) || equal(ddc, toBigDecimal("621.46"))
                    || equal(ddc, toBigDecimal("629.8"))) {
                    return "621.3";
                }

                if (between(ddc, toBigDecimal("622"), toBigDecimal("623"))) {
                    return "624";
                }

                if (between(ddc, toBigDecimal("624"), toBigDecimal("629")) && !equal(ddc, toBigDecimal("625.19"))
                    && !equal(ddc, toBigDecimal("625.2"))) {
                    return "624";
                }

                if (between(ddc, toBigDecimal("680"), toBigDecimal("690"))) {
                    return "670";
                }
            }
            case '7' -> {
                if (equal(ddc, toBigDecimal("741.5"))) {
                    return "741.5";
                }

                if (between(ddc, toBigDecimal("791"), toBigDecimal("792"))) {
                    return "791";
                }

                if (between(ddc, toBigDecimal("792"), toBigDecimal("793"))) {
                    return "792";
                }

                if (between(ddc, toBigDecimal("793"), toBigDecimal("796"))) {
                    return "793";
                }

                if (between(ddc, toBigDecimal("796"), toBigDecimal("800"))) {
                    return "796";
                }
            }
            case '8' -> {
                if (between(ddc, toBigDecimal("839"), toBigDecimal("840"))) {
                    return "839";
                }

                if (between(ddc, toBigDecimal("891.7"), toBigDecimal("891.9"))) {
                    return "891.8";
                }
            }
            case '9' -> {
                if (between(ddc, toBigDecimal("914.3"), toBigDecimal("914.36"))) {
                    return "914.3";
                }

                if (between(ddc, toBigDecimal("943"), toBigDecimal("943.6"))) {
                    return "943";
                }
            }
            default -> {
            }
        }

        ddc = ddc.setScale(-1, RoundingMode.DOWN);

        if (ddc.compareTo(toBigDecimal("100")) < 0) {
            return ("000" + ddc.toPlainString()).substring(ddc.toPlainString().length());
        }

        return ddc.toPlainString();
    }

    private static boolean between(BigDecimal check, BigDecimal lowInc, BigDecimal highExc) {
        return check.compareTo(lowInc) >= 0 && check.compareTo(highExc) < 0;
    }

    private static boolean betweenInc(BigDecimal check, BigDecimal lowInc, BigDecimal highInc) {
        return check.compareTo(lowInc) >= 0 && check.compareTo(highInc) <= 0;
    }

    private static boolean equal(BigDecimal a, BigDecimal b) {
        return a.compareTo(b) == 0;
    }

    private static BigDecimal toBigDecimal(String number) {
        return new BigDecimal(number);
    }
}
