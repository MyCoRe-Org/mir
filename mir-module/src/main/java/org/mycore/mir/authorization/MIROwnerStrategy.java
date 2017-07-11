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
package org.mycore.mir.authorization;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;
import org.mycore.access.strategies.MCRAccessCheckStrategy;
import org.mycore.access.strategies.MCRObjectTypeStrategy;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.common.MCRUserInformation;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.datamodel.ifs2.MCRMetadataVersion;
import org.mycore.datamodel.metadata.MCRObjectID;

import com.google.common.cache.CacheBuilder;
import com.google.common.cache.CacheLoader;
import com.google.common.cache.LoadingCache;

/**
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class MIROwnerStrategy implements MCRAccessCheckStrategy {

    private static final Logger LOGGER = Logger.getLogger(MIROwnerStrategy.class);

    private static final String CONFIG_PREFIX = "MIR.OwnerStrategy.";

    private static final MCRAccessCheckStrategy BASE_STRATEGY = MCRConfiguration.instance()
        .getInstanceOf(CONFIG_PREFIX + "FallbackClass", MCRObjectTypeStrategy.class.getName());

    private static final List<String> OBJECT_TYPES = MCRConfiguration.instance()
        .getStrings(CONFIG_PREFIX + "ObjectTypes", new ArrayList<String>());

    private static final List<String> PERMISSIONS = MCRConfiguration.instance()
        .getStrings(CONFIG_PREFIX + "AllowedPermissions", new ArrayList<String>());

    private static final Pattern TYPE_PATTERN = Pattern.compile("[^_]*_([^_]*)_*");

    private static LoadingCache<MCRObjectID, String> CREATOR_CACHE = CacheBuilder.newBuilder().weakKeys()
        .maximumSize(5000).build(new CacheLoader<MCRObjectID, String>() {

            @Override
            public String load(MCRObjectID mcrObjectID) throws Exception {
                MCRXMLMetadataManager metadataManager = MCRXMLMetadataManager.instance();
                List<MCRMetadataVersion> versions = metadataManager.listRevisions(mcrObjectID);
                if (versions != null && !versions.isEmpty()) {
                    Collections.reverse(versions); //newest revision first
                    for (MCRMetadataVersion version : versions) {
                        //time machine: go back in history
                        if (version.getType() == MCRMetadataVersion.CREATED) {
                            LOGGER.info("Found creator " + version.getUser() + " in revision "
                                + version.getRevision() + " of " + mcrObjectID);
                            return version.getUser();
                        }
                    }
                }
                LOGGER.info("Could not get creator information.");
                return null;
            }
        });

    /* (non-Javadoc)
     * @see org.mycore.access.strategies.MCRAccessCheckStrategy#checkPermission(java.lang.String, java.lang.String)
     */
    @Override
    public boolean checkPermission(String id, String permission) {
        LOGGER.debug("check permission " + permission + " for MCRBaseID " + id);

        if (id == null || id.length() == 0 || permission == null || permission.length() == 0) {
            return false;
        }

        String objectType = getObjectType(id);

        if (OBJECT_TYPES.contains(objectType) && PERMISSIONS.contains(permission)) {
            MCRObjectID mcrObjectId = null;
            try {
                mcrObjectId = MCRObjectID.getInstance(id);
                MCRUserInformation currentUser = MCRSessionMgr.getCurrentSession().getUserInformation();
                if (!currentUser.equals(MCRSystemUserInformation.getGuestInstance())
                    && isCurrentUserCreator(mcrObjectId, currentUser)) {
                    return true;
                }
            } catch (RuntimeException e) {
                if (mcrObjectId == null) {
                    LOGGER.debug("id is not a valid object ID", e);
                } else {
                    LOGGER.warn("Error while checking permission.", e);
                }
            }
        }

        LOGGER.debug("use fallback to check permissions");
        return BASE_STRATEGY.checkPermission(id, permission);
    }

    private static String getObjectType(String id) {
        Matcher m = TYPE_PATTERN.matcher(id);
        if (m.find() && (m.groupCount() == 1)) {
            return m.group(1);
        }
        return "";
    }

    private static boolean isCurrentUserCreator(MCRObjectID mcrObjectID, MCRUserInformation currentUser) {
        try {
            String creator = CREATOR_CACHE.get(mcrObjectID);
            return currentUser.getUserID().equals(creator);
        } catch (ExecutionException e) {
            LOGGER.error("Error while getting creator information.", e);
            return false;
        }
    }
}
