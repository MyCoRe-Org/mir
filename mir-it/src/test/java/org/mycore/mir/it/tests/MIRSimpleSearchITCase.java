package org.mycore.mir.it.tests;

import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.mycore.mir.it.controller.MIRSearchController;
import org.mycore.mir.it.model.MIRSearchTestDataLoader;
import org.mycore.mir.it.model.MIRSimpleSearchFormContent;
import org.openqa.selenium.By;

import com.google.gson.Gson;

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
        MIRSearchTestDataLoader searchTestDataLoader = new MIRSearchTestDataLoader();
        searchTestDataLoader.lazyLoadData(getDriver());

    }

    @Test
    public void testForm() {
        MIRSearchController searchController = new MIRSearchController(getDriver(), getAPPUrlString());

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
            .map(v -> v.getAttribute("value"))
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
            Gson gson = new Gson();
            return gson.fromJson(inputStreamReader, MIRSimpleSearchFormContent.class);
        }

        // return null;
    }
}
