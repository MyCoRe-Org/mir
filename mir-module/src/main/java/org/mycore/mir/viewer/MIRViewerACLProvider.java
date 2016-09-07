package org.mycore.mir.viewer;


import java.util.concurrent.TimeUnit;

import javax.servlet.http.HttpSession;

import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mods.MCRMODSEmbargoUtils;
import org.mycore.viewer.configuration.MCRIviewDefaultACLProvider;

public class MIRViewerACLProvider extends MCRIviewDefaultACLProvider {

    @Override
    public boolean checkAccess(HttpSession session, MCRObjectID derivateID) {
        MCRObjectID objectId = MCRMetadataManager.getObjectId(derivateID, 10, TimeUnit.MINUTES);
        if (MCRMODSEmbargoUtils.getEmbargo(objectId) == null) {
            return super.checkAccess(session, derivateID);
        } else {
            return false;
        }
    }
}


