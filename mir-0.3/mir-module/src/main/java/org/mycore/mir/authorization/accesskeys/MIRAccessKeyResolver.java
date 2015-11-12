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

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import org.jdom2.Element;
import org.jdom2.transform.JDOMSource;
import org.mycore.access.MCRAccessManager;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * This resolver can be used to return a {@link MIRAccessKeyPair} for an given {@link MCRObjectID}.
 *
 *
 * <p>Syntax:</p>
 * <ul>
 * <li><code>accesskeys:{mcrObjectId}</code> to resolve an {@link MIRAccessKeyPair}</li>
 * </ul>
 *
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class MIRAccessKeyResolver implements URIResolver {

    /* (non-Javadoc)
     * @see javax.xml.transform.URIResolver#resolve(java.lang.String, java.lang.String)
     */
    @Override
    public Source resolve(String href, String base) throws TransformerException {
        final String objId = href.substring(href.indexOf(":") + 1);

        MIRAccessKeyPair accKP = MIRAccessKeyManager.getKeyPair(MCRObjectID.getInstance(objId));

        if (accKP != null) {
            if (!MCRAccessManager.checkPermission(objId, MCRAccessManager.PERMISSION_WRITE)) {
                final Element root = new Element("accesskeys");
                root.setAttribute("objId", objId);
                if (accKP.getReadKey() != null)
                    root.setAttribute("readkey", "");
                if (accKP.getWriteKey() != null)
                    root.setAttribute("writekey", "");

                return new JDOMSource(root);
            }

            return new JDOMSource(MIRAccessKeyPairTransformer.buildExportableXML(accKP));
        }

        return new JDOMSource(new Element("null"));
    }
}
