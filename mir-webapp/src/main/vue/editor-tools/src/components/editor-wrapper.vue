<template>
    <div ref="rootEl">
        <div v-if="model.subject && model.settings">

            <div class="card mt-3">

                <div class="card-body">
                    <search-form searchButton="Suche"
                                 @addCustom="addCustom"
                                 @openSearchSettings="openSearchSettings"
                                 @searchSubmitted="searchSubmitted"
                    />
                    <div v-if="model.searchOptionsVisible">
                        <search-settings :editor-settings="model.settings" v-model="model.searchOptions"/>
                    </div>

                    <!-- search results -->
                    <div ref="searchDialog" class="modal" role="dialog" tabindex="-1">
                        <div class="modal-dialog modal-lg" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Suchergebnisse</h5>
                                    <button aria-label="Close" class="close" data-dismiss="modal" type="button" @click.prevent>
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                </div>
                                <div class="modal-body">
                                    <search-result-list
                                        :search-result-group="model.searchResultGroup"
                                        @resultSelected="resultSelected"/>

                                    <div v-if="model.searching" class="text-center">
                                        <div class="spinner-border" role="status">
                                            <span class="sr-only">Loading...</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button class="btn btn-secondary" data-dismiss="modal" type="button" @click.prevent>Schließen
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- add custom -->
                    <div ref="customDialog" class="modal" role="dialog" tabindex="-1">
                        <div class="modal-dialog modal-lg" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Eigene Eingabe</h5>
                                    <button aria-label="Close" class="close" data-dismiss="modal" type="button"
                                            @click.prevent>
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                </div>

                                <div class="modal-body">
                                    <div class="row mb-2">
                                        <div class="col-3">
                                            <label>Typ</label>
                                        </div>
                                        <div class="col-7">
                                            <select v-model="model.custom.type" class="form-control">
                                                <option v-for="type in model.custom.possibleTypes"
                                                        :value="type">
                                                    {{ type }}
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
                                    <button class="btn btn-secondary" data-dismiss="modal" type="button"
                                            @click.prevent>Schließen
                                    </button>
                                    <button :disabled="!model.custom.valid" class="btn btn-primary" type="button"
                                            @click.prevent="addCustomObject">Hinzufügen
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

            <form class="form mt-2" @submit.prevent>
                <subject-editor :settings="model.settings" v-model="model.subject"/>
            </form>

        </div>
    </div>
</template>

<script lang="ts" setup>
import {onMounted, reactive, ref, watch} from "vue";
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

const model = reactive({
    settings: undefined as EditorSettings | undefined,
    subject: undefined as Subject | undefined,
    searchOptionsVisible: false,
    subjectXML: "",
    currentTab: "search",
    searchResultGroup: [] as SearchResultGroup[],
    searching: false,
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
        type: possibleTypes[0] as "Topic" | "Geographic" | "Institution" | "Person" | "Family" | "Conference" | "TitleInfo" | "Cartographic",
        editObject: {
            type: "Topic",
            text: "",
        } as Topic | Geographic |  TitleInfo | Name | Cartographics,
        valid: false
    }
});

const searchDialog = ref<HTMLElement | null>(null);

const customDialog = ref<HTMLElement | null>(null);

const rootEl = ref<HTMLElement | null>(null);

watch(()=>model.subject, (newValue) => {
    if(newValue && rootEl.value) {
        storeSubject(newValue, rootEl.value)
    }
}, {deep: true});

onMounted(() => {
    if(rootEl.value) {
        model.subject = retrieveSubject(rootEl.value);
        model.settings = retrieveSettings(rootEl.value);

        model.searchOptions.searchConference = model.settings.searchable.includes("Conference") || model.settings.searchable.includes("*");
        model.searchOptions.searchFamily = model.settings.searchable.includes("Family") || model.settings.searchable.includes("*");
        model.searchOptions.searchInstitution = model.settings.searchable.includes("Institution") || model.settings.searchable.includes("*");
        model.searchOptions.searchPersons = model.settings.searchable.includes("Person") || model.settings.searchable.includes("*");
        model.searchOptions.searchPlace = model.settings.searchable.includes("Geographic") || model.settings.searchable.includes("*");
        model.searchOptions.searchTitle = model.settings.searchable.includes("TitleInfo") || model.settings.searchable.includes("*");
        model.searchOptions.searchTopic = model.settings.searchable.includes("Topic") || model.settings.searchable.includes("*");

        model.custom.possibleTypes = possibleTypes.filter(t =>
            model.settings?.editor.includes("*") ||
            model.settings?.editor.includes(t as any));

        model.custom.type = model.custom.possibleTypes[0] as any;
    }
});
const searchSubmitted = async (searchTerm: string) => {
    const jq = (window as any).$;
    jq(searchDialog.value).modal("show");
    model.searching = true;
    const searchProvider = new LobidSearchProvider();
    const result = await searchProvider.search(searchTerm, model.searchOptions);
    model.searchResultGroup = [{
        groupId: "lobid",
        title: "Lobid",
        results: result
    }];
    model.searching = false;
}

const openSearchSettings = () => {
    model.searchOptionsVisible = !model.searchOptionsVisible;
}

const resultSelected = (result: SearchResult) => {
    const jq = (window as any).$;
    jq(searchDialog.value).modal("hide");
    model.subject?.children.push(JSON.parse(JSON.stringify(result.result)));
}

const addCustom = () => {
    const jq = (window as any).$;
    jq(customDialog.value).modal("show");


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
        case "Cartographic":
            model.custom.editObject = {
                type: "Cartographics",
                scale: [],
                projection: [],
                coordinates: []
            } as Cartographics;
            break;
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
}

</script>

<style scoped>
.modal-dialog {
    max-width: 90%;
}

.modal-body {
    overflow-y: scroll;
}

</style>
