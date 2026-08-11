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
