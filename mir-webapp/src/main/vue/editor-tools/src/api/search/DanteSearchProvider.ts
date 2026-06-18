import { SearchSettings } from "@/api/search/SearchSettings";
import {Topic } from "@/api/Subject";
import {SearchProvider,SearchResult, SearchResultInfo} from "@/api/search/SearchProvider";


export class DanteSearchProvider extends SearchProvider {

    async search(searchTerm: string, settings: SearchSettings): Promise<Array<SearchResult>> {
        if (!settings || !settings.searchTopic) {
            return [];
        }

        const results: Array<SearchResult> = [];
        const cleanDanteTerm = searchTerm && searchTerm.trim() !== "" ? `*${searchTerm}*` : "*";
        const url = `${this.baseUrl}?voc=${encodeURIComponent(this.vocabulary)}&query=${encodeURIComponent(cleanDanteTerm)}`;

        try {
            const response = await fetch(url);
            if (!response.ok) {
                console.error(`Request failed (${this.vocabulary}):`, response.status, response.statusText);
                return [];
            }

            const json = await response.json();

            for (const concept of json) {
                const label = concept.prefLabel?.de || concept.prefLabel?.en || concept.uri;

                const topic: Topic = {
                    type: "Topic",
                    text: label,
                    valueURI: concept.uri,
                    authority: this.authorityName
                };

                const info: Array<SearchResultInfo> = [
                    { id: this.generateID(), label: "URI", type: "url", value: concept.uri }
                ];

                if (concept.prefLabel?.en) {
                    info.push({
                        id: this.generateID(),
                        label: "English Label",
                        type: "string",
                        value: concept.prefLabel.en
                    });
                }
                if (concept.prefLabel?.de) {
                    info.push({
                        id: this.generateID(),
                        label: "German Label",
                        type: "string",
                        value: concept.prefLabel.de
                    });
                }
                if (concept.notation?.length) {
                    info.push({
                        id: this.generateID(),
                        label: "Notation",
                        type: "string",
                        value: concept.notation.join(", ")
                    });
                }

                results.push({
                    id: concept.uri,
                    result: topic,
                    info
                });
            }
        } catch (e) {
            console.error(`Error parsing results for ${this.vocabulary}:`, e);
        }

        return results;
    }
}
