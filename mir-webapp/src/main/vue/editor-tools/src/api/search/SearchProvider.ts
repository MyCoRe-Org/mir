import {SearchSettings} from "@/api/search/SearchSettings";
import {
    Cartographics,
    Genre,
    Geographic,
    GeographicCode,
    HierarchicalGeographic,
    Name,
    NameIdentifier,
    Occupation,
    RoleTerm,
    Temporal,
    TitleInfo,
    Topic
} from "@/api/Subject";
import {i18n} from "@/api/I18N";

const VIAF_ID_PREFIX_1 = "http://viaf.org/viaf/";
const VIAF_ID_PREFIX_2 = "https://viaf.org/viaf/";


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

export interface SkosProviderConfig {
    vocabulary?: string;
    authorityName: string;
    baseUrl: string;
}

export abstract class SearchProvider {
    protected vocabulary: string;
    protected authorityName: string;
    protected baseUrl: string;

    constructor(config: SkosProviderConfig) {
        this.vocabulary = config.vocabulary || "*";
        this.authorityName = config.authorityName;
        this.baseUrl = config.baseUrl;
    }

    abstract search(searchTerm: string, settings: SearchSettings): Promise<Array<SearchResult>>;

    protected settingsToQuery(settings: SearchSettings): string {
        if (!settings) return "";

        const query: string[] = [];
        if (settings.searchPersons) query.push("type:Person");
        if (settings.searchInstitution) query.push("type:CorporateBody");
        if (settings.searchConference) query.push("type:ConferenceOrEvent");
        if (settings.searchPlace) query.push("type:PlaceOrGeographicName");
        if (settings.searchTopic) query.push("type:SubjectHeading");
        if (settings.searchTitle) query.push("type:Work");
        if (settings.searchFamily) query.push("type:Family");

        return query.join(" OR ");
    }

    protected generateID(): string {
        return Math.random().toString(16).slice(2);
    }

    async handleMember(member: any): Promise<SearchResult | null> {
        if (member.type.indexOf("CorporateBody") > -1) {
            return await this.handleCorporateBody(member);
        }
        if (member.type.indexOf("Person") > -1) {
            return await this.handlePerson(member);
        }
        if (member.type.indexOf("Family") > -1) {
            return await this.handleFamily(member);
        }
        if (member.type.indexOf("ConferenceOrEvent") > -1) {
            return await this.handleConference(member);
        }
        if (member.type.indexOf("PlaceOrGeographicName") > -1) {
            return await this.handlePlace(member);
        }
        if (member.type.indexOf("SubjectHeading") > -1) {
            return await this.handleTopic(member);
        }
        if (member.type.indexOf("Work") > -1) {
            return await this.handleTitle(member);
        }
        return null;
    }

    async handleCorporateBody(member: any): Promise<SearchResult | null> {
        const result: Name = {
            type: "Name",
            nameType: "corporate",
            displayForm: member.preferredName,
            nameIdentifier: [] as NameIdentifier[],
            role: [] as Array<RoleTerm>,
            affiliation: [] as Array<string>,
            nameParts: [],
            valueURI: member.id,
            authority: this.authorityName
        };

        const searchResult: SearchResult = {
            id: member.id,
            result,
            info: [] as Array<SearchResultInfo>
        };

        if ("gndIdentifier" in member) {
            (searchResult.result as Name).nameIdentifier.push({type: "gnd", text: member.gndIdentifier});
        }
        if ("dateOfEstablishment" in member) {
            searchResult.info.push({
                id: this.generateID(),
                type: "string",
                label: await i18n("mir.editor.subject.provider.corporateBody.dateOfEstablishment"),
                value: member.dateOfEstablishment
            });
        }

        await this.addGNDLink(member, searchResult.info);
        return searchResult;
    }

    async handlePerson(member: any): Promise<SearchResult | null> {
        const result: Name = {
            type: "Name",
            nameType: "personal",
            displayForm: member.preferredName,
            nameIdentifier: [] as NameIdentifier[],
            role: [] as Array<RoleTerm>,
            affiliation: [] as Array<string>,
            nameParts: [],
            valueURI: member.id,
            authority: this.authorityName
        };

        const searchResult: SearchResult = {
            id: member.id,
            result,
            info: [] as Array<SearchResultInfo>
        }

        if ("gndIdentifier" in member) {
            (searchResult.result as Name).nameIdentifier.push({type: "gnd", text: member.gndIdentifier});
        }
        if ("dateOfBirth" in member) {
            searchResult.info.push({
                id: this.generateID(),
                type: "string",
                label: await i18n("mir.editor.subject.provider.person.dateOfBirth"),
                value: member.dateOfBirth.join(", ")
            });
        }
        if ("dateOfDeath" in member) {
            searchResult.info.push({
                id: this.generateID(),
                type: "string",
                label: await i18n("mir.editor.subject.provider.person.dateOfDeath"),
                value: member.dateOfDeath.join(", ")
            });
        }

        for (const sameAs of (member.sameAs || [])) {
            if ("id" in sameAs) {
                if (sameAs.id.indexOf(VIAF_ID_PREFIX_1) === 0) {
                    (searchResult.result as Name).nameIdentifier.push({
                        type: "viaf",
                        text: sameAs.id.substring(VIAF_ID_PREFIX_1.length)
                    });
                } else if (sameAs.id.indexOf(VIAF_ID_PREFIX_2) === 0) {
                    (searchResult.result as Name).nameIdentifier.push({
                        type: "viaf",
                        text: sameAs.id.substring(VIAF_ID_PREFIX_2.length)
                    });
                }
            }
        }


        await this.addVariantName(member, searchResult.info);

        const professionCollector: string[] = [];
        for (const profession of (member.professionOrOccupation || [])) {
            if ("label" in profession) {
                professionCollector.push(profession.label);
            }
        }
        if (professionCollector.length > 0) {
            searchResult.info.push({
                label: await i18n("mir.editor.subject.provider.person.profession"),
                value: professionCollector.join(", "),
                id: this.generateID(),
                type: "string"
            });
        }
        await this.addWebsiteIfPresent(member, searchResult.info);
        await this.addGNDLink(member, searchResult.info);

        return searchResult;
    }

    async addVariantName(member: any, info: Array<SearchResultInfo>) {
        if ("variantName" in member) {
            info.push({
                id: this.generateID(),
                type: "string",
                label: await i18n("mir.editor.subject.provider.variantName"),
                value: (member.variantName as string[]).join(", ")
            });
        }
    }

    async addWebsiteIfPresent(member: any, info: Array<SearchResultInfo>) {
        if ("homepage" in member) {
            const urls = (member.homepage as { id: string; label: string }[]).map(hp => hp.id);
            for (const url of urls) {
                info.push({
                    id: this.generateID(),
                    type: "url",
                    label: await i18n("mir.editor.subject.provider.website"),
                    value: url,
                })
            }
        }
    }

    async addGNDLink(member: any, info: Array<SearchResultInfo>) {
        if ("id" in member) {
            info.push({
                id: this.generateID(),
                type: "url",
                label: await i18n("mir.editor.subject.provider.gndLink"),
                value: member.id,
            })
        }
    }

    protected async handleConference(member: any): Promise<SearchResult | null> {
        const conference = await this.handleCorporateBody(member);
        if (conference == null) return null;
        (conference.result as Name).nameType = "conference";
        return conference;
    }

    protected async handlePlace(member: any): Promise<SearchResult | null> {
        const result: Geographic = {
            type: "Geographic",
            text: member.preferredName,
            valueURI: member.id,
            authority: this.authorityName
        };

        const searchResult: SearchResult = {
            id: this.generateID(),
            result,
            info: [] as Array<SearchResultInfo>
        }

        await this.addWebsiteIfPresent(member, searchResult.info);
        await this.addVariantName(member, searchResult.info);

        if ("biographicalOrHistoricalInformation" in member && member.biographicalOrHistoricalInformation.length > 0) {
            for (const bio of member.biographicalOrHistoricalInformation) {
                searchResult.info.push({
                    id: this.generateID(),
                    type: "string",
                    label: await i18n("mir.editor.subject.provider.place.biographicalOrHistoricalInformation"),
                    value: bio
                });
            }
        }

        await this.addGNDLink(member, searchResult.info);
        return searchResult;
    }

    protected async handleTopic(member: any): Promise<SearchResult> {
        const result: Topic = {
            type: "Topic",
            text: member.preferredName,
            valueURI: member.id,
            authority: this.authorityName
        };

        return {
            id: this.generateID(),
            result,
            info: [] as Array<SearchResultInfo>
        }
    }

    protected async handleFamily(member: any):
        Promise<SearchResult | null> {
        const family = await this.handlePerson(member);
        if (family == null) return null;
        (family.result as Name).nameType = "family";
        return family;
    }


    async handleTitle(member: any): Promise<SearchResult> {
        const result: TitleInfo = {
            type: "TitleInfo",
            title: [member.preferredName],
            subTitle: [],
            partNumber: [],
            partName: [],
            nonSort: [],
            authority: this.authorityName,
            valueURI: member.id
        }

        const searchResult: SearchResult = {
            id: this.generateID(),
            result,
            info: [] as Array<SearchResultInfo>
        }

        await this.addVariantName(member, searchResult.info);
        await this.addWebsiteIfPresent(member, searchResult.info);


        return searchResult;
    }

}
