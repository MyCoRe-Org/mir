package org.mycore.mir.migration;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.input.SAXBuilder;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.services.queuedjob.MCRJob;
import org.mycore.services.queuedjob.MCRJobAction;
import org.mycore.services.queuedjob.staticcontent.MCRJobStaticContentGenerator;

import java.io.File;
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
    private Path staticHistoryPath;
    private Logger logger;

    public MIRMigrateStaticHistoryContentJobAction(MCRJob job) {
        super(job);
        logger = LogManager.getLogger(MIRMigrateStaticHistoryContentJobAction.class);

        staticHistoryPath = Path.of(
            MCRConfiguration2.getStringOrThrow("MCR.Object.Static.Content.Default.Path") + File.separator
                + "mir-history");
    }

    @Override
    public void execute() throws ExecutionException {
        try {
            SAXBuilder builder = new SAXBuilder();
            Files.walkFileTree(staticHistoryPath, new SimpleFileVisitor<Path>() {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                    String filename = file.getFileName().toString();
                    String id = filename.substring(0, filename.lastIndexOf('.'));

                    if (!MCRObjectID.isValid(id)) {
                        return FileVisitResult.CONTINUE;
                    }

                    try (InputStream is = Files.newInputStream(file)) {
                        Document history = builder.build(is);
                        if ("table".equals(history.getRootElement().getName())) {
                            logger.info("Migrating static history for object {}", id);
                            MCRJobStaticContentGenerator generator = new MCRJobStaticContentGenerator(
                                "mir-history");
                            generator.generate(MCRMetadataManager.retrieveMCRObject(MCRObjectID.getInstance(id)));
                        }
                    } catch (Exception e) {
                        logger.error("Could not migrate static mcr-history for file {}", file.getFileName(), e);
                    }
                    return FileVisitResult.CONTINUE;
                }
            });
        } catch (IOException e) {
            logger.error("Error occurred during migration of static history content", e);
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
