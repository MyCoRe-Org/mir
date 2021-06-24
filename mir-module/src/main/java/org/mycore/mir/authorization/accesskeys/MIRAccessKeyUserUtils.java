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

import org.mycore.access.MCRAccessManager;
import org.mycore.common.MCRSessionMgr;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKey;
import org.mycore.mir.authorization.accesskeys.exception.MIRAccessKeyException;
import org.mycore.mir.authorization.accesskeys.exception.MIRAccessKeyNotFoundException;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;

public class MIRAccessKeyUserUtils {

    private static final String ACCESS_KEY_PREFIX = "acckey_";

    /**
     * Add the access key to the current {@link MCRUser} for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @param accessKey the access key
     * @throws MIRAccessKeyNotFoundException
     *             if an error was occured
     */
    public static synchronized void addAccessKey(final MCRObjectID mcrObjectId, final String accessKey) 
        throws MIRAccessKeyNotFoundException {
        final MCRUser user = MCRUserManager.getCurrentUser();
        addAccessKey(user, mcrObjectId, accessKey);
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
    public static synchronized void addAccessKey(final MCRUser user, final MCRObjectID objectId, final String value) 
        throws MIRAccessKeyNotFoundException {

        final MIRAccessKey accessKey = MIRAccessKeyManager.getAccessKeyByValue(objectId, value);
        if (accessKey == null) {
            throw new MIRAccessKeyNotFoundException("Key does not exists.");
        }

        user.setUserAttribute(ACCESS_KEY_PREFIX + objectId, value);
        MCRUserManager.updateUser(user);

        MCRAccessManager.invalidPermissionCache(objectId.toString(), accessKey.getType());
        MCRSessionMgr.getCurrentSession().setUserInformation(user.clone());
    }

    /**
     * Deletes the access key from current {@link MCRUser} for given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     */
    public static synchronized void deleteAccessKey(final MCRObjectID mcrObjectId) {
        deleteAccessKey(MCRUserManager.getCurrentUser(), mcrObjectId);
    }

    /**
     * Deletes the access key from given {@link MCRUser} for {@link MCRObjectID}.
     *
     * @param user the {@link MCRUser}
     * @param mcrObjectId the {@link MCRObjectID}
     */
    public static synchronized void deleteAccessKey(final MCRUser user, final MCRObjectID mcrObjectId) {
        user.getAttributes().removeIf(ua -> ua.getName().equals(ACCESS_KEY_PREFIX + mcrObjectId.toString()));
        MCRUserManager.updateUser(user);
        MCRAccessManager.invalidPermissionCache(mcrObjectId.toString(), MCRAccessManager.PERMISSION_READ);
        MCRAccessManager.invalidPermissionCache(mcrObjectId.toString(), MCRAccessManager.PERMISSION_WRITE);
    }

    /**
     * Fetches access key value from user attribute.
     *
     * @param mcrObjectId the {@link MCRObjectID}
     * @return access key value or null
     */
    public static synchronized String getAccessKey(MCRObjectID objectId) {
        return MCRSessionMgr.getCurrentSession().getUserInformation()
            .getUserAttribute(ACCESS_KEY_PREFIX + objectId.toString());
    }
}
