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
package org.mycore.mir.wizard;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.jdom2.Element;

public class MIRWizardCommandChain {

    private static final Logger LOGGER = Logger.getLogger(MIRWizardCommandChain.class);

    private List<MIRWizardCommand> commands;

    private boolean haltOnError = true;

    private boolean success = true;

    public MIRWizardCommandChain() {
        setCommands(new ArrayList<MIRWizardCommand>());
    }

    public List<MIRWizardCommand> getCommands() {
        return commands;
    }

    protected void setCommands(List<MIRWizardCommand> commands) {
        this.commands = commands;
    }

    public void addCommand(MIRWizardCommand cmd) {
        commands.add(cmd);
    }

    public boolean isHaltOnError() {
        return haltOnError;
    }

    public void setHaltOnError(boolean haltOnError) {
        this.haltOnError = haltOnError;
    }

    /**
     * @return the success
     */
    public boolean isSuccess() {
        return success;
    }

    /**
     * @param success the success to set
     */
    public void setSuccess(boolean success) {
        this.success = success;
    }

    public void execute(Element xml) {
        for (MIRWizardCommand cmd : commands) {
            LOGGER.info("Execute " + cmd.getClass().getSimpleName() + "...");

            cmd.execute(xml);

            if (!cmd.getResult().isSuccess()) {
                setSuccess(false);
            }
            if (isHaltOnError() && !cmd.getResult().isSuccess()) {
                break;
            }
        }
    }
}
