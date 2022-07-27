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

import {GenericMetadata, NameSearchResult, SearchProvider, SearchProviderRegistry} from "@/api/SearchProvider";
import {escapeRegex, uuid} from "@/api/Utils";

export class LocalSearchProvider implements SearchProvider {
    name = "Lokal";

    static init() {
        if (SearchProviderRegistry.getProviders().filter(p => p instanceof LocalSearchProvider).length == 0) {
            SearchProviderRegistry.addPersonSearchProvider("Lokal", new LocalSearchProvider());
        }
    }


    async searchPerson(searchTerm: string): Promise<NameSearchResult[]> {
        const result = [] as NameSearchResult[];
        const url = this.getUrl(searchTerm);

        const response = await fetch(url);
        const json = await response.json();

        const array = json.terms["mods.pindexname.published"] as Array<string|number>;

        for (let i = 0; i < array.length; i+=2) {
            const term = array[i] as string;

            const [name, type, identifier] = term.split(":", 3);

            const person: NameSearchResult = {
                id: uuid(),
                displayForm: name,
                identifier: type!=undefined && identifier!=undefined ? [ {type, value:identifier} ] : [],
                metadata: [] as GenericMetadata[],
                person: true
            } ;

            result.push(person);
        }


        return result;
    }

    getUrl(searchTerm:string) {
        return (window as any)["webApplicationBaseURL"] + "servlets/solr/personindexp?XSL.Style=xml&wt=json&terms.regex=" + escapeRegex(searchTerm) + ".*";
    }
}