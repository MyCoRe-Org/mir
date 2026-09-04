import { SearchSettings } from "@/api/search/SearchSettings";
import {Topic } from "@/api/Subject";
import {SearchProvider,SearchResult, SearchResultInfo} from "@/api/search/SearchProvider";
import {i18n} from "@/api/I18N";

export class DanteSearchProvider extends SearchProvider {

    async search(searchTerm: string, settings: SearchSettings): Promise<Array<SearchResult>> {
        if (!settings || !settings.searchTopic || !this.baseUrl) {
            return [];
        }

        const results: Array<SearchResult> = [];
        const cleanDanteTerm = searchTerm && searchTerm.trim() !== "" ? searchTerm.trim() : "*";
        const url = `${this.baseUrl}?voc=${encodeURIComponent(this.vocabulary)}&query=${encodeURIComponent(cleanDanteTerm)}&limit=30`;

        try {
            const response = await fetch(url);
            if (!response.ok) {
                console.error(`Request failed (${this.vocabulary}):`, response.status, response.statusText);
                return [];
            }

            const json = await response.json();
            const limitedJson = json.slice(0, 30);

            for (const concept of limitedJson) {
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

                for (const key of this.keys) {
                    if (key === "uri") continue;

                    const value = concept[key];
                    if (value === null || value === undefined || value === "null") continue;

                    const formattedValue = this.formatPropertyValue(value);
                    if (!formattedValue || formattedValue === "[object Object]") continue;

                    const translationKey = `mir.topic.provider.${key}`;
                    let translatedLabel: string | undefined;
                    try {
                        translatedLabel = await i18n(translationKey);
                    } catch {
                        // Fallback
                    }

                    if (!translatedLabel || translatedLabel === translationKey || translatedLabel.startsWith("???")) {
                        continue;
                    }

                    info.push({
                        id: this.generateID(),
                        label: translatedLabel,
                        type: "string",
                        value: formattedValue
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

    private formatPropertyValue(value: any): string {
        if (Array.isArray(value)) {
            return value
                .map(v => typeof v === "object" && v !== null
                    ? (v.prefLabel?.de || v.prefLabel?.en || v.label || v.uri || Object.values(v)[0] || "")
                    : String(v))
                .filter(Boolean)
                .join(", ");
        }

        if (typeof value === "object" && value !== null) {
            const obj = value as Record<string, any>;
            const firstVal = obj.de || obj.en || Object.values(obj)[0];
            if (Array.isArray(firstVal)) {
                return firstVal.filter(Boolean).join(", ");
            }
            return firstVal !== null && firstVal !== undefined ? String(firstVal) : "";
        }

        return String(value);
    }
}
