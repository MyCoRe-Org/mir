package org.mycore.mir.sword2;

import org.mycore.sword.application.MCRSwordIngester;

public class MIRDisseminCollectionProvider extends MIRSwordCollectionProvider {

    @Override public MCRSwordIngester initIngester() {
        return new MIRMETSIngester();
    }

}
