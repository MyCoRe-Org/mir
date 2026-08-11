/*
 * This file is part of ***  M y C o R e  ***
 * See https://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.mycore.mir.date;

import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class MIRISO8601Formatter implements MIRDateFormatterInterface {

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
            case 7:
                formatter = DateTimeFormatter.ofPattern("yyyy-MM", Locale.ROOT);
                break;
            case 8:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd", Locale.ROOT);
                break;
            case 10:
                formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd", Locale.ROOT);
                break;
            case 11:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HH", Locale.ROOT);
                break;
            case 13:
                if (date.contains("-")) {
                    formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH", Locale.ROOT);
                } else {
                    formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmm", Locale.ROOT);
                }
                break;
            case 14:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HH:mm", Locale.ROOT);
                break;
            case 15:
                if (date.contains("-")) {
                    formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HHmm", Locale.ROOT);
                } else {
                    formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss", Locale.ROOT);
                }
                break;
            case 16:
                formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm", Locale.ROOT);
                break;
            case 17:
                if (date.contains("-")) {
                    formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HHmmss", Locale.ROOT);
                } else {
                    formatter = DateTimeFormatter.ofPattern("yyyyMMdd'T'HH:mm:ss", Locale.ROOT);
                }
                break;
            case 19:
                formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss", Locale.ROOT);
                break;
            default:
                formatter = DateTimeFormatter.ofPattern("yyyyMMdd", Locale.ROOT);
                break;
        }
        return formatter;
    }
}
