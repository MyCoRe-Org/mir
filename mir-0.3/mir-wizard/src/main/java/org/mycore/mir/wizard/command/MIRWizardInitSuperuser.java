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

import java.util.List;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.mycore.backend.hibernate.MCRHIBConnection;
import org.mycore.mir.wizard.MIRWizardCommand;
import org.mycore.user2.MCRUserCommands;

public class MIRWizardInitSuperuser extends MIRWizardCommand {

    public MIRWizardInitSuperuser() {
        this("init.superuser");
    }

    private MIRWizardInitSuperuser(String name) {
        super(name);
    }

    @Override
    public void doExecute() {
        try {
            Session session = MCRHIBConnection.instance().getSession();
            Transaction transaction = session.beginTransaction();

            List<String> users = MCRUserCommands.initSuperuser();

            transaction.commit();
            session.close();

            if (users != null && users.size() != 0) {
                this.result.setSuccess(true);
            } else {
                this.result.setSuccess(false);
            }

        } catch (Exception ex) {
            this.result.setResult(ex.getMessage());
        }
    }
}
