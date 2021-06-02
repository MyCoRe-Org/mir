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

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.JsonProcessingException;

import org.jdom2.Element;

import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKey;

public class MIRAccessKeyTransformer {

    private static final String ROOT_SERVICE = "service";

    private static final String ROOT_SERV_FLAGS = "servflags";
    
    private static final String SERV_FLAG = "servflag";

    public static final String ACCESS_KEY_TYPE = "accesskeys";

    public static List<MIRAccessKey> accessKeysFromJson(final String json) {
        try {
            final ObjectMapper objectMapper = new ObjectMapper();
            return Arrays.asList(objectMapper.readValue(json, MIRAccessKey[].class));
        } catch (JsonProcessingException e) {
            return new ArrayList<MIRAccessKey>(); 
        }
    }

    public static String jsonFromAccessKeys(final List<MIRAccessKey> accessKeys) {
        try {
            final ObjectMapper objectMapper = new ObjectMapper();
            return objectMapper.writeValueAsString(accessKeys);
        } catch (JsonProcessingException e) {
            return null;
        }
    }

    public static List<MIRAccessKey> accessKeysFromElement(MCRObjectID objectId, Element element) {
        if (element.getName().equals(ROOT_SERVICE)) {
            Element servFlagsRoot = element.getChild(ROOT_SERV_FLAGS);
            if (servFlagsRoot != null) {
                final List<Element> servFlags = servFlagsRoot.getChildren(SERV_FLAG);
                for (Element servFlag : servFlags) {
                    if (servFlag.getAttributeValue("type").equals(ACCESS_KEY_TYPE)) {
                        return accessKeysFromServFlag(objectId, servFlag);
                    }
                }
            }
        } else if (element.getName().equals(SERV_FLAG) && element.getAttributeValue("type") == ACCESS_KEY_TYPE) {
            return accessKeysFromServFlag(objectId, element);
        } 
        return new ArrayList<MIRAccessKey>();
    }

    private static List<MIRAccessKey> accessKeysFromServFlag(MCRObjectID objectId, Element servFlag) {
        final String json = servFlag.getText();

        final List<MIRAccessKey> accessKeyList = accessKeysFromJson(json);
        for (MIRAccessKey accessKey : accessKeyList) {
            accessKey.setObjectId(objectId);
        }
        return accessKeyList;
    }

    public static Element servFlagFromAccessKeys(final List<MIRAccessKey> accessKeys) {
        final String jsonString = jsonFromAccessKeys(accessKeys);
        if (jsonString != null) {
            return servFlagfromAccessKeysJson(jsonString);
        }
        return new Element("null");
    }

    private static Element servFlagfromAccessKeysJson(final String json) {
        final Element servFlag = new Element(SERV_FLAG);
        servFlag.setAttribute("type", ACCESS_KEY_TYPE);
        servFlag.setAttribute("inherited", "0");
        servFlag.setAttribute("form", "plain");
        servFlag.setText(json);
        return servFlag;
    } 
}
