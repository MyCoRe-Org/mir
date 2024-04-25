package org.mycore.mir.date;

import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class MIRMARCFormatter implements MIRDateFormatterInterface {

    @Override
    public DateTimeFormatter getFormatter(String date) {
        DateTimeFormatter formatter = switch (date.length()) {
            case 1, 2 -> DateTimeFormatter.ofPattern("yy", Locale.ROOT);
            case 3, 4 -> DateTimeFormatter.ofPattern("yyyy", Locale.ROOT);
            case 5, 6 -> DateTimeFormatter.ofPattern("yyyyMM", Locale.ROOT);
            case 7, 8 -> DateTimeFormatter.ofPattern("yyyyMMdd", Locale.ROOT);
            case 10 -> DateTimeFormatter.ofPattern("yyyyMMddHH", Locale.ROOT);
            case 11 -> DateTimeFormatter.ofPattern("yyyyMMdd'T'HH", Locale.ROOT);
            case 12 -> DateTimeFormatter.ofPattern("yyyyMMddHHmm", Locale.ROOT);
            case 13 -> DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmm", Locale.ROOT);
            case 14 -> DateTimeFormatter.ofPattern("yyyyMMddHHmmss", Locale.ROOT);
            case 15 -> DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss", Locale.ROOT);
            default -> DateTimeFormatter.ofPattern("yyyyMMdd", Locale.ROOT);
        };
        return formatter;
    }
}
