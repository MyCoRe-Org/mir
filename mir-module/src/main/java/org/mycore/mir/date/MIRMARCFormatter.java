package org.mycore.mir.date;

import java.time.format.DateTimeFormatter;

public class MIRMARCFormatter implements MIRDateFormatterInterface{

    @Override
    public DateTimeFormatter getFormatter(String date) {
        DateTimeFormatter formatter;
        switch (date.length()) {
            case 1:
            case 2:
                formatter = DateTimeFormatter.ofPattern("yy");
                break;
            case 3:
            case 4:
                formatter = DateTimeFormatter.ofPattern("yyyy");
                break;
            case 5:
            case 6:
                formatter = DateTimeFormatter.ofPattern("yyyyMM");
                break;
            case 7:
            case 8:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
                break;
            case 10:
                formatter = DateTimeFormatter.ofPattern("yyyyMMddHH");
                break;
            case 11:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HH");
                break;
            case 12:
                formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
                break;
            case 13:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmm");
                break;
            case 14:
                formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
                break;
            case 15:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss");
                break;
            default:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        }
        return formatter;
    }
}