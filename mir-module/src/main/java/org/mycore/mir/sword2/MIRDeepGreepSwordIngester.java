package org.mycore.mir.sword2;

import java.io.IOException;
import java.io.InputStream;
import java.nio.channels.SeekableByteChannel;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import javax.naming.OperationNotSupportedException;

import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ZipFile;
import org.mycore.common.function.MCRThrowFunction;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.sword.MCRSwordUtil;
import org.mycore.sword.application.MCRSwordIngester;
import org.mycore.sword.application.MCRSwordLifecycleConfiguration;
import org.swordapp.server.Deposit;
import org.swordapp.server.SwordError;
import org.swordapp.server.SwordServerException;

public class MIRDeepGreepSwordIngester implements MCRSwordIngester {
    @Override
    public MCRObjectID ingestMetadata(Deposit deposit) throws SwordError, SwordServerException {
        throw new SwordServerException(new OperationNotSupportedException());
    }

    @Override
    public MCRObjectID ingestMetadataResources(Deposit deposit) throws SwordError, SwordServerException {
        // this is the only then which will be called by DG
        try {
            final Path dgZip = MCRSwordUtil
                .createTempFileFromStream("dgZip", deposit.getInputStream(), deposit.getMd5());

            try (SeekableByteChannel sbc = Files.newByteChannel(dgZip)) {
                final ZipFile zipFile = new ZipFile(sbc);
                final List<ZipArchiveEntry> entriesInPhysicalOrder = Collections
                    .list(zipFile.getEntriesInPhysicalOrder());
                final Optional<ZipArchiveEntry> metadataEntryOpt = entriesInPhysicalOrder.stream()
                    .filter(e -> e.getName().endsWith(".xml")).findFirst();
                final Optional<ZipArchiveEntry> pdfEntryOpt = entriesInPhysicalOrder.stream()
                    .filter(e -> e.getName().endsWith(".pdf")).findFirst();

                if (metadataEntryOpt.isEmpty()) {
                    throw new SwordServerException("No Metadata File Found!");
                }

                if (pdfEntryOpt.isEmpty()) {
                    throw new SwordServerException("No PDF File Found!");
                }

                final ZipArchiveEntry metadataEntry = metadataEntryOpt.get();
                final ZipArchiveEntry pdfEntry = pdfEntryOpt.get();

                final MCRThrowFunction<ZipArchiveEntry, InputStream, IOException> getIS = zipFile::getInputStream;
                try (InputStream metadataIS = getIS.apply(metadataEntry); InputStream pdfIS = getIS.apply(pdfEntry)) {

                    return null;
                }
            } catch (IOException e) {
                throw new SwordServerException("Error while processing ZIP: " + dgZip.toAbsolutePath().toString(), e);
            }
        } catch (IOException e) {
            throw new SwordServerException("Error while saving ZIP.", e);
        }
    }

    @Override
    public void ingestResource(MCRObject mcrObject, Deposit deposit) throws SwordError, SwordServerException {
        throw new SwordServerException(new OperationNotSupportedException());
    }

    @Override
    public void updateMetadata(MCRObject mcrObject, Deposit deposit, boolean b)
        throws SwordError, SwordServerException {
        throw new SwordServerException(new OperationNotSupportedException());
    }

    @Override
    public void updateMetadataResources(MCRObject mcrObject, Deposit deposit)
        throws SwordError, SwordServerException {
        throw new SwordServerException(new OperationNotSupportedException());
    }

    @Override
    public void init(MCRSwordLifecycleConfiguration mcrSwordLifecycleConfiguration) {

    }

    @Override
    public void destroy() {

    }
}
