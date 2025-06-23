<template>
  <div ref="root" class="mir-form-group" v-on-click-outside="closeDrops">
    <template v-if="model.i18nLoaded && model.classesLoaded">
      <div ref="input" class="input-group">
        <input :id="`personLabel-${nameLocatorString}`" ref="searchBox" v-model="model.search"
               :placeholder="model.personPlaceholder"
               aria-labelledby="personLabel-"
               class="form-control" type="text"               
               v-on:keydown.enter.prevent="startSearch()">
        <button ref="identifierOpenButton" class="btn btn-secondary"
                v-on:click.prevent="currentIdentifierClicked()">
          <i class="fas fa-address-card"></i>
          <span class="identifier-count">{{ model.currentIdentifier.length }}</span>
        </button>
        <button :id="`search-${nameLocatorString}`" class="btn btn-secondary" type="button"
                v-on:click.prevent="startSearch()">
          {{ model.searchLabel }}
        </button>
      </div>

      <!-- List of selected identifiers -->
      <div v-if="(model.currentIdentifier.length>0 || defineOwnIdentifier ) && model.dropVisible===2"
           class="card current-identifier-list"
           :style="`width: ${getGroupSize()}px;`">
        <div class="card-body">
          <template v-if="defineOwnIdentifier">
            <div class="mir-form-group row">
              <div class="col-4">
                <select aria-label="Select role" v-model="model.currentOwnIdentifierType" class="form-control  form-select">
                  <option selected="selected" value="">{{ model.selectLabel }}</option>
                  <option v-for="identifierType in model.possibleIdentifierTypes" :key="identifierType.value" :value="identifierType.value">
                    {{ identifierType.label }}
                  </option>
                </select>
              </div>
              <div class="col-6">
                <input v-model="model.currentOwnIdentifierValue" class="form-control" type="text"/>
              </div>
              <div class="col-2">
                <button :title="model.addLabel" class="btn btn-secondary" aria-label="Plus Button" v-on:click.prevent="addOwnIdentifier()">
                  <span class="fas fa-plus-circle"> </span>
                </button>
              </div>
            </div>
            <hr/>
          </template>
          <div v-for="identifier in model.currentIdentifier" :key="`${identifier.type}-${identifier.value}`"
               v-on:click.prevent="removeIdentifier(identifier)"
               class="identifier">
            <identifier-display :type="identifier.type" :value="identifier.value"/>
            <i class="identifier-remover fas fa-minus-circle text-info" v-on:click="addIdentifier(identifier)"></i>
          </div>

        </div>
      </div>
      <!-- Search results -->
      <div v-if="model.dropVisible===1" class="card search-completion"
           :style="`width: ${getGroupSize()}px`">
        <div class="card-body">

          <ul class="nav nav-tabs">
            <li v-for="obj in model.results" :key="obj.name" :class="`nav-item`">
              <a :class="`nav-link${model.currentProvider===obj.name?' active':''}${obj.searching===true || obj.nameList.length === 0?' initalism disabled':''}`"
                 v-on:click.prevent="model.currentProvider=obj.name">
                {{ obj.name }}
                <span v-if="obj.searching==true" class="spinner-border spinner-border-sm">
              </span>
              </a>
            </li>
          </ul>

            <template v-if="currentResults">
                <template v-for="searchResult in currentResults.nameList" :key="`row-${searchResult.id}`">
                    <div class="row">
                        <div class="col-10">
                            <span class="result-title">{{ searchResult.displayForm }}</span>
                            <i v-if="searchResult.person" class="fas fa-user"></i>
                            <i v-else class="fas fa-building"> </i>
                            <ul class="metadata-list">
                                <li v-for="meta in searchResult.metadata" :key="meta.id">
                                    <span class="metadata-label">{{ meta.label }}</span><span class="metadata-value">{{
                                    meta.value
                                    }}</span>
                                </li>
                            </ul>
                        </div>
                        <div class="col-2 applyPersonDiv">
                            <i :title="model.applyPersonTitle" class="applyPerson fas fa-check text-info"
                               v-on:click="applyName(searchResult, $event)"></i>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-12">
                            <div v-for="identifier in searchResult.identifier" :key="`${identifier.type}-${identifier.value}`"
                                 class="identifier">
                                <identifier-display :type="identifier.type" :value="identifier.value"/>
                                <i :title="model.addLabel"
                                   class="identifier-add fas fa-plus-circle text-info"
                                   v-on:click="addIdentifier(identifier, $event)"></i>
                            </div>
                        </div>
                    </div>
                    <hr/>
                </template>
            </template>
        </div>
      </div>
    </template>
  </div>
</template>

<script lang="ts" setup>

import {Identifier, NameSearchResult, SearchProviderRegistry} from "@/api/SearchProvider";
import {
  findNameLocator,
  NameLocator,
  retrieveDisplayName,
  retrieveIdentifiers,
  retrieveIsPerson,
  storeIdentifiers,
  storeIsPerson,
  storeName
} from "@/api/XEditorConnector";
import {LobidSearchProvider} from "@/api/LobidSearchProvider";
import {ViafSearchProvider} from "@/api/ViafSearchProvider";
import {ProxiedOrcidProvider} from "@/api/ProxiedOrcidProvider";
import IdentifierDisplay from "@/components/IdentifierDisplay.vue";
import {i18n} from "@/api/I18N";
import {RorSearchProvider} from "@/api/RorSearchProvider";
import {LocalSearchProvider} from "@/api/LocalSearchProvider";
import {computed, defineProps, onMounted, reactive, ref, watch} from "vue";
import {vOnClickOutside} from '@vueuse/components'

LocalSearchProvider.init();
LobidSearchProvider.init();
ViafSearchProvider.init();
ProxiedOrcidProvider.init();
RorSearchProvider.init();

interface IdentifierType {
    value: string;
    label: string;
}

const props = defineProps<
    {
        defineOwnIdentifier: boolean;
    }
>()

const model = reactive({
    nameLocator: undefined as (NameLocator | undefined),
    search: "",
    isPerson: true as boolean,
    results: [] as Array<{ name: string; searching: boolean, nameList: NameSearchResult[] }>,
    currentIdentifier: [] as Identifier[],
    dropVisible: 0 as number,
    currentProvider: "" as string,
    i18nLoaded: false as boolean,
    classesLoaded: false as boolean,
    currentOwnIdentifierType: "" as string,
    currentOwnIdentifierValue: "" as string,
    possibleIdentifierTypes: [] as IdentifierType[],
    personPlaceholder: "" as string,
    searchLabel: "" as string,
    addLabel: "" as string,
    selectLabel: "" as string,
    applyPersonTitle: "" as string,
    currentSearch: "" as string,
});

const isDevMode = () => {
    return process.env.NODE_ENV === 'development';
}

const nameLocatorString = computed(() => {
  return model.nameLocator?.modsIndex + "-" + model.nameLocator?.nameIndex + "-" + (model.nameLocator?.relatedItemIndex || '');
})

watch(() => model.currentIdentifier, (val) => {
    if (!isDevMode() && model.nameLocator !== undefined) {
        storeIdentifiers(model.nameLocator, model.currentIdentifier);
    }

}, {deep: true});

watch(() => model.search, (val) => {
    if (!isDevMode() && model.nameLocator !== undefined) {
        storeName(model.nameLocator, model.search);
    }
}, {deep: true});

watch(() => model.isPerson, (val) => {
    if (!isDevMode() && model.nameLocator !== undefined) {
        storeIsPerson(model.nameLocator, model.isPerson);
    }
}, {deep: true});


onMounted(async () => {
    await loadLanguage();
    model.i18nLoaded = true;
    await loadIdentifierTypeClass();
    model.classesLoaded = true;

    initializeXEditorConnection();
});

const root = ref();
const searchBox = ref();
const identifierOpenButton = ref();
const input = ref();

const loadIdentifierTypeClass = async () => {
    if (props.defineOwnIdentifier) {
        const baseURL = (window as any) ["webApplicationBaseURL"];

        const classificationRESP = await fetch(`${baseURL}api/v2/classifications/nameIdentifier`, {
            headers: {
                "Accept": "application/json"
            }
        });
        const classificationJSON = await classificationRESP.json();

        for (const categ of classificationJSON.categories) {
            model.possibleIdentifierTypes.push(convertCategory(categ));
        }
    }
}

const loadLanguage = async () => {
    model.personPlaceholder = `${await i18n("mir.namePart.family")}, ${await i18n("mir.namePart.given")}`;
    [
        model.searchLabel,
        model.addLabel,
        model.selectLabel,
        model.applyPersonTitle
    ] = await Promise.all([
        i18n("mir.editor.person.search"),
        i18n("mir.editor.addIdentifier"),
        i18n("mir.select"),
        i18n("mir.editor.person.applyPerson")
    ]);
}

const initializeXEditorConnection = async () => {
    if (!isDevMode() && root.value instanceof Element) {
        model.nameLocator = findNameLocator(root.value);
        if(model.nameLocator === undefined) {
            console.error("Name locator not found");
            return;
        }
        model.search = retrieveDisplayName(model.nameLocator);
        model.currentIdentifier = retrieveIdentifiers(model.nameLocator);
        model.isPerson = retrieveIsPerson(model.nameLocator);
    }
}

const convertCategory = (categ: any) => {
    return {
        value: (categ.ID as string).toLowerCase(),
        label: findLabel(categ)
    }
}

const findLabel = (categ: any) => {
    const currentLanguage = (window as any).currentLang;
    for (let labelIndex in categ.labels) {
        const label = categ.labels[labelIndex];
        if (label.lang == currentLanguage) {
            return label.text;
        }
    }
    return categ.labels[0].text;
}

const addOwnIdentifier = () => {
    if (model.currentOwnIdentifierType != "" && model.currentOwnIdentifierValue != "") {
        const identifier: Identifier = {type: model.currentOwnIdentifierType, value: model.currentOwnIdentifierValue};
        model.currentIdentifier.push(identifier);
        model.currentOwnIdentifierValue = "";
        model.currentOwnIdentifierType = "";
    }
}

const currentResults = computed(() => {
    return model.results.filter(prov => prov.name === model.currentProvider)[0];
});

const startSearch = async () => {
    let currentSearchID = Math.random().toString(36).substring(7);
    model.currentSearch = currentSearchID;
    while (model.results.length > 0) {
        model.results.pop();
    }

    if(model.search.trim().length == 0) {
        model.dropVisible = 0;
        return;
    }

    model.currentProvider = "";

    const proms = SearchProviderRegistry.getProviders().map(async (provider) => {
        let currentSearch = {
            name: provider.name,
            searching: true,
            nameList: [] as NameSearchResult[]
        };
        model.results.push(currentSearch);
        try {
            const nameSearchResults = await provider.searchPerson(model.search);
            currentSearch = model.results.filter(prov => prov.name === provider.name)[0];
            if (model.currentSearch == currentSearchID) {

                currentSearch.searching = false;
                nameSearchResults.forEach(result => currentSearch.nameList.push(result))
                if (model.currentProvider == "" && currentSearch.nameList.length > 0) {
                    // the first tabs with results is shown
                    model.currentProvider = provider.name;
                }
            }
        } catch (err) {
            if (model.currentSearch == currentSearchID) {
                currentSearch.searching = false;
            }
        }
    });
    model.dropVisible = 1;
    await Promise.all(proms);
}


const currentIdentifierClicked = () => {
    if (model.dropVisible == 2) {
        model.dropVisible = 0;
    } else {
        model.dropVisible = 2;
    }
}


const getGroupSize = () => {
    return (input.value instanceof HTMLElement ? input.value.clientWidth : 0);
}

const addIdentifier = async (identifier: Identifier, event?: MouseEvent) => {
    // if the function is caused by user action, we do a fancy animation
    if (event) {
        const clickTarget = event.currentTarget as HTMLElement;
        const identifier = (clickTarget.parentElement as HTMLElement).firstElementChild as HTMLElement;
        const animation = animateElementToElement(identifier, identifierOpenButton.value);
        await animation.finished;
    }

    if (model.currentIdentifier.filter((id: any) => id.type == identifier.type && id.value == identifier.value).length == 0) {
        model.currentIdentifier.push(identifier);
    }
}

const animateElementToElement = (from: HTMLElement, to: HTMLElement): Animation => {
    const yMove = -1 * (from.getBoundingClientRect().y - to.getBoundingClientRect().y);
    const xMove = -1 * (from.getBoundingClientRect().x - to.getBoundingClientRect().x);

    const timing = {
        duration: 500,
        interations: 1
    };

    const movement = [
        {transform: `translate(0px,0px)`, opacity: 0.8},
        {transform: `translate(${xMove}px,${yMove}px)`, opacity: 0.4}
    ];

    return from.animate(movement, timing);
}

const removeIdentifier = (identifier: Identifier) => {
    let number = model.currentIdentifier.indexOf(identifier);
    model.currentIdentifier.splice(number, 1);
}

const applyName = async (name: NameSearchResult, event: MouseEvent) => {
    const clickTarget = event.currentTarget as HTMLElement;
    const clickParent = clickTarget.parentElement?.parentElement;
    const resultTitle = (clickParent?.querySelector(".result-title") as HTMLElement | undefined);
    const identifiers = clickParent?.nextElementSibling?.querySelectorAll('.identifier');

    if (resultTitle != undefined && identifiers != undefined) {
        const identifierElements = Array.from(identifiers);
        const animations = identifierElements
            .map(el => animateElementToElement(el as HTMLElement, identifierOpenButton.value))
            .concat(animateElementToElement(resultTitle, searchBox.value))
            .map(anim => anim.finished);

        await Promise.all(animations);
    }

    while (model.currentIdentifier.length > 0) {
        model.currentIdentifier.pop();
    }
    name.identifier.forEach(identifier => addIdentifier(identifier));
    model.search = name.displayForm;
    model.isPerson = name.person;
}

const closeDrops = () => {
    model.dropVisible = 0;
}

</script>

<style scoped>

.search-completion .nav-link {
  padding: 0.5rem 1rem;
}

.disabled {
  color: gray !important;
}

.current-identifier-list {
  position: absolute;
  overflow-y: hidden;
  overflow-x: hidden;
  z-index: 100;
}

.search-completion {
  position: absolute;
  height: 400px;
  overflow-y: scroll;
  overflow-x: hidden;
  z-index: 100;
}

.metadata-list {
  padding-left: 0px;
}

.metadata-list li {
  list-style: none;
  margin-top: 0.5em;
}

.metadata-label {
  margin-right: 0.5em;
}

.metadata-label:after {
  content: ': ';
}

.result-title {
  font-weight: bold;
  margin-right: 0.5em;
  display: inline-block; /* required for the animation */
}


.search-completion .row:first-of-type {
  margin-top: 1em;
}

.identifier-add {
  margin-left: 3px;
  cursor: pointer;
}

.identifier-remover {
  margin-left: 3px;
  cursor: pointer;
}

.identifier-count {
  font-size: 0.9em;
  margin-left: 4px;
  vertical-align: bottom;
}

.applyPerson {
  cursor: pointer;
}

.applyPersonDiv {
  align-items: center;
  display: inline-flex;
  justify-content: end;
}
</style>
