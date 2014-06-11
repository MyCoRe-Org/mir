package org.mycore.mir.wizard;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.jdom2.Element;

public class MIRWizardCommandChain {

    private static final Logger LOGGER = Logger.getLogger(MIRWizardCommandChain.class);

    private List<MIRWizardCommand> commands;

    private boolean haltOnError = true;

    public MIRWizardCommandChain() {
        setCommands(new ArrayList<MIRWizardCommand>());
    }

    public List<MIRWizardCommand> getCommands() {
        return commands;
    }

    protected void setCommands(List<MIRWizardCommand> commands) {
        this.commands = commands;
    }

    public void addCommand(MIRWizardCommand cmd) {
        commands.add(cmd);
    }

    public boolean isHaltOnError() {
        return haltOnError;
    }

    public void setHaltOnError(boolean haltOnError) {
        this.haltOnError = haltOnError;
    }

    public void execute(Element xml) {
        for (MIRWizardCommand cmd : commands) {
            LOGGER.info("Execute " + cmd.getClass().getSimpleName() + "...");

            cmd.execute(xml);

            if (isHaltOnError() && !cmd.getResult().isSuccess())
                break;
        }
    }
}
