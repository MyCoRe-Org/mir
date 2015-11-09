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
import java.io.Serializable;
import java.io.StringWriter;
import java.io.UncheckedIOException;
import java.util.HashMap;
import java.util.Map;

import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.core.Filter;
import org.apache.logging.log4j.core.Layout;
import org.apache.logging.log4j.core.LogEvent;
import org.apache.logging.log4j.core.Logger;
import org.apache.logging.log4j.core.appender.AbstractAppender;
import org.apache.logging.log4j.core.filter.ThresholdFilter;
import org.apache.logging.log4j.core.layout.PatternLayout;
import org.jdom2.Element;

public class MIRWizardCommandResult {

    private final static Logger ROOT_LOGGER = (Logger) LogManager.getRootLogger();

    private String name;

    private boolean success;

    private Map<String, String> attributes = new HashMap<String, String>();

    private Element result;

    private CommandLogAppender logAppender;

    public MIRWizardCommandResult(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public Map<String, String> getAttributes() {
        return attributes;
    }

    public void setAttributes(Map<String, String> attributes) {
        this.attributes = attributes;
    }

    public void setAttribute(String key, String value) {
        this.attributes.put(key, value);
    }

    public String getAttribute(String key) {
        return this.attributes.get(key);
    }

    protected Element getResult() {
        return result == null ? this.toElement() : result;
    }

    public void setResult(String result) {
        this.result = new Element("result").addContent(result);
    }

    public void setResult(Element result) {
        this.result = new Element("result").addContent(result);
    }

    public Element toElement() {
        final Element res = new Element(name);
        res.setAttribute("success", Boolean.toString(success));
        for (String key : attributes.keySet()) {
            res.setAttribute(key, getAttribute(key));
        }

        if (result != null)
            res.addContent(result);
        else {
            res.addContent(new Element("result").addContent(logAppender.getLogs()));
        }

        return res;
    }

    protected void startLogging() {
        logAppender = new CommandLogAppender(name, getAppenderLogFilter(), getAppenderLogLayout());
        logAppender.start();
        
        ROOT_LOGGER.addAppender(logAppender);
    }

    protected void stopLogging() {
        logAppender.stop();
        
        ROOT_LOGGER.removeAppender(logAppender);
    }

    private Filter getAppenderLogFilter() {
        return ThresholdFilter.createFilter(Level.INFO, null, null);
    }

    protected Layout<String> getAppenderLogLayout() {
        return PatternLayout.newBuilder().withNoConsoleNoAnsi(true).withPattern("%d{ISO8601} %p - %m%n%throwable")
                .build();
    }

    @SuppressWarnings("serial")
    private static class CommandLogAppender extends AbstractAppender {

        private StringWriter writer;

        private String logs;

        protected CommandLogAppender(final String name, final Filter filter,
                final Layout<? extends Serializable> layout) {
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
                throw new UncheckedIOException(e);
            }
        }

        public String getLogs() {
            return logs;
        }

    }
}
