package org.mycore.mir.date;

import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAccessor;

public class MIRDateConverter {

    public static String convertDate(String date, String format) {
        try {
            String formatterClassName = "org.mycore.mir.date.MIR" + format.toUpperCase() + "Formatter";
            MIRDateFormatterInterface formatter = (MIRDateFormatterInterface) Class.forName(formatterClassName).newInstance();
            return getFormatedDateString(date, formatter.getFormatter(date));
        } catch (Exception e) {
            e.printStackTrace();
            return date;
        }
    }

    private static String getFormatedDateString(String date, DateTimeFormatter formatter) {
        TemporalAccessor ta = formatter.parseBest(date,
        LocalDateTime::from, LocalDate::from, YearMonth::from, Year::from);
        if (ta instanceof LocalDateTime) {
            LocalDateTime ld = LocalDateTime.from(ta);
            return ld.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss"));
        }
        if (ta instanceof LocalDate) {
            LocalDate ld = LocalDate.from(ta);
            return ld.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        }
        if (ta instanceof YearMonth) {
            YearMonth ld = YearMonth.from(ta);
            return ld.format(DateTimeFormatter.ofPattern("yyyy-MM"));
        }
        if (ta instanceof Year) {
            Year ld = Year.from(ta);
            return ld.format(DateTimeFormatter.ofPattern("yyyy"));
        }
        return date;
    }
}
