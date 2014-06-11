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

import org.jdom2.Element;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.transformer.MCRXSLTransformer;
import org.mycore.mir.wizard.MIRWizardCommand;

public class MIRWizardGenerateHibernateCfg extends MIRWizardCommand {

    public MIRWizardGenerateHibernateCfg() {
        this("hibernate.cfg.xml");
    }

    private MIRWizardGenerateHibernateCfg(String name) {
        super(name);
    }

    @Override
    public void execute(Element xml) {
        File file = MCRConfigurationDir.getConfigFile("hibernate.cfg.xml");

        try {
            this.result.setAttribute("file", file.getAbsolutePath());

            MCRContent source = new MCRJDOMContent(xml.clone());
            MCRXSLTransformer transformer = new MCRXSLTransformer("xsl/" + source.getDocType() + "-hibernate.xsl");
            MCRContent hibCfg = transformer.transform(source);

            hibCfg.sendTo(file);

            this.result.setResult(hibCfg.asXML().getRootElement().clone());
            this.result.setSuccess(true);
        } catch (Exception ex) {
            this.result.setResult(ex.getMessage());
            this.result.setSuccess(false);
        }
    }

}
