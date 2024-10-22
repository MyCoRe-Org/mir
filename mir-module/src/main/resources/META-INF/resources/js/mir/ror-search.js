const RORSearch = {
    baseURL: "https://api.ror.org/",

    search: async function (text) {
        const q = await fetch(RORSearch.baseURL + "organizations?query=" + encodeURIComponent(text));
        let json = await q.json();

        let rorIdentifiers = [];

        json.items.forEach((item) => {
            item.label = item.name + " (" + item.id + ")";
            rorIdentifiers.push(item);
        });

        rorIdentifiers.sort((a, b) => {
            if (a.label < b.label) {
                return -1;
            }
            if (a.label > b.label) {
                return 1;
            }
            return 0;
        });
        return rorIdentifiers;
    },

    /**
     * Find the option (if any) matching the given label.
     *
     * @param dataListId the id of the datalist
     * @param label the label to find in the given datalist
     *
     * @return the option element with the givel label or null
     * */
    getOption: function (dataListId, label) {
        let dataList = document.getElementById(dataListId);

        for (const option of dataList.childNodes) {
            if (option.value === label) {
                return option;
            }
        }

        return null;
    },

    /**
     * Searches ROR for the given text at https://api.ror.org/ .
     * */
    onInput: async function (event) {
        let input = event.target;
        let dataListId = input.getAttribute("list");

        let option = RORSearch.getOption(dataListId, input.value);

        // User selects value from list
        if (option != null) {
            input.value = option.getAttribute("data-ror");
            event.preventDefault();
            return;
        }

        // Selected value is not in list, actually execute search at ROR
        let result = await RORSearch.search(input.value);
        let dataList = document.getElementById(dataListId);
        dataList.textContent = "";

        // Update datalist with results from ROR
        for (const suggestion of result) {
            let option = document.createElement("option");
            option.setAttribute("value", suggestion.label);
            option.setAttribute("data-ror", suggestion.id);
            dataList.appendChild(option);
        }
    },

    debounce: (f, wait) => {
        let timeoutId = null;

        return (...args) => {
            window.clearTimeout(timeoutId);
            timeoutId = window.setTimeout(() => {
                f.apply(null, args);
            }, wait);
        };
    },

    /**
     * Resolve ror links on metadata page.
     * */
    resolve: async function () {
        let rorLinks = document.querySelectorAll("a.mir-ror-link");
        for (const rorLink of rorLinks) {
            RORSearch.search(rorLink.href).then(data => {
                if (data.length > 0) {
                    if (data[0].name.length > 30) {
                        rorLink.innerHTML = data[0].name.substring(0, 30).trim() + " …";
                    } else {
                        rorLink.innerHTML = data[0].name;
                    }
                    rorLink.setAttribute("title", data[0].name + " | " + data[0].id);
                }
            });
        }
    }
};

/**
 * Adds event handler to every ror input element.
 * */
document.addEventListener('DOMContentLoaded', function () {
    const debouncedInputHandler = RORSearch.debounce(RORSearch.onInput, 500);

    for (const input of document.querySelectorAll('[id="mir-ror-input"]')) {
        // create datalist element with random uuid as element id
        let dataList = document.createElement("datalist");
        dataList.id = self.crypto.randomUUID();

        // set the previously created datalist as list to the ror input element
        input.setAttribute("list", dataList.id);
        input.parentElement.append(dataList);

        // add the actual event handler
        input.addEventListener('input', debouncedInputHandler);
    }

    RORSearch.resolve();
});
