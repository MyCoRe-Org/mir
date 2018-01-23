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
import java.nio.file.Paths;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.mir.wizard.MIRWizardCommand;
import org.mycore.mir.wizard.utils.MIRWizardUnzip;

/**
 * @author René Adler (eagle)
 *
 */
public class MIRWizardSolr extends MIRWizardCommand {
    private static final Logger LOGGER = LogManager.getLogger(MIRWizardSolr.class);

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
            final String confDir = Paths
                .get(MCRConfigurationDir.getConfigurationDirectory().getAbsolutePath(), "data", "solr", "mir")
                .toString();

            LOGGER.info("extract SOLR config to {}...", confDir);

            MIRWizardUnzip.unzip(
                Thread.currentThread().getContextClassLoader().getResourceAsStream("solr-home.zip"), confDir);

            this.result.setSuccess(true);
        } catch (final IOException ex) {
            this.result.setResult(ex.getMessage());
        }
    }
}
