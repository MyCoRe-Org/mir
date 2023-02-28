/**
 *
 */
package org.mycore.mir.it.tests;

import org.junit.Before;
import org.junit.Test;
import org.mycore.common.selenium.MCRSeleniumTestBase;
import org.mycore.mir.it.controller.MIRUserController;

/**
 * @author Thomas Scheffler (yagee)
 */
public class MIRUserITCase extends MIRITBase {


    @Before
    public final void init() {
        String appURL = getAPPUrlString();
        userController = new MIRUserController(getDriver(), appURL);

        userController.goToStart();
        if (userController.isLoggedIn()) {
            userController.logOff();
        }
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
    }

    @Test
    public final void testCreateSubmitter() {
        userController.createUser("submitter", "subm1tter123", null, null, "submitter");
        userController.deleteUser("submitter");
    }

    @Test
    public final void testCreateSubmitterValidationPasswordInName() {
        userController.createUser("submitter", "submitter123", null, null, ()-> userController.assertValidationErrorVisible(),"submitter");
    }

    @Test
    public final void testCreateAdmin() {
        userController.createUser("allgroups", "password123", null, null, "reader", "submitter", "editor", "admin");
        userController.deleteUser("allgroups");
    }

    @Test
    public final void testCreateUserNameValidation() {
        userController.createUser("Submitter", "submitter123", null, null, () -> userController.assertValidationErrorVisible(),
            "submitter");
    }

    @Test
    public final void testCreateUserMailValidation() {
        userController.createUser("submitter", "submitter123", null, "wrongmail",
            () -> userController.assertValidationErrorVisible(), "submitter");
    }

}
