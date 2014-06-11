package org.mycore.mir.wizard.command;

import java.io.StringWriter;
import java.util.List;

import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.apache.log4j.WriterAppender;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.jdom2.Element;
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
    public void execute(Element xml) {
        StringWriter consoleWriter = new StringWriter();
        WriterAppender appender = new WriterAppender(new PatternLayout("%d{ISO8601} %p - %m%n"), consoleWriter);

        try {
            appender.setName("CONSOLE_APPENDER");
            appender.setThreshold(org.apache.log4j.Level.INFO);
            Logger.getRootLogger().addAppender(appender);
            
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

            this.result.setResult(consoleWriter.toString());

            Logger.getRootLogger().removeAppender(appender);
            appender.close();
            consoleWriter.close();
        } catch (Exception ex) {
            this.result.setResult(ex.getMessage());
        }
    }
}
