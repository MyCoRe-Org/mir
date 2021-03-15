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

package org.mycore.mir.authorization.accesskey;

import java.util.Arrays;
import java.util.List;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.JsonProcessingException;

import org.jdom2.Element;

import org.mycore.mir.authorization.accesskey.backend.MIRAccessKey;

public class MIRAccessKeyTransformer {

    public static List<MIRAccessKey> jsonToAccessKeys(final String json)
        throws JsonProcessingException {
        final ObjectMapper objectMapper = new ObjectMapper();
        return Arrays.asList(objectMapper.readValue(json, MIRAccessKey[].class));
    }

    public static String accessKeysToJson(final List<MIRAccessKey> accessKeys)
        throws JsonProcessingException {
        final ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.writeValueAsString(accessKeys);
    }

    public static String accessKeyToJson(final MIRAccessKey accessKey)
        throws JsonProcessingException {
        final ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.writeValueAsString(accessKey);
    }

    public static MIRAccessKey jsonToAccessKey(final String json)
        throws JsonProcessingException {
        final ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.readValue(json, MIRAccessKey.class);
    }

    public static Element accessKeysJsonToServFlag(final String json) {
        final Element main = new Element("servflag");
        main.setAttribute("type", "accesskeys");
        main.setAttribute("inherited", "0");
        main.setAttribute("form", "plain");
        main.setText(json);
        return main;
    }
}
