package org.mycore.mir.authorization;


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.MCRSessionMgr;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.accesskeys.MIRAccessKeyManager;
import org.mycore.mir.authorization.accesskeys.MIRAccessKeyPair;

public class MIRKeyStrategyHelper {

    private static final Logger LOGGER = LogManager.getLogger();

    protected boolean checkObjectPermission(MCRObjectID objectId, String permission){
        boolean isWritePermission = MCRAccessManager.PERMISSION_WRITE.equals(permission);
        boolean isReadPermission = MCRAccessManager.PERMISSION_READ.equals(permission);
        if ((isWritePermission || isReadPermission)) {
            String userKey = getUserKey(objectId);
            if (userKey != null) {
                MIRAccessKeyPair keyPair = MIRAccessKeyManager.getKeyPair(objectId);
                if (keyPair != null && (userKey.equals(keyPair.getWriteKey())
                        || isReadPermission && userKey.equals(keyPair.getReadKey()))) {
                    LOGGER.debug("Access granted. User has a key to access the resource {}.", objectId);
                    return true;
                }
                if (keyPair != null && !userKey.equals(keyPair.getWriteKey())
                        && !userKey.equals(keyPair.getReadKey())) {
                    LOGGER.warn("Neither read nor write key matches. Remove access key from user.");
                    MIRAccessKeyManager.deleteAccessKey(objectId);
                }
            }
        }
        return false;
    }

    private static String getUserKey(MCRObjectID objectId) {
        return MCRSessionMgr.getCurrentSession().getUserInformation()
                .getUserAttribute(MIRAccessKeyManager.ACCESS_KEY_PREFIX + objectId.toString());
    }

}
