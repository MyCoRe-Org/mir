/*
$(document).ready(function () {

    const handler = async function handleEvent(event) {
        console.log(event);
        const a = await fetch("https://api.ror.org/organizations")
            .then(r => r.json())
            .then(json => console.log(json));
    }

    for (const input of document.querySelectorAll('[id="mir-ror-input"]')) {
        console.log(input.value);
        input.addEventListener('input', handler);
    }
});*/

const RORSearch = {
    maxLength: 60,

    search: async function (text) {
        const q = await fetch("https://api.ror.org/organizations?query=" + encodeURIComponent(text));
        let json = await q.json();

        let rorIdentifiers = [];

        json.items.forEach((rorIdentifier) => {
            let label = rorIdentifier.name;
            let item = {};

            item.id = rorIdentifier.id;
            item.label = (label.length > RORSearch.maxLength ? label.substring(0, RORSearch.maxLength).trim() + "…" : label) + " [" + rorIdentifier.name + "]";
            rorIdentifiers.push(item);
        });
        return rorIdentifiers;
    },

    onRORSelected: function (event, ui) {
        return false;
    },

    onInput: async function (event) {
        let input = $(event.target);
        let result = await RORSearch.search(event.target.value);

        /*
        input.autocomplete({
            delay: 400,
            minLength: 3,
            source: await RORSearch.search(event.target.value),
            select: RORSearch.onRORSelected
        });
         */
    }
};

document.addEventListener('DOMContentLoaded', function () {
    for (const input of document.querySelectorAll('[id="mir-ror-input"]')) {
        input.addEventListener('input', RORSearch.onInput);
    }
});
