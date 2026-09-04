import {SearchSettings} from "@/api/search/SearchSettings";
import {
    Cartographics,
    Genre,
    Geographic,
    GeographicCode,
    HierarchicalGeographic,
    Name,
    Occupation,
    Temporal,
    TitleInfo,
    Topic
} from "@/api/Subject";

export abstract class SearchProvider {

    protected vocabulary: string;
    protected authorityName: string;
    protected baseUrl: string;
    protected label: string;
    protected keys: string[];

    constructor(config: ProviderConfig) {
        this.vocabulary = config.vocabulary || "*";
        this.label = config.label || "Lobid";
        this.authorityName = config.authorityName;
        this.baseUrl = config.baseUrl;
        this.keys = (config.keys || "")
            .split(",")
            .map(key => key.trim())
            .filter(key => key.length > 0);
    }


    abstract search(searchTerm: string, settings: SearchSettings): Promise<Array<SearchResult>>;

    protected generateID(): string {
        return Math.random().toString(16).slice(2);
    }
}

export interface SearchResultInfo {
    id: string;
    label: string;
    type: "string" | "url";
    value: string;
}

export interface SearchResult {
    id: string;
    result: Topic | Geographic | Temporal | TitleInfo | Name | Genre | HierarchicalGeographic | Cartographics | GeographicCode | Occupation;
    info: Array<SearchResultInfo>;
}

export interface ProviderConfig {
    vocabulary?: string;
    label: string;
    authorityName: string;
    baseUrl: string;
    keys?: string;
}
