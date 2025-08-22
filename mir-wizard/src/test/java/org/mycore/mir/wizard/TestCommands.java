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

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Collection;
import java.util.stream.Collectors;

import org.jdom2.Element;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.common.MCRStreamUtils;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.mir.wizard.command.MIRWizardMCRCommand;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MCRJPATestHelper;
import org.mycore.test.MyCoReTest;

/**
 * @author René Adler (eagle)
 *
 */
@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
public class TestCommands {

    @Test
    public void testLoadClassifications() throws Exception {
        MIRWizardCommandChain chain = new MIRWizardCommandChain();
        MIRWizardMCRCommand loadClassifications = new MIRWizardMCRCommand("load.classifications");
        loadClassifications
            .setInputXML(MCRURIResolver.obtainInstance().resolve("resource:setup/classifications-wizard-commands.xml"));
        chain.addCommand(loadClassifications);

        MCRJPATestHelper.endTransaction();
        chain.execute(null);

        MIRWizardCommandResult result = chain.getCommands().getFirst().getResult();

        new XMLOutputter(Format.getPrettyFormat()).output(result.getResult(), System.out);

        assertTrue(result.isSuccess(), toMessage(result.getResult()));
    }

    @Test
    public void testImportACLs() throws Exception {
        MIRWizardCommandChain chain = new MIRWizardCommandChain();

        MIRWizardMCRCommand importACLs = new MIRWizardMCRCommand("import.acls");
        importACLs
            .setInputXML(MCRURIResolver.obtainInstance().resolve("resource:setup/defaultrules-wizard-commands.xml"));
        chain.addCommand(importACLs);

        MIRWizardMCRCommand importWebACLs = new MIRWizardMCRCommand("import.webacls");
        importWebACLs.setInputXML(MCRURIResolver.obtainInstance().resolve("resource:setup/webacl-wizard-commands.xml"));
        chain.addCommand(importWebACLs);

        MIRWizardMCRCommand importRestApiACLs = new MIRWizardMCRCommand("import.restapiacls");
        importRestApiACLs
            .setInputXML(MCRURIResolver.obtainInstance().resolve("resource:setup/restapiacl-wizard-commands.xml"));
        chain.addCommand(importRestApiACLs);

        MCRJPATestHelper.endTransaction();
        chain.execute(null);

        MIRWizardCommandResult result = chain.getCommands().getFirst().getResult();

        new XMLOutputter(Format.getPrettyFormat()).output(result.getResult(), System.out);

        assertTrue(result.isSuccess(), toMessage(result.getResult()));
    }

    private static String toMessage(Element result) {
        return MCRStreamUtils.flatten(result, Element::getChildren, Collection::stream).map(Element::getTextNormalize)
            .collect(Collectors.joining());
    }
}
