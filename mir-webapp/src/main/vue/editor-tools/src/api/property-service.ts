declare const webApplicationBaseURL: string;

let configPromise: Promise<Record<string, string>> | undefined;

function loadConfig(): Promise<Record<string, string>> {
    if (!configPromise) {
        const url = `${webApplicationBaseURL}rsc/frontend-config`;
        configPromise = fetch(url)
            .then(r => (r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status} bei ${url}`))))
            .catch(e => {
                configPromise = undefined;
                throw e;
            });
    }
    return configPromise;
}

export async function getProperty(
  key: string,
  fallback?: string
): Promise<string | undefined> {
  return (await loadConfig())[key] ?? fallback;
}
