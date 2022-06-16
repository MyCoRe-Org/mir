const store: Record<string, string | Promise<string>> = {}

export async function i18n(key: string): Promise<string> {
    const {webApplicationBaseURL, currentLang} = <any>window;
    if (key in store) {
        const storeContent = store[key];
        if (typeof storeContent === "string") {
            return new Promise((res) => {
                res(storeContent);
            });
        } else {
            return storeContent as Promise<string>
        }
    } else {
        const promise = fetch(`${webApplicationBaseURL}rsc/locale/translate/${currentLang}/${key}`).then(r => r.text());
        store[key] = promise;
        const response = await promise;
        store[key] = response;
        return response;
    }

}