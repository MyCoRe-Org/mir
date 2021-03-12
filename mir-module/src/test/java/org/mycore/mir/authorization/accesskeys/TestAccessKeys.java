/*
 * $Id$ 
 * $Revision$ $Date$
 *
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
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Map;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.mycore.access.MCRAccessException;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.MCRException;
import org.mycore.common.MCRJPATestCase;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKey;
import org.mycore.mir.authorization.accesskeys.exceptions.MIRAccessKeyException;
import org.mycore.user2.MCRTransientUser;
import org.mycore.user2.MCRUser;
import org.xml.sax.SAXParseException;

public class TestAccessKeys extends MCRJPATestCase {

    private static final String MCR_OBJECT_ID = "mir_test_00000001";

    private static final String KEY = "blah";

    private static final String READ = MCRAccessManager.PERMISSION_READ;

    private static final String WRITE = MCRAccessManager.PERMISSION_WRITE;

    @Rule
    public TemporaryFolder folder = new TemporaryFolder();

    @Before()
    public void setUp() throws Exception {
        super.setUp();
        MCRConfiguration2.set("MCR.datadir", folder.newFolder("data").getAbsolutePath());
    }

    @Override
    protected Map<String, String> getTestProperties() {
        Map<String, String> testProperties = super.getTestProperties();
        testProperties.put("MCR.Metadata.Type.test", Boolean.TRUE.toString());
        return testProperties;
    }

    @Test(expected = MIRAccessKeyException.class)
    public void testAddKeyWithoutValue() {
        final MCRObjectID objectId = MCRObjectID.getInstance(MCR_OBJECT_ID);
        final MIRAccessKey accessKey = new MIRAccessKey(objectId, null, READ);
        MIRAccessKeyManager.addAccessKey(accessKey);
    }

    @Test(expected = MIRAccessKeyException.class)
    public void testAddKeyWithEmptyValue() {
        final MCRObjectID objectId = MCRObjectID.getInstance(MCR_OBJECT_ID);
        final MIRAccessKey accessKey = new MIRAccessKey(objectId, "", READ);
        MIRAccessKeyManager.addAccessKey(accessKey);
    }

    @Test(expected = MIRAccessKeyException.class)
    public void testAddKeyWithoutType() {
        final MCRObjectID objectId = MCRObjectID.getInstance(MCR_OBJECT_ID);
        final MIRAccessKey accessKey = new MIRAccessKey(objectId, KEY, null);
        MIRAccessKeyManager.addAccessKey(accessKey);
    }

    @Test(expected = MIRAccessKeyException.class)
    public void testAddKeyWithWrongType() {
        final MCRObjectID objectId = MCRObjectID.getInstance(MCR_OBJECT_ID);
        final MIRAccessKey accessKey = new MIRAccessKey(objectId, KEY, KEY);
        MIRAccessKeyManager.addAccessKey(accessKey);
    }

    @Test(expected = MIRAccessKeyException.class)
    public void testKeyCollision() {
        final MCRObjectID objectId = MCRObjectID.getInstance(MCR_OBJECT_ID);
        MIRAccessKey accessKeyRead = new MIRAccessKey(objectId, KEY, READ);
        MIRAccessKey accessKeyWrite = new MIRAccessKey(objectId, KEY, WRITE);

        MIRAccessKeyManager.addAccessKey(accessKeyRead);
        MIRAccessKeyManager.addAccessKey(accessKeyWrite);
    }

    @Test
    public void testAddKey() throws MCRException, IOException {
        final MCRObjectID objectId = MCRObjectID.getInstance(MCR_OBJECT_ID);
        final MIRAccessKey accessKey = new MIRAccessKey(objectId, KEY, READ);
        MIRAccessKeyManager.addAccessKey(accessKey);

        endTransaction();
        startNewTransaction();

        assertTrue(MIRAccessKeyManager.getAccessKey(objectId, KEY) != null);
    }

    @Test
    public void testGetAccessKeys() throws MCRException, IOException {
        final MCRObjectID objectId = MCRObjectID.getInstance(MCR_OBJECT_ID);
        final MIRAccessKey accessKey = new MIRAccessKey(objectId, KEY, READ);
        MIRAccessKeyManager.addAccessKey(accessKey);

        endTransaction();
        startNewTransaction();

        List<MIRAccessKey> accessKeys = MIRAccessKeyManager.getAccessKeys(objectId);
        assertTrue(accessKeys.size() == 1);

        final MIRAccessKey accessKeyTwo = new MIRAccessKey(objectId, KEY, READ);
        MIRAccessKeyManager.addAccessKey(accessKeyTwo);

        endTransaction();
        startNewTransaction();

        accessKeys = MIRAccessKeyManager.getAccessKeys(objectId);
        assertTrue(accessKeys.size() == 2);
    }

    @Test
    public void testDeleteKey() throws MCRAccessException {
        final MCRObjectID objectId = MCRObjectID.getInstance(MCR_OBJECT_ID);

        MIRAccessKey accessKey = new MIRAccessKey(objectId, KEY, READ);
        MIRAccessKeyManager.addAccessKey(accessKey);

        endTransaction();
        startNewTransaction();

        accessKey = MIRAccessKeyManager.getAccessKey(objectId, KEY);
        MIRAccessKeyManager.removeAccessKey(accessKey.getId());

        endTransaction();
        startNewTransaction();

        assertFalse(MIRAccessKeyManager.getAccessKey(objectId, KEY) != null);
    }

    @Test
    public void testUpdateKey() throws MCRAccessException {
        final MCRObjectID objectId = MCRObjectID.getInstance(MCR_OBJECT_ID);

        MIRAccessKey accessKey = new MIRAccessKey(objectId, KEY, READ);
        MIRAccessKeyManager.addAccessKey(accessKey);

        endTransaction();
        startNewTransaction();

        accessKey = MIRAccessKeyManager.getAccessKey(objectId, KEY);

        MIRAccessKey newAccessKey = new MIRAccessKey(objectId, KEY, WRITE);
        newAccessKey.setId(accessKey.getId());
        MIRAccessKeyManager.updateAccessKey(newAccessKey);

        endTransaction();
        startNewTransaction();

        newAccessKey = MIRAccessKeyManager.getAccessKey(accessKey.getId());
        System.out.println(newAccessKey.getValue());
        System.out.println(newAccessKey.getType());
        assertTrue(newAccessKey.getType().equals(WRITE));
    }

    @Test
    public void testTransientUser() throws SAXParseException, IOException, URISyntaxException {
        final MCRObjectID objectId = MCRObjectID.getInstance(MCR_OBJECT_ID);

        final MIRAccessKey accessKey = new MIRAccessKey(objectId, KEY, WRITE);
        MIRAccessKeyManager.addAccessKey(accessKey);

        MCRUser user = new MCRUser("junit");
        user.setRealName("Test Case");
        user.setPassword("test");

        MCRTransientUser tu = new MCRTransientUser(user);
        MCRSessionMgr.getCurrentSession().setUserInformation(tu);
        MIRAccessKeyManager.addAccessKeyAttribute(user, objectId, KEY);

        assertTrue("user should have write permission",
            MCRAccessManager.checkPermission(objectId, MCRAccessManager.PERMISSION_WRITE));
    }
}
