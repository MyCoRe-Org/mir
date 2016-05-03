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
public class MIRUserITCase extends MCRSeleniumTestBase {


    MIRUserController controller;

    @Before
    public final void init() {
        controller = new MIRUserController(getDriver(), getBaseUrl(System.getProperty("it.port", "8080")) + "/" + System.getProperty("it.context"));

        controller.goToStart();
        if (controller.isLoggedIn()) {
            controller.logOff();
        }
        controller.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);
    }

    @Test
    public final void testCreateSubmitter() {
        controller.createUser("submitter", "submitter123", null, null, "submitter");
        controller.deleteUser("submitter");
    }

    @Test
    public final void testCreateAdmin() {
        controller.createUser("allgroups", "password123", null, null, "reader", "submitter", "editor", "admin");
        controller.deleteUser("allgroups");
    }

    @Test
    public final void testCreateUserNameValidation() {
        controller.createUser("Submitter", "submitter123", null, null, () -> controller.assertValidationErrorVisible(), "submitter");
    }

    @Test
    public final void testCreateUserMailValidation() {
        controller.createUser("submitter", "submitter123", null, "wrongmail", () -> controller.assertValidationErrorVisible(), "submitter");
    }

}
