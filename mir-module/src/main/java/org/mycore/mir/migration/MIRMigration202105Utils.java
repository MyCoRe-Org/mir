/*
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

package org.mycore.mir.migration;

import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.mycore.access.MCRAccessManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyManager;
import org.mycore.mcr.acl.accesskey.backend.MCRAccessKey;
import org.mycore.mir.authorization.accesskeys.MIRAccessKeyManager;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKeyPair;

@MCRCommandGroup(
    name = "MIR migration 2021.05")
public class MIRMigration202105Utils {

    public static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(syntax = "migrate access key pairs",
        help = "Migrates all access key pairs to access keys")
    public static void migrateAccessKeyPairs() throws Exception {
        final List<MIRAccessKeyPair> accessKeyPairs = MIRAccessKeyManager.getAccessKeyPairs();
        for (MIRAccessKeyPair accessKeyPair : accessKeyPairs) {
            final MCRObjectID objectId = accessKeyPair.getMCRObjectId();
            final String readKey = accessKeyPair.getReadKey();
            final String writeKey = accessKeyPair.getWriteKey();
            if (readKey != null) {
                final MCRAccessKey accessKey = new MCRAccessKey(objectId, readKey, MCRAccessManager.PERMISSION_READ);
                MCRAccessKeyManager.addAccessKey(accessKey);
            }
            if (writeKey != null) {
                final MCRAccessKey accessKey = new MCRAccessKey(objectId, writeKey, MCRAccessManager.PERMISSION_WRITE);
                MCRAccessKeyManager.addAccessKey(accessKey);
            }
            MIRAccessKeyManager.removeAccessKeyPair(objectId);
        }
        LOGGER.info("migrated all access key pairs to access keys");
    }
}
