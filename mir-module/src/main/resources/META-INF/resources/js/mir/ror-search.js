/**
 * Initializes ROR-based affiliation autocomplete with Select2
 * in XEditor forms, with i18n support and fallback messages.
 */
document.addEventListener("DOMContentLoaded", async function () {

    const RORSearch = {
        baseURL: "https://api.ror.org/",
        currentLanguage: window?.currentLang,
        webApplicationBaseURL: window?.webApplicationBaseURL,
    };

    /** Selector for affiliation input fields */
    const affiliationSelectSelector = '.mir-select-affiliation';

    // Exit early if no relevant XEditor input is present
    if ($(affiliationSelectSelector).length === 0) {
        return;
    }

    /** i18n translation keys used for Select2 messages */
    const errorKeyMessages = [
        "mir.add.more.text.placeholder",
        "mir.editor.subject.search.result.empty",
        "mir.searching.placeholder"
    ];

    /** Fallback messages if i18n fails */
    const defaultMessages = {
        "mir.add.more.text.placeholder": "Please enter more text...",
        "mir.editor.subject.search.result.empty": "No results found.",
        "mir.searching.placeholder": "Searching..."
    };

    const errorKeyMessagesList = new ErrorKeyMessageBuilder(RORSearch.currentLanguage,
        RORSearch.webApplicationBaseURL);

    /**
     * Loads required translation keys and initializes the Select2 widget
     * with internationalized messages and fallback support.
     */
    async function loadAllTranslations() {
        await errorKeyMessagesList.addTranslationKeys(errorKeyMessages);
        initializeSelect2(errorKeyMessagesList);
    }

    /**
     * Initialize Select2 for affiliation field using ROR search.
     *
     * @param {ErrorKeyMessageBuilder} translationHelper - Instance of translation helper with loaded translations.
     */
    function initializeSelect2(translationHelper) {
        if ($(affiliationSelectSelector).length === 0) return;

        $(affiliationSelectSelector).select2({
            ajax: {
                url: RORSearch.baseURL + 'organizations',
                dataType: 'json',
                delay: 500,
                data: function (params) {
                    const query = params.term.trim();
                    // Special handling for GRID IDs
                    if (/^grid\.\d+\.\d+$/.test(query)) {
                        return {query: `"${query}"`};
                    }
                    return {query};
                },
                processResults: function (data) {
                    return {
                        results: data.items.map(function (item) {
                            return {
                                id: `${item.name} (${item.id ?? 'unknown'})`,
                                text: `${item.name} (${item.id ?? 'unknown'})`,
                                ror_id: item.id ?? null
                            };
                        })
                    };
                },
                cache: true
            },
            minimumInputLength: 1,
            language: {
                inputTooShort: () => translationHelper.getTranslationWithFallback("mir.add.more.text.placeholder", defaultMessages),
                noResults: () => translationHelper.getTranslationWithFallback("mir.editor.subject.search.result.empty", defaultMessages),
                searching: () => translationHelper.getTranslationWithFallback("mir.searching.placeholder", defaultMessages),
            }
        });

        // Reset selection on initial load if no valid option selected
        $(affiliationSelectSelector).each(function () {
            const selectedText = $(this).find("option:selected").text().trim();
            if (selectedText === "" || selectedText === " ()") {
                $(this).val(null).trigger("change");
            }
        });
    }

    await loadAllTranslations();
});

/**
 * A helper class for managing translation keys and their resolved values,
 * especially useful in asynchronous UI contexts like Select2.
 */
class ErrorKeyMessageBuilder {
    /**
     * Constructs a new ErrorKeyMessageBuilder instance.
     * @param {string} language - The current language code (e.g., "en", "de").
     * @param {string} baseURL - The base URL of the web application.
     */
    constructor(language, baseURL) {
        if (typeof language !== 'string' || typeof baseURL !== 'string') {
            throw new Error("Both 'language' and 'baseURL' must be strings");
        }

        /** @private */
        this.language = language;

        /** @private */
        this.baseURL = baseURL;

        /**
         * Map to store resolved translations.
         * @type {Map<string, string>}
         */
        this.translationMap = new Map();

        /**
         * Map to store pending translation promises.
         * Prevents duplicate fetches for the same key.
         * @type {Map<string, Promise<void>>}
         */
        this.translationPromises = new Map();
    }

    /**
     * Adds translation keys to the builder and fetches their translations.
     * Skips keys that are already cached or being fetched.
     *
     * @param {string|string[]} keys - A single key or an array of keys to add.
     * @returns {Promise<void>} Resolves when all translations are fetched and stored.
     * @throws {Error} If keys are not strings or an array of strings.
     */
    async addTranslationKeys(keys) {
        if (typeof keys === 'string') {
            keys = [keys];
        } else if (!Array.isArray(keys)) {
            throw new Error('Keys must be a string or an array of strings');
        }

        for (const key of keys) {
            if (typeof key !== 'string') {
                throw new Error('Each key must be a string');
            }

            if (!this.translationMap.has(key) && !this.translationPromises.has(key)) {
                const promise = this.fetchTranslation(key);
                this.translationPromises.set(key, promise);
                await promise;
            }
        }
    }

    /**
     * Fetches and stores the translation for a given key.
     * Uses internal language and base URL values.
     *
     * @private
     * @param {string} key - The translation key to fetch.
     * @returns {Promise<void>} Resolves when the translation is stored.
     * @throws {Error} If fetching fails.
     */
    async fetchTranslation(key) {
        if (typeof key !== 'string') {
            throw new Error('Translation key must be a string');
        }

        const url = `${this.baseURL}rsc/locale/translate/${this.language}/${key}`;

        try {
            const response = await fetch(url);
            const translation = await response.text();

            this.translationMap.set(key, translation);
            this.translationPromises.delete(key); // Clean up
        } catch (error) {
            console.warn(`Error fetching translation for key "${key}":`, error);
            throw error;
        }
    }

    /**
     * Checks if the translation for a given key is already loaded.
     * @param {string} key - The translation key to check.
     * @returns {boolean} True if translation is available.
     */
    isTranslationReady(key) {
        return this.translationMap.has(key);
    }

    /**
     * Returns the stored translation for a given key, or null if not available.
     * @param {string} key - The translation key.
     * @returns {string|null} The translated string or null.
     */
    getTranslation(key) {
        return this.translationMap.get(key) || null;
    }

    /**
     * Returns the translation for a given key, or a fallback string if not available.
     *
     * @param {string} key - The translation key.
     * @param {Object<string, string>} fallbackMap - Map of fallback strings.
     * @returns {string} The translated or fallback string.
     */
    getTranslationWithFallback(key, fallbackMap) {
        return this.isTranslationReady(key)
            ? this.getTranslation(key)
            : fallbackMap[key] || '';
    }
}

