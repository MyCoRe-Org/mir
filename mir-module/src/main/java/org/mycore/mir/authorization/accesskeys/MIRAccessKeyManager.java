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

import java.util.List;
import java.util.Optional;

import javax.persistence.EntityManager;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.mycore.access.MCRAccessManager;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.common.MCRUsageException;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyManager;
import org.mycore.mcr.acl.accesskey.model.jpa.MCRAccessKey;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKeyPair;

public final class MIRAccessKeyManager {

    @SuppressWarnings("unused")
    private static final Logger LOGGER = LogManager.getLogger();

    /**
     * Returns the {@link MIRAccessKeyPair} for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @return the {@link MIRAccessKeyPair}
     */
    public static synchronized MIRAccessKeyPair getKeyPair(final MCRObjectID mcrObjectId) {
        final MCRAccessKey accessKeyRead = 
            MCRAccessKeyManager.getAccessKeysByType(mcrObjectId, MCRAccessManager.PERMISSION_READ).stream()
                .findFirst()
                .orElse(null);
        final MCRAccessKey accessKeyWrite = 
            MCRAccessKeyManager.getAccessKeysByType(mcrObjectId, MCRAccessManager.PERMISSION_WRITE).stream()
                .findFirst()
                .orElse(null);
        if (accessKeyRead != null) {
            if (accessKeyWrite != null) {
                return new MIRAccessKeyPair(mcrObjectId, accessKeyRead.getValue(), accessKeyWrite.getValue());
            } else {
                return new MIRAccessKeyPair(mcrObjectId, accessKeyRead.getValue(), null);
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
     * @throws MCRUsageException pair is not valid
     */
    public static void createKeyPair(final MIRAccessKeyPair accKP) throws MCRUsageException {
        final MCRObjectID objectId = accKP.getMCRObjectId();
        if (objectId == null) {
            throw new MCRUsageException("Object id is needed.");
        }
        if (existsKeyPair(objectId)) {
            throw new MCRUsageException("There is already an existing key piar.");
        }
        final String readValue = accKP.getReadKey();
        if (readValue == null || !MCRAccessKeyManager.isValidValue(readValue)) {
            throw new MCRUsageException("Read key is needed or invalid.");
        }
        final String writeValue = accKP.getWriteKey();
        if (writeValue != null && !MCRAccessKeyManager.isValidValue(writeValue)) {
            throw new MCRUsageException("Write key is invalid.");
        }
        final MCRAccessKey accessKeyRead = new MCRAccessKey(objectId, readValue, MCRAccessManager.PERMISSION_READ);
        MCRAccessKeyManager.addAccessKey(accessKeyRead);
        if (writeValue != null) {
            final MCRAccessKey accessKeyWrite = new MCRAccessKey(objectId, writeValue, 
            MCRAccessManager.PERMISSION_WRITE);
            MCRAccessKeyManager.addAccessKey(accessKeyWrite);
        }
    }

    /**
     * Updates the given {@link MIRAccessKeyPair}.
     *
     * @param accKP the {@link MIRAccessKeyPair}
     * @throws MCRUsageException pair is not valid
     */
    public static void updateKeyPair(final MIRAccessKeyPair accKP) throws MCRUsageException {
        final MCRObjectID objectId = accKP.getMCRObjectId();
        if (objectId == null) {
            throw new MCRUsageException("Object id is needed.");
        }
        final String readValue = accKP.getReadKey();
        final String writeValue = accKP.getWriteKey();
        if (readValue == null && writeValue == null) {
            MCRAccessKeyManager.clearAccessKeys(objectId);
        } else {
            if (readValue == null || !MCRAccessKeyManager.isValidValue(readValue)) {
                throw new MCRUsageException("Read key is needed or invalid.");
            }
            if (writeValue != null && !MCRAccessKeyManager.isValidValue(writeValue)) {
                throw new MCRUsageException("Write key is invalid.");
            }
            MCRAccessKeyManager.clearAccessKeys(objectId);
            final MCRAccessKey readAccessKey = new MCRAccessKey(objectId, readValue, 
                MCRAccessManager.PERMISSION_READ);
            MCRAccessKeyManager.addAccessKey(readAccessKey);
            if (writeValue != null) {
                final MCRAccessKey writeAccessKey = new MCRAccessKey(objectId, writeValue,
                    MCRAccessManager.PERMISSION_WRITE);
                MCRAccessKeyManager.addAccessKey(writeAccessKey);
            }
        }
    }

    /**
     * Returns all access keys.
     *
     * @return access key pairs as list
     */
    public static List<MIRAccessKeyPair> getAccessKeyPairs() {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.createNamedQuery("MIRAccessKeyPair.get", MIRAccessKeyPair.class)
            .getResultList();
    }

    /**
     * Removes access key pair for given {@link MCRObjectID}.
     *
     * @param objectId the {@link MCRObjectID}
     */
    public static void removeAccessKeyPair(final MCRObjectID objectId) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        em.createNamedQuery("MIRAccessKeyPair.removeById")
            .setParameter("objId", objectId.toString())
            .executeUpdate();
    }
}
