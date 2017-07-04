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
import java.util.Optional;

import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.common.config.MCRConfigurationDirSetup;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.transformer.MCRXSLTransformer;
import org.mycore.mir.wizard.MIRWizardCommand;

public class MIRWizardGenerateJPAConfig extends MIRWizardCommand {

    public MIRWizardGenerateJPAConfig() {
        this("persistence.xml");
    }

    private MIRWizardGenerateJPAConfig(String name) {
        super(name);
    }

    @Override
    public void doExecute() {
        File resDir = new File(MCRConfigurationDir.getConfigurationDirectory(), "resources/META-INF");
        try {
            resDir.mkdirs();

            File file = new File(resDir, "persistence.xml");
            this.result.setAttribute("file", file.getAbsolutePath());

            // set extra engine property for MariaDB and MySQL
            Optional.ofNullable(getInputXML().getChild("database"))
                .map(c -> c.getChildText("driver")).filter(d -> d.contains("mariadb") || d.contains("mysql"))
                .ifPresent(s -> System.setProperty("hibernate.dialect.storage_engine", "innodb"));

            MCRContent source = new MCRJDOMContent(getInputXML().clone());
            MCRXSLTransformer transformer = new MCRXSLTransformer("xsl/" + source.getDocType() + "-persistence.xsl");
            MCRContent pXML = transformer.transform(source);

            pXML.sendTo(file);

            MCRConfigurationDirSetup.loadExternalLibs();

            this.result.setResult(pXML.asXML().getRootElement().clone());
            this.result.setSuccess(true);
        } catch (Exception ex) {
            ex.printStackTrace();
            this.result.setResult(ex.toString());
            this.result.setSuccess(false);
        }
    }
}
