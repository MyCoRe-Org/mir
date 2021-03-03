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
import java.util.UUID;

import javax.persistence.EntityManager;

import org.apache.logging.log4j.LogManager;
import org.mycore.access.MCRAccessManager;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRUsageException;
import org.mycore.common.MCRException;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;

/**
 * Provides methods to store, update, delete and retrieve
 * {@link MCRObject} access keys.
 */
public final class MIRAccessKeyManager {

    /** Prefix for user attribute */
    public static final String ACCESS_KEY_PREFIX = "acckey_";

    /**
     * Adds a access keys for given {@link MCRObjectID}.
     * If there is no value collision
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @param accessKey the access key
     * @throws MIRAccessKeyManagerException key is not valid
     */
    public static void addAccessKey(final MCRObjectID objectId, MIRAccessKey accessKey) 
        throws MIRAccessKeyManagerException {
        final String value = accessKey.getValue();
        if (value == null || value.length() == 0) {
            throw new MIRAccessKeyManagerException("Key cannot be empty.");
        }
        final String type = accessKey.getType();
        if (!(type.equals(MCRAccessManager.PERMISSION_READ)
            || type.equals(MCRAccessManager.PERMISSION_WRITE))) {
            throw new MIRAccessKeyManagerException("Unknown permission type.");
        }
 
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        MIRAccessKeyInformation accessKeyInformation = em.find(MIRAccessKeyInformation.class, objectId.toString());
        if (accessKeyInformation == null) {
            accessKeyInformation = new MIRAccessKeyInformation(objectId);
            accessKeyInformation.getAccessKeys().add(accessKey);
            em.persist(accessKeyInformation);
        } else {
            final List<MIRAccessKey> accessKeys = accessKeyInformation.getAccessKeys();
            if (accessKeys.size() > 0 && hasCollision(accessKeys, value, type)) {
                throw new MIRAccessKeyManagerException("Key collision.");
            } else {
                accessKeyInformation.getAccessKeys().add(accessKey);
                em.merge(accessKeyInformation);
            }
        }
    }

    /**
     * Add the access key to the current {@link MCRUser} for given {@link MCRObjectID}.
     *
     * @param user the {@link MCRUser} the key should assigned
     * @param objectId the {@link MCRObjectID}
     * @param value the value of the access key
     * @throws MCRUsageException
     *             if an error was occured
     */
    public static void addAccessKeyAttribute(final MCRUser user, final MCRObjectID objectId, final String value) 
        throws MCRUsageException {

        final MIRAccessKey accessKey = getAccessKey(objectId, value);
        if (accessKey == null) {
            throw new MCRUsageException("Invalid access key \"" + value + "\"");
        }

        user.setUserAttribute(ACCESS_KEY_PREFIX + objectId, value);
        MCRUserManager.updateUser(user);

        switch (accessKey.getType()) {
            case MCRAccessManager.PERMISSION_WRITE:
                MCRAccessManager.invalidPermissionCache(objectId.toString(), MCRAccessManager.PERMISSION_WRITE);
            case MCRAccessManager.PERMISSION_READ:
                MCRAccessManager.invalidPermissionCache(objectId.toString(), MCRAccessManager.PERMISSION_READ);
                break;
            default:
                LogManager.getLogger().warn("Invalid access key type: " + accessKey.getType());
                break;
        }

        MCRSessionMgr.getCurrentSession().setUserInformation(user.clone());
    }

    /**
     * Deletes access key.
     *
     * @param id the id of the key
     * @throws MCRException if key does not exists
     */
    public static void deleteAccessKey(final UUID id) throws MIRAccessKeyManagerException {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        final MIRAccessKey accessKey = em.find(MIRAccessKey.class, id);
        if (accessKey != null) {
            em.remove(accessKey);
        } else {
            throw new MIRAccessKeyManagerException("Key does not exists.");
        }
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
     * Deletes a {@link MIRAccessKeyInformation} if it exists.
     * @param mcrObjectId the {@link MCRObjectID}
     * @throws MCRException if info does not exists
     */
    public static void deleteAccessKeyInformation(final MCRObjectID objectId) throws MIRAccessKeyManagerException {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        final MIRAccessKeyInformation accessKeyInformation = em.find(MIRAccessKeyInformation.class, objectId);
        if (accessKeyInformation != null) {
            em.remove(accessKeyInformation);
        } else {
            throw new MIRAccessKeyManagerException("Information does not exists.");
        }
    }

    /**
     * Return the access keys for given {@link MCRObjectID} and value.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @param value the key value
     * @return access key or null
     */
    public static MIRAccessKey getAccessKey(final MCRObjectID objectId, final String value) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.createNamedQuery("MIRAccessKeyInformation.getAccessKeyByValue", MIRAccessKey.class)
            .setParameter("objId", objectId.toString())
            .setParameter("value", value)
            .getResultStream()
            .findFirst()
            .orElse(null);
    }

    /**
     * Returns the {@link MIRAccessKeyInformation} for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @return the {@link MIRAccessKeyInformation} or null
     */
    public static MIRAccessKeyInformation getAccessKeyInformation(final MCRObjectID objectId) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.find(MIRAccessKeyInformation.class, objectId.toString());
    }

    /**
     * Returns all access keys for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @return access keys as list
     */
    public static List<MIRAccessKey> getAccessKeys(final MCRObjectID objectId) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.createNamedQuery("MIRAccessKeyInformation.getAccessKeys", MIRAccessKey.class)
            .setParameter("objId", objectId.toString())
            .getResultList();
    }
    
    private static boolean hasCollision(final List<MIRAccessKey> accessKeys, final String value, final String type) {
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
    public static void updateAccessKey(MIRAccessKey accessKey) throws MIRAccessKeyManagerException {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        if (em.find(MIRAccessKey.class, accessKey.getId()) != null) {
            em.merge(accessKey); //TODO collision check (requires bidirectional)
        } else {
            throw new MIRAccessKeyManagerException("Key does not exists.");
        }
    }

    public static class MIRAccessKeyManagerException extends MCRException {
        public MIRAccessKeyManagerException(String errorMessage) {
            super(errorMessage);
        }
    }
}
