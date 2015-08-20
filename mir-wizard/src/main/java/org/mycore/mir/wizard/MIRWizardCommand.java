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

import java.io.IOException;
import java.io.StringWriter;
import java.io.UncheckedIOException;

import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.core.Filter;
import org.apache.logging.log4j.core.Layout;
import org.apache.logging.log4j.core.LogEvent;
import org.apache.logging.log4j.core.appender.AbstractAppender;
import org.apache.logging.log4j.core.filter.ThresholdFilter;
import org.apache.logging.log4j.core.layout.PatternLayout;
import org.jdom2.Element;

public abstract class MIRWizardCommand {

    private String name;

    private Element xml;

    private String logs;

    private CommandLogAppender logAppender;

    protected MIRWizardCommandResult result;

    public MIRWizardCommand(String name) {
        this.name = name;
        this.result = new MIRWizardCommandResult(name);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    /**
     * @return the xml
     */
    public Element getInputXML() {
        return xml;
    }

    /**
     * @param xml
     *            the xml to set
     */
    public void setInputXML(Element xml) {
        this.xml = xml;
    }

    public MIRWizardCommandResult getResult() {
        return result;
    }

    public void execute() {
        logAppender = new CommandLogAppender(getClass().getName(), getAppenderLogFilter(), getAppenderLogLayout());
        logAppender.start();
        doExecute();
        logAppender.stop();
        logs = logAppender.getLogs();
    }

    private Filter getAppenderLogFilter() {
        return ThresholdFilter.createFilter(Level.INFO, null, null);
    }

    protected Layout<String> getAppenderLogLayout() {
        return PatternLayout.newBuilder()
            .withNoConsoleNoAnsi(true)
            .withPattern("%d{ISO8601} %p - %m%n%throwable")
            .build();
    }

    protected abstract void doExecute();

    protected void postExecute() {

    }
    
    protected String getLogs(){
        return logs;
    }
    @SuppressWarnings("serial")
    private static class CommandLogAppender extends AbstractAppender {

        private StringWriter writer;

        private String logs;

        protected CommandLogAppender(String name, Filter filter, Layout<String> layout) {
            super(name, filter, layout);
        }

        @Override
        public void append(LogEvent event) {
            writer.write(this.getLayout().toSerializable(event).toString());
        }

        @Override
        public void start() {
            super.start();
            writer = new StringWriter();
            logs = null;
        }

        @Override
        public void stop() {
            super.stop();
            try {
                writer.close();
                this.logs = writer.toString();
            } catch (IOException e) {
                throw new UncheckedIOException(null, e);
            }
        }

        public String getLogs() {
            return logs;
        }

    }
}
