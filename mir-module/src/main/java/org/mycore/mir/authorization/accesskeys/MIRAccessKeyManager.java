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

package org.mycore.mir.authorization.accesskeys;

import static org.mycore.access.MCRAccessManager.PERMISSION_READ;
import static org.mycore.access.MCRAccessManager.PERMISSION_WRITE;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import org.mycore.common.MCRException;
import org.mycore.common.MCRSessionMgr;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyManager;
import org.mycore.mcr.acl.accesskey.model.MCRAccessKey;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKeyPair;

public final class MIRAccessKeyManager {

    /**
     * Returns the {@link MIRAccessKeyPair} for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @return the {@link MIRAccessKeyPair}
     */
    public static synchronized MIRAccessKeyPair getKeyPair(final MCRObjectID mcrObjectId) {
        final MCRAccessKey accessKeyRead = MCRAccessKeyManager.listAccessKeysWithType(mcrObjectId, PERMISSION_READ)
            .stream()
            .findFirst()
            .orElse(null);
        final MCRAccessKey accessKeyWrite = MCRAccessKeyManager.listAccessKeysWithType(mcrObjectId, PERMISSION_WRITE)
            .stream()
            .findFirst()
            .orElse(null);
        if (accessKeyRead != null) {
            if (accessKeyWrite != null) {
                return new MIRAccessKeyPair(mcrObjectId, accessKeyRead.getSecret(), accessKeyWrite.getSecret());
            } else {
                return new MIRAccessKeyPair(mcrObjectId, accessKeyRead.getSecret(), null);
            }
        } else {
            return null;
        }
    }

    /**
     * Checks if an {@link MIRAccessKeyPair} exists for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}.
     * @return <code>true</code> if exists or <code>false</code> if not
     */
    public static boolean existsKeyPair(final MCRObjectID mcrObjectId) {
        return Optional.ofNullable(getKeyPair(mcrObjectId)).isPresent();
    }

    /**
     * Persists the given {@link MIRAccessKeyPair}.
     *
     * @param accKP the {@link MIRAccessKeyPair}
     * @throws MCRException pair is not valid
     */
    public static void createKeyPair(final MIRAccessKeyPair accKP) throws MCRException {
        final MCRObjectID objectId = accKP.getMCRObjectId();
        if (objectId == null) {
            throw new MCRException("Object id is needed.");
        }
        if (existsKeyPair(objectId)) {
            throw new MCRException("There is already an existing key pair.");
        }
        final String readValue = accKP.getReadKey();
        if (readValue == null || !MCRAccessKeyManager.isValidSecret(readValue)) {
            throw new MCRException("Read key is needed or invalid.");
        }
        final String writeValue = accKP.getWriteKey();
        if (writeValue != null && !MCRAccessKeyManager.isValidSecret(writeValue)) {
            throw new MCRException("Write key is invalid.");
        }
        final MCRAccessKey accessKeyRead = new MCRAccessKey(readValue, PERMISSION_READ);
        MCRAccessKeyManager.createAccessKey(objectId, accessKeyRead);
        if (writeValue != null) {
            final MCRAccessKey accessKeyWrite = new MCRAccessKey(writeValue, PERMISSION_WRITE);
            MCRAccessKeyManager.createAccessKey(objectId, accessKeyWrite);
        }
    }

    /**
     * Updates or creates the given {@link MIRAccessKeyPair}.
     *
     * @param accKP the {@link MIRAccessKeyPair}
     * @throws MCRException pair is not valid
     */
    public static void updateKeyPair(final MIRAccessKeyPair accKP) throws MCRException {
        final MCRObjectID objectId = accKP.getMCRObjectId();
        if (objectId == null) {
            throw new MCRException("Object id is needed.");
        }
        final String readValue = accKP.getReadKey();
        final String writeValue = accKP.getWriteKey();
        if (readValue == null && writeValue != null) {
            throw new MCRException("Cannot update without existing read key.");
        }
        final MCRAccessKey accessKeyRead = MCRAccessKeyManager.listAccessKeysWithType(objectId, PERMISSION_READ)
            .stream()
            .findFirst()
            .orElse(null);
        MCRAccessKey accessKeyWrite = MCRAccessKeyManager.listAccessKeysWithType(objectId, PERMISSION_WRITE)
            .stream()
            .findFirst()
            .orElse(null);

        if (accessKeyRead == null && accessKeyWrite == null) { // create
            createKeyPair(accKP);
        } else {
            final List<MCRAccessKey> accessKeys = new ArrayList<>();
            MCRAccessKeyManager.clearAccessKeys(objectId);
            if (readValue.length() > 0) {
                if (!MCRAccessKeyManager.isValidSecret(readValue)) {
                    throw new MCRException("Secret is invalid.");
                }
                accessKeyRead.setSecret(MCRAccessKeyManager.hashSecret(readValue, objectId));
                accessKeys.add(accessKeyRead);
            }
            if (writeValue != null && writeValue.length() > 0) {
                if (!MCRAccessKeyManager.isValidSecret(writeValue)) {
                    throw new MCRException("Secret is invalid.");
                }
                if (accessKeyWrite == null) {
                    accessKeyWrite = new MCRAccessKey(writeValue, PERMISSION_WRITE);
                }
                accessKeyWrite.setSecret(MCRAccessKeyManager.hashSecret(writeValue, objectId));
                accessKeys.add(accessKeyWrite);
            }
            addDefaultKeyInformations(accessKeys);
            MCRAccessKeyManager.addAccessKeys(objectId, accessKeys);
        }
    }

    private static void addDefaultKeyInformations(final List<MCRAccessKey> accessKeys) {
        for (final MCRAccessKey accessKey : accessKeys) {
            accessKey.setIsActive(true);
            accessKey.setLastModified(new Date());
            accessKey.setLastModifiedBy(MCRSessionMgr.getCurrentSession().getUserInformation().getUserID());
        }
    }

    /**
     * Deletes the {@link MIRAccessKeyPair} for given {@link MCRObjectID}.
     *
     * @param objectId the {@link MCRObjectID}
     * @throws MCRException pair is not valid
     */
    public static void deleteKeyPair(final MCRObjectID objectId) {
        MCRAccessKeyManager.clearAccessKeys(objectId);
    }
}
