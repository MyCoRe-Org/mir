package org.mycore.mir.it.tests;

import java.io.Closeable;
import java.io.IOException;

import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.HttpSolrClient;
import org.apache.solr.client.solrj.request.LukeRequest;
import org.apache.solr.client.solrj.response.LukeResponse;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.mycore.common.selenium.MCRSeleniumTestBase;
import org.mycore.mir.it.controller.MIRModsEditorController;
import org.mycore.mir.it.controller.MIRPublishEditorController;
import org.mycore.mir.it.controller.MIRUserController;
import org.openqa.selenium.support.ui.WebDriverWait;

public class MIRITBase extends MCRSeleniumTestBase {
    MIRUserController userController;

    MIRPublishEditorController publishEditorController;

    MIRModsEditorController editorController;

    private static SolrClient SOLR_CLIENT;

    protected static enum Core {
        main("mir"), classifications("mir-classifications");

        private final String coreName;

        Core(String name) {
            this.coreName = name;
        }

        String getCoreName() {
            return coreName;
        }
    }

    @BeforeClass
    public static void setupSolr() {
        int solrPort = Integer.parseInt(System.getProperty("solr.port"));
        final String baseSolrUrl = String.format("http://localhost:%d/solr/", solrPort);
        SOLR_CLIENT = new HttpSolrClient.Builder()
            .withBaseSolrUrl(baseSolrUrl)
            .build();
    }

    @AfterClass
    public static void closeSolrClient() throws IOException {
        if (SOLR_CLIENT instanceof Closeable) {
            SOLR_CLIENT.close();
        }
        SOLR_CLIENT = null;
    }

    protected SolrClient getSolrClient() {
        return SOLR_CLIENT;
    }

    protected static LukeResponse getLukeResponse(Core core) throws IOException, SolrServerException {
        LukeRequest request = new LukeRequest();
        request.setNumTerms(0);
        request.setShowSchema(false);
        final LukeResponse lukeResponse = request.process(SOLR_CLIENT, core.getCoreName());
        return lukeResponse;
    }

    protected int getSolrNumDocs(Core core) throws IOException, SolrServerException {
        final LukeResponse lukeResponseBefore = getLukeResponse(core);
        return lukeResponseBefore.getNumDocs();
    }

    protected static void waitForNumDocChange(Core core, int beforeNumDocs) {
        WebDriverWait wait = new WebDriverWait(driver, 30, 250);
        final long start = System.currentTimeMillis();
        wait.until(driver -> {
            try {
                return getLukeResponse(core).getNumDocs() != beforeNumDocs;
            } catch (IOException | SolrServerException e) {
                System.err.println(e.getMessage());
                return false;
            }
        });
        System.err.println("Waited " + (System.currentTimeMillis() - start) + "ms for index change.");
    }

    protected void assertBaseValidation() {
        Assert.assertTrue("Title validation message should be visible!",
            this.editorController.isTitleValidationMessageVisible());
        Assert.assertTrue("Rights validation message should be visible!",
            this.editorController.isRightsValidationMessageVisible());
        Assert.assertTrue("Classification validation message should be visible!",
            this.editorController.isClassificationValidationMessageVisible());
    }
    
    protected void assertAdminValidation() {
        Assert.assertTrue("Rights validation message should be visible!",
            this.editorController.isRightsValidationMessageVisible());
        Assert.assertTrue("Classification validation message should be visible!",
            this.editorController.isClassificationValidationMessageVisible());
    }

    public static String getAPPUrlString() {
        return getBaseUrl(System.getProperty("it.port", "8080")) + "/" + System.getProperty("it.context");
    }

    @After
    public void tearDown() {
        takeScreenshot();
    }
}
