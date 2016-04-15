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
import org.mycore.common.MCRException;
import org.mycore.common.MCRHibTestCase;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class TestAccessKeys extends MCRHibTestCase {

    private static final String MCR_OBJECT_ID = "mir_test_00000001";

    private static final String READ_KEY = "blah";

    private static final String WRITE_KEY = "blub";

    @Rule
    public TemporaryFolder folder = new TemporaryFolder();

    @Before()
    public void setUp() throws Exception {
        super.setUp();
        config.set("MCR.datadir", folder.newFolder("data").getAbsolutePath());
    }

    @Override
    protected Map<String, String> getTestProperties() {
        Map<String, String> testProperties = super.getTestProperties();
        testProperties.put("MCR.Metadata.Type.test", Boolean.TRUE.toString());
        return testProperties;
    }

    @Test
    public void testKeyPairFull() {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY,
                WRITE_KEY);

        assertEquals(MCR_OBJECT_ID, accKP.getMCRObjectId().toString());
        assertEquals(READ_KEY, accKP.getReadKey());
        assertEquals(WRITE_KEY, accKP.getWriteKey());
    }

    @Test
    public void testKeyPairWithoutWriteKey() {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY, null);

        assertEquals(MCR_OBJECT_ID, accKP.getMCRObjectId().toString());
        assertEquals(READ_KEY, accKP.getReadKey());
        assertNull(accKP.getWriteKey());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testKeyPairWithoutReadKey() {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), null, WRITE_KEY);

        assertNull(accKP);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testKeyPairWithMatchingKeys() {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), WRITE_KEY,
                WRITE_KEY);

        assertNull(accKP);
    }

    @Test
    public void testCreateKeyPair() throws MCRException, IOException {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY,
                WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(accKP);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testCreateSameKeyPair() throws MCRAccessException {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), WRITE_KEY,
                WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(accKP);

        final MIRAccessKeyPair sameAccKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), WRITE_KEY,
                WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(sameAccKP);
    }

    @Test
    public void testExistsKeyPair() throws MCRAccessException {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY,
                WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(accKP);

        endTransaction();
        startNewTransaction();

        assertTrue(MIRAccessKeyManager.existsKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID)));
    }

    @Test
    public void testUpdateKeyPair() throws MCRAccessException {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY,
                WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(accKP);

        endTransaction();
        startNewTransaction();

        final MIRAccessKeyPair loadAccKP = MIRAccessKeyManager.getKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID));

        assertNotNull(loadAccKP);

        loadAccKP.setReadKey(READ_KEY + WRITE_KEY);
        loadAccKP.setWriteKey(WRITE_KEY + READ_KEY);

        MIRAccessKeyManager.updateKeyPair(loadAccKP);

        assertNotEquals(accKP.getReadKey(), loadAccKP.getReadKey());
        assertNotEquals(accKP.getWriteKey(), loadAccKP.getWriteKey());
    }

    @Test
    public void testDeleteKeyPair() throws MCRAccessException {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY,
                WRITE_KEY);
        MIRAccessKeyManager.createKeyPair(accKP);

        endTransaction();
        startNewTransaction();

        MIRAccessKeyManager.deleteKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID));

        endTransaction();
        startNewTransaction();

        assertFalse(MIRAccessKeyManager.existsKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID)));
    }

    @Test
    public void testKeyPairTransform() throws IOException {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY,
                WRITE_KEY);

        new XMLOutputter(Format.getPrettyFormat()).output(MIRAccessKeyPairTransformer.buildExportableXML(accKP),
                System.out);
    }

    @Test
    public void testAccessKeysTransform() throws IOException {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY,
                WRITE_KEY);

        final Document xml = MIRAccessKeyPairTransformer.buildExportableXML(accKP);

        new XMLOutputter(Format.getPrettyFormat()).output(xml, System.out);

        final MIRAccessKeyPair transAccKP = MIRAccessKeyPairTransformer.buildAccessKeyPair(xml.getRootElement());

        assertEquals(accKP.getMCRObjectId(), transAccKP.getMCRObjectId());
        assertEquals(accKP.getReadKey(), transAccKP.getReadKey());
        assertEquals(accKP.getWriteKey(), transAccKP.getWriteKey());
    }

    @Test
    public void testServFlagsTransform() throws IOException {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY,
                WRITE_KEY);

        final Document xml = MIRAccessKeyPairTransformer.buildServFlagsXML(accKP);

        new XMLOutputter(Format.getPrettyFormat()).output(xml, System.out);

        final MIRAccessKeyPair transAccKP = MIRAccessKeyPairTransformer.buildAccessKeyPair(
                MCRObjectID.getInstance(MCR_OBJECT_ID), xml.getRootElement());

        assertEquals(accKP.getMCRObjectId(), transAccKP.getMCRObjectId());
        assertEquals(accKP.getReadKey(), transAccKP.getReadKey());
        assertEquals(accKP.getWriteKey(), transAccKP.getWriteKey());
    }

    @Test
    public void testServFlagsTransformWithOtherTypes() throws IOException {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair(MCRObjectID.getInstance(MCR_OBJECT_ID), READ_KEY,
                WRITE_KEY);

        final Document xml = MIRAccessKeyPairTransformer.buildServFlagsXML(accKP);
        final Element root = xml.getRootElement();

        final Element sf1 = new Element("servflag");
        sf1.setAttribute("type", "createdby");
        sf1.setAttribute("inherited", "0");
        sf1.setAttribute("form", "plain");
        sf1.setText("administrator");

        root.addContent(sf1);

        new XMLOutputter(Format.getPrettyFormat()).output(xml, System.out);

        final MIRAccessKeyPair transAccKP = MIRAccessKeyPairTransformer.buildAccessKeyPair(
                MCRObjectID.getInstance(MCR_OBJECT_ID), xml.getRootElement());

        assertEquals(accKP.getMCRObjectId(), transAccKP.getMCRObjectId());
        assertEquals(accKP.getReadKey(), transAccKP.getReadKey());
        assertEquals(accKP.getWriteKey(), transAccKP.getWriteKey());
    }
}
