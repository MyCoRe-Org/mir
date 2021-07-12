/*
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

import java.io.IOException;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.transform.JDOMSource;

import org.mycore.common.MCRException;
import org.mycore.common.content.MCRJAXBContent;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKeyPair;
import org.xml.sax.SAXParseException;

/**
 * @author Ren\u00E9 Adler (eagle)
 * @since 0.3
 */
public abstract class MIRAccessKeyPairTransformer {

    public static final JAXBContext JAXB_CONTEXT = initContext();

    private static final String ROOT_ACCESS_KEY_PAIR = "accesskeys";

    private MIRAccessKeyPairTransformer() {
    }

    private static JAXBContext initContext() {
        try {
            return JAXBContext.newInstance(MIRAccessKeyPair.class.getPackage().getName(),
                MIRAccessKeyPair.class.getClassLoader());
        } catch (final JAXBException e) {
            throw new MCRException("Could not instantiate JAXBContext.", e);
        }
    }

    private static Document getAccesKeyPairXML(final MIRAccessKeyPair accKP) {
        final MCRJAXBContent<MIRAccessKeyPair> content = new MCRJAXBContent<MIRAccessKeyPair>(JAXB_CONTEXT, accKP);
        try {
            final Document xml = content.asXML();
            return xml;
        } catch (final SAXParseException | JDOMException | IOException e) {
            throw new MCRException("Exception while transforming MIRAccessKeyPair to JDOM document.", e);
        }
    }

    public static Document buildExportableXML(final MIRAccessKeyPair accKP) {
        return getAccesKeyPairXML(accKP);
    }

    public static MIRAccessKeyPair buildAccessKeyPair(final Element element) {
        try {
            final Unmarshaller unmarshaller = JAXB_CONTEXT.createUnmarshaller();
            if (element.getName().equals(ROOT_ACCESS_KEY_PAIR)) {
                return (MIRAccessKeyPair) unmarshaller.unmarshal(new JDOMSource(element));
            } else {
                throw new IllegalArgumentException("Element is not a MIRAccessKeyPair element.");
            }
        } catch (final JAXBException e) {
            throw new MCRException("Exception while transforming Element to MIRAccessKeyPair.", e);
        }
    }
}
