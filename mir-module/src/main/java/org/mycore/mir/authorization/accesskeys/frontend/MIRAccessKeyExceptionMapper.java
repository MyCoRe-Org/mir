/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.mycore.mir.authorization.accesskeys.frontend;

import java.util.Optional;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Request;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;

import org.mycore.mir.authorization.accesskeys.exception.MIRAccessKeyException;
import org.mycore.mir.authorization.accesskeys.exception.MIRAccessKeyNotFoundException;
import org.mycore.restapi.v2.MCRErrorResponse;

@Provider
public class MIRAccessKeyExceptionMapper implements ExceptionMapper<MIRAccessKeyException> {

    @Context
    Request request;

    @Override
    public Response toResponse(MIRAccessKeyException exception) {
            return fromException(exception);
    }

    public static Response fromException(MIRAccessKeyException e) {
        if (e instanceof MIRAccessKeyNotFoundException) {
            return getResponse(e, Response.Status.NOT_FOUND.getStatusCode(),
                ((MIRAccessKeyException) e).getErrorCode());
        }
        return getResponse(e, Response.Status.BAD_REQUEST.getStatusCode(),
            ((MIRAccessKeyException) e).getErrorCode());
    }

    private static Response getResponse(Exception e, int statusCode, String errorCode) {
        MCRErrorResponse response = MCRErrorResponse.fromStatus(statusCode)
            .withCause(e)
            .withMessage(e.getMessage())
            .withDetail(Optional.of(e)
                .map(ex -> (ex instanceof WebApplicationException) ? ex.getCause() : ex)
                .map(Object::getClass)
                .map(Class::getName)
                .orElse(null))
            .withErrorCode(errorCode);
        //LogManager.getLogger().error(response::getLogMessage, e);
        return Response.status(response.getStatus())
            .entity(response)
            .build();
    }
}
