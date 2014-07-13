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
import java.io.StringWriter;
import java.lang.reflect.InvocationTargetException;
import java.util.List;

import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.apache.log4j.WriterAppender;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.jdom2.Attribute;
import org.jdom2.Element;
import org.mycore.backend.hibernate.MCRHIBConnection;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.frontend.cli.MCRCommandManager;
import org.mycore.mir.wizard.MIRWizardCommand;
import org.mycore.services.i18n.MCRTranslation;

/**
 * @author René Adler (eagle)
 *
 */
public class MIRWizardMCRCommand extends MIRWizardCommand {

    /**
     * @param name
     */
    public MIRWizardMCRCommand(String name) {
        super(name);
    }

    /* (non-Javadoc)
     * @see org.mycore.mir.wizard.MIRWizardCommand#execute(org.jdom2.Element)
     */
    @Override
    public void execute() {
        Session currentSession = MCRHIBConnection.instance().getSession();

        StringWriter consoleWriter = new StringWriter();
        WriterAppender appender = new WriterAppender(new PatternLayout("%d{ISO8601} %p - %m%n"), consoleWriter);

        try {
            appender.setName("CONSOLE_APPENDER");
            appender.setThreshold(org.apache.log4j.Level.INFO);
            Logger.getRootLogger().addAppender(appender);

            String result = "";

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

                Transaction tx = currentSession.beginTransaction();
                try {
                    List<String> res = mcrCmdMgr.invokeCommand(cmd);
                    for (String str : res) {
                        result += str;
                    }
                    tx.commit();
                } catch (HibernateException e) {
                    tx.rollback();

                    this.result.setResult(result + e.toString());
                    this.result.setSuccess(false);
                    return;
                } catch (InvocationTargetException e) {
                    e.printStackTrace();
                    this.result.setResult(result + e.toString());
                    this.result.setSuccess(false);
                    return;
                }

                result += consoleWriter.toString();
            }

            Logger.getRootLogger().removeAppender(appender);
            appender.close();
            consoleWriter.close();

            this.result.setResult(result);
            this.result.setSuccess(true);
        } catch (Exception ex) {
            ex.printStackTrace();
            this.result.setResult(ex.toString());
            this.result.setSuccess(false);
        }
    }

}
