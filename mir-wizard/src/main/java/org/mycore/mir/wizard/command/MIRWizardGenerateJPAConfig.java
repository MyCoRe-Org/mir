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

import java.io.File;
import java.io.FileOutputStream;
import java.io.StringWriter;
import java.util.Objects;
import java.util.Properties;
import java.util.function.Predicate;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.backend.jpa.MCRPersistenceProvider;
import org.mycore.backend.jpa.MCRSimpleConfigPersistenceUnitDescriptor;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.common.config.MCRConfigurationDirSetup;
import org.mycore.mir.wizard.MIRWizardCommand;

import jakarta.persistence.spi.PersistenceProviderResolverHolder;

public class MIRWizardGenerateJPAConfig extends MIRWizardCommand {

    private static final Logger LOGGER = LogManager.getLogger();

    public static final String PERSISTENCE_UNIT_NAME = MCRConfiguration2
        .getStringOrThrow("MCR.JPA.PersistenceUnitName");

    private static final String COMPLEX_DATABASE_PREFIX
        = MCRPersistenceProvider.JPA_PERSISTENCE_UNIT_PROPERTY_NAME + PERSISTENCE_UNIT_NAME + ".";

    public MIRWizardGenerateJPAConfig() {
        this("persistence.properties");
    }

    private MIRWizardGenerateJPAConfig(String name) {
        super(name);
    }

    private static Properties getDefaultProps() {
        Properties props = new Properties();

        props.setProperty(COMPLEX_DATABASE_PREFIX + "Class",
            MCRSimpleConfigPersistenceUnitDescriptor.class.getName());
        props.setProperty("MCR.JPA.Connection.MaximumPoolSize", "10");
        props.setProperty(COMPLEX_DATABASE_PREFIX + "Properties.hibernate.auto_quote_keyword", "true");

        return props;
    }

    private static Properties convertDatabaseElement(Element databaseElement) {
        Properties props = getDefaultProps();
        if (databaseElement != null) {
            String driver = databaseElement.getChildText("driver");

            if (driver != null && !driver.isBlank()) {
                if (driver.contains("mariadb") || driver.contains("mysql")) {
                    props.setProperty(COMPLEX_DATABASE_PREFIX + "Properties.hibernate.dialect.storage_engine",
                        "innodb");
                }
                props.setProperty("MCR.JPA.Driver", driver);
            }

            String url = databaseElement.getChildText("url");
            if (url != null && !url.isBlank()) {
                props.setProperty("MCR.JPA.URL", url);
            }

            String username = databaseElement.getChildText("username");
            if (username != null && !username.isBlank()) {
                props.setProperty("MCR.JPA.User", username);
            }

            String password = databaseElement.getChildText("password");
            if (password != null && !password.isBlank()) {
                props.setProperty("MCR.JPA.Password", password);
            }

            Element extraPropertiesElement = databaseElement.getChild("extra_properties");
            convertExtraPropertiesElement(extraPropertiesElement, props);
        }
        return props;
    }

    private static void convertExtraPropertiesElement(Element extraPropertiesElement, Properties props) {
        if (extraPropertiesElement != null) {
            extraPropertiesElement.getChildren().stream()
                .filter(element -> Objects.equals(element.getName(), "property") &&
                    Objects.equals(element.getAttributeValue("name"), "schema"))
                .map(Element::getText)
                .filter(Predicate.not(String::isBlank))
                .findFirst()
                .ifPresent(schema -> props.setProperty("MCR.JPA.DefaultSchema", schema));

            extraPropertiesElement.getChildren().stream()
                .filter(element -> Objects.equals(element.getName(), "property") &&
                    Objects.equals(element.getAttributeValue("name"), "catalog"))
                .map(Element::getText)
                .filter(Predicate.not(String::isBlank))
                .findFirst()
                .ifPresent(catalog -> props
                    .setProperty(COMPLEX_DATABASE_PREFIX + "Properties.hibernate.default_catalog", catalog));
        }
    }

    @Override
    public void doExecute() {
        try {
            // set extra engine property for MariaDB and MySQL
            Element xml = getInputXML();
            Element databaseElement = xml.getChild("database");

            Properties props = convertDatabaseElement(databaseElement);
            MCRConfigurationDirSetup.loadExternalLibs();

            File file = MCRConfigurationDir.getConfigFile("mycore.properties");
            try (FileOutputStream out = new FileOutputStream(file, true)) {
                props.store(out, "Generated by MIR Wizard.");
            }
            props.forEach((key, value) -> MCRConfiguration2.set(key.toString(), value.toString()));

            StringWriter stringWriter = new StringWriter();
            props.store(stringWriter, "Generated by MIR Wizard.");
            String propertiesAsString = stringWriter.toString();

            PersistenceProviderResolverHolder.getPersistenceProviderResolver()
                    .clearCachedProviders();

            this.result.setResult(propertiesAsString);
            this.result.setSuccess(true);
        } catch (Exception ex) {
            LOGGER.error("Exception while generating JPA config.", ex);
            this.result.setResult(ex.toString());
            this.result.setSuccess(false);
        }
    }
}
