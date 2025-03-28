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
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.mir.impexp.MIRClassificationMapper;

public class MIRValidationHelper {

    public static String validateSDNB(String sdnb) {
        MCRCategoryDAO dao = MCRCategoryDAOFactory.obtainInstance();
        if (dao.exist(new MCRCategoryID("SDNB", sdnb))) {
            return sdnb;
        }
        if (sdnb.length() == 2) {
            String newdSDNB = MIRClassificationMapper.getSDNBfromOldSDNB(sdnb);
            if (dao.exist(new MCRCategoryID("SDNB", newdSDNB))) {
                return newdSDNB;
            }
        }
        return "";
    }

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
            case "topic", "geographic", "place" -> {
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
