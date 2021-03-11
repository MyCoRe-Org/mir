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
import java.util.UUID;

import javax.persistence.EntityManager;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.mycore.access.MCRAccessManager;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRException;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.services.i18n.MCRTranslation;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;

/**
 * Provides methods to store, update, delete and retrieve
 * {@link MCRObject} access keys.
 */
public final class MIRAccessKeyManager {

    private static final Logger LOGGER = LogManager.getLogger();

    /** Prefix for user attribute */
    public static final String ACCESS_KEY_PREFIX = "acckey_";

    /**
     * Checks the quality of the key.
     *
     * @param accessKey the access key
     * @return valid or not
     * @throws MIRAccessKeyManagerException key is not valid
     */
    private static boolean isValidAccessKey(MIRAccessKey accessKey)
        throws MIRAccessKeyManagerException {
        final String value = accessKey.getValue();
        if (value == null || value.length() == 0) {
            LOGGER.warn("Key cannot be empty.");
            throw new MIRAccessKeyManagerException(MCRTranslation.translate("mir.accesskey.emptyKey"));
        }
        final String type = accessKey.getType();
        if (type == null || !(type.equals(MCRAccessManager.PERMISSION_READ)
            || type.equals(MCRAccessManager.PERMISSION_WRITE))) {
            LOGGER.warn("Unknown permission type.");
            throw new MIRAccessKeyManagerException(MCRTranslation.translate("mir.accesskey.unknownType"));
        }

        return true;
    }

    /**
     * Adds a access keys for given {@link MCRObjectID}.
     * If there is no value collision
     *
     * @param accessKey the access key
     * @throws MIRAccessKeyManagerException key is not valid
     */
    public static synchronized void addAccessKey(MIRAccessKey accessKey) 
        throws MIRAccessKeyManagerException {
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
                throw new MIRAccessKeyManagerException(MCRTranslation.translate("mir.accesskey.collision"));
            }
        }
    }

    /**
     * Update access keys.
     *
     * @param objectId the {@link MCRObjectID}
     * @param accessKeys the access keys as list
     */
    public static synchronized void updateAccessKeys(MCRObjectID objectId, List<MIRAccessKey> accessKeys) {

    }

    /**
     * Update access keys.
     *
     * @param objectId the {@link MCRObjectID}
     * @param accessKeys the access keys as list
     */
    public static synchronized void addAccessKeys(MCRObjectID objectId, List<MIRAccessKey> accessKeys) {

    }

    /**
     * Add the access key to the current {@link MCRUser} for given {@link MCRObjectID}.
     *
     * @param user the {@link MCRUser} the key should assigned
     * @param objectId the {@link MCRObjectID}
     * @param value the value of the access key
     * @throws MIRAccessKeyManagerException
     *             if an error was occured
     */
    public static void addAccessKeyAttribute(final MCRUser user, final MCRObjectID objectId, final String value) 
        throws MIRAccessKeyManagerException {

        final MIRAccessKey accessKey = getAccessKey(objectId, value);
        if (accessKey == null) {
            throw new MIRAccessKeyManagerException(MCRTranslation.translate("mir.accesskey.invalidKey"));
        }

        user.setUserAttribute(ACCESS_KEY_PREFIX + objectId, value);
        MCRUserManager.updateUser(user);

        cleanPermissionCache(objectId, accessKey.getType());
        MCRSessionMgr.getCurrentSession().setUserInformation(user.clone());
    }

    /**
     * cleans Permission cache.
     *
     * @param objectId the id of the object
     * @param type the permission type
     */
    private static void cleanPermissionCache(final MCRObjectID objectId, String type) {
        if (type.equals(MCRAccessManager.PERMISSION_READ)) {
            MCRAccessManager.invalidPermissionCache(objectId.toString(), MCRAccessManager.PERMISSION_READ);
        } else {
            MCRAccessManager.invalidPermissionCache(objectId.toString(), MCRAccessManager.PERMISSION_WRITE);
        }
    }

    /**
     * Deletes all access keys.
     */
    protected static void deleteAllAccessKeys() {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        em.createQuery("DELETE FROM MIRAccessKey").executeUpdate();
    }

    /**
     * Deletes access key.
     *
     * @param id the id of the key
     * @throws MCRException if key does not exists
     */
    public static synchronized void deleteAccessKey(final UUID id) throws MIRAccessKeyManagerException {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        final MIRAccessKey accessKey = em.find(MIRAccessKey.class, id);
        if (accessKey != null) {
            deleteAccessKey(accessKey);
        } else {
            LOGGER.warn("Key does not exists.");
            throw new MIRAccessKeyManagerException(MCRTranslation.translate("mir.accesskey.unknownKey"));
        }
    }

    /**
     * Deletes access key.
     *
     * @param id the id of the key
     * @throws MCRException if key does not exists
     */
    private static void deleteAccessKey(final MIRAccessKey accessKey) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        em.remove(accessKey);
        cleanPermissionCache(accessKey.getObjectId(), accessKey.getType());
    }

    /**
     * Deletes the all access keys for given {@link MCRObjectID}.
     *
     * @param objectId the {@link MCRObjectID}
     */
    public static void deleteAccessKeys(final MCRObjectID objectId) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager(); //TODO
        em.createNamedQuery("MIRAccessKey.deleteById", MIRAccessKey.class)
            .setParameter("objId", objectId.toString())
            .executeUpdate();
    }

    /**
     * Deletes the access key attribute from current {@link MCRUser} for given {@link MCRObjectID}.
     *
     * @param objectId the {@link MCRObjectID}
     */
    public static void deleteAccessKeyAttribute(final MCRObjectID objectId) {
        deleteAccessKeyAttribute(MCRUserManager.getCurrentUser(), objectId);
    }

    /**
     * Deletes the access key attribute from given {@link MCRUser} for {@link MCRObjectID}.
     *
     * @param user the {@link MCRUser}
     * @param objectId the {@link MCRObjectID}
     */
    public static void deleteAccessKeyAttribute(final MCRUser user, final MCRObjectID objectId) {
        user.getAttributes().removeIf(ua -> ua.getName().equals(ACCESS_KEY_PREFIX + objectId.toString()));
        MCRUserManager.updateUser(user);
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
     * Return the access key for given {@link MCRObjectID} and value.
     *
     * @param uuid the key value
     * @return access key or null
     */
    public static synchronized MIRAccessKey getAccessKey(final UUID uuid) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.find(MIRAccessKey.class, uuid);
    }

    /**
     * Returns all access keys for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @return access keys as list
     */
    public static synchronized List<MIRAccessKey> getAccessKeys(final MCRObjectID objectId) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.createNamedQuery("MIRAccessKey.getById", MIRAccessKey.class)
            .setParameter("objId", objectId.toString())
            .getResultList();
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
     * Updates access key.
     *
     * @param accessKey the access key
     * @throws MCRException if key does not exists
     */
    public static synchronized void updateAccessKey(MIRAccessKey newAccessKey) throws MIRAccessKeyManagerException {
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
                    throw new MIRAccessKeyManagerException(MCRTranslation.translate("mir.accesskey.collision"));
                }
            } else {
                LOGGER.warn("Key does not exists.");
                throw new MIRAccessKeyManagerException(MCRTranslation.translate("mir.accesskey.unknownKey"));
            }
        }
    }

    public static class MIRAccessKeyManagerException extends MCRException {
        public MIRAccessKeyManagerException(String errorMessage) {
            super(errorMessage);
        }
    }
}
