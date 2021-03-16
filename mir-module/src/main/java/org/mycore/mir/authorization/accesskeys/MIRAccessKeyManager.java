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
package org.mycore.mir.authorization.accesskeys;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import javax.persistence.EntityManager;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.mycore.access.MCRAccessManager;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRUsageException;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKey;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKeyPair;
import org.mycore.mir.authorization.accesskeys.exception.MIRAccessKeyCollisionException;
import org.mycore.mir.authorization.accesskeys.exception.MIRAccessKeyException;
import org.mycore.mir.authorization.accesskeys.exception.MIRAccessKeyNotFoundException;

public final class MIRAccessKeyManager {

    private static final Logger LOGGER = LogManager.getLogger();

    public static final String ACCESS_KEY_PREFIX = "acckey_";

    /**
     * Returns all access keys for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @return access keys as list
     */
    private static List<MIRAccessKey> getAccessKeys(final MCRObjectID objectId) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.createNamedQuery("MIRAccessKey.getById", MIRAccessKey.class)
            .setParameter("objId", objectId.toString())
            .getResultList();
    }

    /**
     * Returns the {@link MIRAccessKeyPair} for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @return the {@link MIRAccessKeyPair}
     */
    public static MIRAccessKeyPair getKeyPair(final MCRObjectID mcrObjectId) {
        final List<MIRAccessKey> accessKeys = getAccessKeys(mcrObjectId);
        if (accessKeys.size() == 1) {
            final MIRAccessKey accessKeyRead = accessKeys.get(0);
            return new MIRAccessKeyPair(mcrObjectId, accessKeyRead.getValue(), null);
        } else if (accessKeys.size() == 2) {
            final MIRAccessKey accessKeyOne = accessKeys.get(0);
            final MIRAccessKey accessKeyTwo = accessKeys.get(1);
            if (accessKeyOne.getType().equals(MCRAccessManager.PERMISSION_READ)) {
                return new MIRAccessKeyPair(mcrObjectId, accessKeyOne.getValue(), accessKeyTwo.getValue());
            } else {
                return new MIRAccessKeyPair(mcrObjectId, accessKeyTwo.getValue(), accessKeyOne.getValue());
            }
        } else {
            return null;
        }
    }

    /**
     * Checks the quality of the key.
     *
     * @param accessKey the access key
     * @return valid or not
     * @throws MIRAccessKeyException key is not valid
     */
    private static boolean isValidAccessKey(MIRAccessKey accessKey)
        throws MIRAccessKeyException {
        final String value = accessKey.getValue();
        if (value == null || value.length() == 0) {
            LOGGER.warn("Key cannot be empty.");
            throw new MIRAccessKeyException("Key cannot be empty.");
        }
        final String type = accessKey.getType();
        if (type == null || !(type.equals(MCRAccessManager.PERMISSION_READ)
            || type.equals(MCRAccessManager.PERMISSION_WRITE))) {
            LOGGER.warn("Unknown permission type.");
            throw new MIRAccessKeyException("Unknown permission type.");
        }
        return true;
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
     */
    public static void createKeyPair(final MIRAccessKeyPair accKP) {
        final MCRObjectID objectId = accKP.getMCRObjectId();
        final String readKeyValue = accKP.getReadKey();
        final MIRAccessKey accessKeyRead = new MIRAccessKey(objectId, readKeyValue, MCRAccessManager.PERMISSION_READ);
        addAccessKey(accessKeyRead);
        final String writeKeyValue = accKP.getWriteKey();
        if (writeKeyValue != null) {
            final MIRAccessKey accessKeyWrite = 
                new MIRAccessKey(objectId, writeKeyValue, MCRAccessManager.PERMISSION_WRITE);
            addAccessKey(accessKeyWrite);
        }
    }

    /**
     * cleans Permission cache.
     *
     * @param objectId the id of the object
     * @param type the permission type
     */
    private static void cleanPermissionCache(final MCRObjectID objectId, final String type) {
        if (type.equals(MCRAccessManager.PERMISSION_READ)) {
            MCRAccessManager.invalidPermissionCache(objectId.toString(), MCRAccessManager.PERMISSION_READ);
        } else {
            MCRAccessManager.invalidPermissionCache(objectId.toString(), MCRAccessManager.PERMISSION_WRITE);
        }
    }

    /**
     * Checks if there is a value/type collison.
     *
     * @param accessKeys access keys 
     * @param value value
     * @param type permission type
     * @return collision or not
     */
    private static boolean hasCollision(final List<MIRAccessKey> accessKeys, 
        final String value, final String type) {
        if (accessKeys.size() == 0) {
            return false;
        }
        final String collisionType = type.equals(MCRAccessManager.PERMISSION_READ)
            ? MCRAccessManager.PERMISSION_WRITE : MCRAccessManager.PERMISSION_READ;
        return accessKeys.stream()
            .filter(s -> s.getValue().equals(value))
            .anyMatch(s -> s.getType().equals(collisionType));
    }

    /**
     * Adds a access keys for given {@link MCRObjectID}.
     * If there is no value collision
     *
     * @param accessKey the access key
     * @throws MIRAccessKeyException key is not valid
     */
    public static void addAccessKey(final MIRAccessKey accessKey) 
        throws MIRAccessKeyException {
        final MCRObjectID objectId = accessKey.getObjectId();
        if (objectId == null) {
            return;
        }
        if (isValidAccessKey(accessKey)) { 
            List<MIRAccessKey> accessKeys = getAccessKeys(objectId);
            if (!hasCollision(accessKeys, accessKey.getValue(), accessKey.getType())) {
                final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
                em.persist(accessKey);
            } else {
                LOGGER.warn("Key collision.");
                throw new MIRAccessKeyCollisionException("Key collision.");
            }
        }
    }

    /**
     * Deletes all access keys.
     */
    public static void clearAccessKeys() {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        em.createNamedQuery("MIRAccessKey.clear")
            .executeUpdate();
    }

    /**
     * Deletes the all access keys for given {@link MCRObjectID}.
     *
     * @param objectId the {@link MCRObjectID}
     */
    public static void clearAccessKeys(final MCRObjectID objectId) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        em.createNamedQuery("MIRAccessKey.clearById")
            .setParameter("objId", objectId.toString())
            .executeUpdate();
    }

    /**
     * Updates the given {@link MIRAccessKeyPair} or create a new one if not exists.
     *
     * @param accKP the {@link MIRAccessKeyPair}
     */
    public static void updateKeyPair(final MIRAccessKeyPair accKP) {
        final MCRObjectID objectId = accKP.getMCRObjectId();
        final List<MIRAccessKey> accessKeys = getAccessKeys(objectId);
        if (accessKeys.size() == 1) {
            final MIRAccessKey accessKeyOld = accessKeys.get(0);
            MIRAccessKey accessKeyNew = 
                new MIRAccessKey(objectId, accKP.getReadKey(), MCRAccessManager.PERMISSION_READ);
            accessKeyNew.setId(accessKeyOld.getId());
            updateAccessKey(accessKeyNew);
            final String writeKeyValue = accKP.getWriteKey();
            if (writeKeyValue != null) {
                final MIRAccessKey writeAccessKey = 
                    new MIRAccessKey(objectId, writeKeyValue, MCRAccessManager.PERMISSION_WRITE);
                addAccessKey(writeAccessKey);
            }
        }
        if (accessKeys.size() == 2) {
            final MIRAccessKey accessKeyOldOne = accessKeys.get(0);
            final MIRAccessKey accessKeyOldTwo = accessKeys.get(1);
            MIRAccessKey accessKeyNewOne = 
                new MIRAccessKey(objectId, accKP.getReadKey(), MCRAccessManager.PERMISSION_READ);
            MIRAccessKey accessKeyNewTwo = 
                new MIRAccessKey(objectId, accKP.getWriteKey(), MCRAccessManager.PERMISSION_WRITE);
            if (accessKeyOldOne.getType().equals(MCRAccessManager.PERMISSION_READ)) {
                accessKeyNewOne.setId(accessKeyOldOne.getId());
                accessKeyNewTwo.setId(accessKeyOldTwo.getId());
            } else {
                accessKeyNewOne.setId(accessKeyOldTwo.getId());
                accessKeyNewTwo.setId(accessKeyOldOne.getId());
            }
            updateAccessKey(accessKeyNewOne);
            updateAccessKey(accessKeyNewTwo);
        }
    }

    /**
     * Deletes the {@link MIRAccessKeyPair} for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     */
    public static void deleteKeyPair(final MCRObjectID mcrObjectId) {
        List<MIRAccessKey> accessKeys = getAccessKeys(mcrObjectId);
        for (MIRAccessKey accessKey : accessKeys) {
            removeAccessKey(accessKey);
        }
    }

    /**
     * Deletes access key.
     *
     * @param id the id of the key
     * @throws MCRException if key does not exists
     */
    private static void removeAccessKey(final MIRAccessKey accessKey) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        em.remove(accessKey);
        cleanPermissionCache(accessKey.getObjectId(), accessKey.getType());
    }

    /**
     * Updates access key.
     *
     * @param accessKey the access key
     * @throws MCRException if key does not exists
     */
    private static void updateAccessKey(MIRAccessKey newAccessKey) throws MIRAccessKeyException {
        if (newAccessKey.getId() == null) {
            LOGGER.warn("Cannot update Key without id.");
            throw new MIRAccessKeyNotFoundException("Cannot update Key without id.");
        }
        if (isValidAccessKey(newAccessKey)) { 
            final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
            final MIRAccessKey accessKey = em.find(MIRAccessKey.class, newAccessKey.getId());
            if (accessKey != null) {
                List<MIRAccessKey> accessKeys = new ArrayList<MIRAccessKey>();
                accessKeys.addAll(getAccessKeys(accessKey.getObjectId()));
                accessKeys.remove(accessKey);
                final String type = newAccessKey.getType();
                final String value = newAccessKey.getValue();
                if (!hasCollision(accessKeys, value, type)) {
                    accessKey.setType(type);
                    accessKey.setValue(value);
                    cleanPermissionCache(accessKey.getObjectId(), type);
                } else {
                    LOGGER.warn("Key collision.");
                    throw new MIRAccessKeyCollisionException("Key collision.");
                }
            } else {
                LOGGER.warn("Key does not exists.");
                throw new MIRAccessKeyNotFoundException("Key does not exists.");
            }
        }
    }

    /**
     * Add the access key to the current {@link MCRUser} for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @param accessKey the access key
     * @throws MCRUsageException
     *             if an error was occured
     */
    public static void addAccessKey(final MCRObjectID mcrObjectId, final String accessKey) throws MCRUsageException {
        final MCRUser user = MCRUserManager.getCurrentUser();
        addAccessKeyAttribute(user, mcrObjectId, accessKey);
    }

    /**
     * Return the access key for given {@link MCRObjectID} and value.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @param value the key value
     * @return access key or null
     */
    public static synchronized MIRAccessKey getAccessKey(final MCRObjectID objectId, final String value) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.createNamedQuery("MIRAccessKey.getByValue", MIRAccessKey.class)
            .setParameter("objId", objectId.toString())
            .setParameter("value", value)
            .getResultStream()
            .findFirst()
            .orElse(null);
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
     * @param mcrObjectId the {@link MCRObjectID}
     */
    public static void removeAccessKeyPair(final MCRObjectID objectId) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        em.createNamedQuery("MIRAccessKeyPair.removeById")
            .setParameter("objId", objectId.toString())
            .executeUpdate();
    }

    /**
     * Add the access key to the current {@link MCRUser} for given {@link MCRObjectID}.
     *
     * @param user the {@link MCRUser} the key should assigned
     * @param objectId the {@link MCRObjectID}
     * @param value the value of the access key
     * @throws MIRAccessKeyException
     *             if an error was occured
     */
    public static void addAccessKeyAttribute(final MCRUser user, final MCRObjectID objectId, final String value) 
        throws MIRAccessKeyException {

        final MIRAccessKey accessKey = getAccessKey(objectId, value);
        if (accessKey == null) {
            throw new MIRAccessKeyNotFoundException("Key does not exists.");
        }

        user.setUserAttribute(ACCESS_KEY_PREFIX + objectId, value);
        MCRUserManager.updateUser(user);

        cleanPermissionCache(objectId, accessKey.getType());
        MCRSessionMgr.getCurrentSession().setUserInformation(user.clone());
    }

    /**
     * Deletes the access key from current {@link MCRUser} for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     */
    public static void deleteAccessKey(final MCRObjectID mcrObjectId) {
        deleteAccessKey(MCRUserManager.getCurrentUser(), mcrObjectId);
    }

    /**
     * Deletes the access key from given {@link MCRUser} for {@link MCRObjectID}.
     *
     * @param user the {@link MCRUser}
     * @param mcrObjectId the {@link MCRObjectID}
     */
    public static void deleteAccessKey(final MCRUser user, final MCRObjectID mcrObjectId) {
        user.getAttributes().removeIf(ua -> ua.getName().equals(ACCESS_KEY_PREFIX + mcrObjectId.toString()));
        MCRUserManager.updateUser(user);
    }

}
