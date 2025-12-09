<template>
    <div class="row">
        <div class="col-3">
            <label :for="id" >
                {{ i18n["mir.editor.subject.topic.editor.topic"] }}
            </label>
        </div>

        <div class="col-7">
            <input :id="id" v-model="topic.text"  :class="'form-control form-control-sm' + validClass(topic.text)" type="text">
            <div class="invalid-feedback">
                {{ i18n["mir.editor.subject.topic.editor.invalid.topic"] }}
            </div>
        </div>

        <div class="col-2">
            <authority-badge v-if="topic.authority"
                             :authority="topic.authority"
                             :editable="true"
                             :valueURI="topic.valueURI"
                             @removeAuthority="removeLink" />
        </div>
    </div>

    <div class="row mt-2">
        <div class="col-3">
            <label :for="id+'language'">{{ i18n["mir.editor.subject.editor.language"] }}</label>
        </div>

        <div class="col-7">
            <classification-select v-model="topic.lang"
                                   :id="id+'language'"
                                   :empty-label="i18n['mir.editor.subject.editor.language.choose']"
                                   :url="`${webApplicationBaseURL}api/v2/classifications/rfc5646`"/>
        </div>
    </div>
</template>
<script lang="ts" setup>

import {i18n, provideTranslations} from "@/api/I18N";
import {defineEmits, defineProps, reactive, watch} from "vue";
import {Topic} from "@/api/Subject";
import AuthorityBadge from "@/components/display/authority-badge.vue";
import {useVModel} from "@vueuse/core";
import ClassificationSelect from "@/components/editor/classification-select.vue";

const emit = defineEmits(['update:modelValue', "invalid:data", "valid:data"])

const id = "topic" + Math.random().toString(36).substring(2, 15);

const props = defineProps<{
    modelValue: Topic
}>();

const topic = useVModel(props, 'modelValue', emit);

const webApplicationBaseURL = (window as any)['webApplicationBaseURL'];

watch(topic, (value) => {
    if (valid(topic.value.text)) {
        emit("valid:data", value);
    } else {
        emit("invalid:data", value);
    }
}, {deep: true});

const i18n = provideTranslations([
    "mir.editor.subject.topic.editor.topic",
    "mir.editor.subject.topic.editor.invalid.topic",
    "mir.editor.subject.editor.language",
    "mir.editor.subject.editor.language.choose",
]);

const validClass = (value: string) => {
    return valid(value) ? ' is-valid' : ' is-invalid';
};

const valid = (value: string) => {
    return !(value === undefined || value === null || value.trim() === '');
};

const removeLink = () => {
    topic.value.authority = undefined;
    topic.value.authorityURI = undefined;
    topic.value.valueURI = undefined;
};


</script>
<style>

</style>