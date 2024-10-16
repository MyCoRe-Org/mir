/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * This program is free software; you can use it, redistribute it
 * and / or modify it under the terms of the GNU General Public License
 * (GPL) as published by the Free Software Foundation; either version 2
 * of the License or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program, in a file called gpl.txt or license.txt.
 * If not, write to the Free Software Foundation Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 */

package org.mycore.mir.migration;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.mycore.access.MCRAccessManager.PERMISSION_READ;
import static org.mycore.access.MCRAccessManager.PERMISSION_WRITE;

import java.util.List;
import java.util.Map;

import org.junit.Before;
import org.junit.Test;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.common.MCRJPATestCase;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyManager;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyUtils;
import org.mycore.mcr.acl.accesskey.model.MCRAccessKey;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKey;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKeyPair;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;

public class MIRMigration202106UtilsTest extends MCRJPATestCase {

    private static final String OBJECT_ID = "mcr_test_00000001";

    private static final String READ_KEY = "blah";

    private static final String WRITE_KEY = "blub";

    private static MCRObjectID objectId;

    @Override
    @Before
    public void setUp() throws Exception {
        super.setUp();
        objectId = MCRObjectID.getInstance(OBJECT_ID);
    }

    @Override
    protected Map<String, String> getTestProperties() {
        Map<String, String> testProperties = super.getTestProperties();
        testProperties.put("MCR.Metadata.Type.test", Boolean.TRUE.toString());
        return testProperties;
    }

    @Deprecated
    @Test
    public void testMigrationAccessKeyPair() throws Exception {
        final MIRAccessKeyPair accessKeyPair = new MIRAccessKeyPair(objectId, READ_KEY, WRITE_KEY);
        MCREntityManagerProvider.getCurrentEntityManager().persist(accessKeyPair);

        MIRMigration202106Utils.migrateAccessKeyPairs();

        final List<MCRAccessKey> accessKeys = MCRAccessKeyManager.listAccessKeys(objectId);
        assertTrue(accessKeys.size() == 2);
        final MCRAccessKey accessKeyRead = accessKeys.getFirst();
        assertEquals(MCRAccessKeyManager.hashSecret(READ_KEY, objectId), accessKeyRead.getSecret());
        assertEquals(PERMISSION_READ, accessKeyRead.getType());
        final MCRAccessKey accessKeyWrite = accessKeys.get(1);
        assertEquals(MCRAccessKeyManager.hashSecret(WRITE_KEY, objectId), accessKeyWrite.getSecret());
        assertEquals(PERMISSION_WRITE, accessKeyWrite.getType());
    }

    @Deprecated
    @Test
    public void testMigrateMIRAccessKey() throws Exception {
        final MIRAccessKey mirAccessKey = new MIRAccessKey(READ_KEY, PERMISSION_READ);
        mirAccessKey.setObjectId(objectId);
        MCREntityManagerProvider.getCurrentEntityManager().persist(mirAccessKey);

        MIRMigration202106Utils.migrateAccessKeys();

        final MCRAccessKey accessKey = MCRAccessKeyManager.getAccessKeyWithSecret(objectId,
            MCRAccessKeyManager.hashSecret(READ_KEY, objectId));
        assertNotNull(mirAccessKey);
        assertEquals(MCRAccessKeyManager.hashSecret(READ_KEY, objectId), accessKey.getSecret());
        assertEquals(PERMISSION_READ, accessKey.getType());
        assertNotNull(accessKey.getComment());
        assertTrue(accessKey.getComment().contains(READ_KEY));
        assertNotNull(accessKey.getCreated());
        assertNotNull(accessKey.getLastModified());
        assertTrue(accessKey.getIsActive());
    }

    @Deprecated
    @Test
    public void testUserAttributeMigration() throws Exception {
        final MCRUser user1 = new MCRUser("junit");
        user1.setUserAttribute(MIRMigration202106Utils.ACCESS_KEY_PREFIX + objectId, READ_KEY);
        MCRUserManager.updateUser(user1);

        MIRMigration202106Utils.migrateAccessKeyUserAttributes();

        final String valueRead = MCRAccessKeyUtils.getAccessKeySecret(user1, objectId);
        assertNotNull(valueRead);
        assertEquals(MCRAccessKeyManager.hashSecret(READ_KEY, objectId), valueRead);
    }
}
