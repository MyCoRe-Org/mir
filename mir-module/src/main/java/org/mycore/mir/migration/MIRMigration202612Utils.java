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

package org.mycore.mir.migration;

import java.io.StringReader;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.List;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamSource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.input.sax.XMLReaderXSDFactory;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.jdom2.transform.JDOMResult;
import org.jdom2.transform.JDOMSource;
import org.mycore.common.MCRException;
import org.mycore.common.xsl.MCRErrorListener;
import org.mycore.common.xsl.uriresolver.MCRURIResolver;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.classifications2.MCRLabel;
import org.mycore.datamodel.classifications2.impl.MCRCategoryImpl;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetaClassification;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.resource.MCRResourceHelper;

@MCRCommandGroup(name = "MIR migration 2026.12")
public class MIRMigration202612Utils {

    private static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(syntax = "migrate navigation", order = 100)
    public static List<String> migrateNavigation() {
        return List.of(
            "create guidance derivate type",
            "select navigation derivates",
            "list selected",
            "execute for selected verify navigation derivate {x}",
            "execute for selected migrate navigation derivate {x}",
            "select guidance derivates",
            "list selected",
            "execute for selected migrate guidance derivate {x} main document",
            "execute for selected verify guidance file guidance.xml in derivate {x}",
            "delete navigation derivate type");
    }

    @MCRCommand(syntax = "create guidance derivate type", order = 20)
    public static void createGuidanceDerivateType() {

        MCRCategoryID derivateTypesCategoryId = new MCRCategoryID("derivate_types");
        MCRCategoryID guidanceCategoryId = new MCRCategoryID("derivate_types", "guidance");

        MCRCategoryDAO categoryDAO = MCRCategoryDAO.obtainInstance();
        MCRCategory guidanceCategory = categoryDAO.getCategory(guidanceCategoryId, 0);

        if (guidanceCategory != null) {
            LOGGER.info("Derivate type 'guidance' already created");
            return;
        }

        LOGGER.info("Creating derivate type 'guidance'");

        guidanceCategory = new MCRCategoryImpl();
        guidanceCategory.setId(guidanceCategoryId);
        guidanceCategory.getLabels().add(new MCRLabel("de", "Wegweisung", null));
        guidanceCategory.getLabels().add(new MCRLabel("de", "Guidance", null));
        categoryDAO.addCategory(derivateTypesCategoryId, guidanceCategory);

        LOGGER.info("Created derivate type 'guidance'");

    }

    @MCRCommand(syntax = "select navigation derivates", order = 20)
    public static List<String> selectNavigationDerivates() {
        return List.of("select derivates with xpath /mycorederivate/derivate"
            + "[internals/internal[@maindoc and @maindoc!='guidance.xml']]"
            + "[classifications/classification[@classid='derivate_types' and @categid='navigation']]");
    }

    @MCRCommand(syntax = "verify navigation derivate {0}", order = 20)
    public static void verifyNavigationDerivate(String derivateIdString) throws Exception {

        MCRPath navigationPath = MCRPath.getPath(derivateIdString, "navigation.xml");

        if (!Files.exists(navigationPath)) {
            throw new MCRException("File navigation.xml doesn't exist in derivate " + derivateIdString);
        }

        String navigationXsdPath = "xsd/mir/migration/navigation.xsd";
        URL navigationXsdUrl = MCRResourceHelper.getResourceUrl(navigationXsdPath);

        SAXBuilder builder = new SAXBuilder(new XMLReaderXSDFactory(navigationXsdUrl));
        String navigationXml = Files.readString(navigationPath, StandardCharsets.UTF_8);

        try {
            builder.build(new StringReader(navigationXml));
        } catch (JDOMException e) {
            LOGGER.warn("Validation of {}/navigation.xml failed", derivateIdString, e);
        }

    }

    @MCRCommand(syntax = "migrate navigation derivate {0}", order = 20)
    public static void migrateNavigationDerivate(String derivateIdString) throws Exception {

        MCRObjectID derivateId = MCRObjectID.getInstance(derivateIdString);
        MCRDerivate derivate = MCRMetadataManager.retrieveMCRDerivate(derivateId);

        List<MCRMetaClassification> classifications = derivate.getDerivate().getClassifications();
        classifications.forEach(classification -> {
            if (classification.getClassId().equals("derivate_types")) {
                if (classification.getCategId().equals("navigation")) {
                    classification.setValue("derivate_types", "guidance");
                }
            }
        });

        MCRPath navigationPath = MCRPath.getPath(derivateIdString, "navigation.xml");
        MCRPath guidancePath = MCRPath.getPath(derivateIdString, "guidance.xml");

        if (!Files.exists(navigationPath)) {
            throw new MCRException("File navigation.xml doesn't exist in derivate " + derivateIdString);
        }

        if (Files.exists(guidancePath)) {
            throw new MCRException("File guidance.xml already exists in derivate " + derivateIdString);
        }

        Files.move(navigationPath, guidancePath, StandardCopyOption.COPY_ATTRIBUTES);

        derivate.getDerivate().getInternals().setMainDoc("guidance.xml");
        MCRMetadataManager.update(derivate);

    }

    @MCRCommand(syntax = "select guidance derivates", order = 20)
    public static List<String> selectGuidanceDerivates() {
        return List.of("select derivates with xpath /mycorederivate/derivate"
            + "[internals/internal[@maindoc='guidance.xml']]"
            + "[classifications/classification[@classid='derivate_types' and @categid='guidance']]");
    }

    @MCRCommand(syntax = "migrate guidance derivate {0} main document", order = 20)
    public static void migrateGuidanceDerivateMainDocument(String derivateIdString) throws Exception {

        MCRObjectID derivateId = MCRObjectID.getInstance(derivateIdString);
        MCRDerivate derivate = MCRMetadataManager.retrieveMCRDerivate(derivateId);

        String mainDoc = derivate.getDerivate().getInternals().getMainDoc();
        if (!mainDoc.equals("guidance.xml")) {
            throw new MCRException("Main document of derivate " + derivateIdString + " is not guidance.xml");
        }

        MCRPath guidancePath = MCRPath.getPath(derivateIdString, "guidance.xml");

        String navigationXml = Files.readString(guidancePath, StandardCharsets.UTF_8);
        Document navigationDocument = new SAXBuilder().build(new StringReader(navigationXml));
        Document guidanceDocument = transformGuidanceDerivateMainDocument(navigationDocument, derivateIdString);
        String guidanceXml = new XMLOutputter(Format.getPrettyFormat()).outputString(guidanceDocument);
        Files.writeString(guidancePath, guidanceXml, StandardCharsets.UTF_8);

    }

    private static Document transformGuidanceDerivateMainDocument(Document xml, String derivateId) throws Exception {

        String xsltPath = "xslt/mir/migration/navigation2guidance.xsl";
        Source xslt = new StreamSource(MCRResourceHelper.getResourceAsStream(xsltPath));

        TransformerFactory factory = TransformerFactory.newInstance();
        factory.setURIResolver(MCRURIResolver.obtainInstance());

        Transformer transformer = factory.newTransformer(xslt);
        transformer.setErrorListener(new MCRErrorListener());
        transformer.setParameter("derivateId", derivateId);

        JDOMResult result = new JDOMResult();
        transformer.transform(new JDOMSource(xml), result);
        return new Document(result.getResult());

    }

    @MCRCommand(syntax = "delete navigation derivate type", order = 20)
    public static void deleteNavigationDerivateType() {

        MCRCategoryID navigationCategoryId = new MCRCategoryID("derivate_types", "navigation");

        MCRCategoryDAO categoryDAO = MCRCategoryDAO.obtainInstance();
        MCRCategory navigationCategory = categoryDAO.getCategory(navigationCategoryId, 0);

        if (navigationCategory == null) {
            LOGGER.info("Derivate type 'navigation' already deleted");
            return;
        }

        LOGGER.info("Deleting derivate type 'navigation'");
        categoryDAO.deleteCategory(navigationCategoryId);
        LOGGER.info("Deleted derivate type 'navigation'");

    }

}
