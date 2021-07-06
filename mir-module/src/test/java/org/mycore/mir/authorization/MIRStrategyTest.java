package org.mycore.mir.authorization;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.junit.Assume.assumeTrue;

import java.lang.reflect.Field;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collection;
import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mycore.access.MCRAccessManager;
import org.mycore.access.mcrimpl.MCRAccessControlSystem;
import org.mycore.backend.jpa.access.MCRJPAAccessStore;
import org.mycore.backend.jpa.access.MCRJPARuleStore;
import org.mycore.common.MCRJPATestCase;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.datamodel.classifications2.MCRCategLinkReference;
import org.mycore.datamodel.classifications2.MCRCategLinkService;
import org.mycore.datamodel.classifications2.MCRCategLinkServiceFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.common.MCRLinkTableManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.MCRCommandLineInterface;
import org.mycore.frontend.cli.MCRCommandManager;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyManager;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyUserUtils;
import org.mycore.mcr.acl.accesskey.backend.MCRAccessKey;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;

public class MIRStrategyTest extends MCRJPATestCase {

    MIRStrategy strategy;

    Path localTestDirectory;

    @Before
    public void setUp() throws Exception {
        super.setUp();
        strategy = new MIRStrategy();
        Path mirCliSrcMainPath = MCRConfiguration2.getOrThrow("app.home", Paths::get);
        final Path defaultRulesFile = mirCliSrcMainPath
            .resolve("config")
            .resolve("acl")
            .resolve("defaultrules-commands.txt");
        final URL mirAccessURL = getResourceAsURL("class/mir_access.xml");
        if ("file".equals(mirAccessURL.getProtocol())) {
            localTestDirectory = Paths.get(mirAccessURL.toURI()).getParent().getParent();
        }
        final List<String> cmds = Files.readAllLines(defaultRulesFile, StandardCharsets.UTF_8);
        cmds.add(
            "update permission read for id mods:mir_access:accessKey with rulefile ${app.home}/config/acl/grant-editors.xml described by ${acl-description.editors}");
        cmds.add(
            "update permission writedb for id mods:mir_access:accessKey with rulefile ${app.home}/config/acl/grant-editors.xml described by ${acl-description.editors}");
        cmds.add(
            "update permission read for id derivate:mir_access:accessKey with rulefile ${app.home}/config/acl/grant-editors.xml described by ${acl-description.editors}");
        cmds.add(
            "update permission writedb for id derivate:mir_access:accessKey with rulefile ${app.home}/config/acl/grant-editors.xml described by ${acl-description.editors}");
        cmds.add("load classification from url " + mirAccessURL);
        executeCommands(cmds);
    }

    private void executeCommands(List<String> cmds) throws Exception {
        if (cmds == null || cmds.isEmpty()) {
            return;
        }
        MCRCommandManager knownCommands = new MCRCommandManager();
        for (String cmd : cmds) {
            String command = MCRCommandLineInterface.expandCommand(cmd);
            if (!command.isBlank()) {
                executeCommands(knownCommands.invokeCommand(command));
            }
        }
    }

    @After
    public void tearDown() throws Exception {
        final Collection<String> allControlledIDs = MCRAccessManager.requireRulesInterface().getAllControlledIDs();
        allControlledIDs.stream()
            .peek(id -> LogManager.getLogger().debug("Removing {} rules...", id))
            .forEach(MCRAccessManager.requireRulesInterface()::removeAllRules);
        MCRJPARuleStore.getInstance().retrieveAllIDs()
            .stream()
            .peek(rule -> LogManager.getLogger().debug("Remove rule {}", rule))
            .forEach(MCRJPARuleStore.getInstance()::deleteRule);
        assertEquals(0, MCRJPAAccessStore.getInstance().getDistinctStringIDs().size());
        assertEquals(0, MCRJPARuleStore.getInstance().retrieveAllIDs().size());
        ACLResetter.resetIDTable();
        super.tearDown();
    }

    @Override
    protected Map<String, String> getTestProperties() {
        final Map<String, String> testProperties = super.getTestProperties();
        Path mirCliSrcMainPath = Paths.get("..", "mir-cli", "src", "main").toAbsolutePath().normalize();
        testProperties.putAll(Map.ofEntries(
            Map.entry("app.home", mirCliSrcMainPath.toString()),
            Map.entry("acl-description.admins", "administrators only"),
            Map.entry("acl-description.all", "always allowed"),
            Map.entry("acl-description.editors", "administrators and editors"),
            Map.entry("acl-description.guests", "guests only"),
            Map.entry("acl-description.guests-and-submitters", "guests and submitters"),
            Map.entry("acl-description.never", "never allowed"),
            Map.entry("acl-description.not-logged-in", "not logged-in"),
            Map.entry("acl-description.require-login", "require login"),
            Map.entry("acl-description.submitters", "submitters, editors and administrators")));

        return testProperties;
    }

    @Test
    public void checkGuestPermission() {
        final MCRObjectID mir_mods_00004711 = MCRObjectID.getInstance("mir_mods_00004711");
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_DELETE));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_VIEW));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_PREVIEW));
    }

    @Test
    public void checkSuperUserPermission() {
        final MCRObjectID mir_mods_00004711 = MCRObjectID.getInstance("mir_mods_00004711");
        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.getSuperUserInstance());
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_DELETE));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_VIEW));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_PREVIEW));
    }

    /**
     * Tests if a derivate is readable if accesstoken is set to the MODS object.
     *
     * @throws Exception
     */
    @Test
    public void checkAccessKeyPermission() throws Exception {
        loadTestData();
        MCRUser junitUser = new MCRUser("junit");
        MCRUser junitEditorUser = new MCRUser("junitEditor");
        junitEditorUser.assignRole("editor");
        MCRSessionMgr.getCurrentSession().setUserInformation(junitUser);
        final MCRObjectID mir_mods_00004711 = MCRObjectID.getInstance("mir_mods_00004711");
        final MCRObjectID mir_derivate_00004711 = MCRObjectID.getInstance("mir_derivate_00004711");
        MCRLinkTableManager.instance().addReferenceLink(mir_mods_00004711, mir_derivate_00004711,
            MCRLinkTableManager.ENTRY_TYPE_DERIVATE, "");
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        Assert
            .assertFalse(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));

        final MCRAccessKey accessKeyRead = new MCRAccessKey(mir_mods_00004711, "mySecret", MCRAccessManager.PERMISSION_READ);
        MCRAccessKeyManager.addAccessKey(accessKeyRead);
        final MCRAccessKey accessKeyWrite = new MCRAccessKey(mir_mods_00004711, "letMeIn", MCRAccessManager.PERMISSION_WRITE);
        MCRAccessKeyManager.addAccessKey(accessKeyWrite);

        final MCRCategLinkService categLinkService = MCRCategLinkServiceFactory.getInstance();
        MCRCategLinkReference ref = new MCRCategLinkReference(mir_mods_00004711);
        categLinkService.setLinks(ref, List.of(MCRCategoryID.fromString("mir_access:accessKey")));

        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        Assert
            .assertFalse(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_READ));

        //Give user read access-token
        MCRAccessKeyUserUtils.addAccessKey(mir_mods_00004711, accessKeyRead.getValue());
        junitUser = MCRUserManager.getUser(junitUser.getUserName());
        MCRSessionMgr.getCurrentSession().setUserInformation(junitUser);

        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        Assert
            .assertFalse(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_DELETE));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_VIEW));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_PREVIEW));

        //Give user write access-token
        MCRAccessKeyUserUtils.addAccessKey(mir_mods_00004711, accessKeyWrite.getValue());
        junitUser = MCRUserManager.getUser(junitUser.getUserName());
        MCRSessionMgr.getCurrentSession().setUserInformation(junitUser);

        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        Assert
            .assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_DELETE));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_VIEW));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_PREVIEW));
        MCRSessionMgr.getCurrentSession().setUserInformation(junitUser);
        //Check fallback to roles
        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.getGuestInstance());
        MCRSessionMgr.getCurrentSession().setUserInformation(junitEditorUser);
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        System.err.println("Foo");
        assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        Assert
            .assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_DELETE));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_VIEW));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_PREVIEW));
    }

    private void loadTestData() throws Exception {
        requireLocalTestFiles();
        //remove org.mycore.services.staticcontent.MCRStaticContentEventHandler
        MCRConfiguration2.set("MCR.EventHandler.MCRObject.025.Class", "");
        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.getSuperUserInstance());
        executeCommands(List.of(
            "load classification from file " + localTestDirectory.resolve("class").resolve("state.xml"),
            "load classification from file " + localTestDirectory.resolve("class").resolve("mcr-roles.xml"),
            "load all objects from directory " + localTestDirectory.resolve("objects"),
            "load all derivates from directory " + localTestDirectory.resolve("derivates")));
    }

    private void requireLocalTestFiles() {
        assumeTrue("Local test files not available.", localTestDirectory != null);
    }

    private static class ACLResetter {
        public static void resetIDTable() throws IllegalAccessException, NoSuchFieldException {
            final Field ruleIDTable = MCRAccessControlSystem.class.getDeclaredField("ruleIDTable");
            ruleIDTable.setAccessible(true); //package private
            ((Map) ruleIDTable.get(null)).clear();
        }
    }
}
