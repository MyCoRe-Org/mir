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

package org.mycore.mir.validation;

import java.io.IOException;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Objects;

import org.apache.logging.log4j.LogManager;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.mycore.common.MCRException;
import org.mycore.common.config.MCRConfiguration2;

public class MIRValidationHelper {

    public static boolean validatePPN(String ppn) {
        String database = MCRConfiguration2.getString("MIR.PPN.DatabaseList").orElse("gvk");
        try {
            URL url = new URI("http://uri.gbv.de/document/" + database + ":ppn:" + ppn).toURL();
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.connect();
            int resCode = connection.getResponseCode();
            if (resCode == 200 || resCode == 302) {
                return true;
            }
        } catch (IOException | URISyntaxException e) {
            LogManager.getLogger().error("Exception while validating PPN.", e);
        }
        return false;
    }

    public static boolean validateSubject(Element subject) {
        return validateSubjectXML(subject, false);
    }

    public static boolean validateSubjectRequired(Element subject) {
        return validateSubjectXML(subject, true);
    }

    public static boolean validateSubjectXML(Element subject, boolean required) {
        String xmlContent = subject.getText();
        SAXBuilder saxBuilder = new SAXBuilder();
        Document result;
        try (StringReader characterStream = new StringReader(xmlContent)) {
            result = saxBuilder.build(characterStream);
        } catch (IOException | JDOMException e) {
            throw new MCRException(e);
        }
        Element newSubject = result.getRootElement();
        return validateSubject(newSubject, required);
    }

    public static boolean validateSubject(Element subjectElement, boolean required) {
        if (subjectElement.getChildren().isEmpty() && required) {
            return false;
        }

        for (Element childElement : subjectElement.getChildren()) {
            String elementName = childElement.getName();
            switch (elementName) {
            case "topic", "geographic", "place", "temporal" -> {
                if (childElement.getText().trim().isEmpty()) {
                    return false;
                }
            }
            case "titleInfo" -> {
                if (validateSubjectTitleInfo(childElement)) {
                    return false;
                }
            }
            case "name" -> {
                if (validateSubjectName(childElement)) {
                    return false;
                }
            }
            case "cartographics" -> {
                if (validateSubjectCartographics(childElement)) {
                    return false;
                }
            }
            default -> {
                LogManager.getLogger().warn("Unknown subject element: " + elementName);
                return false;
            }
            }

        }
        return true;

    }

    private static boolean validateSubjectCartographics(Element childElement) {
        boolean oneTextPresent = false;
        for (Element cartographicsChild : childElement.getChildren()) {
            String cartographicsChildName = cartographicsChild.getName();
            boolean isTextRequired = Objects.equals(cartographicsChildName, "coordinates") ||
                    Objects.equals(cartographicsChildName, "scale") ||
                    Objects.equals(cartographicsChildName, "projection");
            if (!oneTextPresent && isTextRequired) {
                oneTextPresent = true;
            }
            if (isTextRequired && cartographicsChild.getText().trim().isEmpty()) {
                return true;
            }
        }
        return false;
    }

    private static boolean validateSubjectName(Element childElement) {
        boolean oneTextPresent = false;
        for (Element nameChild : childElement.getChildren()) {
            String nameChildName = nameChild.getName();
            boolean isTextRequired = Objects.equals(nameChildName, "namePart") ||
                    Objects.equals(nameChildName, "affiliation") ||
                    Objects.equals(nameChildName, "displayForm");
            if (!oneTextPresent && isTextRequired) {
                oneTextPresent = true;
            }
            if (isTextRequired && nameChild.getText().trim().isEmpty()) {
                return true;
            }
        }
        return !oneTextPresent;
    }

    private static boolean validateSubjectTitleInfo(Element childElement) {
        for (Element titleInfoChild : childElement.getChildren()) {
            String titleInfoChildName = titleInfoChild.getName();
            boolean isTextRequired = Objects.equals(titleInfoChildName, "title") ||
                    Objects.equals(titleInfoChildName, "subTitle") ||
                    Objects.equals(titleInfoChildName, "partNumber") ||
                    Objects.equals(titleInfoChildName, "partName") ||
                    Objects.equals(titleInfoChildName, "nonSort");
            if (isTextRequired && titleInfoChild.getText().trim().isEmpty()) {
                return true;
            }
        }
        return false;
    }
}
