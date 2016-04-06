package org.mycore.mir.sass;


import io.bit3.jsass.importer.Import;
import io.bit3.jsass.importer.Importer;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.servlet.ServletContext;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.core.util.IOUtils;

/**
 * Imports scss files using {@link ServletContext}.
 */
public class MIRServletContextResourceImporter implements Importer {

    private static final Logger LOGGER = LogManager.getLogger();
    private final ServletContext context;

    public MIRServletContextResourceImporter(ServletContext context) {
        this.context = context;
    }

    @Override
    public Collection<Import> apply(String url, Import previous) {
        try {
            String absolute = url;
            if (previous != null) {
                absolute = previous.getAbsoluteUri().resolve(absolute).toString();
            }

            URL resource = null;
            List<String> possibleNameForms = getPossibleNameForms(absolute);
            int i = 0;
            while (i < possibleNameForms.size() && (resource = context.getResource(normalize(possibleNameForms.get(i)))) == null) {
                i++;
            }
            if (resource == null) {
                return null;
            }

            String contents = getStringContent(possibleNameForms.get(i));
            URI absoluteUri = resource.toURI();

            LOGGER.debug("Resolved " + url + " to " + absoluteUri.toString());
            return Stream.of(new Import(absolute, absolute, contents)).collect(Collectors.toList());
        } catch (IOException | URISyntaxException e) {
            LOGGER.error("Error while resolving " + url, e);
            return null;
        }
    }

    private List<String> getPossibleNameForms(String relative) {
        ArrayList<String> nameFormArray = new ArrayList<>();

        int lastSlashPos = relative.lastIndexOf('/');
        if (lastSlashPos != -1) {
            String _Form = relative.substring(0, lastSlashPos) + "/_" + relative.substring(lastSlashPos + 1);
            nameFormArray.add(_Form);
            nameFormArray.add(_Form + ".scss");
        }

        nameFormArray.add(relative);
        nameFormArray.add(relative + ".scss");

        return nameFormArray;
    }

    private String getStringContent(String resource) throws IOException {
        try (InputStream resourceAsStream = context.getResourceAsStream(normalize(resource))) {
            InputStreamReader inputStreamReader = new InputStreamReader(resourceAsStream);
            return IOUtils.toString(inputStreamReader);
        }
    }

    private String normalize(String resource) {
        return !resource.startsWith("/") ? "/" + resource : resource;
    }
}
