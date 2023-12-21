<template>
    <div class="row" v-if="props.searchResultGroup.length>0">

        <div class="col-12 mb-1">

            <div class="row">
                <div class="col-12 mb-1">
                    <button v-if="addCustomEnabled" class="btn btn-sm btn-primary search-add-custom float-right" type="button"
                            @click.prevent="addCustom"> {{ i18n["mir.editor.subject.search.result.addCustom"] }}
                    </button>
                </div>
            </div>

        </div>


        <ul class="col-12 nav nav-tabs mb-1">
            <li class="nav-item" v-for="resultGroup in props.searchResultGroup" :key="resultGroup.groupId">
                <a href="#" @click.prevent :class="`nav-link${model.currentGroupId==resultGroup.groupId?' active':''}`">
                    {{ resultGroup.title }} </a>
            </li>
        </ul>


        <div class="col-md-4 col-sm-12">
            <search-settings v-model="model.searchSettings" :editor-settings="props.editorSettings"/>
        </div>


        <div class="col-md-8 col-sm-12">
            <ol v-if="currentGroup" class="list-group list-group-flush">
                <li class="list-group-item" v-if="currentGroup.results.length==0">
                    {{ i18n["mir.editor.subject.search.result.empty"] }}
                </li>
                <li class="list-group-item" v-for="result in currentGroup.results" :key="result.id">
                    <div class="row">
                        <div class="col-xl-10 col-sm-12">
                            <template v-if="result.result.type === 'Topic'">
                                <topic-display mode="search" :topic="result.result as Topic"/>
                            </template>

                            <template v-else-if="result.result.type === 'Geographic'">
                                <geographic-display mode="search" :geographic="result.result as Geographic"/>
                            </template>

                            <template v-else-if="result.result.type === 'Temporal'">
                            </template>

                            <template v-else-if="result.result.type === 'TitleInfo'">
                                <title-info-display mode="search" :titleInfo="result.result as TitleInfo"/>
                            </template>

                            <template v-else-if="result.result.type === 'Name'">
                                <name-display mode="search" :name="result.result as Name"/>
                            </template>

                            <template v-else-if="result.result.type === 'Genre'">
                            </template>

                            <template v-else-if="result.result.type === 'HierarchicalGeographic'">

                            </template>

                            <template v-else-if="result.result.type === 'Cartographics'">

                            </template>

                            <template v-else-if="result.result.type === 'GeographicCode'">

                            </template>

                            <template v-else-if="result.result.type === 'Occupation'">

                            </template>

                            <div v-if="result.info.length > 0">
                                <ul>
                                    <li v-for="info in result.info">
                                        {{ info.label }}:
                                        <span v-if="info.type=='string'">{{ info.value }}</span>
                                        <a v-else :href="info.value">{{ info.value }}</a>
                                    </li>
                                </ul>
                            </div>
                        </div>


                        <div class="col-xl-2 col-sm-12">
                            <button class="btn btn-primary btn-sm float-right mb-1" @click.prevent="emit('resultSelected', result)">
                                {{ i18n["mir.editor.subject.search.result.add"] }}
                            </button>
                        </div>
                    </div>

                </li>
            </ol>
        </div>
    </div>
</template>

<script lang="ts" setup>

import {
    Cartographics,
    Genre,
    Geographic, GeographicCode,
    HierarchicalGeographic,
    Name, Occupation,
    Temporal,
    TitleInfo,
    Topic
} from "@/api/Subject";
import {watch, reactive, defineProps, ref, computed} from "vue";
import {SearchResult} from "@/api/search/SearchProvider";
import NameDisplay from "@/components/display/name-display.vue";
import TopicDisplay from "@/components/display/topic-display.vue";
import GeographicDisplay from "@/components/display/geographic-display.vue";
import TitleInfoDisplay from "@/components/display/title-info-display.vue";
import {provideTranslations} from "@/api/I18N";
import SearchSettings from "@/components/search/search-settings.vue";
import {SearchSettings as SearchSettingsModel} from "@/api/search/SearchSettings";
import {EditorSettings} from "@/api/XEditorConnector";
import {useVModel} from "@vueuse/core";

export interface SearchResultListProps {
    searchResultGroup: SearchResultGroup[]
    addCustomEnabled: boolean,
    searchOptionsVisible: boolean,
    editorSettings: EditorSettings,
    searchSettings: SearchSettingsModel
}

export interface SearchResultGroup {
    groupId: string,
    title: string,
    results: SearchResult[]
}

const props = defineProps<SearchResultListProps>();


const emit = defineEmits(["resultSelected", "openSearchSettings", "addCustom", "update:searchSettings"]);


const model = reactive({
    currentGroupId: undefined as string | undefined,
    inputValue: "",
    searchSettings: props.searchSettings
});

watch(()=>model.searchSettings, (newValue) => {
    console.log("Updated Search settings");
    emit("update:searchSettings", newValue);
}, {
    deep: true
});

watch(() => props.searchSettings, (newValue) => {
    model.searchSettings = newValue;
}, {
    deep: true
});

const i18n = provideTranslations([
    "mir.editor.subject.search.result.add",
    "mir.editor.subject.search.result.addCustom",
    "mir.editor.subject.search.result.empty",
]);

const addCustom = () => {
    emit("addCustom");
}

const openSearchSettings = () => {
    emit("openSearchSettings");
}

watch(()=>props.searchResultGroup, (newValue) => {
    const isGroupPresent = newValue.filter(g => g.groupId === model.currentGroupId)[0];
    if (!isGroupPresent) {
        model.currentGroupId = newValue[0].groupId;
    }
}, {
    deep: true
});

const currentGroup = computed(() => {
    return props.searchResultGroup?.filter(g => g.groupId === model.currentGroupId)[0];
});

</script>


<style>

</style>