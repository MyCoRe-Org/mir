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

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.mir.wizard.MIRWizardCommand;
import org.mycore.solr.commands.MCRSolrCommands;

/**
 * @author René Adler (eagle)
 *
 */
public class MIRWizardSolr extends MIRWizardCommand {

    private static final Logger LOGGER = LogManager.getLogger();


    private static final String DEFAULT_CORE = "main";

    private static final String DEFAULT_CLASSIFICATION = "classification";

    public MIRWizardSolr() {
        this("solr");
    }

    /**
     * @param name
     */
    private MIRWizardSolr(final String name) {
        super(name);
    }

    /* (non-Javadoc)
     * @see org.mycore.mir.wizard.MIRWizardCommand#execute()
     */
    @Override
    public void doExecute() {
        try {
            MCRSolrCommands.reloadSolrConfiguration(DEFAULT_CORE, DEFAULT_CORE);
            MCRSolrCommands.reloadSolrConfiguration(DEFAULT_CLASSIFICATION, DEFAULT_CLASSIFICATION);

            this.result.setSuccess(true);
        } catch (final Exception ex) {
            LOGGER.error("Exception while initializing SOLR.", ex);
            this.result.setResult(ex.toString());
            this.result.setSuccess(false);
        }
    }
}
