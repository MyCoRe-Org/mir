package org.mycore.mir.it.tests;

import java.io.Closeable;
import java.io.IOException;
import java.time.Clock;
import java.time.Duration;

import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.HttpJdkSolrClient;
import org.apache.solr.client.solrj.request.LukeRequest;
import org.apache.solr.client.solrj.request.QueryRequest;
import org.apache.solr.client.solrj.response.LukeResponse;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.mycore.common.MCRException;
import org.mycore.common.selenium.MCRSeleniumTestBase;
import org.mycore.common.selenium.drivers.MCRWebdriverWrapper;
import org.mycore.mir.it.controller.MIRModsEditorController;
import org.mycore.mir.it.controller.MIRPublishEditorController;
import org.mycore.mir.it.controller.MIRUserController;
import org.openqa.selenium.support.ui.FluentWait;
import org.openqa.selenium.support.ui.Sleeper;

public class MIRITBase extends MCRSeleniumTestBase {
    MIRUserController userController;

    MIRPublishEditorController publishEditorController;

    MIRModsEditorController editorController;

    private static final String SOLR_USER = "admin";

    private static final String SOLR_PASSWD = "alleswirdgut";

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
        SOLR_CLIENT = new HttpJdkSolrClient.Builder(baseSolrUrl)
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
        request.setBasicAuthCredentials(SOLR_USER, SOLR_PASSWD);
        request.setNumTerms(0);
        request.setShowSchema(false);
        final LukeResponse lukeResponse = request.process(SOLR_CLIENT, core.getCoreName());
        return lukeResponse;
    }

    protected static long getSolrIndexVersion(Core core) throws IOException, SolrServerException {
        final LukeResponse lukeResponseBefore = getLukeResponse(core);
        return (Long) lukeResponseBefore.getIndexInfo().get("version");
    }

    /**
     * Waits until at least <code>expectedCount</code> documents match <code>query</code> in the given core. Use
     * this whenever a test has to see the result of an asynchronous index update.
     */
    protected static void waitForDocuments(Core core, String query, long expectedCount) {
        SolrWait wait = new SolrWait(core, 180, 250);
        final long start = System.currentTimeMillis();
        wait.until(solrCore -> {
            SolrQuery solrQuery = new SolrQuery(query);
            solrQuery.setRows(0);
            QueryRequest request = new QueryRequest(solrQuery);
            request.setBasicAuthCredentials(SOLR_USER, SOLR_PASSWD);
            try {
                QueryResponse response = request.process(SOLR_CLIENT, solrCore.getCoreName());
                return response.getResults().getNumFound() >= expectedCount;
            } catch (IOException | SolrServerException e) {
                System.err.println(e.getMessage());
                return false;
            }
        });
        System.err.println("Waited " + (System.currentTimeMillis() - start) + "ms for '" + query + "'.");
    }

    /**
     * Waits until a window other than <code>mainWindowHandle</code> is open and returns its handle. Used to pick up
     * the WebCLI window, which is opened by the application in a new window.
     */
    public static String waitForAdditionalWindow(MCRWebdriverWrapper driver, String mainWindowHandle) {
        return driver.waitFor(() -> driver.getWindowHandles()
            .stream()
            .filter(handle -> !handle.equals(mainWindowHandle))
            .findFirst()
            .orElse(null));
    }

    /**
     * Package independent shortcut for {@link #waitForDocuments(Core, String, long)} on the main core.
     */
    public static void waitForMainIndexDocuments(String query, long expectedCount) {
        waitForDocuments(Core.main, query, expectedCount);
    }

    protected static void waitForIndexVersionChange(Core core, long beforeVersion) {
        SolrWait wait = new SolrWait(core, 180, 250);
        final long start = System.currentTimeMillis();
        wait.until(solrCore -> {
            try {
                return getSolrIndexVersion(solrCore) != beforeVersion;
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

    private static class SolrWait extends FluentWait<Core> {

        private final Core core;

        public SolrWait(Core input, Clock clock, Sleeper sleeper) {
            super(input, clock, sleeper);
            this.core = input;
        }

        public SolrWait(Core core, long timeOutInSeconds, long sleepInMillis) {
            this(core, Clock.systemDefaultZone(), Sleeper.SYSTEM_SLEEPER);
            withTimeout(Duration.ofSeconds(timeOutInSeconds));
            pollingEvery(Duration.ofMillis(sleepInMillis));
        }

        @Override
        protected RuntimeException timeoutException(String message, Throwable lastException) {
            return new MCRException("Error while waiting for condition on Solr core: " + core.getCoreName(),
                lastException);
        }
    }
}
