package org.mycore.mir.authorization.accesskeys;

import org.mycore.common.MCRException;
import org.mycore.datamodel.metadata.MCRObjectID;

public final class MIRAccessKeyHelper {

    public static boolean hasAccessKey(String objectIdString) {
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(objectIdString);
            return MIRAccessKeyManager.getAccessKeys(objectId).size() > 0;
        } catch (MCRException e) {
            return false;
        }
    }
}
