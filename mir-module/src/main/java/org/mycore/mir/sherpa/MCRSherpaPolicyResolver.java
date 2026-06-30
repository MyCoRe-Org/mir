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

package org.mycore.mir.sherpa;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Locale;
import java.util.Optional;
import java.util.concurrent.locks.ReentrantLock;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.jdom2.transform.JDOMSource;
import org.mycore.common.MCRCache;
import org.mycore.common.config.MCRConfiguration2;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * Resolves Open Policy Finder (formerly Sherpa Romeo) publisher policies for a journal ISSN.
 * <p>
 * The resolver is registered for the URI scheme {@code sherpa-policy:} and expects the ISSN as suffix,
 * e.g. {@code sherpa-policy:1178-9905}. It queries the Open Policy Finder API, parses the JSON response
 * into a compact XML structure and caches the parsed result in memory.
 * <p>
 * Configuration is read from the following properties:
 * <ul>
 *   <li>{@code MIR.Sherpa.API.URL} - base URL of the Open Policy Finder API</li>
 *   <li>{@code MIR.Sherpa.API.Key} - API key; if unset, the resolver returns an empty result</li>
 *   <li>{@code MIR.Sherpa.API.TimeoutSeconds} - connect and request timeout in seconds</li>
 *   <li>{@code MIR.Sherpa.API.Limit} - maximum number of items requested from the API</li>
 *   <li>{@code MIR.Sherpa.API.Cache.Size} - number of parsed results kept in memory</li>
 * </ul>
 */
public class MCRSherpaPolicyResolver implements URIResolver {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String PREFIX = "sherpa-policy:";

    private static final String CONFIG_BASE_URL = "MIR.Sherpa.API.URL";

    private static final String CONFIG_API_KEY = "MIR.Sherpa.API.Key";

    private static final String CONFIG_TIMEOUT = "MIR.Sherpa.API.TimeoutSeconds";

    private static final String CONFIG_LIMIT = "MIR.Sherpa.API.Limit";

    private static final String CONFIG_CACHE_SIZE = "MIR.Sherpa.API.Cache.Size";

    private static final String DEFAULT_BASE_URL = "https://api.openpolicyfinder.jisc.ac.uk/retrieve";

    private static final int DEFAULT_TIMEOUT_SECONDS = 5;

    private static final int DEFAULT_LIMIT = 5;

    private static final int DEFAULT_CACHE_SIZE = 1024;

    private static final ReentrantLock CACHE_LOCK = new ReentrantLock();

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        if (!href.startsWith(PREFIX)) {
            return null;
        }
        String issn = normalizeIssn(href.substring(PREFIX.length()));
        if (issn.isBlank()) {
            return new JDOMSource(empty("missing-issn"));
        }
        return new JDOMSource(resolveCachedPolicy(issn).clone());
    }

    private Element resolveCachedPolicy(String issn) {
        MCRCache<String, Element> policyCache = policyCache();
        Element cached = policyCache.get(issn);
        if (cached != null) {
            return cached;
        }
        CACHE_LOCK.lock();
        try {
            cached = policyCache.get(issn);
            if (cached == null) {
                cached = resolvePolicy(issn);
                policyCache.put(issn, cached);
            }
            return cached;
        } finally {
            CACHE_LOCK.unlock();
        }
    }

    private Element resolvePolicy(String issn) {
        Optional<String> apiKey = MCRConfiguration2.getString(CONFIG_API_KEY).filter(key -> !key.isBlank());
        if (apiKey.isEmpty()) {
            return empty("missing-api-key");
        }
        try {
            String json = fetch(issn, apiKey.get());
            return parse(json, issn);
        } catch (IOException e) {
            LOGGER.warn("Unable to retrieve Open Policy Finder data for ISSN {}", issn, e);
            return empty("request-failed");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            LOGGER.warn("Interrupted while retrieving Open Policy Finder data for ISSN {}", issn, e);
            return empty("request-interrupted");
        } catch (RuntimeException e) {
            LOGGER.warn("Unable to parse Open Policy Finder data for ISSN {}", issn, e);
            return empty("parse-failed");
        }
    }

    private String fetch(String issn, String apiKey) throws IOException, InterruptedException {
        int timeoutSeconds = MCRConfiguration2.getInt(CONFIG_TIMEOUT).orElse(DEFAULT_TIMEOUT_SECONDS);
        HttpClient client = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(timeoutSeconds))
            .build();
        HttpRequest request = HttpRequest.newBuilder(buildUri(issn))
            .timeout(Duration.ofSeconds(timeoutSeconds))
            .header("x-api-key", apiKey)
            .header("Accept", "application/json")
            .GET()
            .build();
        HttpResponse<String> response =
            client.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        int status = response.statusCode();
        if (status < 200 || status >= 300) {
            throw new IOException("Open Policy Finder returned HTTP status " + status);
        }
        return response.body();
    }

    private URI buildUri(String issn) {
        String baseUrl = MCRConfiguration2.getString(CONFIG_BASE_URL).orElse(DEFAULT_BASE_URL);
        int limit = MCRConfiguration2.getInt(CONFIG_LIMIT).orElse(DEFAULT_LIMIT);
        String filter = "[[\"issn\",\"equals\",\"" + issn + "\"]]";
        String query = "item-type=publication"
            + "&format=Json"
            + "&limit=" + limit
            + "&offset=0"
            + "&filter=" + encode(filter);
        return URI.create(baseUrl + "?" + query);
    }

    Element parse(String json, String issn) {
        JsonObject rootJson = JsonParser.parseString(json).getAsJsonObject();
        Element root = new Element("sherpa").setAttribute("issn", issn);
        JsonArray items = array(rootJson, "items");
        for (JsonElement itemElement : items) {
            if (!itemElement.isJsonObject()) {
                continue;
            }
            Element item = buildItem(itemElement.getAsJsonObject());
            if (!item.getChildren("publisherPolicy").isEmpty()) {
                root.addContent(item);
            }
        }
        return root;
    }

    private Element buildItem(JsonObject itemJson) {
        Element item = new Element("item");
        addText(item, "title", firstObjectText(array(itemJson, "title"), "title"));
        addText(item, "type", string(itemJson, "type"));
        addText(item, "url", string(itemJson, "url"));
        addText(item, "sherpaURL", string(object(itemJson, "system_metadata"), "uri"));
        addText(item, "publisher", firstPublisherName(itemJson));
        for (JsonElement policyElement : array(itemJson, "publisher_policy")) {
            if (!policyElement.isJsonObject()) {
                continue;
            }
            Element policy = buildPolicy(policyElement.getAsJsonObject());
            if (!policy.getChildren("permittedOA").isEmpty()) {
                item.addContent(policy);
            }
        }
        return item;
    }

    private Element buildPolicy(JsonObject policyJson) {
        Element policy = new Element("publisherPolicy");
        addText(policy, "openAccessProhibited", string(policyJson, "open_access_prohibited"));
        addText(policy, "notes", string(policyJson, "notes"));
        addText(policy, "reviewed", workflowDate(policyJson, "policy_last_reviewed"));
        for (JsonElement urlElement : array(policyJson, "urls")) {
            if (!urlElement.isJsonObject()) {
                continue;
            }
            JsonObject urlJson = urlElement.getAsJsonObject();
            String url = string(urlJson, "url");
            if (url.isBlank()) {
                continue;
            }
            Element urlNode = new Element("policyURL").setAttribute("href", url);
            urlNode.setText(string(urlJson, "description").isBlank() ? url : string(urlJson, "description"));
            policy.addContent(urlNode);
        }
        for (JsonElement permittedElement : array(policyJson, "permitted_oa")) {
            if (permittedElement.isJsonObject()) {
                policy.addContent(buildPermittedOA(permittedElement.getAsJsonObject()));
            }
        }
        return policy;
    }

    private Element buildPermittedOA(JsonObject permittedJson) {
        Element permitted = new Element("permittedOA");
        addValues(permitted, "articleVersion", array(permittedJson, "article_version"));
        addLocation(permitted, permittedJson);
        addEmbargo(permitted, permittedJson);
        addLicenses(permitted, permittedJson);
        addText(permitted, "additionalFee", string(permittedJson, "additional_oa_fee"));
        addText(permitted, "copyrightOwner", string(permittedJson, "copyright_owner"));
        addValues(permitted, "prerequisites", array(object(permittedJson, "prerequisites"), "prerequisites"));
        Element conditions = new Element("conditions");
        for (JsonElement condition : array(permittedJson, "conditions")) {
            if (condition.isJsonPrimitive()) {
                conditions.addContent(new Element("condition").setText(condition.getAsString()));
            }
        }
        if (!conditions.getChildren().isEmpty()) {
            permitted.addContent(conditions);
        }
        addText(permitted, "publicNotes", string(permittedJson, "public_notes"));
        return permitted;
    }

    private void addLocation(Element permitted, JsonObject permittedJson) {
        JsonObject locationJson = object(permittedJson, "location");
        Element location = new Element("location");
        for (JsonElement value : array(locationJson, "location")) {
            if (value.isJsonPrimitive()) {
                location.addContent(new Element("value").setText(value.getAsString()));
            }
        }
        addNamedValues(location, "namedRepository", array(locationJson, "named_repository"));
        addNamedValues(location, "namedAcademicSocialNetwork", array(locationJson, "named_academic_social_network"));
        if (!location.getChildren().isEmpty()) {
            permitted.addContent(location);
        }
    }

    private void addEmbargo(Element permitted, JsonObject permittedJson) {
        JsonObject embargoJson = object(permittedJson, "embargo");
        if (embargoJson.size() == 0) {
            return;
        }
        Element embargo = new Element("embargo");
        if (embargoJson.has("amount") && !embargoJson.get("amount").isJsonNull()) {
            embargo.setAttribute("amount", embargoJson.get("amount").getAsString());
        }
        String units = string(embargoJson, "units");
        if (!units.isBlank()) {
            embargo.setAttribute("units", units);
        }
        permitted.addContent(embargo);
    }

    private void addLicenses(Element permitted, JsonObject permittedJson) {
        Element licenses = new Element("license");
        for (JsonElement licenseElement : array(permittedJson, "license")) {
            if (!licenseElement.isJsonObject()) {
                continue;
            }
            JsonObject licenseJson = licenseElement.getAsJsonObject();
            String license = firstObjectText(array(licenseJson, "license_phrases"), "phrase");
            if (license.isBlank()) {
                license = string(licenseJson, "license");
            }
            if (!license.isBlank()) {
                licenses.addContent(new Element("value").setText(license));
            }
        }
        if (!licenses.getChildren().isEmpty()) {
            permitted.addContent(licenses);
        }
    }

    private static void addValues(Element parent, String elementName, JsonArray values) {
        Element element = new Element(elementName);
        for (JsonElement value : values) {
            if (value.isJsonPrimitive()) {
                element.addContent(new Element("value").setText(value.getAsString()));
            }
        }
        if (!element.getChildren().isEmpty()) {
            parent.addContent(element);
        }
    }

    private static void addNamedValues(Element parent, String elementName, JsonArray values) {
        for (JsonElement value : values) {
            if (value.isJsonPrimitive()) {
                parent.addContent(new Element(elementName).setText(value.getAsString()));
            }
        }
    }

    private static String firstPublisherName(JsonObject itemJson) {
        for (JsonElement publisherElement : array(itemJson, "publishers")) {
            if (!publisherElement.isJsonObject()) {
                continue;
            }
            JsonObject publisherJson = object(publisherElement.getAsJsonObject(), "publisher");
            String name = firstObjectText(array(publisherJson, "name"), "name");
            if (!name.isBlank()) {
                return name;
            }
        }
        return "";
    }

    private static String workflowDate(JsonObject json, String name) {
        return string(object(json, "workflow_dates"), name);
    }

    private static String firstObjectText(JsonArray array, String memberName) {
        for (JsonElement element : array) {
            if (!element.isJsonObject()) {
                continue;
            }
            String value = string(element.getAsJsonObject(), memberName);
            if (!value.isBlank()) {
                return value;
            }
        }
        return "";
    }

    private static void addText(Element parent, String name, String value) {
        if (!value.isBlank()) {
            parent.addContent(new Element(name).setText(value));
        }
    }

    private static JsonArray array(JsonObject object, String name) {
        if (object == null || !object.has(name) || !object.get(name).isJsonArray()) {
            return new JsonArray();
        }
        return object.getAsJsonArray(name);
    }

    private static JsonObject object(JsonObject object, String name) {
        if (object == null || !object.has(name) || !object.get(name).isJsonObject()) {
            return new JsonObject();
        }
        return object.getAsJsonObject(name);
    }

    private static String string(JsonObject object, String name) {
        if (object == null || !object.has(name) || object.get(name).isJsonNull()) {
            return "";
        }
        JsonElement value = object.get(name);
        return value.isJsonPrimitive() ? value.getAsString().trim() : "";
    }

    private static String normalizeIssn(String issn) {
        return issn.trim().replaceAll("[^0-9Xx-]", "").toUpperCase(Locale.ROOT);
    }

    private static int cacheSize() {
        try {
            return MCRConfiguration2.getInt(CONFIG_CACHE_SIZE).orElse(DEFAULT_CACHE_SIZE);
        } catch (RuntimeException e) {
            LOGGER.debug("Using default Open Policy Finder cache size", e);
            return DEFAULT_CACHE_SIZE;
        }
    }

    private static MCRCache<String, Element> policyCache() {
        return CacheHolder.POLICY_CACHE;
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static Element empty(String reason) {
        return new Element("sherpa").setAttribute("empty", "true").setAttribute("reason", reason);
    }

    private static final class CacheHolder {

        private static final MCRCache<String, Element> POLICY_CACHE = new MCRCache<>(cacheSize(),
            "Open Policy Finder policies");
    }
}
