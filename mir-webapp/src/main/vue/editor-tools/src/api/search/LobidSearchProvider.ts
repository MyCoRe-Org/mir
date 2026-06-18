import {SearchSettings} from "@/api/search/SearchSettings";
import {SearchProvider, SearchResult} from "@/api/search/SearchProvider";

export class LobidSearchProvider extends SearchProvider {

    async search(searchTerm: string, settings: SearchSettings): Promise<Array<SearchResult>> {
        const result: Array<SearchResult> = [];

        const filterQuery = this.settingsToQuery(settings);
        if(filterQuery.trim().length === 0){
            return [];
        }

        const filterQueryComponent = "&filter=" + encodeURIComponent(filterQuery);
        const baseUrl = this.baseUrl || "https://lobid.org/gnd/search";
        const url = baseUrl + "?q=" + encodeURIComponent(searchTerm) +
            filterQueryComponent + "&format=json&json=suggest&size=30";

        try {
            const response = await fetch(url);
            if (!response.ok) {
                console.error("Lobid request failed:", response.status, response.statusText);
                return [];
            }

            const json = await response.json();

            if (json && json.member) {
                for (const member of json.member) {
                    const memberResult = await this.handleMember(member);
                    if (memberResult != null) {
                        result.push(memberResult);
                    }
                }
            }
        } catch (e) {
            console.error("Error parsing results for Lobid:", e);
        }

        return result;
    }
}
