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
     * Returns the internal id for a {@link MIRAccessKeyInformation} for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @return the internal id {@link MIRAccessKeyInformation} or null
     */
    private static String getAccessKeyInformationId(final MCRObjectID objectId) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        return em.createNamedQuery("MIRAccessKeyInformation.getId", String.class)
            .setParameter("objId", objectId.toString())
            .getResultStream()
            .findFirst()
            .orElse(null);
    }

    /**
     * Checks if a {@link MIRAccessKeyInformation} for given {@link MCRObjectID} exists.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @return true or false
     */
    private static boolean existsAccessKeyInformation(final MCRObjectID objectId) {
        return getAccessKeyInformationId(objectId) != null;
    }

    /**
     * Return all access keys for given {@link MCRObjectID}.
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
     * Checks if an access key for given {@link MCRObjectID} and value exists.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @param value the key value
     * @return true or false
     */
    public static boolean existsAccessKey(final MCRObjectID objectId, final String value) {
        return getAccessKey(objectId, value) != null;
    }

    /**
     * Stores a {@link MIRAccessKeyInformation}.
     * If there is an existing information, it will be merged. 
     * In the other hand it will saved.
     *
     * @param accessKeyInformation the {@link MIRAccessKeyInformation}
     */
    public static void storeAccessKeyInformation(MIRAccessKeyInformation accessKeyInformation)
        throws MCRUsageException {
        final String accessKeyInformationId = getAccessKeyInformationId(accessKeyInformation.getObjectId());
        if (MIRAccessKeyInformation.isValid(accessKeyInformation)) {
            final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
            if (accessKeyInformationId != null) {
                em.merge(accessKeyInformation);
            } else {
                em.persist(accessKeyInformation);
            }
        } else {
            throw new MCRUsageException("Invalid access key information"); 
        }
    }

    public static void addAccessKey(final MCRObjectID objectId, final MIRAccessKey accessKey) {
        MIRAccessKeyInformation accessKeyInformation = getAccessKeyInformation(objectId);
        if (accessKeyInformation == null) {
            accessKeyInformation = new MIRAccessKeyInformation(objectId);
        }
        accessKeyInformation.getAccessKeys().add(accessKey);
        storeAccessKeyInformation(accessKeyInformation);
    }

    public static void deleteAccessKeyWithId(final UUID id) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        final MIRAccessKey accessKey = em.find(MIRAccessKey.class, id);
        if (accessKey != null) {
            em.remove(accessKey);
        }
    }

    public static void updateAccessKey(MIRAccessKey accessKey) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        if (em.find(MIRAccessKey.class, accessKey.getId()) != null) {
            em.merge(accessKey);
        } 
    }

    /**
     * Delets a {@link MIRAccessKeyInformation} if it exists.
     *
     * @param accessKeyInformation the {@link MIRAccessKeyInformation}
     */
    public static void deleteAccessKeyInformation(final MIRAccessKeyInformation accessKeyInformation) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        em.remove(accessKeyInformation);
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
    public static void addAccessKey(final MCRUser user, final MCRObjectID objectId, final String value) 
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
     * Deletes the access key attribute from current {@link MCRUser} for given {@link MCRObjectID}.
     *
     * @param objectId the {@link MCRObjectID}
     */
    public static void deleteAccessKey(final MCRObjectID objectId) {
        deleteAccessKey(MCRUserManager.getCurrentUser(), objectId);
    }

    /**
     * Deletes the access key attribute from given {@link MCRUser} for {@link MCRObjectID}.
     *
     * @param user the {@link MCRUser}
     * @param objectId the {@link MCRObjectID}
     */
    public static void deleteAccessKey(final MCRUser user, final MCRObjectID objectId) {
        user.getAttributes().removeIf(ua -> ua.getName().equals(ACCESS_KEY_PREFIX + objectId.toString()));
        MCRUserManager.updateUser(user);
    }
}
