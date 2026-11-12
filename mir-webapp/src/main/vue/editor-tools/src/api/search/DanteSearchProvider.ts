import {SearchSettings} from "@/api/search/SearchSettings";
import {Topic} from "@/api/Subject";
import {SearchProvider, SearchResult, SearchResultInfo} from "@/api/search/SearchProvider";
import {i18n} from "@/api/I18N";

export class DanteSearchProvider extends SearchProvider {

    private readonly configuredBaseUrl?: string;
    private baseUrlPromise?: Promise<string>;
    private readonly vocabulary: string;
    private readonly vocabularies: Set<string>;
    private readonly keys: string[];


    constructor(config: { baseUrl?: string; vocabulary?: string; keys?: string }) {
        super();
        this.configuredBaseUrl = config?.baseUrl || (window as any).danteSearchURL;
        if (!config?.vocabulary) {
            throw new Error("DanteSearchProvider requires a vocabulary.");
        }
        this.vocabulary = config.vocabulary;
        this.vocabularies = new Set(
            config.vocabulary
                .split("|")
                .map(voc => voc.trim())
                .filter(voc => voc.length > 0)
        );
        if (this.vocabularies.size === 0) {
            throw new Error("DanteSearchProvider requires a vocabulary.");
        }
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

        try {
            if (!this.configuredBaseUrl) {
                throw new Error("MIR.Lobid.GND.Search.URL is not set");
            }
            const url = new URL(this.configuredBaseUrl, window.location.href);

            url.searchParams.append("voc", this.vocabulary);
            url.searchParams.append("query", cleanDanteTerm);
            url.searchParams.append("limit", "30");


            const response = await fetch(url.toString());
            if (!response.ok) {
                throw new Error(`HTTP ${response.status} ${response.statusText}`);
            }

            const json = await response.json();
            const limitedJson = json.slice(0, 30);
            const uriLabel: string = (await this.translate("mir.editor.subject.provider.uri")) ?? "URI";

            const keyLabels = new Map<string, string>();
            await Promise.all(
                this.keys
                    .filter(key => key !== "uri")
                    .map(async key => {
                        const label = await this.translate(`mir.editor.subject.provider.${key}`);
                        if (label) {
                            keyLabels.set(key, label);
                        }
                    })
            );

            for (const concept of limitedJson) {
                if (!concept || typeof concept.uri !== "string" || concept.uri.length === 0) {
                    continue;
                }

                const authority = this.extractAuthority(concept);
                if (authority === null) {
                    continue;
                }

                const label = this.extractLabel(concept);

                const topic: Topic = {
                    type: "Topic",
                    text: label,
                    valueURI: concept.uri,
                    authority
                };

                const info: Array<SearchResultInfo> = [
                    {id: this.generateID(), label: uriLabel, type: "url", value: concept.uri}
                ];

                for (const key of this.keys) {
                    const translatedLabel = keyLabels.get(key);
                    if (!translatedLabel) continue;

                    const value = concept[key];
                    if (value === null || value === undefined || value === "null") continue;

                    const formattedValue = this.formatPropertyValue(value);
                    if (!formattedValue || formattedValue === "[object Object]") continue;

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
            console.error(`Error fetching or parsing results for ${this.vocabulary}:`, e);
            throw e;
        }

        return results;
    }


    private async translate(key: string, fallback?: string): Promise<string | undefined> {
        try {
            const translated = await i18n(key);
            if (translated && translated !== key && !translated.startsWith("???")) {
                return translated;
            }
        } catch {
            // Fallback
        }
        return fallback;
    }


    private extractAuthority(concept: any): string | null {
        const notation = concept?.inScheme?.[0]?.notation;
        const voc = Array.isArray(notation) ? notation[0] : notation;
        if (typeof voc !== "string" || !this.vocabularies.has(voc)) {
            return null;
        }
        return voc;
    }

    private extractLabel(concept: any): string {
        const rawPrefLabel = concept.prefLabel;
        if (!rawPrefLabel) {
            return concept.uri;
        }
        if (typeof rawPrefLabel === "object") {
            const currentLang = (window as any).currentLang || "en";

            const firstVal =
                rawPrefLabel[currentLang] ||
                rawPrefLabel.en ||
                rawPrefLabel.de ||
                Object.values(rawPrefLabel)[0];

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
