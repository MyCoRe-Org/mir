import {UnwrapNestedRefs} from "@vue/reactivity";
import {reactive} from "vue";

const store: Record<string, string | Promise<string>> = {}


export function provideTranslations<K extends string = string>(translations: K[]): UnwrapNestedRefs<Record<K, string>> {
    const prep = {};
    translations.forEach(key => {
        (prep as any)[key] = "";
    });
    const translationsResult = reactive(prep) as UnwrapNestedRefs<Record<K, string>>;

    translations.forEach(key => {
       i18n(key).then(r => (translationsResult as any)[key]  = r);
    });

   return translationsResult;
}

export async function i18n(key: string): Promise<string> {
    const {webApplicationBaseURL, currentLang} = window as any;
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