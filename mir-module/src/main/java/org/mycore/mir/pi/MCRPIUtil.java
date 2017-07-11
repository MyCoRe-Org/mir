package org.mycore.mir.pi;

import java.util.Locale;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.output.DOMOutputter;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.datamodel.metadata.MCRBase;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.pi.MCRPIRegistrationServiceManager;
import org.mycore.pi.MCRPersistentIdentifierManager;
import org.mycore.pi.exceptions.MCRPersistentIdentifierException;
import org.w3c.dom.NodeList;

public class MCRPIUtil {

    private static final Logger LOGGER = LogManager.getLogger();

    public static boolean hasManagedPI(String objectID) {
        return MCRPersistentIdentifierManager.getInstance()
            .getRegistered(MCRMetadataManager.retrieveMCRObject(MCRObjectID.getInstance(objectID))).size() > 0;
    }

    public static boolean isManagedPI(String pi, String id) {
        return MCRPersistentIdentifierManager.getInstance().getInfo(pi).stream().filter(info -> info.getMycoreID()
            .equals(id)).findAny().isPresent();
    }

    /**
     * Gets all available services which are configured.
     * e.g.
     *   <ul>
     *     <li>&lt;service id="service1" inscribed="false" permission="true" type="urn" /&gt;</li>
     *     <li>&lt;service id="service2" inscribed="true" permission="false"type="doi" /&gt;</li>
     *   </ul>
     *
     * @param ObjectID the object
     * @return a Nodelist
     * @throws JDOMException
     */
    public static NodeList getPIServiceInformation(String ObjectID) throws JDOMException {
        Element e = new Element("list");

        MCRBase obj = MCRMetadataManager.retrieve(MCRObjectID.getInstance(ObjectID));
        MCRConfiguration.instance().getPropertiesMap("MCR.PI.Registration.")
            .keySet()
            .stream()
            .map(s -> s.substring("MCR.PI.Registration.".length()))
            .filter(id -> !id.contains("."))
            .map((serviceID) -> MCRPIRegistrationServiceManager.getInstance().getRegistrationService(serviceID))
            .map((rs -> {
                Element service = new Element("service");

                service.setAttribute("id", rs.getRegistrationServiceID());

                // Check if the inscriber of this service can read a PI
                try {
                    if (rs.getMetadataManager().getIdentifier(obj, "").isPresent()) {
                        service.setAttribute("inscribed", "true");
                    } else {
                        service.setAttribute("inscribed", "false");
                    }
                } catch (MCRPersistentIdentifierException e1) {
                    LOGGER.warn("Error happened while try to read PI from object: " + ObjectID, e1);
                    service.setAttribute("inscribed", "false");
                }

                // rights
                String permission = "register-" + rs.getRegistrationServiceID();
                Boolean canRegister = MCRAccessManager.checkPermission(ObjectID, "writedb") &&
                    MCRAccessManager.checkPermission(obj.getId(), permission);

                service.setAttribute("permission", canRegister.toString().toLowerCase(Locale.ROOT));

                // add the type
                service.setAttribute("type", rs.getType());

                return service;
            }))
            .forEach(e::addContent);
        return new DOMOutputter().output(e).getElementsByTagName("service");
    }

}
