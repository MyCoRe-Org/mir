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

import java.lang.reflect.InvocationTargetException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Attribute;
import org.jdom2.Element;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.frontend.cli.MCRCommandManager;
import org.mycore.mir.wizard.MIRWizardCommand;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.PersistenceException;

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
        MCRCommandManager cm = new MCRCommandManager();

        try {
            for (Element command : getInputXML().getChildren()) {

                String cmd = command.getTextTrim();
                cmd = cmd.replaceAll("[\\r\\n]+", " ");
                cmd = cmd.replaceAll("  +", " ");

                for (Attribute attr : command.getAttributes()) {
                    cmd = cmd.replaceAll(Pattern.quote("{" + attr.getName() + "}"),
                        Matcher.quoteReplacement(attr.getValue()));
                }

                LOGGER.info("Executing command: {}", cmd);

                EntityTransaction tx = em.getTransaction();
                tx.begin();
                try {
                    cm.invokeCommand(cmd);
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
