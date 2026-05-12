<template>
    <div ref="rootEl">
        <div v-if="model.subject && model.settings">

            <div class="card mt-3">

                <div v-if="anySearchable" class="card-body">
                    <search-form :searchEnabled="searchEnabled"
                                 @searchSubmitted="searchSubmitted"
                                 :searchTerm="model.searchTerm"
                    />

                </div>

                <!-- search results -->
                <div ref="searchDialog" class="modal" role="dialog" tabindex="-1">
                    <div class="modal-dialog modal-xl" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5>{{ i18n["mir.editor.subject.search.modal.title"] }}</h5>
                                <button aria-label="Close" class="btn-close" data-bs-dismiss="modal" type="button" @click.prevent>
                                </button>
                            </div>
                            <div class="modal-body">
                                <search-result-list
                                    v-model:search-settings="model.searchOptions"
                                    :addCustomEnabled="possibleTypeList.length>0"
                                    :editor-settings="model.settings"
                                    :search-result-group="model.searchResultGroup"
                                    :searchOptionsVisible="model.searchOptionsVisible"
                                    @addCustom="addCustom"
                                    @openSearchSettings="openSearchSettings"
                                    @resultSelected="resultSelected"
                                />

                                <div v-if="model.searching" class="text-center">
                                    <div class="spinner-border" role="status">
                                        <span class="sr-only">Loading...</span>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-secondary" data-bs-dismiss="modal" type="button" @click.prevent>
                                    {{ i18n["mir.editor.subject.search.modal.close"]}}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- add custom -->
                <div ref="customDialog" class="modal" role="dialog" tabindex="-1">
                    <div class="modal-dialog modal-xl" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5>{{ i18n["mir.editor.subject.custom.modal.title"] }}</h5>
                              <button aria-label="Close" class="btn-close" data-bs-dismiss="modal" type="button" @click.prevent>
                              </button>
                            </div>

                            <div class="modal-body">
                                <div class="row mb-2">
                                    <div class="col-3">
                                        <label :for="selectId">{{ i18n["mir.editor.subject.custom.modal.type"] }}</label>
                                    </div>
                                    <div class="col-7">
                                        <select :id="selectId" v-model="model.custom.type" class="form-control form-control-sm custom-type-select form-select">
                                            <option v-for="type in possibleTypeList"
                                                    :value="type">
                                                {{ i18n["mir.editor.subject.custom.modal.type."+type] }}
                                            </option>
                                        </select>
                                    </div>
                                </div>

                                <topic-editor v-if="model.custom.editObject.type=='Topic'"
                                              v-model="model.custom.editObject"
                                              @valid:data="markValid"
                                              @invalid:data="markInvalid"
                                />
                                <name-editor v-if="model.custom.editObject.type=='Name'"
                                             v-model="model.custom.editObject"
                                             @valid:data="markValid"
                                             @invalid:data="markInvalid"
                                />
                                <title-info-editor v-if="model.custom.editObject.type=='TitleInfo'"
                                                   v-model="model.custom.editObject"
                                                   @valid:data="markValid"
                                                   @invalid:data="markInvalid"
                                />
                                <cartographics-editor v-if="model.custom.editObject.type=='Cartographics'"
                                                      v-model="model.custom.editObject"
                                                      @valid:data="markValid"
                                                      @invalid:data="markInvalid"
                                />
                                <geographic-editor v-if="model.custom.editObject.type=='Geographic'"
                                                   v-model="model.custom.editObject"
                                                   @valid:data="markValid"
                                                   @invalid:data="markInvalid"
                                />

                            </div>

                            <div class="modal-footer">
                                <button class="btn btn-secondary" data-bs-dismiss="modal" type="button"
                                        @click.prevent>{{ i18n["mir.editor.subject.custom.modal.close"]}}
                                </button>
                                <button :disabled="!model.custom.valid" class="btn btn-primary custom-add" type="button"
                                        @click.prevent="addCustomObject">{{ i18n["mir.editor.subject.custom.modal.add"]}}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <subject-editor v-model="model.subject" :settings="model.settings">
                    <template v-if="showCartographics" #coords>
                        <a class="add-coordinate" @click="addCoordinates">
                            {{ i18n["mir.editor.subject.addCoordinates"] }}
                        </a>
                    </template>
                </subject-editor>

            </div>


        </div>
    </div>
</template>

<script lang="ts" setup>
import {computed, onMounted, reactive, ref, watch} from "vue";
import {Cartographics, Geographic, Name, Subject, TitleInfo, Topic} from "@/api/Subject";
import subjectEditor from "@/components/editor/subject-editor.vue";
import searchForm from "@/components/search/search-form.vue";
import SearchResultList, {SearchResultGroup} from "@/components/search/search-result-list.vue";
import SearchSettings from "@/components/search/search-settings.vue";
import {SearchSettings as SearchSettingsModel} from "@/api/search/SearchSettings";
import {LobidSearchProvider} from "@/api/search/LobidSearchProvider";
import {SearchResult} from "@/api/search/SearchProvider";
import {EditorSettings, possibleTypes, retrieveSettings, retrieveSubject, storeSubject} from "@/api/XEditorConnector";
import TopicEditor from "@/components/editor/topic-editor.vue";
import NameEditor from "@/components/editor/name-editor.vue";
import TitleInfoEditor from "@/components/editor/title-info-editor.vue";
import GeographicEditor from "@/components/editor/geographic-editor.vue";
import CartographicsEditor from "@/components/editor/cartographic-editor.vue";
import {provideTranslations} from "@/api/I18N";

const selectId = ref('');
const model = reactive({
    settings: undefined as EditorSettings | undefined,
    subject: undefined as Subject | undefined,
    searchOptionsVisible: false,
    subjectXML: "",
    currentTab: "search",
    searchResultGroup: [] as SearchResultGroup[],
    searching: false,
    searchTerm: "",
    searchOptions: {
        searchInstitution: true,
        searchTopic: true,
        searchPlace: true,
        searchPersons: true,
        searchConference: true,
        searchTitle: true,
        searchFamily: true
    } as SearchSettingsModel,
    custom: {
        possibleTypes: possibleTypes,
        type: possibleTypes[0] as "Topic" | "Geographic" | "Institution" | "Person" | "Family" | "Conference" | "TitleInfo" | "Cartographics" | undefined,
        editObject: {
            type: "Topic",
            text: "",
        } as Topic | Geographic |  TitleInfo | Name | Cartographics,
        valid: false
    }
});

const i18n = provideTranslations([
    "mir.editor.subject.search.modal.title",
    "mir.editor.subject.search.modal.close",
    "mir.editor.subject.custom.modal.title",
    "mir.editor.subject.custom.modal.type",
    "mir.editor.subject.custom.modal.type.Topic",
    "mir.editor.subject.custom.modal.type.Geographic",
    "mir.editor.subject.custom.modal.type.Institution",
    "mir.editor.subject.custom.modal.type.Person",
    "mir.editor.subject.custom.modal.type.Family",
    "mir.editor.subject.custom.modal.type.Conference",
    "mir.editor.subject.custom.modal.type.TitleInfo",
    "mir.editor.subject.custom.modal.type.Cartographics",
    "mir.editor.subject.custom.modal.close",
    "mir.editor.subject.custom.modal.add",
    "mir.editor.subject.addCoordinates",
    "mir.editor.subject.search.leaving"
]);

const searchDialog = ref<HTMLElement | null>(null);

const customDialog = ref<HTMLElement | null>(null);

const rootEl = ref<HTMLElement | null>(null);

watch(()=>model.subject, (newValue) => {
    if(newValue && rootEl.value) {
        storeSubject(newValue, rootEl.value)
    }
}, {deep: true});

watch( () => model.searchOptions, (newValue) => {
    search();
}, {deep: true});

onMounted(() => {
    if(rootEl.value) {
        model.subject = retrieveSubject(rootEl.value);
        model.settings = retrieveSettings(rootEl.value);

        const filter = model.settings?.searchFilterDefault || [];
        const searchable = model.settings.searchable || [];

        model.searchOptions.searchConference = filter.includes("Conference") && searchable.includes("Conference");
        model.searchOptions.searchFamily = filter.includes("Family") && searchable.includes("Family");
        model.searchOptions.searchInstitution =  filter.includes("Institution") && searchable.includes("Institution");
        model.searchOptions.searchPersons = filter.includes("Person") && searchable.includes("Person");
        model.searchOptions.searchPlace = filter.includes("Geographic") && searchable.includes("Geographic");
        model.searchOptions.searchTitle = filter.includes("TitleInfo") && searchable.includes("TitleInfo");
        model.searchOptions.searchTopic = filter.includes("Topic") && searchable.includes("Topic");

        // prevent leaving the page if the search term is not empty. This is to prevent the user from accidentally
        // entering a topic thinking it will be saved.
        const value = rootEl.value as HTMLElement;
        let parent : HTMLElement|null= value as HTMLElement;
        do  {
            parent = parent.parentElement;
        } while (parent != null && parent.tagName != "FORM");
        if(parent != null) {
            parent.addEventListener("submit", (e) => {
                const searchEl = rootEl.value?.querySelector("input.search-topic") as HTMLInputElement;
                const searchElVal = searchEl?.value;
                if(searchable != null && searchElVal.trim().length>0){
                    searchEl.scrollIntoView({ behavior: 'smooth', block: 'center'});
                    if(!confirm(i18n["mir.editor.subject.search.leaving"])){
                        e.preventDefault();
                    }
                }
            });
        }
    }
    selectId.value = 'custom_typ_select-' + Math.random().toString(36).substring(2, 9);
});
const searchSubmitted = async (searchTerm: string) => {
    const jq = (window as any).$;
    jq(searchDialog.value).modal("show");
    model.searching = true;
    model.searchTerm = searchTerm;
    await search();
}

const search = async () => {
    const searchProvider = new LobidSearchProvider();
    const result = await searchProvider.search(model.searchTerm, model.searchOptions);
    model.searchResultGroup = [{
        groupId: "lobid",
        title: "Lobid",
        results: result
    }];
    model.searching = false;
}

// used to make the search form not editable
const searchEnabled = computed(()=>{
    if(model.settings?.admin == "geographicPair"){
       const enabled = model.subject?.children.length == undefined || model.subject?.children.filter(child=>child.type=="Geographic").length == 0;
       console.log("search enabled", enabled);
       return enabled;
    } else {
       if(model.settings?.admin === false){
           const enabled = model.subject?.children.length==0 && model.settings?.searchable.length > 0;
           console.log("search enabled child searchable", enabled)
           return enabled;
       } else {
           console.log("search enabled is admin!");
           return true;
       }
   }
});

const idForAccessibility = computed(()=>{return Date.now(); });
// used to display the 'add cartographics button'
const showCartographics = computed(() => {
    const isPair = model.settings?.admin == 'geographicPair' && possibleTypeList.value.includes('Cartographics');
    const isGeographic = model.settings?.editor.length == 1 && model.settings?.editor[0] == "Cartographics" &&
        model.subject?.children.filter(c => c.type == "Cartographics").length == 0;

    return isPair || isGeographic;
});

// used to hide the entire search form
const anySearchable = computed( () => {
    if(model.settings?.admin == "geographicPair"){
        return true;
    }

    return model.settings?.searchable.length != undefined && model.settings?.searchable.length > 0;
});

const possibleTypeList = computed(() => {
    if(model.settings?.admin === "geographicPair"){
        if(model.subject?.children.length == undefined || model.subject?.children.length > 1){
            return [];
        } else {
            const geographicPresent = model.subject.children.filter(c => {
                if(c.type === "Geographic"){
                    return true;
                }
            }).length == 1;
            const cartographicsPresent = model.subject.children.filter(c => {
                if(c.type === "Cartographics"){
                    return true;
                }
            }).length == 1;
            if(geographicPresent && cartographicsPresent){
                return [];
            } else if(geographicPresent){
                return ["Cartographics"];
            } else if(cartographicsPresent){
                return ["Geographic"];
            } else {
                return ["Geographic", "Cartographics"];
            }
        }
    } else {
        if(model.settings?.admin === false && (model.subject == undefined || model.subject?.children.length > 0)){
            return [];
        }
        return possibleTypes.filter(t => {
            return model.settings?.editor.includes("*") ||
                model.settings?.editor.includes(t as any);
        });
    }
});


watch(()=> possibleTypeList.value, (newValue) => {
    if(model.custom.type == undefined || !newValue.includes(model.custom.type)){
        model.custom.type = (newValue[0] as any) || undefined;
    }
}, {deep: true});

const openSearchSettings = () => {
    model.searchOptionsVisible = !model.searchOptionsVisible;
}

const resultSelected = (result: SearchResult) => {
    const jq = (window as any).$;
    jq(searchDialog.value).modal("hide");
    model.subject?.children.push(JSON.parse(JSON.stringify(result.result)));
    model.searchTerm = "";
}

const addCustom = () => {
    const jq = (window as any).$;
    jq(searchDialog.value).modal("hide");
    jq(customDialog.value).modal("show");
    switch (model.custom.editObject.type) {
        case "Geographic":
        case "Topic":
            model.custom.editObject.text = model.searchTerm;
            break;
        case "TitleInfo":
            model.custom.editObject.title = [model.searchTerm];
            break;
        case "Name":
            model.custom.editObject.displayForm = model.searchTerm;
            break;
    }

}

const addCoordinates = () => {
    model.custom.type = "Cartographics";
    addCustom();
}

watch(()=> model.custom.type, (newType)=> {
    switch (newType){
        case "Topic":
            model.custom.editObject = {
                type: "Topic",
                text: "",
            } as Topic;
            break;
        case "Geographic":
            model.custom.editObject = {
                type: "Geographic",
                text: "",
            } as Geographic;
            break;
        case "Institution":
            model.custom.editObject = {
                type: "Name",
                nameType: "corporate",
                displayForm: "",
                nameParts: [],
                nameIdentifier: [],
                affiliation: [],
                role: [],
            } as Name;
            break;
        case "Person":
            model.custom.editObject = {
                type: "Name",
                nameType: "personal",
                displayForm: "",
                nameParts: [],
                nameIdentifier: [],
                affiliation: [],
                role: [],
            } as Name;
            break;
        case "Family":
            model.custom.editObject = {
                type: "Name",
                nameType: "family",
                displayForm: "",
                nameParts: [],
                nameIdentifier: [],
                affiliation: [],
                role: [],
            } as Name;
            break;
        case "Conference":
            model.custom.editObject = {
                type: "Name",
                nameType: "conference",
                displayForm: "",
                nameParts: [],
                nameIdentifier: [],
                affiliation: [],
                role: [],
            } as Name;
            break;
        case "TitleInfo":
            model.custom.editObject = {
                type: "TitleInfo",
                title: [],
                subTitle: [],
                partNumber: [],
                partName: [],
                nonSort: [],
                displayLabel: "",
            } as TitleInfo;
            break;
        case "Cartographics":
            model.custom.editObject = {
                type: "Cartographics",
                scale: [],
                projection: [],
                coordinates: []
            } as Cartographics;
            break;
        default:
            console.log("Unknown type " + model.custom.type);
    }

});

const markValid = () => {
    model.custom.valid = true;
}

const markInvalid = () => {
    model.custom.valid = false;
}

const addCustomObject = () => {
    model.subject?.children.push(JSON.parse(JSON.stringify(model.custom.editObject)));
    const jq = (window as any).$;
    jq(customDialog.value).modal("hide");
    model.searchTerm = "";
}

</script>

<style scoped>

.modal-body {
    overflow-y: scroll;
}

</style>
