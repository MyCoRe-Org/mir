package org.mycore.mir.authorization.accesskeys;

import static org.mycore.access.MCRAccessManager.PERMISSION_WRITE;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.core.JsonProcessingException;

import javax.ws.rs.core.Response;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.Consumes;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.FormParam;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.mycore.access.MCRAccessManager;
import org.mycore.common.MCRException;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mir.authorization.accesskeys.backend.MIRAccessKey;
import org.mycore.mir.authorization.accesskeys.exceptions.MIRAccessKeyException;
import org.mycore.services.i18n.MCRTranslation;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;

@Path("/accesskey")
public class MIRAccessKeyResource {

    private static final Logger LOGGER = LogManager.getLogger();

    @GET
    @Path("/{object}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAccessKeyInformation(@PathParam("object") final String object) {
        final MCRUser user = MCRUserManager.getCurrentUser();
        if (user.getUserID().equals(MCRSystemUserInformation.getGuestInstance().getUserID())) {
            return Response.status(Response.Status.FORBIDDEN).build();
        }
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            if (!MCRAccessManager.checkPermission(objectId, PERMISSION_WRITE)) {
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            final List<MIRAccessKey> accessKeys 
                = MIRAccessKeyManager.getAccessKeys(objectId);
            final String result = MIRAccessKeyTransformer.accessKeysToJson(accessKeys);
            return Response.status(Response.Status.OK).entity(result).build();
        } catch (MCRException e) {
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        } catch (JsonProcessingException e) { 
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

    @POST
    @Path("/{object}")
    public Response setAccessKey(@PathParam("object") final String object, @FormParam("value") final String value,
        @HeaderParam("Referer") final String referer) {
        if (value == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity(MCRTranslation.translate("mir.accesskey.invalidKey")).build();
        }
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            final MCRUser user = MCRUserManager.getCurrentUser();
            if (user.getUserID().equals(MCRSystemUserInformation.getGuestInstance().getUserID())) {
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            MIRAccessKeyManager.addAccessKeyAttribute(user, objectId, value);
            return Response.temporaryRedirect(new URI(referer)).build(); //TODO if referer null alternative
        } catch(URISyntaxException e) {
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        } catch(MIRAccessKeyException e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
        } catch (MCRException e) {
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        }
    }

    @PUT
    @Path("/{object}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response addAccessKey(@PathParam("object") final String object, final String json) {
        final MCRUser user = MCRUserManager.getCurrentUser();
        if (user.getUserID().equals(MCRSystemUserInformation.getGuestInstance().getUserID())) {
            return Response.status(Response.Status.FORBIDDEN).build();
        }
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            if (!MCRAccessManager.checkPermission(objectId, PERMISSION_WRITE)) {
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            final MIRAccessKey accessKey = MIRAccessKeyTransformer.jsonToAccessKey(json);
            accessKey.setObjectId(objectId);
            MIRAccessKeyManager.addAccessKey(accessKey);
            final MIRAccessKey accessKeyResult = MIRAccessKeyManager.getAccessKey(objectId, accessKey.getValue());
            final String result = MIRAccessKeyTransformer.accessKeyToJson(accessKeyResult);
            return Response.status(Response.Status.OK).entity(result).build();
        } catch(MIRAccessKeyException e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
        } catch (JsonProcessingException | MCRException e) {
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        }
    }

    @DELETE
    @Path("/{object}/{uuid}")
    public Response deleteAccessKey(@PathParam("object") final String object, @PathParam("uuid") final UUID uuid) {
        final MCRUser user = MCRUserManager.getCurrentUser();
        if (user.getUserID().equals(MCRSystemUserInformation.getGuestInstance().getUserID())) {
            return Response.status(Response.Status.FORBIDDEN).build();
        }
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            if (!MCRAccessManager.checkPermission(objectId, PERMISSION_WRITE)) {
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            MIRAccessKeyManager.deleteAccessKey(uuid);
            return Response.status(Response.Status.OK).build();
        } catch(MIRAccessKeyException e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
        } catch (IllegalArgumentException | MCRException e) {
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        }
    }
    
    @POST
    @Path("/{object}/{uuid}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response updateAccessKey(@PathParam("object") final String object, 
            @PathParam("uuid") final UUID uuid, final String json) {
        final MCRUser user = MCRUserManager.getCurrentUser();
        if (user.getUserID().equals(MCRSystemUserInformation.getGuestInstance().getUserID())) {
                return Response.status(Response.Status.FORBIDDEN).build();
        }
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            if (!MCRAccessManager.checkPermission(objectId, PERMISSION_WRITE)) {
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            final MIRAccessKey accessKey = MIRAccessKeyTransformer.jsonToAccessKey(json);
            MIRAccessKeyManager.updateAccessKey(accessKey);
            return Response.status(Response.Status.OK).build();
        } catch(MIRAccessKeyException e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
        } catch (JsonProcessingException | MCRException e) {
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        }
    }
}
