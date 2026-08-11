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

import static org.mycore.mir.migration.MIRMigrateStaticHistoryContent.STATIC_HISTORY_PATH;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.input.SAXBuilder;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.services.queuedjob.MCRJob;
import org.mycore.services.queuedjob.MCRJobAction;
import org.mycore.services.queuedjob.staticcontent.MCRJobStaticContentGenerator;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.concurrent.ExecutionException;


/**
 * Class converts all static history content on start up automatically.
 *
 * @author shermann (Silvio Hermann)
 * */
public class MIRMigrateStaticHistoryContentJobAction extends MCRJobAction {

    private static final Logger LOGGER = LogManager.getLogger();

    public MIRMigrateStaticHistoryContentJobAction(MCRJob job) {
        super(job);
    }

    @Override
    public void execute() throws ExecutionException {
        try {
            SAXBuilder builder = new SAXBuilder();
            Files.walkFileTree(STATIC_HISTORY_PATH, new SimpleFileVisitor<>() {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs)  {
                    String filename = file.getFileName().toString();
                    String id = filename.substring(0, filename.lastIndexOf('.'));

                    if (!MCRObjectID.isValid(id)) {
                        return FileVisitResult.CONTINUE;
                    }

                    try (InputStream is = Files.newInputStream(file)) {
                        Document history = builder.build(is);
                        if ("table".equals(history.getRootElement().getName())) {
                            LOGGER.info("Migrating static history for object {}", id);
                            MCRJobStaticContentGenerator generator = new MCRJobStaticContentGenerator(
                                "mir-history");
                            generator.generate(MCRMetadataManager.retrieveMCRObject(MCRObjectID.getInstance(id)));
                        }
                    } catch (Exception e) {
                        LOGGER.error("Could not migrate static mcr-history for file {}", file.getFileName(), e);
                    }
                    return FileVisitResult.CONTINUE;
                }
            });
        } catch (IOException e) {
            LOGGER.error("Error occurred during migration of static history content", e);
        }
    }

    @Override
    public boolean isActivated() {
        return true;
    }

    @Override
    public String name() {
        return MIRMigrateStaticHistoryContent.class.getName();
    }

    @Override
    public void rollback() {
        //not implemented
    }
}
