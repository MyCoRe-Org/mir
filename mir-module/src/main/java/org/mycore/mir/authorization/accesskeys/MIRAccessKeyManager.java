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
import org.mycore.mir.authorization.accesskeys.exception.MIRAccessKeyInvalidTypeException;
import org.mycore.mir.authorization.accesskeys.exception.MIRAccessKeyInvalidValueException;
import org.mycore.mir.authorization.accesskeys.exception.MIRAccessKeyNotFoundException;

public final class MIRAccessKeyManager {

    private static final Logger LOGGER = LogManager.getLogger();

    public static final String ACCESS_KEY_PREFIX = "acckey_";

    /**
     * Returns all access keys for given {@link MCRObjectID}.
     *
     * @param objectId the {@link MCRObjectID}
     * @return access keys as list
     */
    public static List<MIRAccessKey> getAccessKeys(final MCRObjectID objectId) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.createNamedQuery("MIRAccessKey.getById", MIRAccessKey.class)
            .setParameter("objId", objectId)
            .getResultList();
    }

    /**
     * Returns the {@link MIRAccessKeyPair} for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @return the {@link MIRAccessKeyPair}
     */
    public static MIRAccessKeyPair getKeyPair(final MCRObjectID mcrObjectId) {
        final MIRAccessKey accessKeyRead = 
            getAccessKeysByType(mcrObjectId, MCRAccessManager.PERMISSION_READ).stream()
                .findFirst()
                .orElse(null);
        final MIRAccessKey accessKeyWrite = 
            getAccessKeysByType(mcrObjectId, MCRAccessManager.PERMISSION_WRITE).stream()
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
     * Checks the quality of the permission.
     *
     * @param type permission type
     * @return valid or not
     */
    private static boolean isValidType(String type) {
        return (type.equals(MCRAccessManager.PERMISSION_READ)
            || type.equals(MCRAccessManager.PERMISSION_WRITE));
    }

    /**
     * Checks the quality of the value.
     *
     * @param value the value 
     * @return valid or not
     */
    private static boolean isValidValue(String value) {
        return value.length() > 0;
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
     * Adds a access keys for given {@link MCRObjectID}.
     * If there is no value collision
     *
     * @param accessKey the access key
     * @throws MIRAccessKeyException key is not valid
     */
    public static synchronized void addAccessKey(final MIRAccessKey accessKey) throws MIRAccessKeyException {
        final MCRObjectID objectId = accessKey.getObjectId();
        if (objectId == null) {
            LOGGER.warn("Object id is required.");
            throw new MIRAccessKeyException("Object id is required.");
        }
        final String type = accessKey.getType();
        if (type == null || !isValidType(type)) {
            LOGGER.warn("Invalid permission type.");
            throw new MIRAccessKeyInvalidTypeException("Invalid permission type.");
        }
        final String value = accessKey.getValue();
        if (value == null || !isValidValue(value)) {
            LOGGER.warn("Incorrect value.");
            throw new MIRAccessKeyInvalidValueException("Incorrect value.");
        }
        if (getAccessKeyByValue(objectId, value) == null) {
            final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
            em.persist(accessKey);
        } else {
            LOGGER.warn("Key collision.");
            throw new MIRAccessKeyCollisionException("Key collision.");
        }
    }

    /**
    * Update access keys.
    *
    * @param objectId the {@link MCRObjectID}
    * @param accessKeys the access keys as list
    */
    public static synchronized void addAccessKeys(final MCRObjectID objectId, final List<MIRAccessKey> accessKeys)
        throws MIRAccessKeyException {
        for (MIRAccessKey accessKey : accessKeys) {
            accessKey.setObjectId(objectId);
            accessKey.setId(0); //prevent collision
            addAccessKey(accessKey);
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
            .setParameter("objId", objectId)
            .executeUpdate();
    }

    /**
     * Deletes access keys for given {@link MCRObjectID} and value.
     *
     * @param objectId the {@link MCRObjectID}
     * @param value the value
     */
    public static void deleteAccessKey(final MCRObjectID objectId, final String value)
        throws MIRAccessKeyNotFoundException {
        final MIRAccessKey accessKey = getAccessKeyByValue(objectId, value);
        if (accessKey == null) {
            LOGGER.warn("Key does not exists.");
            throw new MIRAccessKeyNotFoundException("Key does not exists.");
        } else {
            removeAccessKey(accessKey);
        }
    }

    /**
     * Updates the given {@link MIRAccessKeyPair} or create a new one if not exists.
     *
     * @param accKP the {@link MIRAccessKeyPair}
     * @throws MIRAccessKeyException key is not valid
     */
    public static void updateKeyPair(final MIRAccessKeyPair accKP) {
        if (accKP.getReadKey().equals(accKP.getWriteKey())) {
            LOGGER.warn("Key collision.");
            throw new MIRAccessKeyCollisionException("Key collision.");
        }
        final MCRObjectID objectId = accKP.getMCRObjectId();
        final MIRAccessKey accessKeyRead = getAccessKeysByType(objectId, MCRAccessManager.PERMISSION_READ).stream()
            .findFirst()
            .orElse(null);
        final MIRAccessKey accessKeyWrite = getAccessKeysByType(objectId, MCRAccessManager.PERMISSION_WRITE).stream()
            .findFirst()
            .orElse(null);
        final MIRAccessKey accessKeyReadNew = 
                new MIRAccessKey(objectId, accKP.getReadKey(), MCRAccessManager.PERMISSION_READ);
        updateAccessKey(objectId, accessKeyRead.getValue(), accessKeyReadNew);
        if (accKP.getWriteKey() != null) {
            final MIRAccessKey accessKeyWriteNew = 
                new MIRAccessKey(objectId, accKP.getWriteKey(), MCRAccessManager.PERMISSION_WRITE);
            if (accessKeyWrite == null) {
                addAccessKey(accessKeyWriteNew);
            } else {
                updateAccessKey(objectId, accessKeyWrite.getValue(), accessKeyWriteNew);
            }
        } else {
            if (accessKeyWrite != null) {
                removeAccessKey(accessKeyWrite);
            }
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
     * @param objectId id of the key to be updated
     * @param currentValue current value of the key to be updated
     * @param newAccessKey the new access key
     * @throws MIRAccessKeyException if update fails
     */
    public static synchronized void updateAccessKey(final MCRObjectID objectId,
        final String currentValue, final MIRAccessKey newAccessKey)
        throws MIRAccessKeyException {
        final String type = newAccessKey.getType();
        if (type == null) {
            LOGGER.warn("Permission type is required");
            throw new MIRAccessKeyInvalidTypeException("Permission type is required.");
        }
        final String value = newAccessKey.getValue();
        if (value == null) {
            LOGGER.warn("Value is required.");
            throw new MIRAccessKeyInvalidValueException("Value is required.");
        }
        final MIRAccessKey accessKey = getAccessKeyByValue(objectId, currentValue);
        if (accessKey != null) {
            if (accessKey.getValue().equals(value) && accessKey.getType().equals(type)) {
                return;
            } else if (!accessKey.getValue().equals(value)) {
                if (!accessKey.getType().equals(type)) {
                    if (isValidType(type)) {
                        accessKey.setType(type);
                        cleanPermissionCache(objectId, type);
                    } else {
                        LOGGER.warn("Unkown Type.");
                        throw new MIRAccessKeyInvalidTypeException("Unknown permission type.");
                    }
                } else {
                    if (isValidValue(value)) {
                        accessKey.setValue(value);
                        cleanPermissionCache(objectId, type);
                    } else {
                        LOGGER.warn("Incorrect Value.");
                        throw new MIRAccessKeyInvalidValueException("Incorrect Value.");
                    }
                }
            } else {
                if (getAccessKeyByValue(objectId, value) == null) {
                    if (isValidValue(value)) {
                        if (accessKey.getType().equals(type)) {
                            accessKey.setValue(value);
                            cleanPermissionCache(objectId, type);
                        } else {
                            if (isValidType(type)) {
                                accessKey.setValue(value);
                                accessKey.setType(type);
                                cleanPermissionCache(objectId, type);
                            } else {
                                LOGGER.warn("Unkown Type.");
                                throw new MIRAccessKeyInvalidTypeException("Unknown permission type.");
                            }
                        }
                    } else {
                        LOGGER.warn("Incorrect Value.");
                        throw new MIRAccessKeyInvalidValueException("Incorrect Value.");
                    } 
                } else {
                    LOGGER.warn("Key collision.");
                    throw new MIRAccessKeyCollisionException("Key collision.");
                }
            } 
        } else {
            LOGGER.warn("Key does not exists.");
            throw new MIRAccessKeyNotFoundException("Key does not exists.");
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
     * @param objectId the {@link MCRObjectID}
     * @param value the key value
     * @return access key list
     */
    public static synchronized MIRAccessKey getAccessKeyByValue(final MCRObjectID objectId, final String value) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.createNamedQuery("MIRAccessKey.getByValue", MIRAccessKey.class)
            .setParameter("objId", objectId)
            .setParameter("value", value)
            .getResultList()
            .stream()
            .findFirst()
            .orElse(null);
    }

    /**
     * Return the access key for given {@link MCRObjectID} and value.
     *
     * @param objectId the {@link MCRObjectID}
     * @param type the type
     * @return access key list
     */
    public static synchronized List<MIRAccessKey> getAccessKeysByType(final MCRObjectID objectId, final String type) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.createNamedQuery("MIRAccessKey.getByType", MIRAccessKey.class)
            .setParameter("objId", objectId)
            .setParameter("type", type)
            .getResultList();
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

        final MIRAccessKey accessKey = getAccessKeyByValue(objectId, value);
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
