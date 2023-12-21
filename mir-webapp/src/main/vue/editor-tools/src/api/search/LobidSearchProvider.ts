import {SearchSettings} from "@/api/search/SearchSettings";
import {Geographic, Name, NameIdentifier, RoleTerm, TitleInfo, Topic} from "@/api/Subject";
import {SearchProvider, SearchResult, SearchResultInfo} from "@/api/search/SearchProvider";
import {i18n} from "@/api/I18N";

const VIAF_ID_PREFIX_1 = "http://viaf.org/viaf/";
const VIAF_ID_PREFIX_2 = "https://viaf.org/viaf/";

export class LobidSearchProvider extends SearchProvider {

    settingsToQuery(settings: SearchSettings): string {
        let query = [];

        if (settings.searchPersons) {
            query.push("type:Person");
        }

        if (settings.searchInstitution) {
            query.push("type:CorporateBody");
        }

        if (settings.searchConference) {
            query.push("type:ConferenceOrEvent");
        }

        if (settings.searchPlace) {
            query.push("type:PlaceOrGeographicName");
        }

        if (settings.searchTopic) {
            query.push("type:SubjectHeading");
        }

        if (settings.searchTitle) {
            query.push("type:Work");
        }

        if (settings.searchFamily) {
            query.push("type:Family");
        }

        return query.join(" OR ");
    }

    async search(searchTerm: string, settings: SearchSettings): Promise<Array<SearchResult>> {
        const result: Array<SearchResult> = [];

        const filterQuery = this.settingsToQuery(settings);
        if(filterQuery.trim().length === 0){
            return [];
        }

        const filterQueryComponent = "&filter=" + encodeURIComponent(filterQuery);
        const url = "https://lobid.org/gnd/search?q=" + encodeURIComponent(searchTerm) +
            filterQueryComponent + "&format=json&json=suggest&size=30";

        const response = await fetch(url);
        const json = await response.json();

        for (const member of json.member) {
            const memberResult = await this.handleMember(member);
            if (memberResult != null) {
                result.push(memberResult);
            }
        }


        return result;
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
            "type": "Name",
            "nameType": "corporate",
            "displayForm": member.preferredName,
            "nameIdentifier": [] as NameIdentifier[],
            "role": [] as Array<RoleTerm>,
            "affiliation": [] as Array<string>,
            nameParts: [],
            valueURI: member.id,
            authority: "gnd"
        };

        const searchResult = {
            id: member.id,
            result,
            info: [] as Array<SearchResultInfo>
        };

        if ("gndIdentifier" in member) {
            searchResult.result.nameIdentifier.push({type: "gnd", text: member.gndIdentifier});
        }

        if ("dateOfEstablishment" in member) {
            searchResult.info.push({
                "id": this.generateID(),
                "type": "string",
                "label": await i18n("mir.editor.subject.provider.corporateBody.dateOfEstablishment"),
                "value": member.dateOfEstablishment
            });
        }

        await this.addGNDLink(member, searchResult.info);

        return searchResult;
    }


    async handlePerson(member: any): Promise<SearchResult | null> {
        const result: Name = {
            "type": "Name",
            "nameType": "personal",
            "displayForm": member.preferredName,
            "nameIdentifier": [] as NameIdentifier[],
            "role": [] as Array<RoleTerm>,
            "affiliation": [] as Array<string>,
            "nameParts": [],
            valueURI: member.id,
            authority: "gnd"
        };


        const searchResult = {
            id: member.id,
            result,
            info: [] as Array<SearchResultInfo>
        }

        if ("gndIdentifier" in member) {
            searchResult.result.nameIdentifier.push({type: "gnd", text: member.gndIdentifier});
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

        for (const sameAsIndex in member.sameAs) {
            const sameAs = member.sameAs[sameAsIndex];
            if ("id" in sameAs) {
                if (sameAs.id.indexOf(VIAF_ID_PREFIX_1) == 0) {
                    const id = {type: "viaf", text: sameAs.id.substr(VIAF_ID_PREFIX_1.length)};
                    searchResult.result.nameIdentifier.push(id);
                } else if (sameAs.id.indexOf(VIAF_ID_PREFIX_2) == 0) {
                    const id = {type: "viaf", text: sameAs.id.substr(VIAF_ID_PREFIX_2.length)};
                    searchResult.result.nameIdentifier.push(id);
                }
            }
        }
        (await this.addVariantName(member, searchResult.info));

        const professionCollector: string[] = [];
        for (const professionIndex in member.professionOrOccupation) {
            const profession = member.professionOrOccupation[professionIndex];
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
            for (let i = 0; i < urls.length; i++){
                const url: string = urls[i];
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
        if("id" in member) {
            info.push({
                id: this.generateID(),
                type: "url",
                label: await i18n( "mir.editor.subject.provider.gndLink"),
                value: member.id,
            })
        }
    }

    private generateID() {
        return Math.random().toString(16);
    }

    async handleConference(member: any) {
        const conference = await this.handleCorporateBody(member);
        if (conference == null) {
            return null;
        }

        (conference.result as Name).nameType = "conference";
        return conference;
    }

    async handlePlace(member: any) {
        const result: Geographic = {
            "type": "Geographic",
            text: member.preferredName,
            valueURI: member.id,
            authority: "gnd"
        };

        const searchResult = {
            id: this.generateID(),
            result,
            info: [] as Array<SearchResultInfo>
        }

        await this.addWebsiteIfPresent(member, searchResult.info);
        await this.addVariantName(member, searchResult.info);

        if("biographicalOrHistoricalInformation" in member && member.biographicalOrHistoricalInformation.length > 0){
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

    async handleTopic(member: any) {
        const result: Topic = {
            "type": "Topic",
            text: member.preferredName,
            valueURI: member.id,
            authority: "gnd"
        };

        const searchResult = {
            id: this.generateID(),
            result,
            info: [] as Array<SearchResultInfo>
        }

        return searchResult;
    }

    async handleFamily(member: any) {
        const handlePerson = await this.handlePerson(member);
        if(handlePerson == null) {
            return null;
        }

        (handlePerson.result as Name).nameType = "family";

        return handlePerson;
    }

    async handleTitle(member: any) {
        const result: TitleInfo = {
            "type": "TitleInfo",
            title: [member.preferredName],
            subTitle: [],
            partNumber: [],
            partName: [],
            nonSort: [],
            authority: "gnd",
            valueURI: member.id
        }



        const searchResult = {
            id: this.generateID(),
            result,
            info: [] as Array<SearchResultInfo>
        }

        await this.addVariantName(member, searchResult.info);
        await this.addWebsiteIfPresent(member, searchResult.info);



        return searchResult;
    }
}