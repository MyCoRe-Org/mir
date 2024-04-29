package org.mycore.mir.date;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Year;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAccessor;
import java.util.Locale;

import org.apache.logging.log4j.LogManager;

public class MIRDateConverter {

    public static String convertDate(String date, String format) {
        try {
            String formatterClassName = "org.mycore.mir.date.MIR" + format.toUpperCase(Locale.ROOT) + "Formatter";
            MIRDateFormatterInterface formatter = (MIRDateFormatterInterface) Class.forName(formatterClassName)
                .getDeclaredConstructor().newInstance();
            return getFormatedDateString(date, formatter.getFormatter(date));
        } catch (Exception e) {
            LogManager.getLogger().warn("Error while converting " + date + " from format " + format, e);
            return date;
        }
    }

    private static String getFormatedDateString(String date, DateTimeFormatter formatter) {
        TemporalAccessor ta = formatter.parseBest(date,
            LocalDateTime::from, LocalDate::from, YearMonth::from, Year::from);
        return switch (ta) {
            case LocalDateTime localDateTime
                -> LocalDateTime.from(ta).format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss", Locale.ROOT));
            case LocalDate localDate
                -> LocalDate.from(ta).format(DateTimeFormatter.ofPattern("yyyy-MM-dd", Locale.ROOT));
            case YearMonth yearMonth -> YearMonth.from(ta).format(DateTimeFormatter.ofPattern("yyyy-MM", Locale.ROOT));
            case Year year -> Year.from(ta).format(DateTimeFormatter.ofPattern("yyyy", Locale.ROOT));
            default -> date;
        };
    }
}
