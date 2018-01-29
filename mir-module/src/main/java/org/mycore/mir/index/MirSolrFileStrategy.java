package org.mycore.mir.index;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Arrays;
import java.util.List;
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

    private final static List<String> IGNORE_XML_ROOT_LOCAL_NAMES = Arrays.asList("alto", "mets");

    @Override
    public boolean check(Path file, BasicFileAttributes attrs) {
        return super.check(file, attrs) && notAltoOrMets(file);
    }

    private static boolean notAltoOrMets(Path file) {
        String mimeType = MCRXMLFunctions.getMimeType(file.getFileName().toString());
        return !XML_MIME_TYPES.contains(mimeType)
            || !getLocalRootName(file).map(IGNORE_XML_ROOT_LOCAL_NAMES::contains).orElse(false);
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
