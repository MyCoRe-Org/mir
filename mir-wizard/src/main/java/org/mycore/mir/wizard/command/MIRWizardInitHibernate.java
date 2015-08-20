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
import java.nio.charset.Charset;
import java.util.Scanner;

import org.hibernate.tool.hbm2ddl.SchemaUpdate;
import org.mycore.backend.hibernate.MCRHIBConnection;
import org.mycore.mir.wizard.MIRWizardCommand;

public class MIRWizardInitHibernate extends MIRWizardCommand {

    public MIRWizardInitHibernate() {
        this("init.hibernate");
    }

    private MIRWizardInitHibernate(String name) {
        super(name);
    }

    @Override
    public void doExecute() {
        try {
            File temp = File.createTempFile("hib", ".log");
            SchemaUpdate su = new SchemaUpdate(MCRHIBConnection.instance().getConfiguration());
            su.setOutputFile(temp.getAbsolutePath());
            su.execute(true, true);

            Scanner scanner = new Scanner(temp, Charset.defaultCharset().name());
            this.result.setResult(scanner.useDelimiter("\\Z").next());

            scanner.close();

            temp.delete();

            this.result.setSuccess(true);
        } catch (Exception ex) {
            this.result.setSuccess(false);
            this.result.setResult(ex.getMessage());
        }
    }
}
