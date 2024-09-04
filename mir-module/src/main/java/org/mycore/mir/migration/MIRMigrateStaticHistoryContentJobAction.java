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
