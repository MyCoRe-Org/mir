/*
 * This file is part of ***  M y C o R e  ***
 * See https://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.mycore.mir.sword2;

import java.util.Arrays;
import java.util.List;

import org.apache.solr.client.solrj.request.SolrQuery;
import org.mycore.sword.application.MCRSwordAuthHandler;
import org.mycore.sword.application.MCRSwordCollectionProvider;
import org.mycore.sword.application.MCRSwordDefaultAuthHandler;
import org.mycore.sword.application.MCRSwordIngester;
import org.mycore.sword.application.MCRSwordLifecycleConfiguration;
import org.mycore.sword.application.MCRSwordMetadataProvider;
import org.mycore.sword.application.MCRSwordObjectIDSupplier;
import org.mycore.sword.application.MCRSwordSolrObjectIDSupplier;
import org.swordapp.server.UriRegistry;

/**
 * @author Sebastian Hofmann (mcrshofm)
 */
public abstract class MIRSwordCollectionProvider extends MCRSwordCollectionProvider {

    private MCRSwordDefaultAuthHandler mcrSwordDefaultAuthHandler;

    private MIRSwordMetadataProvider mirSwordMetadataProvider;

    private MCRSwordSolrObjectIDSupplier mcrSwordSolrObjectIDSupplier;

    private MCRSwordIngester ingester;

    public MIRSwordCollectionProvider() {
        mcrSwordDefaultAuthHandler = new MCRSwordDefaultAuthHandler();
        mirSwordMetadataProvider = new MIRSwordMetadataProvider();
        //mcrSwordSolrObjectIDSupplier = new MCRSwordSolrObjectIDSupplier(new SolrQuery("objectType:mods AND "));
        this.ingester = initIngester();
    }

    @Override
    public boolean isVisible() {
        // this collection can be seen by everybody
        return true;
    }

    @Override
    public List<String> getSupportedPagacking() {
        return Arrays.asList(UriRegistry.PACKAGE_SIMPLE_ZIP);
    }

    @Override
    public MCRSwordObjectIDSupplier getIDSupplier() {
        return mcrSwordSolrObjectIDSupplier;
    }

    @Override
    public MCRSwordMetadataProvider getMetadataProvider() {
        return mirSwordMetadataProvider;
    }

    @Override
    public MCRSwordAuthHandler getAuthHandler() {
        return mcrSwordDefaultAuthHandler;
    }

    @Override
    public MCRSwordIngester getIngester() {
        return ingester;
    }

    public abstract MCRSwordIngester initIngester();

    @Override
    public void init(MCRSwordLifecycleConfiguration lifecycleConfiguration) {
        super.init(lifecycleConfiguration);
        this.mcrSwordSolrObjectIDSupplier = new MCRSwordSolrObjectIDSupplier(
            new SolrQuery("objectType:mods AND servflag.type.sword:" + lifecycleConfiguration.getCollection()));
    }

}
