/**
 *
 */
package org.mycore.mir.it.admin;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.mycore.mir.it.MIRBaseITCase;
import org.mycore.mir.it.helper.MIRUserHelper;

/**
 * @author Thomas Scheffler (yagee)
 */
public class MIRUserITCase extends MIRBaseITCase {

    @Test
    @Ignore("currently not working")
    public final void testCreateUser() {
        goToStart();
        loginAs(ADMIN_LOGIN, ADMIN_PASSWD);
        MIRUserHelper.createUser(getDriver(), "submitter", "submitter123", "submitter");
        MIRUserHelper.createUser(getDriver(), "allgroups", "password123", "reader", "submitter", "editor", "admin");
        MIRUserHelper.deleteUser(getDriver(), "submitter");
        MIRUserHelper.deleteUser(getDriver(), "allgroups");
        logOff();
    }

}
