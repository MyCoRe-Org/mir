package org.mycore.mir.index;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.logging.log4j.LogManager;
import org.mycore.common.xml.MCRXMLFunctions;
import org.mycore.solr.index.strategy.MCRSolrMimeTypeStrategy;
import org.xml.sax.Attributes;
import org.xml.sax.helpers.DefaultHandler;

public class MirSolrFileStrategy extends MCRSolrMimeTypeStrategy {
    private final static List<String> XML_MIME_TYPES = Arrays.asList("application/xml", "text/xml");

    public static final String ALTO_ROOT = "alto";

    @Override
    public boolean check(Path file, BasicFileAttributes attrs) {
        String mimeType = MCRXMLFunctions.getMimeType(file.getFileName().toString());

        if (XML_MIME_TYPES.contains(mimeType)) {
            final String localRootName = getLocalRootName(file).orElse(null);
            return !Objects.equals(localRootName, ALTO_ROOT);
        }

        return super.check(file, attrs);
    }

    private static Optional<String> getLocalRootName(Path path) {
        SAXParserFactory factory = SAXParserFactory.newInstance();
        factory.setNamespaceAware(true);
        try {
            SAXParser saxParser = factory.newSAXParser();
            ProbeXMLHandler handler = new ProbeXMLHandler();
            try (InputStream is = Files.newInputStream(path)) {
                saxParser.parse(is, handler);
            }
        } catch (ProbeXMLException probeExc) {
            return Optional.of(probeExc.rootName);
        } catch (Exception exc) {
            LogManager.getLogger().warn("unable to probe root node of  " + path);
        }
        return Optional.empty();
    }

    private static class ProbeXMLHandler extends DefaultHandler {

        @Override
        public void startElement(String uri, String localName, String qName, Attributes attributes) {
            throw new ProbeXMLException(localName);
        }

    }

    private static class ProbeXMLException extends RuntimeException {

        private String rootName;

        private ProbeXMLException(String rootName) {
            this.rootName = rootName;
        }

    }
}
