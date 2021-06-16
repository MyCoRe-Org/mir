package org.mycore.mir.authorization.accesskeys.frontend.converter;

import java.lang.annotation.Annotation;
import java.lang.reflect.Type;

import javax.ws.rs.BadRequestException;
import javax.ws.rs.ext.ParamConverter;
import javax.ws.rs.ext.ParamConverterProvider;
import javax.ws.rs.ext.Provider;

import org.mycore.common.MCRException;
import org.mycore.datamodel.metadata.MCRObjectID;

@Provider
public class MCRObjectIDParamConverterProvider implements ParamConverterProvider {

    public static final String MSG_INVALID = "Invalid ID supplied";

    @Override
    public <T> ParamConverter<T> getConverter(Class<T> rawType, Type genericType, Annotation[] annotations)
        throws BadRequestException {
        if (MCRObjectID.class.isAssignableFrom(rawType)) {
            return new ParamConverter<>() {
                @Override
                public T fromString(String value) {
                    try {
                        return rawType.cast(MCRObjectID.getInstance(value));
                    } catch (MCRException e) {
                        throw new BadRequestException(MSG_INVALID);
                    }
                }

                @Override
                public String toString(T value) {
                    return value.toString();
                }
            };
        }
        return null;
    }
}
