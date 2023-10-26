<template>
    <div class="form-check-wrapper">

    <div class="form-check" v-if="props.editorSettings.searchable.includes('Person')">
        <input v-model="model.searchSettings.searchPersons" class="form-check-input" type="checkbox" :id="`${idPrefixRng}PersonCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}PersonCheck`">
            <i class="fas fa-person"> </i>
            {{ i18n["mir.editor.subject.search.options.persons"] }}
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('Conference')">
        <input v-model="model.searchSettings.searchConference" class="form-check-input" type="checkbox" :id="`${idPrefixRng}ConferenceCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}ConferenceCheck`">
            <i class="fas fa-people-line"> </i>
            {{ i18n["mir.editor.subject.search.options.conferences"] }}
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('Institution')">
        <input v-model="model.searchSettings.searchInstitution" class="form-check-input" type="checkbox" :id="`${idPrefixRng}InstitutionCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}InstitutionCheck`">
            <i class="fas fa-building"> </i>
            {{ i18n["mir.editor.subject.search.options.institutions"] }}
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('Family')">
        <input v-model="model.searchSettings.searchFamily" class="form-check-input" type="checkbox" :id="`${idPrefixRng}FamilyCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}FamilyCheck`">
            <i class="fas fa-people-roof"> </i>
            {{ i18n["mir.editor.subject.search.options.families"] }}
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('Topic')">
        <input v-model="model.searchSettings.searchTopic" class="form-check-input" type="checkbox" :id="`${idPrefixRng}TopicCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}TopicCheck`">
            <i class="fas fa-tag"> </i>
            {{ i18n["mir.editor.subject.search.options.topics"] }}
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('Geographic')">
        <input v-model="model.searchSettings.searchPlace" class="form-check-input" type="checkbox" :id="`${idPrefixRng}PlaceCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}PlaceCheck`">
            <i class="fas fa-map-location-dot"> </i>
            {{ i18n["mir.editor.subject.search.options.places"] }}
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('TitleInfo')">
        <input v-model="model.searchSettings.searchTitle" class="form-check-input" type="checkbox" :id="`${idPrefixRng}TitleCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}TitleCheck`">
            <i class="fas fa-newspaper"></i>
            {{ i18n["mir.editor.subject.search.options.titles"] }}
        </label>
    </div>
    </div>

</template>

<script setup lang="ts">
import {watch, reactive, defineProps} from "vue";
import {SearchSettings} from "@/api/search/SearchSettings";
import {EditorSettings} from "@/api/XEditorConnector";
import {provideTranslations} from "@/api/I18N";

const props = defineProps<{
    modelValue: SearchSettings,
    editorSettings: EditorSettings
}>();

const emits = defineEmits(["update:modelValue"]);

const model = reactive({
    searchSettings: {
        searchInstitution: props.modelValue.searchInstitution,
        searchPersons: props.modelValue.searchPersons,
        searchTopic: props.modelValue.searchTopic,
        searchPlace: props.modelValue.searchPlace,
        searchConference: props.modelValue.searchConference,
        searchFamily: props.modelValue.searchFamily,
        searchTitle: props.modelValue.searchTitle,
    } as SearchSettings
});

const i18n = provideTranslations([
    "mir.editor.subject.search.options.persons",
    "mir.editor.subject.search.options.conferences",
    "mir.editor.subject.search.options.institutions",
    "mir.editor.subject.search.options.families",
    "mir.editor.subject.search.options.topics",
    "mir.editor.subject.search.options.places",
    "mir.editor.subject.search.options.titles"
]);

const idPrefixRng = "settings" + Math.random().toString(36).substring(2, 15);

watch(props.modelValue, (newSettings) => {
        model.searchSettings = newSettings;
    },
    {deep: true});

watch(model.searchSettings, ()=> {
    console.log("Updated Search settings!")
   emits("update:modelValue", model.searchSettings);
});

</script>

<style scoped>

.fas {
    margin-right: 0.5em;
}

</style>