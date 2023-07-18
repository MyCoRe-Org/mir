import {SearchSettings} from "@/api/search/SearchSettings";
import {
    Cartographics,
    Genre,
    Geographic, GeographicCode,
    HierarchicalGeographic,
    Name, Occupation,
    Temporal,
    TitleInfo,
    Topic
} from "@/api/Subject";

export abstract class SearchProvider {
    abstract search(searchTerm: string, settings: SearchSettings): Promise<Array<SearchResult>>;
}

export interface SearchResultInfo {
    id: string;
    labelI18N: string;
    type: "string" | "url";
    value: string;
}

export interface SearchResult {
    id: string
    result: Topic | Geographic | Temporal | TitleInfo | Name | Genre | HierarchicalGeographic | Cartographics | GeographicCode | Occupation;
    info: Array<SearchResultInfo>;
}