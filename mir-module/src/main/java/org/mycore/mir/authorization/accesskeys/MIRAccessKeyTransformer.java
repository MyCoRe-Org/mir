package org.mycore.mir.authorization.accesskeys;

import java.util.Arrays;
import java.util.List;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.JsonProcessingException;

public class MIRAccessKeyTransformer {

    protected static List<MIRAccessKey> jsonToAccessKeys(String json)
        throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();
        return Arrays.asList(objectMapper.readValue(json, MIRAccessKey[].class));
    }

    protected static String accessKeysToJson(List<MIRAccessKey> accessKeys)
        throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.writeValueAsString(accessKeys);
    }

    protected static String accessKeyToJson(MIRAccessKey accessKey)
        throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.writeValueAsString(accessKey);
    }

    protected static MIRAccessKey jsonToAccessKey(String json)
        throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.readValue(json, MIRAccessKey.class);
    }
}
