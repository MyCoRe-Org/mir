package org.mycore.mir.migration;

import jakarta.servlet.ServletContext;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.events.MCRStartupHandler.AutoExecutable;
import org.mycore.services.queuedjob.MCRJob;
import org.mycore.services.queuedjob.MCRJobQueue;
import org.mycore.services.queuedjob.MCRJobQueueManager;
import org.mycore.services.queuedjob.MCRJobStatus;
import org.mycore.util.concurrent.MCRTransactionableRunnable;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.List;

/**
 * Class creates {@link MCRJob} in {@link MCRJobQueue} that migrates all static history content.
 *
 * @author shermann (Silvio Hermann)
 */
public class MIRMigrateStaticHistoryContent implements AutoExecutable {

    private static final Logger LOGGER = LogManager.getLogger();

    static final Path STATIC_HISTORY_PATH = Path.of(
        MCRConfiguration2.getStringOrThrow("MCR.Object.Static.Content.Default.Path"), "mir-history");

    @Override
    public String getName() {
        return MIRMigrateStaticHistoryContent.class.getName();
    }

    @Override
    public int getPriority() {
        return Integer.MIN_VALUE;
    }

    @Override
    public void startUp(ServletContext servletContext) {
        MCRTransactionableRunnable runnable = new MCRTransactionableRunnable(() -> {
            if (Files.notExists(STATIC_HISTORY_PATH)) {
                LOGGER.info("No static content exists, nothing to do.");
            } else if (alreadyDone()) {
                LOGGER.info("Static content migration already scheduled, nothing to do.");
            } else if (!alreadyDone()) {
                MCRJobQueueManager
                    .getInstance()
                    .getJobQueue(MIRMigrateStaticHistoryContentJobAction.class)
                    .offer(new MCRJob(MIRMigrateStaticHistoryContentJobAction.class));
            }
        });
        new Thread(runnable).start();
    }

    private boolean alreadyDone() {
        return MCRJobQueueManager
            .getInstance()
            .getJobDAO()
            .getJobCount(MIRMigrateStaticHistoryContentJobAction.class, Collections.emptyMap(),
                List.of(MCRJobStatus.FINISHED)) > 0;
    }

}
