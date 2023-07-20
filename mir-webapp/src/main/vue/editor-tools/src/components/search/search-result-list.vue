<template>
    <div class="row" v-if="props.searchResultGroup.length>0">

        <ul class="col-12 nav nav-tabs mb-1">
            <li class="nav-item" v-for="resultGroup in props.searchResultGroup" :key="resultGroup.groupId">
                <a href="#" @click.prevent :class="`nav-link${model.currentGroupId==resultGroup.groupId?' active':''}`">
                    {{ resultGroup.title }} </a>
            </li>
        </ul>

        <div class="col-12">
            <ol v-if="currentGroup" class="list-group list-group-flush">
                <li class="list-group-item" v-for="result in currentGroup.results" :key="result.id">
                    <div class="row">
                        <div class="col-10">
                            <template v-if="result.result.type === 'Topic'">
                                <topic-display :topic="result.result as Topic"/>
                            </template>

                            <template v-else-if="result.result.type === 'Geographic'">
                                <geographic-display :geographic="result.result as Geographic"/>
                            </template>

                            <template v-else-if="result.result.type === 'Temporal'">
                            </template>

                            <template v-else-if="result.result.type === 'TitleInfo'">
                                <title-info-display :titleInfo="result.result as TitleInfo"/>
                            </template>

                            <template v-else-if="result.result.type === 'Name'">
                                <name-display :name="result.result as Name"/>
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


                        <div class="col-2 float-right">
                            <button class="btn btn-primary btn-sm" @click.prevent="emit('resultSelected', result)">
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

export interface SearchResultListProps {
    searchResultGroup: SearchResultGroup[]
}

export interface SearchResultGroup {
    groupId: string,
    title: string,
    results: SearchResult[]
}

const props = defineProps<SearchResultListProps>();

const emit = defineEmits(["resultSelected"]);

const model = reactive({
    currentGroupId: undefined as string | undefined,
    inputValue: "",
});

const i18n = provideTranslations([
    "mir.editor.subject.search.result.add",
]);

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