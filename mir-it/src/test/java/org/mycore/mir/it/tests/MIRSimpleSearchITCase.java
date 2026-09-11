package org.mycore.mir.it.tests;

import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.mycore.mir.it.controller.MIRSearchController;
import org.mycore.mir.it.model.MIRInstitutes;
import org.mycore.mir.it.model.MIRSampleInstitutes;
import org.mycore.mir.it.model.MIRSearchTestDataLoader;
import org.mycore.mir.it.model.MIRSimpleSearchFormContent;
import org.openqa.selenium.By;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonParseException;

@RunWith(Parameterized.class)
public class MIRSimpleSearchITCase extends MIRITBase {

    private final MIRSimpleSearchFormContent parsed;

    private final List<String> ids;

    public MIRSimpleSearchITCase(final String jsonFile, final String idsString) throws IOException {
        this.parsed = parseJsonFile(jsonFile);
        this.ids = Arrays.asList(idsString.split(","));
    }

    @Parameterized.Parameters
    public static Collection<Object[]> input() {
        return Stream.of(new Object[] { "simpleTest1.json", "mir_mods_00010000" },
            new Object[] { "simpleTest2.json", "mir_mods_00010000" })
            .collect(Collectors.toList());
    }

    @Before
    public final void ini() throws IOException, InterruptedException {
        createSearchTestDataLoader().lazyLoadData();
    }

    @Test
    public void testForm() {
        MIRSearchController searchController = controllerFactory.createSearchController();

        if (parsed.getTitle() != null) {
            searchController.setTitle(parsed.getTitle());
        }
        if (parsed.getAuthor() != null) {
            searchController.setAuthor(parsed.getAuthor());
        }

        if (parsed.getFiles() != null) {
            searchController.setFiles(parsed.getFiles());
        }

        if (parsed.getInstitute() != null) {
            searchController.setInstitute(parsed.getInstitute());
        }

        if (parsed.getMetadata() != null) {
            searchController.setMetadata(parsed.getMetadata());
        }

        if (parsed.getStatus() != null) {
            searchController.setStatus(parsed.getStatus());
        }

        //String url = getDriver()
        //    .waitFor((webDriver) -> webDriver.getCurrentUrl().contains("receive") ? webDriver.getCurrentUrl() : null);

        List<String> foundIds = getDriver().waitAndFindElements(By.xpath(".//input[@name='id']"))
            .stream()
            .map(v -> Optional.ofNullable(v.getDomProperty("value"))
                .orElseGet(() -> v.getDomAttribute("value")))
            .collect(Collectors.toList());

        ids.forEach(id -> Assert
            .assertTrue("List should contain: " + id + " [" + foundIds.stream().collect(Collectors.joining(",")) + "]",
                foundIds.contains(id)));
    }

    /**
     * Parses the json file to {@link MIRSimpleSearchFormContent}
     * @param jsonFile
     * @return
     */

    private MIRSimpleSearchFormContent parseJsonFile(String jsonFile) throws IOException {
        try (InputStreamReader inputStreamReader = new InputStreamReader(
            getClass().getClassLoader().getResourceAsStream(jsonFile))) {
            return createGson().fromJson(inputStreamReader, MIRSimpleSearchFormContent.class);
        }

        // return null;
    }

    protected MIRInstitutes[] institutes() {
        return MIRSampleInstitutes.values();
    }

    /**
     * {@link MIRInstitutes} is an interface, which Gson cannot instantiate on its own
     */
    private Gson createGson() {
        JsonDeserializer<MIRInstitutes> instituteDeserializer = (json, type, context) -> {
            String value = json.getAsString();
            return Arrays.stream(institutes())
                .filter(institute -> value.equals(institute.getValue()))
                .findFirst()
                .orElseThrow(() -> new JsonParseException("Unknown institute '" + value + "', known institutes are: "
                    + Arrays.stream(institutes()).map(MIRInstitutes::getValue).collect(Collectors.joining(", "))));
        };
        return new GsonBuilder().registerTypeAdapter(MIRInstitutes.class, instituteDeserializer).create();
    }

    protected MIRSearchTestDataLoader createSearchTestDataLoader() {
        return new MIRSearchTestDataLoader(controllerFactory);
    }

}
