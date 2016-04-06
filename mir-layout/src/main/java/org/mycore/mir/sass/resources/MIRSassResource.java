package org.mycore.mir.sass.resources;

import io.bit3.jsass.CompilationException;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.servlet.ServletContext;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.CacheControl;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.EntityTag;
import javax.ws.rs.core.Request;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.StreamingOutput;

import org.mycore.mir.sass.MIRSassCompilerManager;
import org.mycore.mir.sass.MIRServletContextResourceImporter;

import com.sun.jersey.spi.resource.Singleton;

@Path("sass/")
@Singleton
public class MIRSassResource {

    @javax.ws.rs.core.Context
    ServletContext context;

    @GET
    @Path("{fileName:.+}")
    @Produces("text/css")
    public Response getCSS(@PathParam("fileName") String name, @Context Request request) {
        try {
            MIRServletContextResourceImporter importer = new MIRServletContextResourceImporter(context);
            Optional<String> cssFile = MIRSassCompilerManager.getInstance().getCSSFile(name, Stream.of(importer).collect(Collectors.toList()));

            if (cssFile.isPresent()) {
                CacheControl cc = new CacheControl();
                cc.setMaxAge(60 * 60 * 24);

                String etagString = MIRSassCompilerManager.getInstance().getLastMD5(name).get();
                EntityTag etag = new EntityTag(etagString);

                Response.ResponseBuilder builder;
                if ((builder = request.evaluatePreconditions(etag)) != null) {
                    return builder.cacheControl(cc).tag(etag).build();
                }

                return Response.ok().status(Response.Status.OK)
                        .cacheControl(cc)
                        .tag(etag)
                        .entity(cssFile.get())
                        .build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                        .build();
            }
        } catch (IOException | CompilationException  e) {
            StreamingOutput so = (OutputStream os) -> e.printStackTrace(new PrintStream(os));
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(so).build();
        }
    }
}
