import {LobidSearchProvider} from "@/api/search/LobidSearchProvider";
import {DanteSearchProvider} from "@/api/search/DanteSearchProvider";

export const SearchProviders: Record<string, any> = {};

const pendingPromises: Promise<void>[] = [];

export function instantiateProvider(item: { id: string; type: string; config: any }) {
    try {
        const authorityName = item.config?.authorityName;
        if (!authorityName) {
            console.error(`[MIR] Missing required "authorityName" for provider type: "${item.type}" (ID: "${item.id}"). Provider discarded.`);
            return;
        }

        switch (item.type) {
            case "lobid": {
                SearchProviders[item.id] = new LobidSearchProvider(item.config);
                break;
            }
            case "dante": {
                SearchProviders[item.id] = new DanteSearchProvider(item.config);
                break;
            }
            default: {
                const win = typeof window !== "undefined" ? (window as any) : {};
                const CustomProviderClass = win.SearchProviderRegistry?.[item.type];

                if (CustomProviderClass) {
                    SearchProviders[item.id] = new CustomProviderClass(item.config);
                } else {
                    console.warn(`[MIR] Unknown search provider type: "${item.type}" for ID "${item.id}".`);
                }
                break;
            }
        }
    } catch (error) {
        console.error(`[MIR] Failed to instantiate search provider type: "${item.type}" for ID "${item.id}".`, error);
    }
}

export function registerProvider(item: { id: string; type: string; config: any }) {
    instantiateProvider(item);
    const promise = Promise.resolve();
    pendingPromises.push(promise);
    return promise;
}

export async function ensureProvidersLoaded() {
    await Promise.all(pendingPromises);
}

declare global {
    interface Window {
        MIRPendingProviders?: Array<any> & { push: (item: any) => number };
        SearchProviderRegistry?: Record<string, new (config: any) => any>;
    }
}

if (typeof window !== "undefined") {
    const win = window as Window;
    const queue = (win.MIRPendingProviders || []) as Array<any> & { push: (item: any) => number };

    if (Array.isArray(queue)) {
        queue.forEach(registerProvider);
    }

    queue.push = (item: any) => {
        registerProvider(item);
        return queue.length;
    };

    win.MIRPendingProviders = queue;
}
