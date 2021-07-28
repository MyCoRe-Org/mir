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

import java.io.IOException;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.Persistence;
import jakarta.persistence.PersistenceException;
import jakarta.persistence.Query;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.backend.jpa.MCRJPABootstrapper;
import org.mycore.mir.wizard.MIRWizardCommand;

public class MIRWizardInitDatabase extends MIRWizardCommand {

    private final static String ACTION = "create";

    private static final Logger LOGGER = LogManager.getLogger();

    public MIRWizardInitDatabase() {
        this("init.database");
    }

    private MIRWizardInitDatabase(String name) {
        super(name);
    }

    @Override
    public void doExecute() {
        try {
            StringBuffer res = new StringBuffer();

            HashMap<String, String> initProps = new HashMap<String, String>();
            initProps.put("hibernate.hbm2ddl.auto", "create");
            MCRJPABootstrapper.initializeJPA(MCRJPABootstrapper.PERSISTENCE_UNIT_NAME, initProps);

            doSchemaOperation(schema -> "create schema " + schema);

            Map<String, Object> schemaProperties = new HashMap<>();
            schemaProperties.put("javax.persistence.schema-generation.database.action", ACTION);
            try (StringWriter output = new StringWriter()) {
                schemaProperties.put("javax.persistence.schema-generation.scripts.action", ACTION);
                schemaProperties.put("javax.persistence.schema-generation.scripts." + ACTION + "-target", output);
                Persistence.generateSchema(MCRJPABootstrapper.PERSISTENCE_UNIT_NAME, schemaProperties);
                res.append(output.toString());
            }

            this.result.setSuccess(true);
            this.result.setResult(res.toString());
        } catch (IOException | PersistenceException ex) {
            LOGGER.error("Exception while initializing database.", ex);
            this.result.setSuccess(false);
            this.result.setResult(ex.getMessage());
        }
    }

    private void doSchemaOperation(Function<String, String> schemaFunction) {
        EntityManager currentEntityManager = MCREntityManagerProvider.getCurrentEntityManager();
        EntityTransaction transaction = currentEntityManager.getTransaction();
        try {
            transaction.begin();
            getDefaultSchema().ifPresent(
                schemaFunction
                    .andThen(currentEntityManager::createNativeQuery)
                    .andThen(Query::executeUpdate)::apply);
        } finally {
            if (transaction.isActive()) {
                if (transaction.getRollbackOnly()) {
                    transaction.rollback();
                } else {
                    transaction.commit();
                }
            }
        }
    }

    private Optional<String> getDefaultSchema() {
        return Optional.ofNullable(MCREntityManagerProvider
            .getEntityManagerFactory()
            .getProperties()
            .get("hibernate.default_schema"))
            .map(Object::toString);
    }
}
