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

export class ProxiedOrcidProvider implements SearchProvider {
    name = "Orcid";

    static init() {
        if (process.env.NODE_ENV === 'development') {
            return;
        }
        if (SearchProviderRegistry.getProviders().filter(p => p instanceof ProxiedOrcidProvider).length == 0) {
            SearchProviderRegistry.addPersonSearchProvider("Orcid", new ProxiedOrcidProvider());
        }
    }

    async searchPerson(searchTerm: string): Promise<NameSearchResult[]> {
        const response = await fetch(`${this.url}?q=${encodeURIComponent(searchTerm)}`);
        const json = await response.json();
        const result = [];
        for (const orcidPerson of json) {
            if (orcidPerson.type == "personal") {

                const person: NameSearchResult = {
                    id: uuid(),
                    displayForm: orcidPerson.label,
                    identifier: [] as Identifier[],
                    metadata: [] as GenericMetadata[],
                    person: true
                }

                person.metadata.push({id: uuid(), label: await i18n("mir.namePart.given"), value: orcidPerson.forename})
                person.metadata.push({
                    id: uuid(),
                    label: await i18n("mir.namePart.family "),
                    value: orcidPerson.sureName
                })
                person.identifier.push({type: "orcid", value: orcidPerson.value.substr("https://orcid.org/".length)});

                result.push(person);
            }
        }

        return result;
    }

    get url() {
        return (window as any)["webApplicationBaseURL"] + "servlets/MIROrcidServlet"
    }
}