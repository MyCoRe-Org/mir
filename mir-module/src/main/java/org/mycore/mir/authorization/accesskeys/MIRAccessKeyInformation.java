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

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.JoinColumn;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Transient;
import javax.xml.bind.annotation.XmlRootElement;

import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * Base object that contains access keys for a {@link MCRObject}.
 * A {@link MCRObject} can be assigned exactly one information with n access keys.
 */
@Entity
@NamedQueries({
    @NamedQuery(name = "MIRAccessKeyInformation.getAccessKeys",
        query = "SELECT k"
            + "  FROM MIRAccessKeyInformation i"
            + "  JOIN i.accessKeys k"
            + "  WHERE i.objectIdString = :objId"),
    @NamedQuery(name = "MIRAccessKeyInformation.getAccessKeyByValue",
        query = "SELECT k"
            + "  FROM MIRAccessKeyInformation i"
            + "  JOIN i.accessKeys k"
            + "  WHERE i.objectIdString = :objId and k.value = :value"),
})
@XmlRootElement(name = "accesskeyinformation")
public class MIRAccessKeyInformation {

    private static final long serialVersionUID = 1L;

    /** The assigned id of the {@link MCRObject} */
    private MCRObjectID mcrObjectId; 

    /** Assigned accesskeys */
    @OneToMany(cascade = CascadeType.ALL , fetch = FetchType.LAZY, mappedBy = "mirAccessKeyInformation")
    private List<MIRAccessKey> accessKeys = new ArrayList<MIRAccessKey>();

    protected MIRAccessKeyInformation() {
    }

    /**
     * Creates a new Information for a {@link MCRObject}.
     *
     * @param mcrObjectId The id of the @link MCRObject}.
     */
    public MIRAccessKeyInformation(final MCRObjectID mcrObjectId) {
        this.mcrObjectId = mcrObjectId;
    }

    /**
     * Creates a new Information for a {@link MCRObject} and assigns access keys.
     *
     * @param mcrObjectId The id of the @link MCRObject}.
     * @param accessKeys access keys.
     */
    public MIRAccessKeyInformation(final MCRObjectID mcrObjectId, final List<MIRAccessKey> accessKeys) {
        this.mcrObjectId = mcrObjectId;
        this.accessKeys = accessKeys;
    }

    /**
     * @return the linked mcrObjectId
     */
    @Transient
    public MCRObjectID getObjectId() {
        return mcrObjectId;
    }

    /**
     * @param mcrObjectId the {@MCRObjectID} to set
     */
    public void setObjectId(final MCRObjectID mcrObjectId) {
        this.mcrObjectId = mcrObjectId;
    }

    /**
     * @return objectId as String
     */
    @Id
    @Column(name = "accesskeyinformation_id", nullable = false)
    public String getObjectIdString() {
        return mcrObjectId.toString();
    }

    /**
     * @param objectId id as String
     */
    public void setObjectIdString(String objectIdString) {
        this.mcrObjectId = MCRObjectID.getInstance(objectIdString.trim());
    }

    /**
     * @return Assigned access keys
     */
    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "fk_accesskeyinformation")
    public List<MIRAccessKey> getAccessKeys() {
        return accessKeys;
    }

    /**
     * @param accessKeys access keys
     */
    public void setAccessKeys(final List<MIRAccessKey> accessKeys) {
        this.accessKeys = accessKeys;
    }
}
