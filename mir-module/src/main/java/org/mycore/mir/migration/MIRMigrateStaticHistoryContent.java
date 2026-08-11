/*
 * This file is part of ***  M y C o R e  ***
 * See https://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

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
