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

import java.util.UUID;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.JoinColumn;
import javax.persistence.Id;
import javax.persistence.ManyToOne;

import com.fasterxml.jackson.annotation.JsonBackReference;

/**
 * Access keys for a {@link MCRObject}.
 * An access keys contains a value and a type.
 * Value is the key value of the key and type the permission.
 */
@Entity
public class MIRAccessKey {

    private static final long serialVersionUID = 1L;

    /** The unique and internal information id */
    private UUID id;

    /** The key value*/
    private String value;

    /** The permission type*/
    private String type;

    /** The access key information*/
    private MIRAccessKeyInformation accessKeyInformation;

    protected MIRAccessKey() {
    }

    /**
     * Creates a new access key with value and type.
     *
     * @param value the value the user must know to acquire permission.
     * @param type the type of permission.
     */
    public MIRAccessKey(final String value, final String type) {
        setValue(value);
        setType(type);
    }

    /**
     * @return internal id
     */
    @Id
    @GeneratedValue
    @Column(name = "accesskey_id")
    public UUID getId() {
        return id;
    }

    /**
     * @param id internal id
     */
    public void setId(UUID id) {
        this.id = id;
    }

    /**
     * @return the key value
     */
    public String getValue() {
        return value;
    }

    /**
     * @param value key value
     import com.fasterxml.jackson.annotation.JsonBackReference;*/
    public void setValue(final String value) {
        this.value = value;
    }

    /**
     * @return permission type 
     */
    public String getType() {
        return type;
    }

    /**
     * @param type permission type
     */
    public void setType(String type) {
        this.type = type;
    }

    /**
     * @return access key information
     */
    @JsonBackReference
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fk_accesskeyinformation", nullable = false)
    public MIRAccessKeyInformation getAccessKeyInformation() {
        return accessKeyInformation;
    }

    /**
     * @param MIRAccessKeyInformation access key information
     */
    public void setAccessKeyInformation(MIRAccessKeyInformation accessKeyInformation) {
        this.accessKeyInformation = accessKeyInformation;
    }

    @Override
    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (!(o instanceof MIRAccessKey)) {
            return false;
        }
        MIRAccessKey other = (MIRAccessKey) o;
        return this.id.equals(other.getId()) && this.type.equals(other.getType())
            && this.value.equals(other.getValue());
    }
}
