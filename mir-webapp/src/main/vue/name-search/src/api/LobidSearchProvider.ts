/*
 *  This file is part of ***  M y C o R e  ***
 *  See http://www.mycore.de/ for details.
 *
 *  MyCoRe is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  MyCoRe is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */


import {NameSearchResult, SearchProvider, SearchProviderRegistry} from "@/api/SearchProvider";
import {uuid} from "@/api/Utils";
import {i18n} from "@/api/I18N";


const VIAF_ID_PREFIX_1 = "http://viaf.org/viaf/";
const VIAF_ID_PREFIX_2 = "https://viaf.org/viaf/";

export class LobidSearchProvider implements SearchProvider {

    name = "Lobid";

    static init() {
        if (SearchProviderRegistry.getProviders().filter(p => p instanceof LobidSearchProvider).length == 0) {
            SearchProviderRegistry.addPersonSearchProvider("Lobid", new LobidSearchProvider());
        }
    }

    async searchPerson(searchTerm: string): Promise<NameSearchResult[]> {
        const url = `https://lobid.org/gnd/search?filter=type:DifferentiatedPerson%20OR%20type:CorporateBody&json=suggest&q=${encodeURIComponent(searchTerm)}&size=30`;
        const response = await fetch(url);
        const json = await response.json()
        const result: NameSearchResult[] = [];

        for (const memberIndex in json.member) {
            const member = json.member[memberIndex];

            if(member.type.indexOf("CorporateBody") == -1 && member.type.indexOf("DifferentiatedPerson") == -1){
                continue;
            }

            const searchResult: NameSearchResult = {
                metadata: [],
                identifier: [{type: "gnd", value: member.gndIdentifier}],
                displayForm: member.preferredName,
                id: uuid(),
                person: member.type.indexOf("DifferentiatedPerson") > -1
            };

            const professionCollector: string[] = [];
            for (const professionIndex in member.professionOrOccupation) {
                const profession = member.professionOrOccupation[professionIndex];
                if ("label" in profession) {
                    professionCollector.push(profession.label);
                }
            }
            if (professionCollector.length > 0) {
                searchResult.metadata.push({
                    label: await i18n("mir.editor.person.profession"),
                    value: professionCollector.join(", "),
                    id: uuid()
                });
            }

            if("variantName" in member){
                searchResult.metadata.push({
                    label: await i18n("mir.editor.person.alternateNames"),
                    value: (member.variantName as string[]).join(", "),
                    id: uuid()
                })
            }

            if("homepage" in member) {
                searchResult.metadata.push({
                    label: await i18n("mir.editor.person.website"),
                    value: (member.homepage as {id: string; label: string}[]).map(hp => hp.id).join(", "),
                    id: uuid()
                })
            }

            for (const genderIndex in member.gender) {
                const gender = member.gender[genderIndex];
                searchResult.metadata.push({label: await i18n("mir.editor.person.gender"), value: gender.label, id: uuid()});
            }

            for (const sameAsIndex in member.sameAs) {
                const sameAs = member.sameAs[sameAsIndex];
                if ("id" in sameAs) {
                    if (sameAs.id.indexOf(VIAF_ID_PREFIX_1) == 0) {
                        const id = {type: "viaf", value: sameAs.id.substr(VIAF_ID_PREFIX_1.length)};
                        searchResult.identifier.push(id);
                    } else if (sameAs.id.indexOf(VIAF_ID_PREFIX_2) == 0) {
                        const id = {type: "viaf", value: sameAs.id.substr(VIAF_ID_PREFIX_2.length)};
                        searchResult.identifier.push(id);
                    }
                }
            }

            if (member.dateOfBirth > 0) {
                searchResult.metadata.push({
                    label: await i18n("mir.editor.person.dateOfBirth"),
                    value: <string>member.dateOfBirth.join(", "),
                    id: uuid()
                });
            }

            result.push(searchResult);
        }

        return result;
    }

}