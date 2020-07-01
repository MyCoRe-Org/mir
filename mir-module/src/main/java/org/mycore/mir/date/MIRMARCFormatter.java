package org.mycore.mir.date;

import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class MIRMARCFormatter implements MIRDateFormatterInterface {

    @Override
    public DateTimeFormatter getFormatter(String date) {
        DateTimeFormatter formatter;
        switch (date.length()) {
            case 1:
            case 2:
                formatter = DateTimeFormatter.ofPattern("yy", Locale.ROOT);
                break;
            case 3:
            case 4:
                formatter = DateTimeFormatter.ofPattern("yyyy", Locale.ROOT);
                break;
            case 5:
            case 6:
                formatter = DateTimeFormatter.ofPattern("yyyyMM", Locale.ROOT);
                break;
            case 7:
            case 8:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd", Locale.ROOT);
                break;
            case 10:
                formatter = DateTimeFormatter.ofPattern("yyyyMMddHH", Locale.ROOT);
                break;
            case 11:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HH", Locale.ROOT);
                break;
            case 12:
                formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmm", Locale.ROOT);
                break;
            case 13:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmm", Locale.ROOT);
                break;
            case 14:
                formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss", Locale.ROOT);
                break;
            case 15:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss", Locale.ROOT);
                break;
            default:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd", Locale.ROOT);
                break;
        }
        return formatter;
    }
}
