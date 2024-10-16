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

import static org.mycore.access.MCRAccessManager.PERMISSION_READ;
import static org.mycore.access.MCRAccessManager.PERMISSION_WRITE;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.common.MCRException;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyManager;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyUtils;
import org.mycore.mcr.acl.accesskey.model.MCRAccessKey;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKey;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKeyPair;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserAttribute;
import org.mycore.user2.MCRUserManager;

import jakarta.persistence.EntityManager;

@MCRCommandGroup(
    name = "MIR migration 2021.06")
public class MIRMigration202106Utils {

    public static final Logger LOGGER = LogManager.getLogger();

    protected static final String ACCESS_KEY_PREFIX = "acckey_";

    @MCRCommand(syntax = "migrate all access key pairs",
        help = "Migrates all access key pairs to MCR access keys (2020.06"
            + " Should be used to migrate from version up to and including 2020.06.")
    public static void migrateAccessKeyPairs() throws MCRException {
        final List<MIRAccessKeyPair> accessKeyPairs = listAccessKeyPairs();
        for (final MIRAccessKeyPair accessKeyPair : accessKeyPairs) {
            final MCRObjectID objectId = accessKeyPair.getMCRObjectId();
            final String readKey = accessKeyPair.getReadKey();
            final String writeKey = accessKeyPair.getWriteKey();
            if (readKey != null) {
                final MIRAccessKey accessKey = new MIRAccessKey(readKey, PERMISSION_READ);
                createAccessKey(objectId, accessKey);
            }
            if (writeKey != null) {
                final MIRAccessKey accessKey = new MIRAccessKey(writeKey, PERMISSION_WRITE);
                createAccessKey(objectId, accessKey);
            }
            removeAccessKeyPair(accessKeyPair);
        }
        migrateAccessKeys();
    }

    @Deprecated
    @MCRCommand(syntax = "migrate all access keys",
        help = "Migrates all MIR access key to MCR access keys."
            + " Should be used to migrate from version 2021.05.")
    public static void migrateAccessKeys() throws MCRException {
        final List<MIRAccessKey> mirAccessKeys = listAccessKeys();
        for (final MIRAccessKey mirAccessKey : mirAccessKeys) {
            final MCRObjectID objectId = mirAccessKey.getObjectId();
            final MCRAccessKey accessKey = new MCRAccessKey(MCRAccessKeyManager.hashSecret(mirAccessKey.getValue(),
                objectId), mirAccessKey.getType());
            accessKey.setIsActive(true);
            accessKey.setCreated(new Date());
            accessKey.setCreatedBy("migration");
            accessKey.setLastModified(new Date());
            accessKey.setLastModifiedBy("migration");
            accessKey.setComment(mirAccessKey.getValue());
            final List<MCRAccessKey> accessKeys = new ArrayList<>();
            accessKeys.add(accessKey);
            MCRAccessKeyManager.addAccessKeys(objectId, accessKeys);
            removeAccessKey(mirAccessKey);
        }
        LOGGER.info("migrated all keys to MCR access keys");
    }

    @Deprecated
    @MCRCommand(syntax = "migrate all access key user attributes",
        help = "Hashes all access key user attributes."
            + " Is only necessary if the secrets are hashed."
            + " Should be used after access key migration.")
    public static void migrateAccessKeyUserAttributes() {
        int offset = 0;
        final int limit = 1024;
        List<MCRUser> users = new ArrayList<>();
        do {
            users = listUsersWithMIRAccessKeyUserAttribute(offset, limit);
            for (final MCRUser user : users) {
                final List<MCRUserAttribute> attributes = user.getAttributes()
                    .stream()
                    .filter(attribute -> attribute.getName().startsWith(ACCESS_KEY_PREFIX))
                    .collect(Collectors.toList());
                for (MCRUserAttribute attribute : attributes) {
                    final String attributeName = attribute.getName();
                    final MCRObjectID objectId = MCRObjectID.getInstance(attributeName.substring(
                        attributeName.indexOf("_") + 1));
                    attribute.setName(MCRAccessKeyUtils.ACCESS_KEY_PREFIX + objectId.toString());
                    attribute.setValue(MCRAccessKeyManager.hashSecret(attribute.getValue(), objectId));
                }
            }
            offset += limit;
        } while (users.size() == limit);
    }

    /**
     * Checks the quality of the permission.
     *
     * @param type permission type
     * @return valid or not
     */
    private static boolean isValidType(String type) {
        return (type.equals(PERMISSION_READ) || type.equals(PERMISSION_WRITE));
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

    private static List<MCRUser> listUsersWithMIRAccessKeyUserAttribute(final int offset, final int limit) {
        return MCRUserManager.listUsers(null, null, null, null, ACCESS_KEY_PREFIX + "*",
            null, offset, limit);
    }

    /**
     * Lists all {@link MIRAccessKey}.
     *
     * @return access keys as list
     */
    private static List<MIRAccessKey> listAccessKeys() {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        final List<MIRAccessKey> accessKeys = em.createNamedQuery("MIRAccessKey.listAll",
            MIRAccessKey.class).getResultList();
        for (MIRAccessKey accessKey : accessKeys) {
            em.detach(accessKey);
        }
        return accessKeys;
    }

    /**
     * Returns {@MIRAccessKey }for given {@link MCRObjectID} and value.
     *
     * @param objectId the {@link MCRObjectID}
     * @param value the key value
     * @return access key
     */
    private static synchronized MIRAccessKey getAccessKeyWithValue(final MCRObjectID objectId, final String value) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        final MIRAccessKey accessKey = em.createNamedQuery("MIRAccessKey.getWithValue", MIRAccessKey.class)
            .setParameter("objectId", objectId)
            .setParameter("value", value)
            .getResultList()
            .stream()
            .findFirst()
            .orElse(null);
        if (accessKey != null) {
            em.detach(accessKey);
        }
        return accessKey;
    }

    /**
     * Creates an {@link MIRAccessKey} for given {@link MCRObjectID}.
     * If there is no value collision
     *
     * @param accessKey the access key
     * @throws MCRException key is not valid
     */
    private static synchronized void createAccessKey(final MCRObjectID objectId, final MIRAccessKey accessKey)
        throws MCRException {
        accessKey.setObjectId(objectId);
        final String type = accessKey.getType();
        if (type == null || !isValidType(type)) {
            throw new MCRException("Invalid permission type.");
        }
        final String value = accessKey.getValue();
        if (value == null || !isValidValue(value)) {
            throw new MCRException("Incorrect value.");
        }
        if (getAccessKeyWithValue(objectId, value) == null) {
            final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
            em.persist(accessKey);
            em.detach(accessKey);
        } else {
            throw new MCRException("Key collision.");
        }
    }

    /**
     * Removes {@link MIRAccessKey}
     *
     * @param accessKey the {@link MIRAccessKey}
     */
    private static void removeAccessKey(final MIRAccessKey accessKey) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        em.remove(em.contains(accessKey) ? accessKey : em.merge(accessKey));
    }

    /**
     * Lists all {@link MIRAccessKeyPair}.
     *
     * @return access key pairs as list
     */
    private static List<MIRAccessKeyPair> listAccessKeyPairs() {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        final List<MIRAccessKeyPair> accessKeyPairs = em.createNamedQuery("MIRAccessKeyPair.listAll",
            MIRAccessKeyPair.class).getResultList();
        for (MIRAccessKeyPair accessKeyPair : accessKeyPairs) {
            em.detach(accessKeyPair);
        }
        return accessKeyPairs;
    }

    /**
     * Removes {@link MIRAccessKeyPair}.
     *
     * @param accessKeyPair the {@link MIRAccessKeyPair}
     */
    private static void removeAccessKeyPair(final MIRAccessKeyPair accessKeyPair) {
        final EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();
        em.remove(em.contains(accessKeyPair) ? accessKeyPair : em.merge(accessKeyPair));
    }
}
