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

import org.apache.log4j.Logger;
import org.mycore.access.MCRAccessManager;
import org.mycore.access.strategies.MCRAccessCheckStrategy;
import org.mycore.access.strategies.MCRObjectTypeStrategy;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRUserInformation;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class MIRAccessKeyStrategy implements MCRAccessCheckStrategy {

    private static final Logger LOGGER = Logger.getLogger(MIRAccessKeyStrategy.class);

    private static final MCRObjectTypeStrategy BASE_STRATEGY = new MCRObjectTypeStrategy();

    /* (non-Javadoc)
     * @see org.mycore.access.strategies.MCRAccessCheckStrategy#checkPermission(java.lang.String, java.lang.String)
     */
    @Override
    public boolean checkPermission(String id, String permission) {
        LOGGER.debug("check permission " + permission + " for MCRBaseID " + id);

        if (id == null || id.length() == 0 || permission == null || permission.length() == 0) {
            return false;
        }

        MCRObjectID mcrObjectId = null;
        try {
            mcrObjectId = MCRObjectID.getInstance(id);
            final MIRAccessKeyPair accKP = MIRAccessKeyManager.getKeyPair(mcrObjectId);

            if (accKP != null) {
                if (permission.equals(MCRAccessManager.PERMISSION_READ)) {
                    final String uAccKey = getUserAccessKey(id, MIRAccessKeyPair.PERMISSION_READ);
                    if (uAccKey != null) {
                        return uAccKey.equals(accKP.getReadKey()) || accKP.getWriteKey() != null
                                && uAccKey.equals(accKP.getWriteKey());
                    }
                } else if (permission.equals(MCRAccessManager.PERMISSION_WRITE) && accKP.getWriteKey() != null) {
                    final String uAccKey = getUserAccessKey(id, MIRAccessKeyPair.PERMISSION_WRITE);
                    if (uAccKey != null) {
                        return uAccKey.equals(accKP.getWriteKey());
                    }
                }
            }
        } catch (RuntimeException e) {
            if (mcrObjectId == null) {
                LOGGER.debug("id is not a valid object ID", e);
            } else {
                LOGGER.warn("Error while checking permission.", e);
            }
        }

        return BASE_STRATEGY.checkPermission(id, permission);
    }

    private static String getUserAccessKey(final String id, final String permission) {
        final MCRUserInformation currentUser = MCRSessionMgr.getCurrentSession().getUserInformation();

        LOGGER.debug("check user access key for " + currentUser.getUserID() + " with permission " + permission
                + " and MCRBaseID " + id);

        return currentUser.getUserAttribute(id + "_" + permission);
    }
}
