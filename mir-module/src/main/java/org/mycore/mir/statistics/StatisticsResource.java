package org.mycore.mir.statistics;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.CacheControl;
import jakarta.ws.rs.core.Response;

import org.mycore.frontend.jersey.MCRStaticContent;

@Path("stat")
@MCRStaticContent
public class StatisticsResource {

    @GET
    @Path("{filename: .*\\.css}")
    @Produces("text/css;charset=UTF-8")
    public Response getResource(@PathParam("filename") String filename) {
        CacheControl cc = new CacheControl();
        cc.setMaxAge(0);
        cc.setNoCache(true);
        Response.ResponseBuilder builder = Response.ok("/* empty css for statistics */");
        builder.cacheControl(cc);
        return builder.build();
    }
}
