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
package org.mycore.mir.wizard.utils;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.apache.commons.io.FilenameUtils;
import org.apache.log4j.Logger;

/**
 * This utility extracts files and directories of a standard zip file to
 * a destination directory.
 * 
 * @author René Adler (eagle)
 *
 */
public class MIRWizardUnzip {
    private static final Logger LOGGER = Logger.getLogger(MIRWizardUnzip.class);

    /**
     * Size of the buffer to read/write data.
     */
    private static final int BUFFER_SIZE = 4096;

    /**
     * Extracts a zip file specified by the zipFilePath to a directory specified by
     * destDirectory (will be created if does not exists).
     * 
     * @param zipFilePath the zip file path
     * @param destDirectory the destination directory
     * @throws IOException occurs on failed I/O operations 
     */
    public static void unzip(final String zipFilePath, final String destDirectory) throws IOException {
        final File destDir = new File(destDirectory);
        if (!destDir.exists()) {
            destDir.mkdir();
        }
        final ZipInputStream zipIn = new ZipInputStream(new FileInputStream(zipFilePath));
        ZipEntry entry = zipIn.getNextEntry();

        final String fname = FilenameUtils.getName(zipFilePath);
        LOGGER.info("Extract " + fname + " to " + destDirectory + "...");

        while (entry != null) {
            final String filePath = destDirectory + File.separator + entry.getName();

            LOGGER.info(" " + entry.getName());

            if (!entry.isDirectory()) {
                extractFile(zipIn, filePath);
            } else {
                final File dir = new File(filePath);
                dir.mkdir();
            }
            zipIn.closeEntry();
            entry = zipIn.getNextEntry();
        }

        zipIn.close();

        LOGGER.info("done.");
    }

    /**
     * Extracts a zip entry (file entry).
     * 
     * @param zipIn the zip input stream
     * @param filePath the destination file path
     * @throws IOException occurs on failed I/O operations
     */
    private static void extractFile(final ZipInputStream zipIn, final String filePath) throws IOException {
        final BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(filePath));
        final byte[] bytesIn = new byte[BUFFER_SIZE];
        int read = 0;
        while ((read = zipIn.read(bytesIn)) != -1) {
            bos.write(bytesIn, 0, read);
        }
        bos.close();
    }

}
