export const MODS_NAMESPACE = "http://www.loc.gov/mods/v3";


export interface Authority {
    authority?: string;
    authorityURI?: string;
    valueURI?: string;
}

export interface Subject extends Authority {
    children: Array<Topic | Geographic | Temporal | TitleInfo | Name | Genre | HierarchicalGeographic | Cartographics | GeographicCode | Occupation>;
}



export interface SubjectChild<T extends string> {
    type: T;
}

export interface Topic extends Authority, SubjectChild<"Topic"> {
    text: string;
}

export interface Geographic extends Authority, SubjectChild<"Geographic"> {
    text: string;
}

export interface Temporal extends Authority, SubjectChild<"Temporal"> {
    text: string;
    encoding?: string;
    point?: "start" | "end";
    keyDate?: boolean;
    qualifier?: "approximate" | "inferred" | "questionable";
    calendar?: string;
}

export interface TitleInfo extends Authority, SubjectChild<"TitleInfo"> {
    title: string[];
    subTitle: string[];
    partNumber: string[];
    partName: string[];
    nonSort: string[];
    displayLabel?: string;
    titleType?: string;
    lang?: string;
}

export interface NameIdentifier {
    type?: string;
    text: string;
}

export interface Name extends Authority, SubjectChild<"Name"> {
    nameType?: "personal" | "corporate" | "conference" | "family";
    displayForm?: string;
    nameParts: NamePart[];
    nameIdentifier: NameIdentifier[];
    role: RoleTerm[];
    affiliation: string[];
}

export interface RoleTerm extends Authority {
    type?: "text" | "code";
    text?: string;
}

export interface NamePart {
    type?: "family" | "given" | "termsOfAddress";
    text: string;
}

export interface Genre extends Authority, SubjectChild<"Genre"> {
    genreType?: string;
    text: string;
}

export interface HierarchicalGeographic extends SubjectChild<"HierarchicalGeographic"> {
    children: Array<Continent | Country |  Region | State | Territory | County | City | CitySection | Island | Area | ExtraterrestrialArea>;
}

export interface Continent extends Authority {
    type: "continent";
    level?: number;
    period?: string;
    text: string;
}

export interface Country extends Authority {
    type: "country";
    level?: number;
    period?: string;
    text: string;
}

export interface Region extends Authority {
    type: "region";
    level?: number;
    period?: string;
    regionType?: string;
    text: string;
}

export interface State extends Authority {
    type: "state";
    level?: number;
    period?: string;
    text: string;
    stateType?: string;
}

export interface Territory extends Authority {
    type: "territory";
    level?: number;
    period?: string;
    text: string;
}

export interface County extends Authority {
    type: "county";
    level?: number;
    period?: string;
    text: string;
}

export interface City extends Authority {
    type: "city";
    level?: number;
    period?: string;
    text: string;
}

export interface CitySection extends Authority {
    type: "citySection";
    level?: number;
    period?: string;
    text: string;
    citySectionType?: string;
}

export interface Island extends Authority {
    type: "island";
    level?: number;
    period?: string;
    text: string;
}

export interface Area extends Authority {
    type: "area";
    level?: number;
    period?: string;
    text: string;
    areaType?: string;
}

export interface ExtraterrestrialArea extends Authority {
    type: "extraterrestrialArea";
    level?: number;
    period?: string;
    text: string;
}

export interface Cartographics extends SubjectChild<"Cartographics"> {
    coordinates?: string[];
    projection?: string[];
    scale?: string[];
}

export interface GeographicCode extends SubjectChild<"GeographicCode">, Authority {
    text: string;
}

export interface Occupation extends Authority, SubjectChild<"Occupation"> {
    text: string;
}