package org.mycore.mir.statistics;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.CacheControl;
import javax.ws.rs.core.Response;

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
