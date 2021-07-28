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
package org.mycore.mir.wizard.command;

import java.net.URL;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.PersistenceException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.common.MCRException;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRURLContent;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.impl.MCRCategoryDAOImpl;
import org.mycore.datamodel.classifications2.utils.MCRXMLTransformer;
import org.mycore.mir.wizard.MIRWizardCommand;
import org.mycore.services.i18n.MCRTranslation;

public class MIRWizardLoadClassifications extends MIRWizardCommand {

    private static final MCRCategoryDAO DAO = new MCRCategoryDAOImpl();

    private static final String CLASSIFICATIONS_CFG = "resource:setup/classifications.xml";

    private static final Logger LOGGER = LogManager.getLogger();

    public MIRWizardLoadClassifications() {
        this("load.classifications");
    }

    private MIRWizardLoadClassifications(String name) {
        super(name);
    }

    @Override
    public void doExecute() {
        EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();

        try {
            String result = "";
            Element classifications = MCRURIResolver.instance().resolve(CLASSIFICATIONS_CFG);

            for (Element classification : classifications.getChildren()) {
                String classifURL = classification.getAttributeValue("url");

                MCRContent content = new MCRURLContent(new URL(classifURL));

                try {
                    Document classif = content.asXML();
                    if (classif.hasRootElement() && classif.getRootElement().getChildren().size() > 0) {
                        MCRCategory category = MCRXMLTransformer.getCategory(classif);

                        result += MCRTranslation.translate("component.mir.wizard.loadClassification",
                            category
                                .getCurrentLabel()
                                .orElseThrow(
                                    () -> new MCRException("Classification " + category.getId() + " has no label.")));

                        EntityTransaction tx = em.getTransaction();
                        tx.begin();
                        try {
                            DAO.addCategory(null, category);
                            tx.commit();

                            result += MCRTranslation.translate("component.mir.wizard.done").concat(".\n");
                        } catch (PersistenceException e) {
                            tx.rollback();
                            result += MCRTranslation.translate("component.mir.wizard.error", e.toString())
                                .concat(".\n");
                            LOGGER.error("Exception while loading classification " + category.getId(), e);
                        }
                    }
                } catch (MCRException ex) {
                    result += MCRTranslation.translate("component.mir.wizard.loadClassification.error", classifURL)
                        .concat("\n");
                    LOGGER.error(MCRTranslation.translate("component.mir.wizard.loadClassification.error", classifURL),
                        ex);
                    this.result.setResult(result);
                    this.result.setSuccess(false);
                    return;
                }
            }

            this.result.setResult(result);
            this.result.setSuccess(true);
        } catch (Exception ex) {
            this.result.setResult(ex.toString());
            this.result.setSuccess(false);
        }
    }
}
