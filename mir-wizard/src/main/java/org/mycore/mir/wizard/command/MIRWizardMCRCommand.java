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
import java.lang.reflect.InvocationTargetException;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.PersistenceException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Attribute;
import org.jdom2.Element;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.frontend.cli.MCRCommandManager;
import org.mycore.mir.wizard.MIRWizardCommand;

/**
 * @author René Adler (eagle)
 */
public class MIRWizardMCRCommand extends MIRWizardCommand {

    private static final Logger LOGGER = LogManager.getLogger();

    public MIRWizardMCRCommand(String name) {
        super(name);
    }

    /* (non-Javadoc)
     * @see org.mycore.mir.wizard.MIRWizardCommand#execute(org.jdom2.Element)
     */
    @Override
    public void doExecute() {
        EntityManager em = MCREntityManagerProvider.getCurrentEntityManager();

        try {
            for (Element command : getInputXML().getChildren()) {
                String cmd = command.getTextTrim();
                cmd = cmd.replaceAll("\n", "").replaceAll("\r", "").replaceAll("  ", " ");
                cmd = cmd.replaceAll("  ", " ");

                for (Attribute attr : command.getAttributes()) {
                    if (attr.getValue().startsWith("resource:")) {
                        File tmpFile = File.createTempFile("resfile", ".xml");
                        MCRContent source = new MCRJDOMContent(MCRURIResolver.instance().resolve(attr.getValue()));
                        source.sendTo(tmpFile);

                        cmd = cmd.replace("{" + attr.getName() + "}", tmpFile.getAbsolutePath());
                    } else {
                        cmd = cmd.replace("{" + attr.getName() + "}", attr.getValue());
                    }
                }

                MCRCommandManager mcrCmdMgr = new MCRCommandManager();

                EntityTransaction tx = em.getTransaction();
                tx.begin();
                try {
                    mcrCmdMgr.invokeCommand(cmd);
                    tx.commit();
                } catch (PersistenceException e) {
                    tx.rollback();

                    this.result.setResult(result + e.toString());
                    this.result.setSuccess(false);
                    return;
                } catch (InvocationTargetException e) {
                    LOGGER.error("Exception while executing command: " + cmd, e);
                    this.result.setResult(result + e.toString());
                    this.result.setSuccess(false);
                    return;
                }

            }

            this.result.setSuccess(true);
        } catch (Exception ex) {
            LOGGER.error("Exception while executing commands.", ex);
            this.result.setResult(ex.toString());
            this.result.setSuccess(false);
        }
    }
}
