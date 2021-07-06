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

package org.mycore.mir.authorization.accesskeys.backend;

import java.io.Serializable;
import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;
import javax.persistence.Transient;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;

import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;

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

@NamedQueries({
    @NamedQuery(name = "MIRAccessKeyPair.get",
        query = "SELECT k"
            + "  FROM MIRAccessKeyPair k"),
    @NamedQuery(name = "MIRAccessKeyPair.removeById",
        query = "DELETE"
            + "  FROM MIRAccessKeyPair k"
            + "  WHERE k.objectId = :objId"),
})

@Entity
@Table(name = "MIRAccesskeys")
@XmlRootElement(name = "accesskeys")
@XmlAccessorType(XmlAccessType.NONE)
public class MIRAccessKeyPair implements Serializable {

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
     * @param mcrObjectId the {@link MCRObjectID} to set
     */
    protected void setMCRObjectId(final MCRObjectID mcrObjectId) {
        this.mcrObjectId = mcrObjectId;
    }

    @Id
    @Column(name = "objId", nullable = false, length = 128)
    @XmlAttribute(name = "objId", required = true)
    public String getObjectId() {
        return mcrObjectId.toString();
    }

    public void setObjectId(final String mcrObjectId) {
        this.mcrObjectId = MCRObjectID.getInstance(mcrObjectId);
    }

    /**
     * Returns the key the user must know to acquire read permission on the {@link MCRObject}.
     * 
     * @return the key the user must know to acquire read permission on the {@link MCRObject}.
     */
    @Column(name = "readkey", nullable = false, length = 128)
    @XmlAttribute(name = "readkey", required = true)
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
        if ((readKey == null) || readKey.trim().length() == 0) {
            throw new IllegalArgumentException("Read key must not be empty: " + readKey);
        } else if ((writeKey != null) && readKey.equalsIgnoreCase(writeKey)) {
            throw new IllegalArgumentException("Read key must not be the same as write key: " + readKey);
        } else {
            this.readKey = readKey.trim();
        }
    }

    /**
     * Returns the key the user must know to acquire write permission on the {@link MCRObject}.
     * 
     * @return the key the user must know to acquire write permission on the {@link MCRObject}. This key may be empty.
     */
    @Column(name = "writekey", nullable = true, length = 128)
    @XmlAttribute(name = "writekey")
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
        if ((writeKey == null) || writeKey.trim().length() == 0) {
            this.writeKey = null;
        } else if ((readKey != null) && writeKey.equalsIgnoreCase(readKey)) {
            throw new IllegalArgumentException("Write key must not be the same as read key: " + writeKey);
        } else {
            this.writeKey = writeKey.trim();
        }
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((mcrObjectId == null) ? 0 : mcrObjectId.hashCode());
        result = prime * result + ((readKey == null) ? 0 : readKey.hashCode());
        result = prime * result + ((writeKey == null) ? 0 : writeKey.hashCode());
        return result;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof MIRAccessKeyPair)) {
            return false;
        }
        MIRAccessKeyPair that = (MIRAccessKeyPair) obj;
        return Objects.equals(mcrObjectId, that.mcrObjectId) &&
            Objects.equals(readKey, that.readKey) &&
            Objects.equals(writeKey, that.writeKey);
    }
}
