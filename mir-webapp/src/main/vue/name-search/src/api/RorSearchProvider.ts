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

export class RorSearchProvider implements SearchProvider {
    name = "Ror";

    static init() {
        if (SearchProviderRegistry.getProviders().filter(p => p instanceof RorSearchProvider).length == 0) {
            SearchProviderRegistry.addPersonSearchProvider("Ror", new RorSearchProvider());
        }
    }

    async searchPerson(searchTerm: string) {
        const responsePromise = await fetch(`https://api.ror.org/v2/organizations?query=${encodeURIComponent(searchTerm)}`);
        const json = await responsePromise.json();

        const result: NameSearchResult[] = [];

        for (const itemIndex in json.items) {
            const item = json.items[itemIndex];

            let displayName = "";
            for (let n of item.names) {
                if (n.types.includes("ror_display")) {
                    displayName = n.value;
                    break;
                }
            }

            const searchResult: NameSearchResult = {
                metadata: [],
                identifier: [{type: "ror", value: item.id.substring("https://ror.org/".length)}],
                displayForm: displayName,
                id: uuid(),
                person: false
            };

            for (const type in item.external_ids) {
                if ("preferred" in item.external_ids[type] && item.external_ids[type].preferred != null) {
                    searchResult.identifier.push({type, value: item.external_ids[type].preferred});
                } else {
                    if ("all" in item.external_ids[type]) {
                        if (item.external_ids[type].all instanceof Array) {
                            for (const index in item.external_ids[type].all) {
                                searchResult.identifier.push({
                                    type, value: item.external_ids[type].all[index]
                                });
                            }
                        } else if (typeof item.external_ids[type].all == "string" && item.external_ids[type].all.length > 0) {
                            searchResult.identifier.push({
                                type, value: item.external_ids[type].all
                            });
                        }
                    }
                }
            }

            let refs: string[] = [];
            let wikipediaURL = null;

            for (let l of item.links) {
                if (l.type !== "wikipedia") {
                    refs.push(l.value);
                } else {
                    wikipediaURL = l.value;
                }
            }

            if (refs.length > 0) {
                searchResult.metadata.push(
                    {
                        id: uuid(),
                        label: await i18n("mir.editor.person.link"),
                        value: refs.join(", ")
                    });
            }

            if (wikipediaURL != null && wikipediaURL.length > 0) {
                searchResult.metadata.push(
                    {
                        id: uuid(),
                        label: await i18n("mir.editor.person.wikipedia"),
                        value: wikipediaURL
                    }
                );
            }

            result.push(searchResult);
        }

        return result;
    }
}
