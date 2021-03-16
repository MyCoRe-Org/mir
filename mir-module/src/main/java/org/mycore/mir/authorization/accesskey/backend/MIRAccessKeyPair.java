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
package org.mycore.mir.authorization.accesskey.backend;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;

@NamedQueries({
    @NamedQuery(name = "MIRAccessKeyPair.get",
        query = "SELECT k"
            + "  FROM MIRAccessKeyPair k"),
    @NamedQuery(name = "MIRAccessKey.removeById",
        query = "DELETE"
            + "  FROM MIRAccessKeyPair k"
            + "  WHERE k.objectId = :objId"),
})

/**
 * Represent access keys to acquire access permission on a {@link MCRObject}. 
 * For a {@link MCRObject}, there may be a read key and a write key stored.
 * A user can input the key in UI and acquire the permission to access the {@link MCRObject}
 * if the key is correct. When the user enters the read key, 
 * he will be granted read permission on the {@link MCRObject}. When the user enters the write
 * key, he will be granted write permission on the {@link MCRObject}. The read 
 * key and write key must be different. There can not be a write key without a read key, 
 * if there is any key at all for a {@link MCRObject}.
 *  
 * @author Ren\u00E9 Adler (eagle)
 * @since 0.3
 */
@Entity
@Table(name = "MIRAccesskeys")
public class MIRAccessKeyPair {

    public static final String PERMISSION_READ = "read";

    public static final String PERMISSION_WRITE = "write";

    private static final long serialVersionUID = 1L;

    private MCRObjectID mcrObjectId;

    private String readKey;

    private String writeKey;

    private MIRAccessKeyPair() {

    }

    /**
     * Creates a new access key pair for the given {@link MCRObjectID}.
     *
     * @param mcrObjectId the {@link MCRObjectID} of the {@link MCRObject} the keys belong to.
     * @param readKey the key the user must know to acquire read permission on the {@link MCRObject}.
     * @param writeKey the key the user must know to acquire write permission on the {@link MCRObject}.
     *                This key may be empty.
     */
    public MIRAccessKeyPair(final MCRObjectID mcrObjectId, final String readKey, final String writeKey) {
        this.mcrObjectId = mcrObjectId;
        setReadKey(readKey);
        setWriteKey(writeKey);
    }

    /**
     * Returns the {@link MCRObjectID} of the {@link MCRObject} the keys belong to.
     * 
     * @return the mcrObjectId
     */
    @Transient
    public MCRObjectID getMCRObjectId() {
        return mcrObjectId;
    }

    /**
     * @param mcrObjectId the {@MCRObjectID} to set
     */
    private void setMCRObjectId(final MCRObjectID mcrObjectId) {
        this.mcrObjectId = mcrObjectId;
    }

    @Id
    @Column(name = "objId", nullable = false, length = 128)
    protected String getObjectId() {
        return mcrObjectId.toString();
    }

    protected void setObjectId(final String mcrObjectId) {
        this.mcrObjectId = MCRObjectID.getInstance(mcrObjectId);
    }

    /**
     * Returns the key the user must know to acquire read permission on the {@link MCRObject}.
     * 
     * @return the key the user must know to acquire read permission on the {@link MCRObject}.
     */
    @Column(name = "readkey", nullable = false, length = 128)
    public String getReadKey() {
        return readKey;
    }

    /**
     * Sets the key the user must know to acquire read permission on the {@link MCRObject}.
     * If there is a write key specified, too, the read key must be different from the write key.
     * 
     * @param readKey the key the user must know to acquire read permission on the {@link MCRObject}.
     */
    public void setReadKey(String readKey) {
        this.readKey = readKey;
    }

    /**
     * Returns the key the user must know to acquire write permission on the {@link MCRObject}.
     * 
     * @return the key the user must know to acquire write permission on the {@link MCRObject}. This key may be empty.
     */
    @Column(name = "writekey", nullable = true, length = 128)
    public String getWriteKey() {
        return writeKey;
    }

    /**
     * Sets the key the user must know to acquire write permission on the {@link MCRObject}.
     * This may be set to null. The write key must be different from the read key.
     * 
     * @param writeKey the key the user must know to acquire write permission on the {@link MCRObject}.
     *                This key may be empty.
     */
    public void setWriteKey(String writeKey) {
        this.writeKey = writeKey;
    }
}
