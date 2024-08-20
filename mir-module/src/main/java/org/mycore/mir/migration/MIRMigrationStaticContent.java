package org.mycore.mir.migration;

import jakarta.servlet.ServletContext;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.input.SAXBuilder;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.events.MCRStartupHandler.AutoExecutable;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.services.queuedjob.staticcontent.MCRJobStaticContentGenerator;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;

/**
 * Class converts automatically all static history content on start up.
 *
 * @author shermann (Silvio Hermann)
 * */
public class MIRMigrationStaticContent implements AutoExecutable {

    protected static final Path MIR_STATIC_HISTORY_PATH = Path.of(
        MCRConfiguration2.getString("MCR.Object.Static.Content.Default.Path").get() + File.separator + "mir-history");

    private static Logger LOGGER = LogManager.getLogger(MIRMigrationStaticContent.class);

    @Override
    public String getName() {

        return MIRMigrationStaticContent.class.getName();
    }

    @Override
    public int getPriority() {
        return 0;
    }

    @Override
    public void startUp(ServletContext servletContext) {
        try {
            SAXBuilder builder = new SAXBuilder();
            Files.walkFileTree(MIR_STATIC_HISTORY_PATH, new SimpleFileVisitor<Path>() {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                    try (InputStream is = Files.newInputStream(file)) {
                        Document history = builder.build(is);
                        if ("table".equals(history.getRootElement().getName())) {
                            String filename = file.getFileName().toString();
                            String id = filename.substring(0, filename.lastIndexOf('.'));
                            LOGGER.info("Migrating static history for object {}", id);

                            MCRJobStaticContentGenerator generator = new MCRJobStaticContentGenerator("mir-history");
                            generator.generate(MCRMetadataManager.retrieveMCRObject(MCRObjectID.getInstance(id)));
                        }
                    } catch (Exception e) {
                        LOGGER.error("Could not migrate static mcr-history for file {}", file.getFileName(), e);
                    }
                    return FileVisitResult.CONTINUE;
                }
            });
        } catch (IOException e) {
            LOGGER.error("Error occured during migration of static history content", e);
        }
    }
}
