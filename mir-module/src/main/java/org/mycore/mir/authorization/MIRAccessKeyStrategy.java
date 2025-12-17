package org.mycore.mir.authorization;

import java.util.Date;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.access.MCRAccessManager;
import org.mycore.access.strategies.MCRAccessCheckStrategy;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mcr.acl.accesskey.config.MCRAccessKeyConfig;
import org.mycore.mcr.acl.accesskey.dto.MCRAccessKeyDto;
import org.mycore.mcr.acl.accesskey.service.MCRAccessKeySessionService;
import org.mycore.mcr.acl.accesskey.service.MCRAccessKeyUserService;

/**
 * Strategy class for checking access permissions on objects based on access keys.
 * This class implements the {@link MCRAccessCheckStrategy} interface and provides methods
 * to check permissions for both string-based object IDs and {@link MCRObjectID} instances.
 */
public class MIRAccessKeyStrategy implements MCRAccessCheckStrategy {

    private static final Logger LOGGER = LogManager.getLogger();

    @Override
    public boolean checkPermission(String id, String permission) {
        if (!MCRObjectID.isValid(id)) {
            return false;
        }
        return checkObjectPermission(MCRObjectID.getInstance(id), permission);
    }

    /**
     * Checks whether the specified permission is granted for the given {@link MCRObjectID}.
     *
     * @param objectId   the {@link MCRObjectID} instance representing the object
     * @param permission the requested permission (e.g., "read", "write")
     * @return {@code true} if the permission is granted, {@code false} otherwise
     */
    public boolean checkObjectPermission(MCRObjectID objectId, String permission) {
        if (!MCRAccessKeyConfig.getAllowedObjectTypes().contains(objectId.getTypeId())) {
            return false;
        }
        final String sanitizedPermission = sanitizePermission(permission);
        if (!(MCRAccessManager.PERMISSION_WRITE.equals(sanitizedPermission)
            || MCRAccessManager.PERMISSION_READ.equals(sanitizedPermission))) {
            return false;
        }
        if (MCRAccessKeyConfig.getAllowedSessionPermissionTypes().contains(sanitizedPermission)) {
            if (checkSessionHasValidAccessKey(objectId.toString(), permission)) {
                return true;
            }
        }
        return checkUserHasValidAccessKey(objectId.toString(), permission);
    }

    private static String sanitizePermission(String permission) {
        if (MCRAccessManager.PERMISSION_VIEW.equals(permission)
            || MCRAccessManager.PERMISSION_PREVIEW.equals(permission)) {
            LOGGER.debug("Mapped {} to read.", permission);
            return MCRAccessManager.PERMISSION_READ;
        }
        return permission;
    }

    private boolean checkSessionHasValidAccessKey(String objectId, String permission) {
        final MCRAccessKeyDto accessKey = MCRAccessKeySessionService.obtainInstance().findActiveAccessKey(objectId);
        if (accessKey != null) {
            LOGGER.debug("Found match in access key strategy for {} on {} in session.", permission,
                objectId);
            return checkAccessKey(accessKey, permission);
        }
        return false;
    }

    private boolean checkUserHasValidAccessKey(String objectId, String permission) {
        final MCRAccessKeyDto accessKey = MCRAccessKeyUserService.obtainInstance().findActiveAccessKey(objectId);
        if (accessKey != null) {
            LOGGER.debug("Found match in access key strategy for {} on {} in user attributes.", permission,
                objectId);
            return checkAccessKey(accessKey, permission);
        }
        return false;
    }

    private boolean checkAccessKey(MCRAccessKeyDto accessKey, String permission) {
        if (MCRAccessManager.PERMISSION_READ.equals(permission)
            || MCRAccessManager.PERMISSION_WRITE.equals(permission)) {
            if (Boolean.FALSE.equals(accessKey.getActive())) {
                return false;
            }
            final Date expiration = accessKey.getExpiration();
            if (expiration != null && new Date().after(expiration)) {
                return false;
            }
            if ((permission.equals(MCRAccessManager.PERMISSION_READ)
                && accessKey.getPermission().equals(MCRAccessManager.PERMISSION_READ))
                || accessKey.getPermission().equals(MCRAccessManager.PERMISSION_WRITE)) {
                LOGGER.debug("Access granted.");
                return true;
            }
        }
        return false;
    }

}
