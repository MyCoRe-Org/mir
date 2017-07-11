package org.mycore.mir.date;

import java.time.format.DateTimeFormatter;

public class MIRISO8601Formatter implements MIRDateFormatterInterface {

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
            case 7:
                formatter = DateTimeFormatter.ofPattern("yyyy-MM");
                break;
            case 8:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
                break;
            case 10:
                formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                break;
            case 11:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HH");
                break;
            case 13:
                if (date.contains("-")) {
                    formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH");
                } else {
                    formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmm");
                }
                break;
            case 14:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HH:mm");
                break;
            case 15:
                if (date.contains("-")) {
                    formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HHmm");
                } else {
                    formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss");
                }
                break;
            case 16:
                formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
                break;
            case 17:
                if (date.contains("-")) {
                    formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HHmmss");
                } else {
                    formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HH:mm:ss");
                }
                break;
            case 19:
                formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
                break;
            default:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        }
        return formatter;
    }
}
