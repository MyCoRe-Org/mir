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

import org.hibernate.Session;
import org.mycore.backend.hibernate.MCRHIBConnection;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * Provides methods to store, update, delete and retrieve
 * {@link MCRObject} access keys.
 * 
 * @author Ren\u00E9 Adler (eagle)
 * @since 0.3
 */
public final class MIRAccessKeyManager {

    private static final MCRHIBConnection MCRHIB_CONNECTION = MCRHIBConnection.instance();

    public static MIRAccessKeyPair getKeyPair(final MCRObjectID mcrObjectId) {
        final Session session = MCRHIB_CONNECTION.getSession();

        return (MIRAccessKeyPair) session.get(MIRAccessKeyPair.class, mcrObjectId.toString());
    }

    public static boolean existsKeyPair(final MCRObjectID mcrObjectId) {
        return getKeyPair(mcrObjectId) != null;
    }

    public static void createKeyPair(final MIRAccessKeyPair accKP) {
        if (existsKeyPair(accKP.getMCRObjectId()))
            throw new IllegalArgumentException("Access key pair for MCRObject " + accKP.getObjectId()
                    + " already exists");

        final Session session = MCRHIB_CONNECTION.getSession();
        session.save(accKP);
    }

    public static void updateKeyPair(final MIRAccessKeyPair accKP) {
        if (!existsKeyPair(accKP.getMCRObjectId())) {
            createKeyPair(accKP);
            return;
        }

        final Session session = MCRHIB_CONNECTION.getSession();
        session.update(accKP);
    }

    public static void deleteKeyPair(final MCRObjectID mcrObjectId) {
        if (!existsKeyPair(mcrObjectId))
            throw new IllegalArgumentException("Couldn't delete non exists key pair for MCRObject " + mcrObjectId);

        final Session session = MCRHIB_CONNECTION.getSession();
        session.delete(getKeyPair(mcrObjectId));
    }
}
