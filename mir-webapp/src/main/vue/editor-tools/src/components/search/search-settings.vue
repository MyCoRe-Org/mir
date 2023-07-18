<template>
    <div class="form-check" v-if="props.editorSettings.searchable.includes('*') || props.editorSettings.searchable.includes('Person')">
        <input v-model="model.searchSettings.searchPersons" class="form-check-input" type="checkbox" :id="`${idPrefixRng}PersonCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}PersonCheck`">
            nach Personen Suchen
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('*') || props.editorSettings.searchable.includes('Conference')">
        <input v-model="model.searchSettings.searchConference" class="form-check-input" type="checkbox" :id="`${idPrefixRng}ConferenceCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}ConferenceCheck`">
            nach Konferenzen Suchen
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('*') || props.editorSettings.searchable.includes('Institution')">
        <input v-model="model.searchSettings.searchInstitution" class="form-check-input" type="checkbox" :id="`${idPrefixRng}InstitutionCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}InstitutionCheck`">
            nach Institutionen Suchen
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('*') || props.editorSettings.searchable.includes('Family')">
        <input v-model="model.searchSettings.searchFamily" class="form-check-input" type="checkbox" :id="`${idPrefixRng}FamilyCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}FamilyCheck`">
            nach Familien Suchen
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('*') || props.editorSettings.searchable.includes('Topic')">
        <input v-model="model.searchSettings.searchTopic" class="form-check-input" type="checkbox" :id="`${idPrefixRng}TopicCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}TopicCheck`">
            nach Themen Suchen
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('*') || props.editorSettings.searchable.includes('Geographic')">
        <input v-model="model.searchSettings.searchPlace" class="form-check-input" type="checkbox" :id="`${idPrefixRng}PlaceCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}PlaceCheck`">
            nach Orten Suchen
        </label>
    </div>

    <div class="form-check" v-if="props.editorSettings.searchable.includes('*') || props.editorSettings.searchable.includes('TitleInfo')">
        <input v-model="model.searchSettings.searchTitle" class="form-check-input" type="checkbox" :id="`${idPrefixRng}TitleCheck`">
        <label class="form-check-label" :for="`${idPrefixRng}TitleCheck`">
            nach Titeln Suchen
        </label>
    </div>

</template>

<script setup lang="ts">
import {watch, reactive, defineProps, ref} from "vue";
import {SearchSettings} from "@/api/search/SearchSettings";
import {EditorSettings} from "@/api/XEditorConnector";

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

const idPrefixRng = "settings" + Math.random().toString(36).substring(2, 15);

watch(props.modelValue, (newSettings) => {
        model.searchSettings = newSettings;
    },
    {deep: true});

watch(model.searchSettings, ()=> {
   emits("update:modelValue", model.searchSettings);
});

</script>

<style>

</style>