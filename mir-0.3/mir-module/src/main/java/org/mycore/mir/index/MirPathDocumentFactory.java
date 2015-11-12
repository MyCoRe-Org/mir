/*
 * $Id$
 * $Revision: 5697 $ $Date: Jul 5, 2013 $
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

package org.mycore.mir.index;

import static org.mycore.wfc.MCRConstants.STATUS_CLASS_ID;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Collection;

import org.apache.log4j.Logger;
import org.apache.solr.common.SolrInputDocument;
import org.mycore.common.MCRPersistenceException;
import org.mycore.datamodel.classifications2.MCRCategLinkReference;
import org.mycore.datamodel.classifications2.MCRCategLinkServiceFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.solr.index.file.MCRSolrPathDocumentFactory;

/**
 * @author Thomas Scheffler (yagee)
 *
 */
public class MirPathDocumentFactory extends MCRSolrPathDocumentFactory {
    private static Logger LOGGER = Logger.getLogger(MirPathDocumentFactory.class);

    @Override
    public SolrInputDocument getDocument(Path input, BasicFileAttributes attr) throws IOException,
        MCRPersistenceException {
        SolrInputDocument document = super.getDocument(input, attr);
        Object returnId = document.getFieldValue("returnId");
        if (returnId == null) {
            LOGGER.warn("No returnId is set for Path: " + input);
            return document;
        }
        MCRObjectID objId = MCRObjectID.getInstance(returnId.toString());
        MCRCategoryID status = getStatus(objId);
        if (status == null) {
            LOGGER.warn("No status set for " + objId + ", could not set for MCRFile: " + input);
            return document;
        }
        document.setField(status.getRootID(), status.getID());
        return document;
    }

    protected MCRCategoryID getStatus(MCRObjectID objId) {
        MCRCategLinkReference reference = new MCRCategLinkReference(objId);
        Collection<MCRCategoryID> linkedCategories = MCRCategLinkServiceFactory.getInstance().getLinksFromReference(
            reference);
        for (MCRCategoryID categId : linkedCategories) {
            LOGGER.info("Checking " + categId);
            if (categId.getRootID().equals(STATUS_CLASS_ID.getRootID())) {
                return categId;
            }
        }
        return null;
    }

}
