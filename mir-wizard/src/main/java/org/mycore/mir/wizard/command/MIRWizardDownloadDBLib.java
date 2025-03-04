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
import java.net.URI;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.common.config.MCRConfigurationDirSetup;
import org.mycore.mir.wizard.MIRWizardCommand;

public class MIRWizardDownloadDBLib extends MIRWizardCommand {

    private static final Logger LOGGER = LogManager.getLogger();

    public MIRWizardDownloadDBLib() {
        this("download");
    }

    private MIRWizardDownloadDBLib(String name) {
        super(name);
    }

    @Override
    public void doExecute() {
        try {

            Element library = getInputXML().getChild("database").getChild("library");

            if (library != null && library.getChildren().size() > 0) {
                String libDir = MCRConfigurationDir.getConfigurationDirectory().getAbsolutePath() + File.separator 
                    + "lib";

                boolean success = true;
                for (Element lib : library.getChildren()) {
                    String url = lib.getTextTrim();
                    String fname = FilenameUtils.getName(url);
                    File file = new File(libDir + File.separator + fname);
                    try {

                        FileUtils.copyURLToFile(new URI(url).toURL(), file);
                        MCRConfigurationDirSetup.loadExternalLibs();

                        success = true;
                    } catch (Exception ex) {
                        LOGGER.error("Exception while downloading or loading database library: " 
                                + file.getAbsolutePath(), ex);
                        success = false;
                    }

                    if (success) {
                        this.result.setAttribute("lib", fname);
                        this.result.setAttribute("url", url);
                        this.result.setAttribute("to", libDir);
                        break;
                    }
                }

                this.result.setSuccess(success);
            }
        } catch (Exception ex) {
            LOGGER.error("Exception while downloading DB library.", ex);
            this.result.setResult(ex.toString());
            this.result.setSuccess(false);
        }
    }
}
