package org.mycore.mir.date;

import java.time.format.DateTimeFormatter;

public interface MIRDateFormatterInterface {
    DateTimeFormatter getFormatter(String date);
}
