package org.mycore.mir.authorization.accesskeys;

import static org.mycore.access.MCRAccessManager.PERMISSION_WRITE;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.databind.ObjectMapper;
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
import org.mycore.mir.authorization.accesskeys.MIRAccessKeyManager.MIRAccessKeyManagerException;
import org.mycore.services.i18n.MCRTranslation;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserManager;

@Path("/miraccesskeyinformation")
public class MIRAccessKeyInformationResource {

    private static final Logger LOGGER = LogManager.getLogger();

    @GET
    @Path("/{object}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAccessKeyInformation(@PathParam("object") String object) {
        final MCRUser user = MCRUserManager.getCurrentUser();
        if (user.getUserID().equals(MCRSystemUserInformation.getGuestInstance().getUserID())) {
                return Response.status(Response.Status.FORBIDDEN).build();
        }
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            if (!MCRAccessManager.checkPermission(objectId, PERMISSION_WRITE)) {
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            MIRAccessKeyInformation accessKeyInformation 
                = MIRAccessKeyManager.getAccessKeyInformation(objectId);
            ObjectMapper objectMapper = new ObjectMapper();
            String result = objectMapper.writeValueAsString(accessKeyInformation);
            return Response.status(Response.Status.OK).entity(result).build();
        } catch (MCRException e) {
            System.out.println("aaa1");
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        } catch (JsonProcessingException e) { 
            System.out.println("aaa2");
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

    @POST
    @Path("/{object}")
    public Response setAccessKey(@PathParam("object") String object, @FormParam("value") String value,
        @HeaderParam("Referer") String referer) {
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
        } catch(MIRAccessKeyManagerException e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
        } catch (MCRException e) {
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        }
    }

    @GET
    @Path("/{object}/accesskey")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAccessKeys(@PathParam("object") String object) {
        final MCRUser user = MCRUserManager.getCurrentUser();
        if (user.getUserID().equals(MCRSystemUserInformation.getGuestInstance().getUserID())) {
                return Response.status(Response.Status.FORBIDDEN).build();
        }
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            if (!MCRAccessManager.checkPermission(objectId, PERMISSION_WRITE)) {
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            final List<MIRAccessKey> accessKeys = MIRAccessKeyManager.getAccessKeys(objectId);
            ObjectMapper objectMapper = new ObjectMapper();
            final String result = objectMapper.writeValueAsString(accessKeys);
            return Response.status(Response.Status.OK).entity(result).build();
        } catch (MCRException e) {
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        } catch (JsonProcessingException e) { 
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PUT
    @Path("/{object}/accesskey")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response addAccessKey(@PathParam("object") String object, String json) {
        final MCRUser user = MCRUserManager.getCurrentUser();
        if (user.getUserID().equals(MCRSystemUserInformation.getGuestInstance().getUserID())) {
                return Response.status(Response.Status.FORBIDDEN).build();
        }
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            if (!MCRAccessManager.checkPermission(objectId, PERMISSION_WRITE)) {
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            ObjectMapper objectMapper = new ObjectMapper();
            final MIRAccessKey accessKey = objectMapper.readValue(json, MIRAccessKey.class);
            MIRAccessKeyManager.addAccessKey(objectId, accessKey);
            final MIRAccessKey accessKeyResult = MIRAccessKeyManager.getAccessKey(objectId, accessKey.getValue());
            String result = objectMapper.writeValueAsString(accessKeyResult);
            return Response.status(Response.Status.OK).entity(result).build();
        } catch(MIRAccessKeyManagerException e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
        } catch (JsonProcessingException | MCRException e) {
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        }
    }

    @DELETE
    @Path("/{object}/accesskey/{id}")
    public Response deleteAccessKey(@PathParam("object") String object, @PathParam("id") String id) {
        final MCRUser user = MCRUserManager.getCurrentUser();
        if (user.getUserID().equals(MCRSystemUserInformation.getGuestInstance().getUserID())) {
                return Response.status(Response.Status.FORBIDDEN).build();
        }
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            if (!MCRAccessManager.checkPermission(objectId, PERMISSION_WRITE)) {
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            final UUID uuid = UUID.fromString(id);
            MIRAccessKeyManager.deleteAccessKey(uuid);
            return Response.status(Response.Status.OK).build();
        } catch(MIRAccessKeyManagerException e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
        } catch (IllegalArgumentException | MCRException e) {
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        }
    }
    
    @POST
    @Path("/{object}/accesskey")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response updateAccessKey(@PathParam("object") String object, String json) {
        final MCRUser user = MCRUserManager.getCurrentUser();
        if (user.getUserID().equals(MCRSystemUserInformation.getGuestInstance().getUserID())) {
                return Response.status(Response.Status.FORBIDDEN).build();
        }
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            if (!MCRAccessManager.checkPermission(objectId, PERMISSION_WRITE)) {
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            ObjectMapper objectMapper = new ObjectMapper();
            final MIRAccessKey accessKey = objectMapper.readValue(json, MIRAccessKey.class);
            MIRAccessKeyManager.updateAccessKey(accessKey);
            return Response.status(Response.Status.OK).build();
        } catch(MIRAccessKeyManagerException e) {
            return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
        } catch (JsonProcessingException | MCRException e) {
            LOGGER.error("failed! {}", e);
            return Response.status(Response.Status.BAD_REQUEST).build();
        }
    }
}
