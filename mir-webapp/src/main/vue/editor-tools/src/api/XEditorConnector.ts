import {Subject} from "@/api/Subject";
import {outputSubject} from "@/api/SubjectXMLOutputter";
import {parseSubject} from "@/api/SubjectParser";

export const storeSubject = (subject:Subject, root: HTMLElement) => {
    const input = root.parentElement?.parentElement?.querySelector(`.subjectXML`);
    if(input instanceof HTMLInputElement){
        const result = outputSubject(subject);
        input.value = new XMLSerializer().serializeToString(result);
    } else {
        throw new Error("Could not find subjectXML input");
    }
}

export const retrieveSubject = (root: HTMLElement): Subject => {
    const input = root.parentElement?.parentElement?.querySelector(`.subjectXML`);
    if(input instanceof HTMLInputElement){
        const xml = input.value;
        let subject: Subject;
        if(input.value == ""){
            subject = {
                children: [],
            }
        } else {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(xml, "text/xml");
            subject = parseSubject(xmlDoc.children.item(0) as Element);
        }

        return subject;
    } else {
        throw new Error("Could not find subjectXML input");
    }

};

export interface ProviderConfigDetails {
    authorityName: string;
    label?: string;
    baseUrl: string;
    vocabulary?: string;
    displayedProperties?: string;
    [key: string]: string | undefined;
}

export interface ProviderConfig {
    id: string;
    type: string;
    label:string
    config: ProviderConfigDetails;
}

export interface EditorSettings {
    /**
     * List of types which facet should be enabled in the search.
     */
    searchFilterDefault:  ("Topic" | "Geographic" | "Institution" | "Person" | "Family" | "Conference" | "TitleInfo" | "Cartographics" | "*"|"")[]
    /**
     * List of searchable types. If contains *, all elements are searchable.
     * If empty, no elements are searchable.
     */
    searchable: ("Topic" | "Geographic" | "Institution" | "Person" | "Family" | "Conference" | "TitleInfo" | "Cartographics" | "*"|"")[],

    /**
     * List of editable types. If contains *, all elements are editable. If empty, no elements are
     * editable.
     */
    editor: ("Topic" | "Geographic" | "Institution" | "Person" | "Family" | "Conference" | "TitleInfo" | "Cartographics"|"*"|"")[],

    /**
     * If false the editor only allows editing of one subelement. If the subject contains more than one subelement, the
     * editor is disabled. If the type is "geographicPair" the editor allows editing of two subelements.
     */
    admin: boolean|"geographicPair",

    /**
     * If true there must be at least one subelement. If the subject contains no subelements the editor will print
     * a warning.
     */
    required: boolean|string[],

    /**
     * List of search providers.
     */
    providers: ProviderConfig[];
}

export const possibleTypes = ["Topic", "Geographic" , "Institution" , "Person" , "Family" , "Conference" , "TitleInfo" , "Cartographics"];

const KNOWN_PROVIDER_PROPERTY_SUFFIXES = [
    "enabled",
    "type",
    "label",
    "baseurl",
    "authorityname",
    "authority",
    "vocabulary",
    "keys",
].sort((a, b) => b.length - a.length);

export const retrieveSettings = (root: HTMLElement): EditorSettings => {
    const input = root.parentElement;
    if(input instanceof Element){
        const settings:EditorSettings = {
            searchable: [],
            editor: [],
            providers: []
        } as any;


        let editor = input.getAttribute("data-editor");
        if(editor == null){
            editor = "*";
        }

        let searchable = input.getAttribute("data-searchable");
        if(searchable == null){
            searchable = "*";
        }

        let adminStr = input.getAttribute("data-admin");
        if(adminStr == null){
            adminStr = "false";
        }

        let requiredStr= input.getAttribute("data-required");
        if(requiredStr == null){
            requiredStr = "false";
        }

        let searchFilterDefaultStr = input.getAttribute("data-search-filter-default");
        if(searchFilterDefaultStr == null) {
            searchFilterDefaultStr = "*";
        }

        if(adminStr != "true" && adminStr != "false" && adminStr != "geographicPair"){
            throw new Error(`Unknown value ${adminStr} for data-simple. Expected true, false or geographicPair`);
        } else if(adminStr == "true" || adminStr == "false") {
            settings.admin = adminStr === "true";
        } else {
            settings.admin = "geographicPair";
        }

        if(requiredStr == "true" || requiredStr == "false") {
            settings.required = requiredStr == "true";
        } else {
            settings.required = requiredStr.split(",");
            settings.required = settings.required.filter((value, index, array) => {
                const includes = possibleTypes.includes(value);
                if(!includes){
                    console.warn(`Unknown type ${value} in required list`);
                }
                return includes;
            });
        }

        if(editor == "*"){
            settings.editor = Array.of(...possibleTypes) as any;
        } else {
            settings.editor = editor.split(",") as any;
            settings.editor = settings.editor
                .filter(value => value.trim().length >0 )
                .filter((value, index, array) => {
                    const includes = possibleTypes.includes(value);
                    if(!includes){
                        console.warn(`Unknown type ${value} in editor list`);
                    }
                    return includes;
                });
        }

        if(searchable == "*"){
            settings.searchable = Array.of(...possibleTypes) as any;
        } else {
            settings.searchable = searchable.split(",") as any;
            settings.searchable = settings.searchable.filter((value, index, array) => {
                const includes = possibleTypes.includes(value);
                if(!includes){
                    console.warn(`Unknown type ${value} in searchable list`);
                }
                return includes;
            });
        }

        if(searchFilterDefaultStr == "*") {
            settings.searchFilterDefault = Array.of(...possibleTypes) as any;
        } else {
            settings.searchFilterDefault = searchFilterDefaultStr.split(",") as any;
            settings.searchFilterDefault = settings.searchFilterDefault.filter((value, index, array) => {
                const includes = possibleTypes.includes(value);
                if(!includes){
                    console.warn(`Unknown type ${value} in searchFilterDefault list`);
                }
                return includes;
            });
        }


        if (input instanceof HTMLElement) {
            const providersMap: Record<string, Record<string, string>> = {};

            for (const attr of input.attributes) {
                if (!attr.name.startsWith("data-provider-")) continue;
                const remainder = attr.name.substring("data-provider-".length);

                const matchedSuffix = KNOWN_PROVIDER_PROPERTY_SUFFIXES.find(
                    suffix => remainder === suffix || remainder.endsWith(`-${suffix}`)
                );

                if (!matchedSuffix) {
                    console.warn(`Unknown provider property in attribute "${attr.name}", skipping. Add it to KNOWN_PROVIDER_PROPERTY_SUFFIXES if this is intentional.`);
                    continue;
                }

                const providerId = remainder === matchedSuffix
                    ? ""
                    : remainder.slice(0, remainder.length - matchedSuffix.length - 1);

                if (!providerId) {
                    console.warn(`Attribute "${attr.name}" has no provider id, skipping.`);
                    continue;
                }

                let propName = matchedSuffix.replace(/-([a-z])/g, (_, char) => char.toUpperCase());
                if (propName === "baseurl") propName = "baseUrl";
                if (propName === "authorityname") propName = "authorityName";

                providersMap[providerId] ??= {};
                providersMap[providerId][propName] = attr.value;
            }

            settings.providers = Object.entries(providersMap)
                .filter(([_, props]) => props.enabled === "true")
                .map(([baseId, props]) => {
                    const { enabled, type, label, baseUrl, authorityName, authority, vocabulary, ...restConfig } = props;

                    const resolvedAuthority = authorityName || authority || "";
                    const specificSuffix = vocabulary || resolvedAuthority;

                    const cleanSuffix = specificSuffix.replace(/[^a-zA-Z]/g, "");
                    const uniqueId = cleanSuffix ? `${baseId}_${cleanSuffix}` : baseId;

                    if (!baseUrl) {
                        console.error(`Search provider "${uniqueId}" has no baseUrl configured, provider is discarded.`);
                        return null;
                    }
                    if (!resolvedAuthority) {
                        console.error(`Search provider "${uniqueId}" has no authorityName configured, provider is discarded.`);
                        return null;
                    }

                    return {
                        id: uniqueId,
                        type: type || baseId,
                        label: label || uniqueId,
                        config: {
                            baseUrl,
                            authorityName: resolvedAuthority,
                            ...(vocabulary ? { vocabulary } : {}),
                            ...restConfig
                        }
                    };
                })
                .filter((provider): provider is ProviderConfig => provider !== null);
        }

        // Fallback to lobid,
        if (settings.providers.length === 0) {
            settings.providers = [
                {
                    id: "lobid",
                    type: "lobid",
                    label: "Lobid",
                    config: {
                        authorityName: "gnd",
                        baseUrl: "https://lobid.org/gnd/search",
                    },
                },
            ];
        }

        return settings
    }
    throw new Error("Could not find subjectXML input");
}
