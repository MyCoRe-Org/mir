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

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.frontend.servlets.MCRServlet;

import java.io.File;
import java.io.Serial;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;

public class MIRWizard extends MCRServlet {

    @Serial
    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = LogManager.getLogger();

    public static boolean isNecessary() {

        File mcrProps = MCRConfigurationDir.getConfigFile("mycore.properties");


        return (mcrProps == null || !mcrProps.canRead());
    }

    public Element doMagic(Element wizXML) {

        final Element results = new Element("results");

        final Element commands = MCRURIResolver.obtainInstance().resolve("resource:setup/install.xml");

        final MIRWizardCommandChain chain = new MIRWizardCommandChain();

        for (Element command : commands.getChildren("command")) {
            final String cls = command.getAttributeValue("class");
            final String name = command.getAttributeValue("name");
            final String src = command.getAttributeValue("src");

            try {
                final Class<?> cmdCls = Class.forName(cls);
                MIRWizardCommand cmd = null;

                if (name != null) {
                    final Constructor<?> cmdC = cmdCls.getConstructor(String.class);
                    cmd = (MIRWizardCommand) cmdC.newInstance(name);
                } else {
                    final Constructor<?> cmdC = cmdCls.getConstructor();
                    cmd = (MIRWizardCommand) cmdC.newInstance();
                }

                if (src != null) {
                    cmd.setInputXML(MCRURIResolver.obtainInstance().resolve(src));
                }

                if (cmd != null) {
                    chain.addCommand(cmd);
                }
            } catch (final ClassNotFoundException | NoSuchMethodException | SecurityException
                    | InstantiationException | IllegalAccessException | IllegalArgumentException
                    | InvocationTargetException e) {
                LOGGER.error(e);
            }
        }

        LOGGER.info("Execute Wizard Commands");
        MCRSessionMgr.unlock();
        chain.execute(wizXML);

        boolean success = chain.isSuccess();
        results.setAttribute("success", Boolean.toString(success));
        if (success) {
            LOGGER.info("Executed Wizard Commands successfully");
        } else {
            LOGGER.info("Executed Wizard Commands unsuccessfully");
        }

        for (MIRWizardCommand cmd : chain.getCommands()) {
            if (cmd.getResult() != null) {
                results.addContent(cmd.getResult().toElement());
            }
        }

        return results;
    }

}
