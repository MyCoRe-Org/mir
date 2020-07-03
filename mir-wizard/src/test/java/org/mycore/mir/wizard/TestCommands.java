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

import static org.junit.Assert.assertTrue;

import java.util.Collection;
import java.util.stream.Collectors;

import org.jdom2.Element;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.junit.Test;
import org.mycore.common.MCRJPATestCase;
import org.mycore.common.MCRStreamUtils;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.mir.wizard.command.MIRWizardLoadClassifications;
import org.mycore.mir.wizard.command.MIRWizardMCRCommand;

/**
 * @author René Adler (eagle)
 *
 */
public class TestCommands extends MCRJPATestCase {

    @Test
    public void testLoadClassifications() throws Exception {
        MIRWizardCommandChain chain = new MIRWizardCommandChain();
        chain.addCommand(new MIRWizardLoadClassifications());

        endTransaction();
        chain.execute(null);

        MIRWizardCommandResult result = chain.getCommands().get(0).getResult();

        new XMLOutputter(Format.getPrettyFormat()).output(result.getResult(), System.out);

        assertTrue(toMessage(result.getResult()), result.isSuccess());
    }

    @Test
    public void testImportACLs() throws Exception {
        MIRWizardCommandChain chain = new MIRWizardCommandChain();

        MIRWizardMCRCommand importACLs = new MIRWizardMCRCommand("import.acls");
        importACLs.setInputXML(MCRURIResolver.instance().resolve("resource:setup/defaultrules-wizard-commands.xml"));
        chain.addCommand(importACLs);

        MIRWizardMCRCommand importWebACLs = new MIRWizardMCRCommand("import.webacls");
        importWebACLs.setInputXML(MCRURIResolver.instance().resolve("resource:setup/webacl-wizard-commands.xml"));
        chain.addCommand(importWebACLs);

        MIRWizardMCRCommand importRestApiACLs = new MIRWizardMCRCommand("import.restapiacls");
        importRestApiACLs
            .setInputXML(MCRURIResolver.instance().resolve("resource:setup/restapiacl-wizard-commands.xml"));
        chain.addCommand(importRestApiACLs);

        endTransaction();
        chain.execute(null);

        MIRWizardCommandResult result = chain.getCommands().get(0).getResult();

        new XMLOutputter(Format.getPrettyFormat()).output(result.getResult(), System.out);

        assertTrue(toMessage(result.getResult()), result.isSuccess());
    }

    private static String toMessage(Element result) {
        return MCRStreamUtils.flatten(result, Element::getChildren, Collection::stream).map(Element::getTextNormalize)
            .collect(Collectors.joining());
    }
}
