export const SearchProviders: Record<string, any> = {};

const pendingPromises: Promise<void>[] = [];

export async function instantiateProvider(item: { id: string; type: string; config: any }) {
    switch (item.type) {
        case "lobid": {
            const { LobidSearchProvider } = await import("@/api/search/LobidSearchProvider");
            SearchProviders[item.id] = new LobidSearchProvider(item.config);
            break;
        }
        case "dante": {
            const { DanteSearchProvider } = await import("@/api/search/DanteSearchProvider");
            SearchProviders[item.id] = new DanteSearchProvider(item.config);
            break;
        }
        default: {
            const win = typeof window !== "undefined" ? (window as any) : {};
            const CustomProviderClass = win.MyCoReSearchProviderRegistry?.[item.type];

            if (CustomProviderClass) {
                SearchProviders[item.id] = new CustomProviderClass(item.config);
            } else {
                console.warn(`[MyCoRe] Unknown search provider type: "${item.type}" for ID "${item.id}".`);
            }
            break;
        }
    }
}

export function registerProvider(item: { id: string; type: string; config: any }) {
    const promise = instantiateProvider(item);
    pendingPromises.push(promise);
    return promise;
}

export async function ensureProvidersLoaded() {
    await Promise.all(pendingPromises);
}

if (typeof window !== "undefined") {
    const win = window as any;

    if (win.MyCoRePendingProviders && Array.isArray(win.MyCoRePendingProviders)) {
        win.MyCoRePendingProviders.forEach(registerProvider);
    }

    win.MyCoRePendingProviders = {
        push: (item: any) => {
            registerProvider(item);
        }
    };
}
