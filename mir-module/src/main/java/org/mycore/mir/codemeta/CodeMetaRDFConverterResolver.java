package org.mycore.mir.codemeta;

import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.eclipse.rdf4j.model.Model;
import org.eclipse.rdf4j.model.impl.LinkedHashModel;
import org.eclipse.rdf4j.rio.Rio;
import org.eclipse.rdf4j.rio.helpers.JSONLDSettings;
import org.eclipse.rdf4j.rio.helpers.StatementCollector;
import org.eclipse.rdf4j.rio.jsonld.JSONLDParser;
import org.eclipse.rdf4j.rio.rdfxml.RDFXMLWriter;
import org.jdom2.Document;
import org.jdom2.input.SAXBuilder;
import org.jdom2.transform.JDOMSource;

import com.github.jsonldjava.core.DocumentLoader;

public class CodeMetaRDFConverterResolver implements URIResolver {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String CODEMETA_JSONLD_PATH = "/jsonld/codemeta.jsonld";

    private static final String CODEMETA_JSONLD_URL = "https://doi.org/10.5063/schema/codemeta-2.0";

    /**
     * Converts CodeMeta jsonld to rdf
     *
     * Syntax: <code>codemeta2rdf:{baseURI}:{json}</code>
     * 
     * @param href URI in the syntax above
     * @param base not used
     * 
     * @return document contains the converted rdf
     * @see javax.xml.transform.URIResolver
     */
    @Override
    public Source resolve(String href, String base) throws TransformerException {
        final String[] hrefParts = href.split(":", 3);
        if (hrefParts.length > 2) {
            final String baseURI = hrefParts[1];
            final String json = hrefParts[2];
            try (InputStream input = new ByteArrayInputStream(json.getBytes(StandardCharsets.UTF_8));
                ByteArrayOutputStream out = new ByteArrayOutputStream()) {
                final String codemetaJsonld = IOUtils.resourceToString(CODEMETA_JSONLD_PATH, StandardCharsets.UTF_8);
                final DocumentLoader docLoader = new DocumentLoader();
                docLoader.addInjectedDoc(CODEMETA_JSONLD_URL, codemetaJsonld);
                final JSONLDParser parser = new JSONLDParser();
                parser.getParserConfig().set(JSONLDSettings.DOCUMENT_LOADER, docLoader);
                final Model model = new LinkedHashModel();
                parser.setRDFHandler(new StatementCollector(model));
                if (baseURI.isEmpty()) {
                    parser.parse(input, null);
                } else {
                    parser.parse(input, baseURI);
                }
                final RDFXMLWriter writer = new RDFXMLWriter(out);
                Rio.write(model, writer);
                final Document result = new SAXBuilder().build(new ByteArrayInputStream(out.toByteArray()));
                return new JDOMSource(result);
            } catch (Exception e) {
                LOGGER.error("Unable to convert to rdf", e);
            }
        }
        throw new IllegalArgumentException("Invalid format of uri for retrieval of json2rdf: " + href);
    }
}
