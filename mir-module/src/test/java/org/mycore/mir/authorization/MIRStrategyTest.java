package org.mycore.mir.authorization;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

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
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mycore.access.MCRAccessManager;
import org.mycore.access.mcrimpl.MCRAccessControlSystem;
import org.mycore.access.mcrimpl.MCRAccessStore;
import org.mycore.access.mcrimpl.MCRRuleStore;
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
import org.mycore.mcr.acl.accesskey.dto.MCRAccessKeyDto;
import org.mycore.mcr.acl.accesskey.service.MCRAccessKeyService;
import org.mycore.mcr.acl.accesskey.service.MCRAccessKeyUserService;
import org.mycore.resource.MCRResourceHelper;
import org.mycore.test.MCRJPAExtension;
import org.mycore.test.MyCoReTest;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;

@MyCoReTest
@ExtendWith(MCRJPAExtension.class)
public class MIRStrategyTest {

    MIRStrategy strategy;

    Path localTestDirectory;

    @BeforeEach
    public void setUp() throws Exception {
        setTestProperties();
        strategy = new MIRStrategy();
        Path mirCliSrcMainPath = MCRConfiguration2.getOrThrow("app.home", Paths::get);
        final Path defaultRulesFile = mirCliSrcMainPath
            .resolve("config")
            .resolve("acl")
            .resolve("defaultrules-commands.txt");
        final URL mirAccessURL =
            MCRResourceHelper.getResourceUrl(MIRStrategyTest.class.getSimpleName() + "/class/mir_access.xml");
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

    @AfterEach
    public void tearDown() throws Exception {
        final Collection<String> allControlledIDs = MCRAccessManager.requireRulesInterface().getAllControlledIDs();
        allControlledIDs.stream()
            .peek(id -> LogManager.getLogger().debug("Removing {} rules...", id))
            .forEach(MCRAccessManager.requireRulesInterface()::removeAllRules);
        MCRRuleStore.obtainInstance().retrieveAllIDs()
            .stream()
            .peek(rule -> LogManager.getLogger().debug("Remove rule {}", rule))
            .forEach(MCRRuleStore.obtainInstance()::deleteRule);
        assertEquals(0, MCRAccessStore.obtainInstance().getDistinctStringIDs().size());
        assertEquals(0, MCRRuleStore.obtainInstance().retrieveAllIDs().size());
        ACLResetter.resetIDTable();
    }

    protected void setTestProperties() {
        MCRConfiguration2.set("MCR.ACL.AccessKey.Strategy.AllowedObjectTypes", "mods,derivate");
        Path mirCliSrcMainPath = Paths.get("..", "mir-cli", "src", "main").toAbsolutePath().normalize();
        MCRConfiguration2.set("app.home", mirCliSrcMainPath.toString());
        MCRConfiguration2.set("acl-description.admins", "administrators only");
        MCRConfiguration2.set("acl-description.all", "always allowed");
        MCRConfiguration2.set("acl-description.editors", "administrators and editors");
        MCRConfiguration2.set("acl-description.guests", "guests only");
        MCRConfiguration2.set("acl-description.guests-and-submitters", "guests and submitters");
        MCRConfiguration2.set("acl-description.never", "never allowed");
        MCRConfiguration2.set("acl-description.not-logged-in", "not logged-in");
        MCRConfiguration2.set("acl-description.require-login", "require login");
        MCRConfiguration2.set("acl-description.submitters", "submitters, editors and administrators");
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
        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.SUPER_USER);
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
        MCRLinkTableManager.getInstance().addReferenceLink(mir_mods_00004711, mir_derivate_00004711,
            MCRLinkTableManager.ENTRY_TYPE_DERIVATE, "");
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        assertFalse(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));

        final MCRAccessKeyDto accessKeyRead = new MCRAccessKeyDto();
        accessKeyRead.setSecret("mySecret");
        accessKeyRead.setPermission(MCRAccessManager.PERMISSION_READ);
        accessKeyRead.setReference(mir_mods_00004711.toString());
        MCRAccessKeyService.obtainInstance().addAccessKey(accessKeyRead);

        final MCRAccessKeyDto accessKeyWrite = new MCRAccessKeyDto();
        accessKeyWrite.setSecret("letMeIn");
        accessKeyWrite.setPermission(MCRAccessManager.PERMISSION_WRITE);
        accessKeyWrite.setReference(mir_mods_00004711.toString());
        MCRAccessKeyService.obtainInstance().addAccessKey(accessKeyWrite);

        final MCRCategLinkService categLinkService = MCRCategLinkServiceFactory.obtainInstance();
        MCRCategLinkReference ref = new MCRCategLinkReference(mir_mods_00004711);
        categLinkService.setLinks(ref, List.of(MCRCategoryID.ofString("mir_access:accessKey")));

        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        assertFalse(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_READ));

        //Give user read access-token
        MCRAccessKeyUserService.obtainInstance().activateAccessKey(mir_mods_00004711.toString(), "mySecret");
        junitUser = MCRUserManager.getUser(junitUser.getUserName());
        MCRSessionMgr.getCurrentSession().setUserInformation(junitUser);

        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        assertFalse(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_DELETE));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_VIEW));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_PREVIEW));

        //Give user write access-token
        MCRAccessKeyUserService.obtainInstance().activateAccessKey(mir_mods_00004711.toString(), "letMeIn");
        junitUser = MCRUserManager.getUser(junitUser.getUserName());
        MCRSessionMgr.getCurrentSession().setUserInformation(junitUser);

        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_DELETE));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_VIEW));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_PREVIEW));
        MCRSessionMgr.getCurrentSession().setUserInformation(junitUser);
        //Check fallback to roles
        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.GUEST);
        MCRSessionMgr.getCurrentSession().setUserInformation(junitEditorUser);
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        System.err.println("Foo");
        assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_READ));
        assertTrue(strategy.checkPermission(mir_derivate_00004711.toString(), MCRAccessManager.PERMISSION_WRITE));
        assertFalse(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_DELETE));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_VIEW));
        assertTrue(strategy.checkPermission(mir_mods_00004711.toString(), MCRAccessManager.PERMISSION_PREVIEW));
    }

    private void loadTestData() throws Exception {
        requireLocalTestFiles();
        //remove org.mycore.services.staticcontent.MCRStaticContentEventHandler
        MCRConfiguration2.set("MCR.EventHandler.MCRObject.025.Class", "");
        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.SUPER_USER);
        executeCommands(List.of(
            "load classification from file " + localTestDirectory.resolve("class").resolve("state.xml"),
            "load classification from file " + localTestDirectory.resolve("class").resolve("mcr-roles.xml"),
            "load all objects from directory " + localTestDirectory.resolve("objects"),
            "load all derivates from directory " + localTestDirectory.resolve("derivates")));
    }

    private void requireLocalTestFiles() {
        Assumptions.assumeTrue(localTestDirectory != null, "Local test files not available.");
    }

    private static class ACLResetter {
        public static void resetIDTable() throws IllegalAccessException, NoSuchFieldException {
            final Field ruleIDTable = MCRAccessControlSystem.class.getDeclaredField("RULE_ID_TABLE");
            ruleIDTable.setAccessible(true); //package private
            ((Map) ruleIDTable.get(null)).clear();
        }
    }
}
