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
import java.io.IOException;
import java.io.StringWriter;
import java.net.URL;
import java.nio.file.Files;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.apache.log4j.WriterAppender;
import org.jdom2.Element;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.common.xml.MCRURIResolver;
import org.mycore.mir.wizard.MIRWizardCommand;
import org.mycore.mir.wizard.utils.MIRWizardUnzip;

/**
 * @author René Adler (eagle)
 *
 */
public class MIRWizardSolr extends MIRWizardCommand {
    private static final Logger LOGGER = Logger.getLogger(MIRWizardSolr.class);

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
    public void execute() {
        final StringWriter consoleWriter = new StringWriter();
        final WriterAppender appender = new WriterAppender(new PatternLayout("%d{ISO8601} %p - %m%n"), consoleWriter);

        final Element xml = MCRURIResolver.instance().resolve("resource:setup/solr.xml");
        // TODO make SOLR version selectable
        final Element config = xml.getChildren("instance").get(0).getChild("config");

        if (config != null && config.getChildren().size() > 0) {
            try {
                final File tmpDir = Files.createTempDirectory("solr").toFile();
                File file = null;

                boolean success = true;
                for (Element c : config.getChildren()) {
                    final String url = c.getTextTrim();
                    final String fname = FilenameUtils.getName(url);
                    try {
                        file = new File(tmpDir.getAbsolutePath() + File.separator + fname);

                        FileUtils.copyURLToFile(new URL(url), file);

                        success = true;
                    } catch (final Exception ex) {
                        success = false;
                    }

                    if (success) {
                        this.result.setAttribute("url", url);
                        break;
                    }
                }

                if (success && file != null) {
                    appender.setName("CONSOLE_APPENDER");
                    appender.setThreshold(org.apache.log4j.Level.INFO);
                    Logger.getRootLogger().addAppender(appender);

                    final String dataDir = MCRConfigurationDir.getConfigurationDirectory().getAbsolutePath()
                            + File.separator + "data";

                    MIRWizardUnzip.unzip(file.getAbsolutePath(), dataDir);

                    final String confDir = dataDir + File.separator + "solr" + File.separator + "collection1"
                            + File.separator + "conf";
                    final String[] confs = { "schema.xml", "solrconfig.xml" };
                    for (String name : confs) {
                        LOGGER.info("copy file \"" + name + "\" to \"" + confDir + "\"...");
                        file = new File(confDir + File.separator + name);
                        FileUtils.copyInputStreamToFile(
                                this.getClass().getClassLoader().getResourceAsStream("setup/solr/" + name), file);
                    }

                    this.result.setResult(consoleWriter.toString());

                    Logger.getRootLogger().removeAppender(appender);
                    appender.close();
                    consoleWriter.close();
                }

                this.result.setSuccess(success);
            } catch (final IOException ex) {
                this.result.setResult(ex.getMessage());
            }
        }
    }
}
