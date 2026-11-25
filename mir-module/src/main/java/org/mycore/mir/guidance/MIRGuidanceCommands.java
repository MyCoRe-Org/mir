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

package org.mycore.mir.guidance;

import java.io.StringReader;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.input.sax.XMLReaderXSDFactory;
import org.mycore.common.MCRException;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.resource.MCRResourceHelper;

@MCRCommandGroup(name = "MIR Guidance Commands")
public class MIRGuidanceCommands {

    private static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(syntax = "verify guidance file {0} in derivate {1}", order = 20)
    public static void verifyGuidanceDerivate(String guidanceFileName, String derivateIdString) throws Exception {

        MCRPath guidancePath = MCRPath.getPath(derivateIdString, guidanceFileName);

        if (!Files.exists(guidancePath)) {
            throw new MCRException("File " + guidanceFileName + " doesn't exist in derivate " + derivateIdString);
        }

        String guidanceXsdPath = "xsd/mir/guidance.xsd";
        URL guidanceXsdUrl = MCRResourceHelper.getResourceUrl(guidanceXsdPath);

        SAXBuilder builder = new SAXBuilder(new XMLReaderXSDFactory(guidanceXsdUrl));
        String guidanceXml = Files.readString(guidancePath, StandardCharsets.UTF_8);

        try {
            builder.build(new StringReader(guidanceXml));
        } catch (JDOMException e) {
            LOGGER.warn("Validation of {}/{} failed", derivateIdString, guidanceFileName, e);
        }

    }

}
