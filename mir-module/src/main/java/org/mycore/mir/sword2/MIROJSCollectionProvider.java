package org.mycore.mir.sword2;

import org.mycore.sword.application.MCRSwordIngester;

public class MIROJSCollectionProvider extends MIRSwordCollectionProvider {

    @Override public MCRSwordIngester initIngester() {
        return new MIROJSIngester();
    }

}
