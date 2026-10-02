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

package org.mycore.mir.alias;

import java.util.Optional;

/**
 * The result of resolving an alias path: an object or a file in one of its derivates.
 *
 * @param objectId the resolved object
 * @param file the requested file, empty if the object itself was requested
 */
public record MIRAliasTarget(String objectId, Optional<File> file) {

    public static MIRAliasTarget object(String objectId) {
        return new MIRAliasTarget(objectId, Optional.empty());
    }

    public static MIRAliasTarget file(String objectId, String derivateId, String fileName) {
        return new MIRAliasTarget(objectId, Optional.of(new File(derivateId, fileName)));
    }

    public record File(String derivateId, String fileName) {
    }
}
