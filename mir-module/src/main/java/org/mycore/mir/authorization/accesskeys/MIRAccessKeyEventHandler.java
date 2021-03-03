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
package org.mycore.mir.authorization.accesskeys;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.events.MCREvent;
import org.mycore.common.events.MCREventHandlerBase;
import org.mycore.datamodel.metadata.MCRBase;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRObject;


/**
 * This class contains EventHandler methods to manage access keys of
 * MCRObjects and MCRDerivates.
 * org.jdom2.output.XMLOutputter
 * @author Ren\u00E9 Adler (eagle)
 * @since 0.3
 */
public class MIRAccessKeyEventHandler extends MCREventHandlerBase {

    private static Logger LOGGER = LogManager.getLogger();

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectCreated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectCreated(MCREvent evt, MCRObject obj) {
        handleBaseCreated(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectUpdated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectUpdated(MCREvent evt, MCRObject obj) {
        handleBaseUpdated(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectDeleted(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectDeleted(MCREvent evt, MCRObject obj) {
        handleBaseDeleted(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleDerivateCreated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRDerivate)
     */
    @Override
    protected void handleDerivateCreated(MCREvent evt, MCRDerivate der) {
        handleBaseCreated(der);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleDerivateUpdated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRDerivate)
     */
    @Override
    protected void handleDerivateUpdated(MCREvent evt, MCRDerivate der) {
        handleBaseUpdated(der);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleDerivateDeleted(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRDerivate)
     */
    @Override
    protected void handleDerivateDeleted(MCREvent evt, MCRDerivate der) {
        handleBaseDeleted(der);
    }

    private void handleBaseCreated(final MCRBase obj) {
        handleBaseUpdated(obj);
    }

    private void handleBaseUpdated(final MCRBase obj) {
        //TODO
    }

    private void handleBaseDeleted(final MCRBase obj) {
        //TODO
    }

    /*private void removeAccessKeys(final MCRBase obj) {
        LOGGER.debug("Remove access keys from pipe");
        /*for (MIRAccessKey.ServiceFlagType type : MIRAccessKey.ServiceFlagType.values()) {
            obj.getService().removeFlags(type.value());
        }
    }*/
}
