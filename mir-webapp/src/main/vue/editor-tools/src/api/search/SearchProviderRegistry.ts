import {LobidSearchProvider} from "@/api/search/LobidSearchProvider";
import {DanteSearchProvider} from "@/api/search/DanteSearchProvider";
import {SearchProvider} from "@/api/search/SearchProvider";

export type SearchProviderConstructor = new (config: any) => SearchProvider;

export const SearchProviderClasses: Record<string, SearchProviderConstructor> = {
    lobid: LobidSearchProvider,
    dante: DanteSearchProvider,
};


declare global {
    interface Window {
        SearchProviderRegistry?: Record<string, SearchProviderConstructor>;
    }
}

if (typeof window !== "undefined") {
    window.SearchProviderRegistry = {
        ...SearchProviderClasses,
        ...(window.SearchProviderRegistry || {}),
    };
}


export function createProviderInstance(type: string, config: any): SearchProvider | null {
    const win = typeof window !== "undefined" ? window : undefined;
    const ProviderClass = win?.SearchProviderRegistry?.[type] || SearchProviderClasses[type];

    if (!ProviderClass) {
        console.warn(`[MIR] Unknown search provider type: "${type}".`);
        return null;
    }

    try {
        return new ProviderClass(config);
    } catch (error) {
        console.error(`[MIR] Failed to instantiate search provider type: "${type}".`, error);
        return null;
    }
}
