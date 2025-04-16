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

import {GenericMetadata, Identifier, NameSearchResult, SearchProvider, SearchProviderRegistry} from "@/api/SearchProvider";
import {uuid} from "@/api/Utils";
import {i18n} from "@/api/I18N";

export class ViafSearchProvider implements SearchProvider {

    name = "Viaf";

    async searchPerson(searchTerm: string) {
        const url = "https://viaf.org/viaf/AutoSuggest?";
        const params = new URLSearchParams();
        params.append("query", searchTerm);
        params.toString()
        const response = await fetch(url + params.toString(), {
            method: "GET",
            headers: {
                "Accept": "application/json"
            }
        });
        const data = await response.json()
        return this.processData(data);
    }


    async processData(data: any): Promise<NameSearchResult[]> {
        const result: NameSearchResult[] = [];
        const otherData = await i18n("mir.namePart.other");


        for (const suggestIndex in data.result) {
            const suggest = data.result[suggestIndex];
            if (suggest.nametype == "personal") {
                const displayFormUnparsed = suggest.displayForm as string;


                const person: NameSearchResult = {
                    id: uuid(),
                    displayForm: this.parseDisplayForm(displayFormUnparsed),
                    identifier: [] as Identifier[],
                    metadata: [] as GenericMetadata[],
                    person: true
                }

                if (displayFormUnparsed.length > person.displayForm.length) {
                    const rest = displayFormUnparsed.substr(displayFormUnparsed.indexOf(",") + 1);
                    person.metadata.push({id: uuid(), label: otherData, value: rest});
                }

                this.addIdentifierType(suggest, person, "viaf", "viafid");
                this.addIdentifierType(suggest, person, "gnd", "dnb");
                this.addIdentifierType(suggest, person, "selibre", "selibre");
                this.addIdentifierType(suggest, person, "loc", "lc");

                result.push(person);
            }
        }
        return result;
    }

    private addIdentifierType(suggest: any, person: NameSearchResult, idType: string, type: string) {
        if (type in suggest) {
            person.identifier.push({type: idType, value: suggest[type]})
        }
    }

    public parseDisplayForm(displayForm: string) {
        const parts = displayForm.split(",");
        return parts[0];
    }

    static init() {
        if (SearchProviderRegistry.getProviders().filter(p => p instanceof ViafSearchProvider).length == 0) {
            SearchProviderRegistry.addPersonSearchProvider("Viaf", new ViafSearchProvider());
        }
    }

}