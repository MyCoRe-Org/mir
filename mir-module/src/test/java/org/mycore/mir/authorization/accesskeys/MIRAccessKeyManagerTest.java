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

package org.mycore.mir.authorization.accesskeys;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mycore.access.MCRAccessManager.PERMISSION_READ;
import static org.mycore.access.MCRAccessManager.PERMISSION_WRITE;

import java.util.Map;

import javax.persistence.EntityManager;

import org.junit.Test;
import org.junit.Before;
import org.mycore.backend.jpa.MCREntityManagerProvider;
import org.mycore.common.MCRException;
import org.mycore.common.MCRJPATestCase;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mcr.acl.accesskey.MCRAccessKeyManager;
import org.mycore.mcr.acl.accesskey.model.MCRAccessKey;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKeyPair;

public class MIRAccessKeyManagerTest extends MCRJPATestCase {

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
    public void testKeyPairFull() {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(objectId, READ_KEY, WRITE_KEY);

        assertEquals(OBJECT_ID, accKP.getMCRObjectId().toString());
        assertEquals(READ_KEY, accKP.getReadKey());
        assertEquals(WRITE_KEY, accKP.getWriteKey());
    }

    @Test
    public void testKeyPairWithoutWriteKey() {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(objectId, READ_KEY, null);

        assertEquals(OBJECT_ID, accKP.getMCRObjectId().toString());
        assertEquals(READ_KEY, accKP.getReadKey());
        assertNull(accKP.getWriteKey());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testKeyPairWithoutReadKey() {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(objectId, null, WRITE_KEY);

        assertNull(accKP);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testKeyPairWithMatchingKeys() {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(objectId, WRITE_KEY, WRITE_KEY);

        assertNull(accKP);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testCreateSameKeyPair() {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(objectId, WRITE_KEY, WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(accKP);

        final MIRAccessKeyPair sameAccKP = new MIRAccessKeyPair(objectId, WRITE_KEY, WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(sameAccKP);
    }


    @Test
    public void testGetKeyPair() {
        final MCRAccessKey accessKeyRead = new MCRAccessKey(READ_KEY, PERMISSION_READ);
        final MCRAccessKey accessKeyWrite = new MCRAccessKey(WRITE_KEY, PERMISSION_WRITE);
        MCRAccessKeyManager.createAccessKey(objectId, accessKeyRead);
        MCRAccessKeyManager.createAccessKey(objectId, accessKeyWrite);

        final MIRAccessKeyPair pair = MIRAccessKeyManager.getKeyPair(objectId);
        assertNotNull(pair);
        assertEquals(MCRAccessKeyManager.hashSecret(READ_KEY, objectId), pair.getReadKey());
        assertEquals(MCRAccessKeyManager.hashSecret(WRITE_KEY, objectId), pair.getWriteKey());
    }

    @Test
    public void testCreatePair() {
        MIRAccessKeyPair pair = new MIRAccessKeyPair(objectId, READ_KEY, WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(pair);

        pair = MIRAccessKeyManager.getKeyPair(objectId);
        assertNotNull(pair);
        assertEquals(MCRAccessKeyManager.hashSecret(READ_KEY, objectId), pair.getReadKey());
        assertEquals(MCRAccessKeyManager.hashSecret(WRITE_KEY, objectId), pair.getWriteKey());
    }

    @Test
    public void testCreateWithUpdateKeyPair() {
        MIRAccessKeyPair pair = new MIRAccessKeyPair(objectId, READ_KEY, WRITE_KEY);
        MIRAccessKeyManager.updateKeyPair(pair);

        pair = MIRAccessKeyManager.getKeyPair(objectId);
        assertNotNull(pair);
        assertEquals(MCRAccessKeyManager.hashSecret(READ_KEY, objectId), pair.getReadKey());
        assertEquals(MCRAccessKeyManager.hashSecret(WRITE_KEY, objectId), pair.getWriteKey());
    }

    @Test
    public void testExistsKeyPair() {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(objectId, READ_KEY, WRITE_KEY);
        assertFalse(MIRAccessKeyManager.existsKeyPair(objectId));
        MIRAccessKeyManager.createKeyPair(accKP);
        assertTrue(MIRAccessKeyManager.existsKeyPair(objectId));
    }

    @Test
    public void testUpdateKeyPair() {
        MIRAccessKeyPair pair = new MIRAccessKeyPair(objectId, READ_KEY, WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(pair);

        pair = new MIRAccessKeyPair(objectId, READ_KEY, "");
        MIRAccessKeyManager.updateKeyPair(pair);
        pair = MIRAccessKeyManager.getKeyPair(objectId);
        assertNotNull(pair);
        assertEquals(MCRAccessKeyManager.hashSecret(READ_KEY, objectId), pair.getReadKey());
        assertNull(pair.getWriteKey());

        pair = new MIRAccessKeyPair(objectId, READ_KEY, WRITE_KEY);
        MIRAccessKeyManager.updateKeyPair(pair);
        pair = MIRAccessKeyManager.getKeyPair(objectId);
        assertEquals(MCRAccessKeyManager.hashSecret(READ_KEY, objectId), pair.getReadKey());
        assertEquals(MCRAccessKeyManager.hashSecret(WRITE_KEY, objectId), pair.getWriteKey());
    }

    @Test
    public void testDeleteKeyPair() {
        MIRAccessKeyPair pair = new MIRAccessKeyPair(objectId, READ_KEY, WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(pair);

        MIRAccessKeyManager.deleteKeyPair(pair);

        assertFalse(MIRAccessKeyManager.existsKeyPair(objectId));
    }
}
