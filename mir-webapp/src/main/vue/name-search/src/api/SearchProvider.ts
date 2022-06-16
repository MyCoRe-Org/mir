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

export class SearchProviderRegistry {

    private static _searchProviderMap: Record<string, SearchProvider> = {};

    public static addPersonSearchProvider(id: string, provider: SearchProvider) {
        this._searchProviderMap[id] = provider;
    }

    public static getProviders() {
        return Object.values(this._searchProviderMap);
    }
}

export interface SearchProvider {
    name: string;

    searchPerson(searchTerm: string): Promise<NameSearchResult[]>;
}

export interface NameSearchResult {
    id: string; // a id that needs to be unique in all results (you should just generate a UUID), can change in next request
    displayForm: string;
    identifier: Identifier[];
    metadata: GenericMetadata[];
    person: boolean;
}

export interface GenericMetadata {
    label: string;
    value: string;
    id: string;
}

export interface Identifier {
    type: string;
    value: string;
}