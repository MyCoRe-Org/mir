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

import java.io.Serial;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import org.mycore.datamodel.metadata.MCRMetaLangText;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.NamedQueries;
import jakarta.persistence.NamedQuery;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlAttribute;
import jakarta.xml.bind.annotation.XmlElement;
import jakarta.xml.bind.annotation.XmlEnum;
import jakarta.xml.bind.annotation.XmlEnumValue;
import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlType;
import jakarta.xml.bind.annotation.XmlValue;

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
    @NamedQuery(name = "MIRAccessKeyPair.listAll",
        query = "SELECT k"
            + "  FROM MIRAccessKeyPair k"),
})

@Entity
@Table(name = "MIRAccesskeys")
@XmlRootElement(name = "accesskeys")
@XmlAccessorType(XmlAccessType.NONE)
@Deprecated
public class MIRAccessKeyPair implements Serializable {

    public static final String PERMISSION_READ = "read";

    public static final String PERMISSION_WRITE = "write";

    @Serial
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
     * @deprecated Use {@link #ofServiceFlags(MCRObjectID, ServiceFlags)} instead
     */
    @Deprecated
    public static MIRAccessKeyPair fromServiceFlags(final MCRObjectID mcrObjectId, final ServiceFlags servFlags) {
        return ofServiceFlags(mcrObjectId, servFlags);
    }

    public static MIRAccessKeyPair ofServiceFlags(final MCRObjectID mcrObjectId, final ServiceFlags servFlags) {
        final MIRAccessKeyPair accKP = new MIRAccessKeyPair();
        accKP.setMCRObjectId(mcrObjectId);

        for (ServiceFlag flag : servFlags.flags) {
            if (flag.type == ServiceFlagType.READ) {
                accKP.setReadKey(flag.key);
            }
            if (flag.type == ServiceFlagType.WRITE) {
                accKP.setWriteKey(flag.key);
            }
        }

        return accKP.getReadKey() != null && accKP.getWriteKey() != null ? accKP : null;
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

    public ServiceFlags toServiceFlags() {
        return ServiceFlags.build(this);
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
        if (!(obj instanceof MIRAccessKeyPair that)) {
            return false;
        }
        return Objects.equals(mcrObjectId, that.mcrObjectId) &&
            Objects.equals(readKey, that.readKey) &&
            Objects.equals(writeKey, that.writeKey);
    }

    @XmlType(name = "serviceFlagType")
    @XmlEnum
    public enum ServiceFlagType {
        /**
         *  Read key permission type.
         */
        @XmlEnumValue("readkey")
        READ("readkey"),

        /**
         * Write key permission type.
         */
        @XmlEnumValue("writekey")
        WRITE("writekey");

        private final String value;

        ServiceFlagType(final String value) {
            this.value = value;
        }

        /**
         * Returns the access key permission type from given value.
         *
         * @param value the access key permission type value
         * @return the access key permission type
         */
        public static ServiceFlagType fromValue(final String value) {
            for (ServiceFlagType type : values()) {
                if (type.value.equals(value)) {
                    return type;
                }
            }
            throw new IllegalArgumentException(value);
        }

        /**
         * Returns the set access key permission type.
         *
         * @return the set access key permission type
         */
        public String value() {
            return value;
        }
    }

    @XmlRootElement(name = "servflags")
    @XmlAccessorType(XmlAccessType.FIELD)
    public static class ServiceFlags {
        @XmlElement(name = "servflag")
        public List<ServiceFlag> flags;

        @XmlAttribute(name = "class", required = true)
        @SuppressWarnings("PMD.UnusedPrivateField")
        private String cls = MCRMetaLangText.class.getSimpleName();

        public static ServiceFlags build(final MIRAccessKeyPair accKP) {
            ServiceFlags servFlags = new ServiceFlags();

            servFlags.flags = new ArrayList<ServiceFlag>();

            servFlags.flags.add(ServiceFlag.build(ServiceFlagType.READ, accKP.getReadKey()));

            if (accKP.getWriteKey() != null) {
                servFlags.flags.add(ServiceFlag.build(ServiceFlagType.WRITE, accKP.getWriteKey()));
            }

            return servFlags;
        }
    }

    @XmlRootElement(name = "servflag")
    @XmlAccessorType(XmlAccessType.FIELD)
    public static class ServiceFlag {
        @XmlAttribute(name = "type", required = true)
        public ServiceFlagType type;

        @XmlValue
        public String key;

        @XmlAttribute(name = "inherited")
        @SuppressWarnings("PMD.UnusedPrivateField")
        private int inherited = 0;

        @XmlAttribute(name = "form")
        @SuppressWarnings("PMD.UnusedPrivateField")
        private String form = "plain";

        public static ServiceFlag build(final ServiceFlagType permission, final String key) {
            ServiceFlag accKey = new ServiceFlag();

            accKey.type = permission;
            accKey.key = key;

            return accKey;
        }
    }
}
