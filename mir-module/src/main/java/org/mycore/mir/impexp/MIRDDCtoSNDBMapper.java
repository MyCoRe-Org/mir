package org.mycore.mir.impexp;

import java.math.BigDecimal;

/**
 * Created by michel on 14.04.16.
 *
 * This Class maps the DDC Classification to the SNDB Classification using the DNB provided PDF
 *
 * http://www.dnb.de/SharedDocs/Downloads/DE/DNB/service/ddcSachgruppenDNB.html
 *
 * state: 01.01.2011
 *
 */
public class MIRDDCtoSNDBMapper {

    public static String getSNDBfromDDC(String ddcString) {
        BigDecimal ddc = new BigDecimal(ddcString);

        switch (ddcString.charAt(0)){
            case '0':
            {
                if (between(ddc, toBigDecimal("000"), toBigDecimal("004"))) {
                    return "000";
                }

                if (between(ddc, toBigDecimal("004"), toBigDecimal("007"))) {
                    return "004";
                }
                break;
            }

            case '1':
            {
                if (between(ddc, toBigDecimal("100"), toBigDecimal("130"))) {
                    return "100";
                }

                if (between(ddc, toBigDecimal("140"), toBigDecimal("150"))) {
                    return "100";
                }

                if (between(ddc, toBigDecimal("160"), toBigDecimal("200"))) {
                    return "100";
                }
                break;
            }

            case '2':
            {
                if (between(ddc, toBigDecimal("210"), toBigDecimal("220"))) {
                    return "200";
                }

                if (between(ddc, toBigDecimal("230"), toBigDecimal("290"))) {
                    return "230";
                }
                break;
            }

            case '3':
            {
                if (between(ddc, toBigDecimal("333.7"), toBigDecimal("334"))) {
                    return "333.7";
                }

                if (between(ddc, toBigDecimal("350"), toBigDecimal("355"))) {
                    return "350";
                }

                if (between(ddc, toBigDecimal("355"), toBigDecimal("360"))) {
                    return "355";
                }
                break;
            }

            case '4':
            {
                if (between(ddc, toBigDecimal("410"), toBigDecimal("420"))) {
                    return "400";
                }

                if (between(ddc, toBigDecimal("439"), toBigDecimal("440"))) {
                    return "439";
                }

                if (between(ddc, toBigDecimal("491.7"), toBigDecimal("491.9"))) {
                    return "491.8";
                }
                break;
            }

            case '6':
            {
                if (between(ddc, toBigDecimal("621"), toBigDecimal("622")) && !equal(ddc, toBigDecimal("621.3")) && !equal(ddc, toBigDecimal("621.46"))) {
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

                if (equal(ddc, toBigDecimal("621.3")) || equal(ddc, toBigDecimal("621.46")) || equal(ddc, toBigDecimal("629.8"))) {
                    return "621.3";
                }

                if (between(ddc, toBigDecimal("622"), toBigDecimal("623"))) {
                    return "624";
                }

                if (between(ddc, toBigDecimal("624"), toBigDecimal("629")) && !equal(ddc, toBigDecimal("625.19")) && !equal(ddc, toBigDecimal("625.2"))) {
                    return "624";
                }

                if (between(ddc, toBigDecimal("680"), toBigDecimal("690"))) {
                    return "670";
                }
                break;
            }

            case '7':
            {
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
                break;
            }

            case '8':
            {
                if (between(ddc, toBigDecimal("839"), toBigDecimal("840"))) {
                    return "839";
                }

                if (between(ddc, toBigDecimal("891.7"), toBigDecimal("891.9"))) {
                    return "891.8";
                }
                break;
            }

            case '9':
            {
                if (between(ddc, toBigDecimal("914.3"), toBigDecimal("914.36"))) {
                    return "914.3";
                }

                if (between(ddc, toBigDecimal("943"), toBigDecimal("943.6"))) {
                    return "943";
                }
                break;
            }
            default: break;
        }

        ddc = ddc.setScale(-1, BigDecimal.ROUND_DOWN);

        if (ddc.compareTo(toBigDecimal("100")) < 0) {
            return ("000" + ddc.toPlainString()).substring(ddc.toPlainString().length());
        }

        return ddc.toPlainString();
    }

    private static boolean between(BigDecimal check, BigDecimal lowInc, BigDecimal highExc) {
        return check.compareTo(lowInc) >= 0 && check.compareTo(highExc) < 0;
    }
    private static boolean equal(BigDecimal a, BigDecimal b) {
        return a.compareTo(b) == 0;
    }

    private static BigDecimal toBigDecimal(String number) {
        return new BigDecimal(number);
    }
}