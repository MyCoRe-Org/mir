package org.mycore.mir.authorization.accesskeys;

import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.JsonProcessingException;

import javax.ws.rs.core.Response;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.Consumes;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;

import org.mycore.common.MCRException;
import org.mycore.datamodel.metadata.MCRObjectID;

@Path("/miraccesskeyinformation")
public class MIRAccessKeyInformationResource {

    @GET
    @Path("/{object}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response get(@PathParam("object") String object) {
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            MIRAccessKeyInformation accessKeyInformation 
                = MIRAccessKeyManager.getAccessKeyInformation(objectId);
            ObjectMapper objectMapper = new ObjectMapper();
            String result = objectMapper.writeValueAsString(accessKeyInformation);
            return Response.status(Response.Status.OK).entity(result).build();
        } catch (MCRException e) {
            e.printStackTrace();
            return Response.status(Response.Status.BAD_REQUEST).build();
        } catch (JsonProcessingException e) { 
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GET
    @Path("/{object}/accesskey")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAccessKeys(@PathParam("object") String object) {
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            final List<MIRAccessKey> accessKeys = MIRAccessKeyManager.getAccessKeys(objectId);
            ObjectMapper objectMapper = new ObjectMapper();
            final String result = objectMapper.writeValueAsString(accessKeys);
            return Response.status(Response.Status.OK).entity(result).build();
        } catch (MCRException e) {
            e.printStackTrace();
            return Response.status(Response.Status.BAD_REQUEST).build();
        } catch (JsonProcessingException e) { 
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PUT
    @Path("/{object}/accesskey")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response get(@PathParam("object") String object, String json) {
        try {
            final MCRObjectID objectId = MCRObjectID.getInstance(object);
            ObjectMapper objectMapper = new ObjectMapper();
            final MIRAccessKey accessKey = objectMapper.readValue(json, MIRAccessKey.class);
            MIRAccessKeyManager.addAccessKey(objectId, accessKey);
            final MIRAccessKey accessKeyResult = MIRAccessKeyManager.getAccessKey(objectId, accessKey.getValue());
            String result = objectMapper.writeValueAsString(accessKeyResult);
            return Response.status(Response.Status.OK).entity(result).build();
        } catch (JsonProcessingException | MCRException e) {
            e.printStackTrace();
            return Response.status(Response.Status.BAD_REQUEST).build();
        }
    }

    @DELETE
    @Path("/{object}/accesskey/{uuid}")
    public Response geta(@PathParam("object") String object, @PathParam("uuid") String uuid) {
        try {
            final UUID id = UUID.fromString(uuid);
            MIRAccessKeyManager.deleteAccessKeyWithId(id);
            return Response.status(Response.Status.OK).build();
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            return Response.status(Response.Status.BAD_REQUEST).build();
        }
    }
    
    @POST
    @Path("/{object}/accesskey")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response getaa(@PathParam("object") String object, String json) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            final MIRAccessKey accessKey = objectMapper.readValue(json, MIRAccessKey.class);
            MIRAccessKeyManager.updateAccessKey(accessKey);
            return Response.status(Response.Status.OK).build();
        } catch (JsonProcessingException e) {
            e.printStackTrace();
            return Response.status(Response.Status.BAD_REQUEST).build();
        }
    }
}
