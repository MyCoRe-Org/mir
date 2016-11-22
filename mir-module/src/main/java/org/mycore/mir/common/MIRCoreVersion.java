/*
 * $Id$ 
 * $Revision$ $Date$
 *
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * This program is free software; you can use it, redistribute it
 * and / or modify it under the terms of the GNU General Public License
 * (GPL) as published by the Free Software Foundation; either version 2
 * of the License or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program, in a file called gpl.txt or license.txt.
 * If not, write to the Free Software Foundation Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 */
package org.mycore.mir.common;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.net.URL;
import java.util.Locale;
import java.util.Properties;

/**
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class MIRCoreVersion {

    private static Properties prop = loadVersionProperties();

    public static final String VERSION = prop.getProperty("mir.version");
    public static final String BRANCH = prop.getProperty("git.branch");


    public static final String REVISION = getRevisionFromProperty();

    public static final String COMPLETE = VERSION + " " + BRANCH + ":" + REVISION;

    public static String getVersion() {
        return VERSION;
    }

    private static Properties loadVersionProperties() {
        Properties props = new Properties();
        URL propURL = MIRCoreVersion.class.getResource("/org/mycore/mir/version.properties");
        try {
            InputStream propStream = propURL.openStream();
            try {
                props.load(propStream);
            } finally {
                propStream.close();
            }
        } catch (IOException e) {
            throw new UncheckedIOException("Error while initializing MIRCoreVersion.", e);
        }
        return props;
    }

    public static String getRevision() {
        return REVISION;
    }

    public static String getCompleteVersion() {
        return COMPLETE;
    }

    public static void main(String arg[]) {
        System.out.printf(Locale.ROOT, "MIR\tver: %s\tbranch: %s\tcommit: %s%n", VERSION, BRANCH, REVISION);
    }

    private static String getRevisionFromProperty() {
        return prop.getProperty("revision.number");
    }
}
