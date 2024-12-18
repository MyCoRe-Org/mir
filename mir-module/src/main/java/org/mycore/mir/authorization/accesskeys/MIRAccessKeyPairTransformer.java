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
import java.util.Map;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.transform.JDOMSource;
import org.mycore.common.MCRException;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRJAXBContent;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKeyPair;

import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.JAXBContextFactory;
import jakarta.xml.bind.JAXBException;
import jakarta.xml.bind.Unmarshaller;

/**
 * @author Ren\u00E9 Adler (eagle)
 * @since 0.3
 */
public abstract class MIRAccessKeyPairTransformer {

    public static final JAXBContext JAXB_CONTEXT = initContext();

    private static final String ROOT_ACCESS_KEY_PAIR = "accesskeys";

    private static final String ROOT_SERV_FLAGS = "servflags";

    private static final String ROOT_MCR_OBJECT = "mycoreobject";

    private static final String ROOT_MCR_DERIVATE = "mycorederivate";

    private MIRAccessKeyPairTransformer() {
    }

    private static JAXBContext initContext() {
        try {
            String factoryProperty = "MIR.AccessKey.JAXBContextFactory";
            JAXBContextFactory jaxbContextFactory =
                MCRConfiguration2.getInstanceOf(JAXBContextFactory.class, factoryProperty)
                    .orElseThrow(() -> MCRConfiguration2.createConfigurationException(factoryProperty));
            return jaxbContextFactory.createContext(MIRAccessKeyPair.class.getPackage().getName(),
                MIRAccessKeyPair.class.getClassLoader(), Map.of());
        } catch (final JAXBException e) {
            throw new MCRException("Could not instantiate JAXBContext.", e);
        }
    }

    private static Document getAccesKeyPairXML(final MIRAccessKeyPair accKP) {
        final MCRJAXBContent<MIRAccessKeyPair> content = new MCRJAXBContent<MIRAccessKeyPair>(JAXB_CONTEXT, accKP);
        try {
            final Document xml = content.asXML();
            return xml;
        } catch (IOException e) {
            throw new MCRException("Exception while transforming MIRAccessKeyPair to JDOM document.", e);
        }
    }

    private static Document getServFlagsXML(final MIRAccessKeyPair.ServiceFlags servFlags) {
        final MCRJAXBContent<MIRAccessKeyPair.ServiceFlags> content = new MCRJAXBContent<MIRAccessKeyPair.ServiceFlags>(
            JAXB_CONTEXT, servFlags);
        try {
            final Document xml = content.asXML();
            return xml;
        } catch (IOException e) {
            throw new MCRException("Exception while transforming MIRAccessKeyPair to JDOM document.", e);
        }
    }

    public static Document buildExportableXML(final MIRAccessKeyPair accKP) {
        return getAccesKeyPairXML(accKP);
    }

    public static Document buildServFlagsXML(final MIRAccessKeyPair accKP) {
        return getServFlagsXML(accKP.toServiceFlags());
    }

    public static MIRAccessKeyPair buildAccessKeyPair(final Element element) {
        try {
            final Unmarshaller unmarshaller = JAXB_CONTEXT.createUnmarshaller();
            switch (element.getName()) {
                case ROOT_ACCESS_KEY_PAIR:
                    return (MIRAccessKeyPair) unmarshaller.unmarshal(new JDOMSource(element));
                case ROOT_MCR_OBJECT:
                case ROOT_MCR_DERIVATE:
                    final MCRObjectID mcrObjectId = MCRObjectID.getInstance(element.getAttributeValue("ID"));
                    final Element service = element.getChild("service");
                    if (service != null) {
                        final Element accKeys = service.getChild(ROOT_SERV_FLAGS);
                        if (accKeys != null) {
                            return buildAccessKeyPair(mcrObjectId, accKeys);
                        }
                    }
                    return null;
                default:
                    throw new IllegalArgumentException("Element is not a MIRAccessKeyPair element.");
            }
        } catch (final JAXBException e) {
            throw new MCRException("Exception while transforming Element to MIRAccessKeyPair.", e);
        }
    }

    public static MIRAccessKeyPair buildAccessKeyPair(final MCRObjectID mcrObjectId, final Element element) {
        if (!ROOT_SERV_FLAGS.equals(element.getName())) {
            throw new IllegalArgumentException("Element is not a MIRAccessKeyPair element.");
        }
        try {
            final Unmarshaller unmarshaller = JAXB_CONTEXT.createUnmarshaller();
            MIRAccessKeyPair.ServiceFlags serviceFlags =
                unmarshaller.unmarshal(new JDOMSource(element.clone()), MIRAccessKeyPair.ServiceFlags.class).getValue();
            return MIRAccessKeyPair.fromServiceFlags(mcrObjectId, serviceFlags);
        } catch (final JAXBException e) {
            throw new MCRException("Exception while transforming Element to MIRAccessKeyPair.", e);
        }
    }
}
