import {SearchSettings} from "@/api/search/SearchSettings";
import {Topic} from "@/api/Subject";
import {SearchProvider, SearchResult, SearchResultInfo} from "@/api/search/SearchProvider";
import {i18n} from "@/api/I18N";

export class DanteSearchProvider extends SearchProvider {

    private readonly baseUrl: string;
    private readonly vocabulary: string;
    private readonly keys: string[];

    constructor(config: { baseUrl?: string; vocabulary?: string; keys?: string }) {
        super();
        if (!config?.baseUrl) {
            throw new Error("DanteSearchProvider requires a baseUrl.");
        }
        if (!config?.vocabulary) {
            throw new Error("DanteSearchProvider requires a vocabulary.");
        }
        this.baseUrl = config.baseUrl;
        this.vocabulary = config.vocabulary;
        this.keys = (config.keys || "")
            .split(",")
            .map(key => key.trim())
            .filter(key => key.length > 0);
    }

    async search(searchTerm: string, settings: SearchSettings): Promise<Array<SearchResult>> {
        if (!settings || !settings.searchTopic) {
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
                const label = this.extractLabel(concept);

                const topic: Topic = {
                    type: "Topic",
                    text: label,
                    valueURI: concept.uri,
                    authority: "dante"
                };

                const info: Array<SearchResultInfo> = [
                    {id: this.generateID(), label: "URI", type: "url", value: concept.uri}
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

    private extractLabel(concept: any): string {
        const rawPrefLabel = concept.prefLabel;
        if (!rawPrefLabel) {
            return concept.uri;
        }
        if (typeof rawPrefLabel === "object") {
            const firstVal = rawPrefLabel.de || rawPrefLabel.en || Object.values(rawPrefLabel)[0];
            return (Array.isArray(firstVal) ? firstVal[0] : firstVal) || concept.uri;
        }
        return rawPrefLabel;
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
