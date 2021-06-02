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
import java.util.ArrayList;
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
import org.mycore.mir.authorization.accesskeys.exception.MIRAccessKeyCollisionException;
import org.mycore.user2.MCRTransientUser;
import org.mycore.user2.MCRUser;
import org.xml.sax.SAXParseException;

/**
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class TestAccessKeys extends MCRJPATestCase {

    private static final String MCR_OBJECT_ID = "mir_test_00000001";

    private static final String READ_KEY = "blah";

    private static final String WRITE_KEY = "blub";

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

    @Test
    public void testKey() {
        final MIRAccessKey accessKey = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, MCRAccessManager.PERMISSION_READ);

        assertEquals(MCR_OBJECT_ID, accessKey.getObjectId().toString());
        assertEquals(READ_KEY, accessKey.getValue());
        assertEquals(MCRAccessManager.PERMISSION_READ, accessKey.getType());
    }

    @Test(expected = MIRAccessKeyCollisionException.class)
    public void testKeyCollison() {
        final MIRAccessKey accessKeyRead = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), WRITE_KEY, MCRAccessManager.PERMISSION_READ);
        MIRAccessKeyManager.addAccessKey(accessKeyRead);
        final MIRAccessKey accessKeyWrite = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), WRITE_KEY, MCRAccessManager.PERMISSION_WRITE);
        MIRAccessKeyManager.addAccessKey(accessKeyWrite);
    }

    @Test
    public void testCreateKey() throws MCRException, IOException {
        final MIRAccessKey accessKeyRead = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, MCRAccessManager.PERMISSION_READ);
        MIRAccessKeyManager.addAccessKey(accessKeyRead);
    }

    @Test(expected = MIRAccessKeyCollisionException.class)
    public void testDuplicate() throws MCRAccessException {
        final MIRAccessKey accessKey = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, MCRAccessManager.PERMISSION_READ);
        MIRAccessKeyManager.addAccessKey(accessKey);
        final MIRAccessKey accessKeySame = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, MCRAccessManager.PERMISSION_READ);
        MIRAccessKeyManager.addAccessKey(accessKeySame);
    }

    @Test
    public void testExistsKey() throws MCRAccessException {
        final MIRAccessKey accessKey = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, MCRAccessManager.PERMISSION_READ);
        MIRAccessKeyManager.addAccessKey(accessKey);

        endTransaction();
        startNewTransaction();

        assertTrue(MIRAccessKeyManager.getAccessKeys(MCRObjectID.getInstance(MCR_OBJECT_ID)).size() > 0);
    }

    @Test
    public void testUpdateKey() throws MCRAccessException {
        final MIRAccessKey accessKey = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, MCRAccessManager.PERMISSION_READ);
        MIRAccessKeyManager.addAccessKey(accessKey);

        endTransaction();
        startNewTransaction();

        final MIRAccessKey accessKeyNew = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY + WRITE_KEY, MCRAccessManager.PERMISSION_READ);
        MIRAccessKeyManager.updateAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, accessKeyNew);

        final MIRAccessKey accessKeyUpdated = MIRAccessKeyManager.getAccessKeys(MCRObjectID.getInstance(MCR_OBJECT_ID)).get(0);
        assertEquals(accessKeyNew.getValue(), accessKeyUpdated.getValue());
    }

    @Test
    public void testDeleteKey() throws MCRAccessException {
        final MIRAccessKey accessKey = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, MCRAccessManager.PERMISSION_READ);
        MIRAccessKeyManager.addAccessKey(accessKey);

        endTransaction();
        startNewTransaction();

        MIRAccessKeyManager.deleteAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY);

        endTransaction();
        startNewTransaction();

        assertFalse(MIRAccessKeyManager.getAccessKeys(MCRObjectID.getInstance(MCR_OBJECT_ID)).size() > 0);
    }

    @Test
    public void testAccessKeysTransform() throws IOException {
        final MIRAccessKey accessKey = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, MCRAccessManager.PERMISSION_READ);
        final List<MIRAccessKey> accessKeys = new ArrayList<MIRAccessKey>();
        accessKeys.add(accessKey);
        final String json = MIRAccessKeyTransformer.jsonFromAccessKeys(accessKeys);

        final List<MIRAccessKey> transAccessKeys = MIRAccessKeyTransformer.accessKeysFromJson(json);
        final MIRAccessKey transAccessKey = transAccessKeys.get(0);

        assertEquals(transAccessKey.getObjectId(), null);
        assertEquals(transAccessKey.getId(), 0);
        assertEquals(accessKey.getValue(), transAccessKey.getValue());
        assertEquals(accessKey.getType(), transAccessKey.getType());
    }

    @Test
    public void testServFlagTransform() throws IOException {
        final MIRAccessKey accessKeyRead = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, MCRAccessManager.PERMISSION_READ);
        final MIRAccessKey accessKeyWrite = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), WRITE_KEY, MCRAccessManager.PERMISSION_WRITE);
        final List<MIRAccessKey> accessKeys = new ArrayList<MIRAccessKey>();
        accessKeys.add(accessKeyRead);
        accessKeys.add(accessKeyWrite);
        final Element servFlag = MIRAccessKeyTransformer.servFlagFromAccessKeys(accessKeys);

        new XMLOutputter(Format.getPrettyFormat()).output(servFlag, System.out);

        final List<MIRAccessKey> transAccessKeys = MIRAccessKeyTransformer.accessKeysFromElement(
            MCRObjectID.getInstance(MCR_OBJECT_ID), servFlag);
        assertTrue(transAccessKeys.size() == 2);

        final MIRAccessKey transAccessKeyRead = transAccessKeys.get(0);
        assertEquals(accessKeyRead.getObjectId(), transAccessKeyRead.getObjectId());
        assertEquals(accessKeyRead.getValue(), transAccessKeyRead.getValue());
        assertEquals(accessKeyRead.getType(), transAccessKeyRead.getType());
    }

    @Test
    public void testServiceTransform() throws IOException {
        final Element service = new Element("service");
        final Element servFlags = new Element("servflags");

        final MIRAccessKey accessKey = new MIRAccessKey(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, MCRAccessManager.PERMISSION_READ);
        final List<MIRAccessKey> accessKeys = new ArrayList<MIRAccessKey>();
        accessKeys.add(accessKey);
        final Element servFlag = MIRAccessKeyTransformer.servFlagFromAccessKeys(accessKeys);
        servFlags.addContent(servFlag);

        final Element sf1 = new Element("servflag");
        sf1.setAttribute("type", "createdby");
        sf1.setAttribute("inherited", "0");
        sf1.setAttribute("form", "plain");
        sf1.setText("administrator");
        servFlags.addContent(sf1);

        service.addContent(servFlags);

        new XMLOutputter(Format.getPrettyFormat()).output(service, System.out);

        final List<MIRAccessKey> transAccessKeys = MIRAccessKeyTransformer.accessKeysFromElement(
            MCRObjectID.getInstance(MCR_OBJECT_ID), service);

        final MIRAccessKey transAccessKey = transAccessKeys.get(0);
        assertEquals(accessKey.getObjectId(), transAccessKey.getObjectId());
        assertEquals(accessKey.getValue(), transAccessKey.getValue());
        assertEquals(accessKey.getType(), transAccessKey.getType());
    }

    @Test
    public void testTransientUser() throws SAXParseException, IOException, URISyntaxException {
        final MCRObjectID mcrObjectId = MCRObjectID.getInstance(MCR_OBJECT_ID);

        final MIRAccessKey accessKey = new MIRAccessKey(mcrObjectId, WRITE_KEY, MCRAccessManager.PERMISSION_WRITE);
        MIRAccessKeyManager.addAccessKey(accessKey);

        MCRUser user = new MCRUser("junit");
        user.setRealName("Test Case");
        user.setPassword("test");

        MCRTransientUser tu = new MCRTransientUser(user);
        MCRSessionMgr.getCurrentSession().setUserInformation(tu);
        MIRAccessKeyManager.addAccessKey(mcrObjectId, WRITE_KEY);

        assertTrue("user should have write permission",
            MCRAccessManager.checkPermission(mcrObjectId, MCRAccessManager.PERMISSION_WRITE));
    }
}
