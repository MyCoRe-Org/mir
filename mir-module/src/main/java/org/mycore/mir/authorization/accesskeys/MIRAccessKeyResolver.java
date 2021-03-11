
package org.mycore.mir.authorization.accesskeys;

import java.util.List;

import com.fasterxml.jackson.core.JsonProcessingException;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.jdom2.Element;
import org.jdom2.transform.JDOMSource;

import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKey;

public class MIRAccessKeyResolver implements URIResolver {

    private static final Logger LOGGER = LogManager.getLogger();

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        LOGGER.info(href);
        final String objId = href.substring(href.indexOf(":") + 1);
        final MCRObjectID objectId = MCRObjectID.getInstance(objId);

        List<MIRAccessKey> accessKeys = MIRAccessKeyManager.getAccessKeys(objectId);
        
        Element main = new Element("servflag");
        main.setAttribute("type", "accesskeys");
        main.setAttribute("inherited", "0");
        main.setAttribute("form", "plain");
        
        try {
            main.setText(MIRAccessKeyTransformer.accessKeysToJson(accessKeys));
            return new JDOMSource(main);
        } catch (JsonProcessingException e) {
            return new JDOMSource(new Element("null"));
        }
    }
}
