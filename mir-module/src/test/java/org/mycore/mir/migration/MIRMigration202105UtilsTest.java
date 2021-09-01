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

import org.junit.Test;
import org.junit.Before;
import org.mycore.common.MCRJPATestCase;
import org.mycore.common.MCRSessionMgr;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.accesskeys.MIRAccessKeyManager;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKeyPair;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyManager;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyUtils;
import org.mycore.mcr.acl.accesskey.model.MCRAccessKey;
import org.mycore.user2.MCRUser;

public class MIRMigration202105UtilsTest extends MCRJPATestCase {

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

    @Test
    public void testMigrationRead() throws Exception {
        final MIRAccessKeyPair accessKeyPair = new MIRAccessKeyPair(objectId, READ_KEY, null);
        MIRAccessKeyManager.createKeyPair(accessKeyPair);
        MIRMigration202105Utils.migrateAccessKeyPairs();
        final List<MCRAccessKey> accessKeys = MCRAccessKeyManager.getAccessKeys(objectId);
        assertTrue(accessKeys.size() == 1);
        final MCRAccessKey accessKey = accessKeys.get(0);
        assertEquals(MCRAccessKeyManager.encryptValue(READ_KEY, objectId), accessKey.getValue());
        assertEquals(PERMISSION_READ, accessKey.getType());
    }

    @Test
    public void testMigrationReadAndWrite() throws Exception {
        final MIRAccessKeyPair accessKeyPair = new MIRAccessKeyPair(objectId, READ_KEY, WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(accessKeyPair);
        MIRMigration202105Utils.migrateAccessKeyPairs();
        final List<MCRAccessKey> accessKeys = MCRAccessKeyManager.getAccessKeys(objectId);
        assertTrue(accessKeys.size() == 2);
        final MCRAccessKey accessKeyRead = accessKeys.get(0);
        assertEquals(MCRAccessKeyManager.encryptValue(READ_KEY, objectId), accessKeyRead.getValue());
        assertEquals(PERMISSION_READ, accessKeyRead.getType());
        final MCRAccessKey accessKeyWrite = accessKeys.get(1);
        assertEquals(MCRAccessKeyManager.encryptValue(WRITE_KEY, objectId), accessKeyWrite.getValue());
        assertEquals(PERMISSION_WRITE, accessKeyWrite.getType());
    }

    @Test
    public void testUserAttributeMigration() throws Exception {
        final MIRAccessKeyPair accessKeyPair = new MIRAccessKeyPair(objectId, READ_KEY, WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(accessKeyPair);
        final MCRUser user1 = new MCRUser("junit");
        MCRAccessKeyUtils.addAccessKey(user1, objectId, READ_KEY); 
        final MCRUser user2 = new MCRUser("junit");
        MCRAccessKeyUtils.addAccessKey(user2, objectId, WRITE_KEY); 
        
        MIRMigration202105Utils.migrateAccessKeyPairs();

        final String valueRead = MCRAccessKeyUtils.getAccessKeyValue(user1, objectId);
        assertNotNull(valueRead);
        assertEquals(MCRAccessKeyManager.encryptValue(READ_KEY, objectId), valueRead);

        final String valueWrite = MCRAccessKeyUtils.getAccessKeyValue(user2, objectId);
        assertNotNull(valueWrite);
        assertEquals(MCRAccessKeyManager.encryptValue(WRITE_KEY, objectId), valueWrite);
    }
}
