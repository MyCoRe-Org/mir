import {SearchSettings} from "@/api/search/SearchSettings";
import {
    Cartographics,
    Genre,
    Geographic, GeographicCode,
    HierarchicalGeographic,
    Name, NameIdentifier, Occupation, RoleTerm,
    Temporal,
    TitleInfo,
    Topic
} from "@/api/Subject";
import {SearchProvider, SearchResult, SearchResultInfo} from "@/api/search/SearchProvider";

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
        const url = "https://lobid.org/gnd/search?q=" + encodeURIComponent(searchTerm) + "&filter=" + encodeURIComponent(filterQuery) + "&format=json&json=suggest&size=30";

        const response = await fetch(url);
        const json = await response.json();

        json.member.forEach((member: any) => {
            const memberResult = this.handleMember(member);
            if (memberResult != null) {
                result.push(memberResult);
            }
        });


        return result;
    }

    handleMember(member: any): SearchResult | null {
        if (member.type.indexOf("CorporateBody") > -1) {
            return this.handleCorporateBody(member);
        }

        if (member.type.indexOf("Person") > -1) {
            return this.handlePerson(member);
        }

        if (member.type.indexOf("Family") > -1) {
            return this.handleFamily(member);
        }

        if (member.type.indexOf("ConferenceOrEvent") > -1) {
            return this.handleConference(member);
        }

        if (member.type.indexOf("PlaceOrGeographicName") > -1) {
            return this.handlePlace(member);
        }

        if (member.type.indexOf("SubjectHeading") > -1) {
            return this.handleTopic(member);
        }

        if (member.type.indexOf("Work") > -1) {
            return this.handleTitle(member);
        }

        return null;
    }

    handleCorporateBody(member: any): SearchResult | null {
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
                "labelI18N": "mir.editor.corporateBody.dateOfEstablishment",
                "value": member.dateOfEstablishment
            });
        }

        this.addGNDLink(member, searchResult.info);

        return searchResult;
    }


    private handlePerson(member: any): SearchResult | null {
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
                labelI18N: "mir.editor.person.dateOfBirth",
                value: member.dateOfBirth.join(", ")
            });
        }

        if ("dateOfDeath" in member) {
            searchResult.info.push({
                id: this.generateID(),
                type: "string",
                labelI18N: "mir.editor.person.dateOfDeath",
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
        this.addVariantName(member, searchResult.info);

        const professionCollector: string[] = [];
        for (const professionIndex in member.professionOrOccupation) {
            const profession = member.professionOrOccupation[professionIndex];
            if ("label" in profession) {
                professionCollector.push(profession.label);
            }
        }
        if (professionCollector.length > 0) {
            searchResult.info.push({
                labelI18N: "mir.editor.person.profession",
                value: professionCollector.join(", "),
                id: this.generateID(),
                type: "string"
            });
        }
        this.addWebsiteIfPresent(member, searchResult.info);
        this.addGNDLink(member, searchResult.info);

        return searchResult;
    }

    private addVariantName(member: any, info: Array<SearchResultInfo>) {
        if ("variantName" in member) {
            info.push({
                id: this.generateID(),
                type: "string",
                labelI18N: "mir.editor.variantName",
                value: (member.variantName as string[]).join(", ")
            });
        }
    }

    private addWebsiteIfPresent(member: any, info: Array<SearchResultInfo>) {
        if ("homepage" in member) {
            (member.homepage as { id: string; label: string }[]).map(hp => hp.id).forEach((url: string) => {
                info.push({
                    id: this.generateID(),
                    type: "url",
                    labelI18N: "mir.editor.person.website",
                    value: url,
                })
            });
        }
    }

    private addGNDLink(member: any, info: Array<SearchResultInfo>) {
        if("id" in member) {
            info.push({
                id: this.generateID(),
                type: "url",
                labelI18N: "mir.editor.person.gndLink",
                value: member.id,
            })
        }
    }

    private generateID() {
        return Math.random().toString(16);
    }

    private handleConference(member: any) {
        const conference = this.handleCorporateBody(member);
        if (conference == null) {
            return null;
        }

        (conference.result as Name).nameType = "conference";
        return conference;
    }

    private handlePlace(member: any) {
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

        this.addWebsiteIfPresent(member, searchResult.info);
        this.addVariantName(member, searchResult.info);

        member.biographicalOrHistoricalInformation?.forEach((bio: string) => {
            searchResult.info.push({
                id: this.generateID(),
                type: "string",
                labelI18N: "mir.editor.place.biographicalOrHistoricalInformation",
                value: bio
            });
        });

        this.addGNDLink(member, searchResult.info);

        return searchResult;
    }

    private handleTopic(member: any) {
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

    private handleFamily(member: any) {
        const handlePerson = this.handlePerson(member);
        if(handlePerson == null) {
            return null;
        }

        (handlePerson.result as Name).nameType = "family";

        return handlePerson;
    }

    private handleTitle(member: any) {
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

        this.addVariantName(member, searchResult.info);
        this.addWebsiteIfPresent(member, searchResult.info);



        return searchResult;
    }
}