package org.mycore.mir.validation;

import static java.time.format.ResolverStyle.STRICT;
import static java.time.temporal.ChronoField.DAY_OF_MONTH;
import static java.time.temporal.ChronoField.DAY_OF_WEEK;
import static java.time.temporal.ChronoField.DAY_OF_YEAR;
import static java.time.temporal.ChronoField.MONTH_OF_YEAR;
import static java.time.temporal.ChronoField.YEAR;
import static java.time.temporal.IsoFields.WEEK_BASED_YEAR;
import static java.time.temporal.IsoFields.WEEK_OF_WEEK_BASED_YEAR;

import java.time.DateTimeException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.Year;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.util.Locale;

/**
 * Validates date values according to the MODS definitions of the {@code w3cdtf} and {@code iso8601}
 * encoding attributes.
 * <p>
 * W3CDTF values follow the
 * <a href="https://www.w3.org/TR/NOTE-datetime">W3C Date and Time Formats profile</a>. The supported
 * granularities are year, year-month, complete date, and complete date with hours and minutes or
 * seconds plus a mandatory time zone.
 * </p>
 * <p>
 * MODS ISO 8601 values follow the basic representations from ISO 8601-1:2019, with the MODS
 * year-month exception {@code YYYY-MM}, and support calendar, ordinal, and week dates. Date-times
 * require a complete date and may contain hours, minutes, or seconds, with an optional UTC designator
 * or basic offset. A range consists of two independently valid endpoints separated by one slash. The
 * validator deliberately does not compare range endpoints chronologically.
 * </p>
 * <p>
 * The following representations are deliberately unsupported:
 * </p>
 * <ul>
 * <li>fractional time values, because MODS specifies no agreed precision;</li>
 * <li>expanded and negative years, because MODS specifies no agreed expanded year width;</li>
 * <li>{@code YYYYMM}, because ISO 8601-1 defines no basic year-month representation;</li>
 * <li>leap seconds, to keep validation independent of leap-second data;</li>
 * <li>standalone times, durations, recurring intervals, and open ranges, because MODS date values
 * describe temporal points or bounded ranges.</li>
 * </ul>
 * Years therefore range from {@code 0000} through {@code 9999}. All validation is strict and uses
 * ASCII digits and case-sensitive designators.
 */
public final class MIRMODSDateValidator {

    private static final DateTimeFormatter YEAR_FORMATTER = formatter(new DateTimeFormatterBuilder()
        .appendValue(YEAR, 4));

    private static final DateTimeFormatter YEAR_MONTH_FORMATTER = formatter(new DateTimeFormatterBuilder()
        .appendValue(YEAR, 4)
        .appendLiteral('-')
        .appendValue(MONTH_OF_YEAR, 2));

    private static final DateTimeFormatter BASIC_CALENDAR_DATE_FORMATTER = formatter(new DateTimeFormatterBuilder()
        .appendValue(YEAR, 4)
        .appendValue(MONTH_OF_YEAR, 2)
        .appendValue(DAY_OF_MONTH, 2));

    private static final DateTimeFormatter EXTENDED_CALENDAR_DATE_FORMATTER = formatter(new DateTimeFormatterBuilder()
        .appendValue(YEAR, 4)
        .appendLiteral('-')
        .appendValue(MONTH_OF_YEAR, 2)
        .appendLiteral('-')
        .appendValue(DAY_OF_MONTH, 2));

    private static final DateTimeFormatter ORDINAL_DATE_FORMATTER = formatter(new DateTimeFormatterBuilder()
        .appendValue(YEAR, 4)
        .appendValue(DAY_OF_YEAR, 3));

    private static final DateTimeFormatter WEEK_DATE_FORMATTER = formatter(new DateTimeFormatterBuilder()
        .appendValue(WEEK_BASED_YEAR, 4)
        .appendLiteral('W')
        .appendValue(WEEK_OF_WEEK_BASED_YEAR, 2)
        .appendValue(DAY_OF_WEEK, 1));

    private static final DateTimeFormatter WEEK_FORMATTER = formatter(new DateTimeFormatterBuilder()
        .appendValue(WEEK_BASED_YEAR, 4)
        .appendLiteral('W')
        .appendValue(WEEK_OF_WEEK_BASED_YEAR, 2)
        .parseDefaulting(DAY_OF_WEEK, 1));

    private MIRMODSDateValidator() {
    }

    /**
     * Validates a MODS {@code w3cdtf} value against the non-fractional granularities of the W3C
     * Date and Time Formats profile.
     *
     * @param value the value to validate
     * @return {@code true} if the value is a supported W3CDTF representation
     */
    public static boolean validateW3CDTF(String value) {
        if (value == null || value.isEmpty()) {
            return false;
        }

        int timeSeparator = value.indexOf('T');
        if (timeSeparator < 0) {
            return isW3CDTFDate(value);
        }
        if (timeSeparator != 10 || timeSeparator != value.lastIndexOf('T')) {
            return false;
        }

        String date = value.substring(0, timeSeparator);
        String timeAndOffset = value.substring(timeSeparator + 1);
        return isExtendedCalendarDate(date) && isW3CDTFTimeAndOffset(timeAndOffset);
    }

    /**
     * Validates a MODS {@code iso8601} value. This validates syntax and calendar semantics only;
     * range endpoint order is intentionally not compared.
     *
     * @param value the value to validate
     * @return {@code true} if the value is a supported MODS ISO 8601 representation
     */
    public static boolean validateISO8601(String value) {
        if (value == null || value.isEmpty()) {
            return false;
        }

        int rangeSeparator = value.indexOf('/');
        if (rangeSeparator < 0) {
            return isISO8601Point(value);
        }
        if (rangeSeparator == 0
            || rangeSeparator == value.length() - 1
            || rangeSeparator != value.lastIndexOf('/')) {
            return false;
        }

        return isISO8601Point(value.substring(0, rangeSeparator))
            && isISO8601Point(value.substring(rangeSeparator + 1));
    }

    private static boolean isW3CDTFDate(String value) {
        return switch (value.length()) {
            case 4 -> isYear(value);
            case 7 -> isYearMonth(value);
            case 10 -> isExtendedCalendarDate(value);
            default -> false;
        };
    }

    private static boolean isW3CDTFTimeAndOffset(String value) {
        String time;
        if (value.endsWith("Z")) {
            time = value.substring(0, value.length() - 1);
        } else {
            int offsetStart = value.length() - 6;
            if (offsetStart <= 0 || !isExtendedOffset(value.substring(offsetStart))) {
                return false;
            }
            time = value.substring(0, offsetStart);
        }
        return isExtendedTime(time);
    }

    private static boolean isISO8601Point(String value) {
        int timeSeparator = value.indexOf('T');
        if (timeSeparator < 0) {
            return isISO8601Date(value);
        }
        if (timeSeparator == 0
            || timeSeparator == value.length() - 1
            || timeSeparator != value.lastIndexOf('T')) {
            return false;
        }

        String date = value.substring(0, timeSeparator);
        String timeAndOffset = value.substring(timeSeparator + 1);
        return isISO8601CompleteDate(date) && isISO8601TimeAndOffset(timeAndOffset);
    }

    private static boolean isISO8601Date(String value) {
        return switch (value.length()) {
            case 2, 3 -> hasOnlyASCIIDigits(value);
            case 4 -> isYear(value);
            case 7 -> isISO8601SevenCharacterDate(value);
            case 8 -> isISO8601EightCharacterDate(value);
            default -> false;
        };
    }

    private static boolean isISO8601SevenCharacterDate(String value) {
        return switch (value.charAt(4)) {
            case '-' -> isYearMonth(value);
            case 'W' -> isWeek(value);
            default -> isOrdinalDate(value);
        };
    }

    private static boolean isISO8601EightCharacterDate(String value) {
        return value.charAt(4) == 'W' ? isWeekDate(value) : isBasicCalendarDate(value);
    }

    private static boolean isISO8601CompleteDate(String value) {
        return switch (value.length()) {
            case 7 -> isOrdinalDate(value);
            case 8 -> isISO8601EightCharacterDate(value);
            default -> false;
        };
    }

    private static boolean isISO8601TimeAndOffset(String value) {
        String timeAndOffset = value;
        if (value.endsWith("Z")) {
            timeAndOffset = value.substring(0, value.length() - 1);
        } else {
            int offsetStart = findOffsetStart(value);
            if (offsetStart >= 0) {
                if (!isBasicOffset(value.substring(offsetStart))) {
                    return false;
                }
                timeAndOffset = value.substring(0, offsetStart);
            }
        }
        return isBasicTime(timeAndOffset);
    }

    private static int findOffsetStart(String value) {
        for (int i = 1; i < value.length(); i++) {
            char character = value.charAt(i);
            if (character == '+' || character == '-') {
                return i;
            }
        }
        return -1;
    }

    private static boolean isYear(String value) {
        return hasOnlyASCIIDigits(value) && canParseYear(value);
    }

    private static boolean isYearMonth(String value) {
        return hasOnlyASCIIDigits(value, 0, 4)
            && value.charAt(4) == '-'
            && hasOnlyASCIIDigits(value, 5, 7)
            && canParseYearMonth(value);
    }

    private static boolean isBasicCalendarDate(String value) {
        return hasOnlyASCIIDigits(value) && canParseDate(value, BASIC_CALENDAR_DATE_FORMATTER);
    }

    private static boolean isExtendedCalendarDate(String value) {
        return value.length() == 10
            && hasOnlyASCIIDigits(value, 0, 4)
            && value.charAt(4) == '-'
            && hasOnlyASCIIDigits(value, 5, 7)
            && value.charAt(7) == '-'
            && hasOnlyASCIIDigits(value, 8, 10)
            && canParseDate(value, EXTENDED_CALENDAR_DATE_FORMATTER);
    }

    private static boolean isOrdinalDate(String value) {
        return hasOnlyASCIIDigits(value) && canParseDate(value, ORDINAL_DATE_FORMATTER);
    }

    private static boolean isWeek(String value) {
        return hasOnlyASCIIDigits(value, 0, 4)
            && hasOnlyASCIIDigits(value, 5, 7)
            && canParseDate(value, WEEK_FORMATTER);
    }

    private static boolean isWeekDate(String value) {
        return hasOnlyASCIIDigits(value, 0, 4)
            && hasOnlyASCIIDigits(value, 5, 8)
            && canParseDate(value, WEEK_DATE_FORMATTER);
    }

    private static boolean isBasicTime(String value) {
        if (!hasOnlyASCIIDigits(value)) {
            return false;
        }
        return switch (value.length()) {
            case 2 -> isValidTime(value, false, false);
            case 4 -> isValidTime(value, true, false);
            case 6 -> isValidTime(value, true, true);
            default -> false;
        };
    }

    private static boolean isExtendedTime(String value) {
        if (value.length() == 5
            && value.charAt(2) == ':'
            && hasOnlyASCIIDigits(value, 0, 2)
            && hasOnlyASCIIDigits(value, 3, 5)) {
            return isValidTime(value.substring(0, 2) + value.substring(3), true, false);
        }
        if (value.length() == 8
            && value.charAt(2) == ':'
            && value.charAt(5) == ':'
            && hasOnlyASCIIDigits(value, 0, 2)
            && hasOnlyASCIIDigits(value, 3, 5)
            && hasOnlyASCIIDigits(value, 6, 8)) {
            return isValidTime(value.substring(0, 2) + value.substring(3, 5) + value.substring(6), true, true);
        }
        return false;
    }

    private static boolean isValidTime(String value, boolean hasMinutes, boolean hasSeconds) {
        int hour = parseTwoDigits(value, 0);
        int minute = hasMinutes ? parseTwoDigits(value, 2) : 0;
        int second = hasSeconds ? parseTwoDigits(value, 4) : 0;
        try {
            LocalTime ignored = LocalTime.of(hour, minute, second);
            return true;
        } catch (DateTimeException e) {
            return false;
        }
    }

    private static boolean isBasicOffset(String value) {
        if ((value.length() != 3 && value.length() != 5)
            || (value.charAt(0) != '+' && value.charAt(0) != '-')
            || !hasOnlyASCIIDigits(value, 1, value.length())) {
            return false;
        }
        int hour = parseTwoDigits(value, 1);
        int minute = value.length() == 5 ? parseTwoDigits(value, 3) : 0;
        return hour <= 23 && minute <= 59;
    }

    private static boolean isExtendedOffset(String value) {
        if (value.length() != 6
            || (value.charAt(0) != '+' && value.charAt(0) != '-')
            || value.charAt(3) != ':'
            || !hasOnlyASCIIDigits(value, 1, 3)
            || !hasOnlyASCIIDigits(value, 4, 6)) {
            return false;
        }
        int hour = parseTwoDigits(value, 1);
        int minute = parseTwoDigits(value, 4);
        return hour <= 23 && minute <= 59;
    }

    private static int parseTwoDigits(String value, int start) {
        return (value.charAt(start) - '0') * 10 + value.charAt(start + 1) - '0';
    }

    private static boolean hasOnlyASCIIDigits(String value) {
        return hasOnlyASCIIDigits(value, 0, value.length());
    }

    private static boolean hasOnlyASCIIDigits(String value, int start, int end) {
        for (int i = start; i < end; i++) {
            char character = value.charAt(i);
            if (character < '0' || character > '9') {
                return false;
            }
        }
        return true;
    }

    private static boolean canParseYear(String value) {
        try {
            Year ignored = Year.parse(value, YEAR_FORMATTER);
            return true;
        } catch (DateTimeException e) {
            return false;
        }
    }

    private static boolean canParseYearMonth(String value) {
        try {
            YearMonth ignored = YearMonth.parse(value, YEAR_MONTH_FORMATTER);
            return true;
        } catch (DateTimeException e) {
            return false;
        }
    }

    private static boolean canParseDate(String value, DateTimeFormatter formatter) {
        try {
            LocalDate ignored = LocalDate.parse(value, formatter);
            return true;
        } catch (DateTimeException e) {
            return false;
        }
    }

    private static DateTimeFormatter formatter(DateTimeFormatterBuilder builder) {
        return builder
            .parseCaseSensitive()
            .toFormatter(Locale.ROOT)
            .withResolverStyle(STRICT);
    }
}
