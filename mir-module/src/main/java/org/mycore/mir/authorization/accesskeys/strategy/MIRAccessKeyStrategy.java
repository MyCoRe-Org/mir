package org.mycore.mir.authorization.accesskeys.strategy;

import java.util.Objects;
import java.util.concurrent.TimeUnit;
import java.util.stream.Stream;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.mycore.access.MCRAccessManager;
import org.mycore.access.strategies.MCRAccessCheckStrategy;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.accesskeys.MIRAccessKeyManager;
import org.mycore.mir.authorization.accesskeys.MIRAccessKeyUserUtils;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKey;

public class MIRAccessKeyStrategy implements MCRAccessCheckStrategy {

    private static final Logger LOGGER = LogManager.getLogger();
    
    @Override
    public boolean checkPermission(String id, String permission) {
        final MCRObjectID objectId = MCRObjectID.getInstance(id);
        if (objectId.getTypeId().equals("derivate")) {
            MCRObjectID objId = MCRMetadataManager.getObjectId(objectId, 10, TimeUnit.MINUTES);
            return checkDerivatePermission(objectId, objId, permission);
        }
        return checkObjectPermission(objectId, permission);
    }

    private boolean checkObjectPermission(MCRObjectID objectId, String permission) {
        LOGGER.debug("check object {} permission {}.", objectId, permission);
        boolean isWritePermission = MCRAccessManager.PERMISSION_WRITE.equals(permission);
        boolean isReadPermission = MCRAccessManager.PERMISSION_READ.equals(permission);
        return (isWritePermission || isReadPermission) && userHasValidAccessKey(objectId, isReadPermission);
    }

    private static boolean userHasValidAccessKey(MCRObjectID objectId, boolean isReadPermission) {
        final String userKey = MIRAccessKeyUserUtils.getAccessKey(objectId);
        if (userKey != null) {
            MIRAccessKey accessKey = MIRAccessKeyManager.getAccessKeyByValue(objectId, userKey);
            if (accessKey != null) {
                if (isReadPermission && accessKey.getType().equals(MCRAccessManager.PERMISSION_READ) || 
                        accessKey.getType().equals(MCRAccessManager.PERMISSION_WRITE)) {
                    LOGGER.debug("Access granted. User has a key to access the resource {}.", objectId);
                    return true;
                }
            } else {
                MIRAccessKeyUserUtils.deleteAccessKey(objectId);
            }
        }
        return false;
    }

    private boolean checkDerivatePermission(MCRObjectID derivateId, MCRObjectID objectId, String permission) {
        LOGGER.debug("check derivate {}, object {} permission {}.", derivateId, objectId, permission);
        boolean isWritePermission = MCRAccessManager.PERMISSION_WRITE.equals(permission);
        boolean isReadPermission = MCRAccessManager.PERMISSION_READ.equals(permission);
        if ((isWritePermission || isReadPermission)) {
            return Stream.of(derivateId, objectId)
                .filter(Objects::nonNull)
                .filter(id -> MIRAccessKeyManager.getAccessKeys(id).size() > 0)
                .findFirst()
                .map(id -> userHasValidAccessKey(id, isReadPermission))
                .orElse(Boolean.FALSE);
        }
        return false;
    }
}
