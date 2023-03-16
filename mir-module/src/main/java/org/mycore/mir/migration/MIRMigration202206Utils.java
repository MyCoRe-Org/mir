package org.mycore.mir.migration;

import java.util.Collection;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.classifications2.MCRLabel;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mods.MCRMODSWrapper;

@MCRCommandGroup(name = "MIR migration 2022.06")
public class MIRMigration202206Utils {

    private static final Logger LOGGER = LogManager.getLogger();
    public static final String NAME_IDENTIFIER = "nameIdentifier";

    public static final HashSet<String> getAllRegularLabelLanguagesPresentInCategory(MCRCategory category,
        final HashSet<String> languages) {
        category.getLabels().forEach(label -> {
            // ignore x-* labels (not regular labels)
            if (label.getLang().startsWith("x-")) {
                return;
            }
            languages.add(label.getLang());
        });
        category.getChildren().forEach(c -> getAllRegularLabelLanguagesPresentInCategory(c, languages));
        return languages;
    }

    @MCRCommand(syntax = "fix name identifier type for id {0} dry run {1}")
    public static void checkNameIdentifierType(String objectID, String dryStr)
        throws Exception {
        boolean dry = Boolean.parseBoolean(dryStr);

        if (!MCRObjectID.isValid(objectID)) {
            throw new MCRException("Invalid object ID: " + objectID);
        }

        MCRObjectID mcrObjectID = MCRObjectID.getInstance(objectID);
        MCRObject mcrObject = MCRMetadataManager.retrieveMCRObject(mcrObjectID);
        MCRMODSWrapper mcrModsWrapper = new MCRMODSWrapper(mcrObject);

        MCRCategoryID rootID = MCRCategoryID.rootID(NAME_IDENTIFIER);
        MCRCategory rootCategory = MCRCategoryDAOFactory.getInstance().getCategory(rootID, -1);
        HashSet<String> labelLanguages = getAllRegularLabelLanguagesPresentInCategory(rootCategory, new HashSet<>());

        AtomicBoolean update = new AtomicBoolean(false);
        mcrModsWrapper.getElements("mods:name").forEach(name -> {
            fixModsName(NAME_IDENTIFIER, rootID, labelLanguages, update, name);
        });

        if (update.get() && !dry) {
            LOGGER.info("Save updated object: " + mcrObjectID);
            MCRMetadataManager.update(mcrObject);
        }
    }

    private static void fixModsName(String classification, MCRCategoryID rootID, HashSet<String> labelLanguages,
        AtomicBoolean update, Element name) {
        name.getChildren(NAME_IDENTIFIER, MCRConstants.MODS_NAMESPACE).forEach(nameIdentifier -> {
            fixModsNameIdentifier(classification, rootID, labelLanguages, update, nameIdentifier);
        });
    }

    private static void fixModsNameIdentifier(String classification, MCRCategoryID rootID,
        HashSet<String> labelLanguages, AtomicBoolean update, Element nameIdentifier) {
        String type = nameIdentifier.getAttributeValue("type");
        if (type == null || type.isEmpty()) {
            LOGGER.info("Missing type for nameIdentifier: " + nameIdentifier.getText());
        }

        MCRCategoryID id = new MCRCategoryID(classification, type);
        if (MCRCategoryDAOFactory.getInstance().exist(id)) {
            return;
        }

        LOGGER.info("Unknown type for nameIdentifier: " + nameIdentifier.getText()
            + " check if label match!");

        Set<MCRCategory> foundCategoryByLabel = labelLanguages.stream()
            .map(lang -> MCRCategoryDAOFactory.getInstance().getCategoriesByLabel(rootID, lang, type))
            .flatMap(Collection::stream)
            .collect(Collectors.toCollection(HashSet::new));

        if (foundCategoryByLabel.size() > 1) {
            String list = foundCategoryByLabel.stream()
                .map(MCRCategory::toString)
                .collect(Collectors.joining(","));

            throw new MCRException("Found multiple matching categories with label '" + list + "'");
        } else if (foundCategoryByLabel.size() == 0) {
            throw new MCRException("Found no matching categories with label '" + type + "'");
        }

        MCRCategory category = foundCategoryByLabel.iterator().next();
        LOGGER.info("Found single matching category: " + category.toString());
        nameIdentifier.setAttribute("type", category.getId().getID());
        update.set(true);

        if (nameIdentifier.getAttributeValue("typeURI") != null) {
            LOGGER.info("Remove typeURI attribute for nameIdentifier: " + nameIdentifier.getText());
            nameIdentifier.removeAttribute("typeURI");
        }

        Optional<MCRLabel> xuri = category.getLabels()
            .stream()
            .filter(l -> "x-uri".equals(l.getLang()))
            .findFirst();

        if (xuri.isPresent()) {
            LOGGER.info("Add typeURI attribute for nameIdentifier: " + xuri.get().getText());
            nameIdentifier.setAttribute("typeURI", xuri.get().getText());
        } else {
            LOGGER.info("No x-uri label found for category: " + category +
                " leave typeURI attribute empty");
        }
    }

}
