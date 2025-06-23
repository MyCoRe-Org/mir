<template>
    <div class="row">
        <label class="col-3" :for="id"> {{ i18n['mir.editor.subject.geographic.editor.name'] }}</label>

        <div class="col-7">
            <input :class="'form-control form-control-sm' + validClass(geographic.text)"
                   type="text"
                   :id="id"
                   v-model="geographic.text">
            <div class="invalid-feedback">
                {{ i18n["mir.editor.subject.geographic.editor.invalid.name"] }}
            </div>
        </div>

        <div class="col-2">
            <authority-badge v-if="geographic.authority"
                             :authority="geographic.authority"
                             :editable="true"
                             :valueURI="geographic.valueURI"
                             @removeAuthority="removeLink" />
        </div>
    </div>

    <div class="row mt-2">
        <div class="col-3">
            <label :for="id+'language'">{{ i18n["mir.editor.subject.editor.language"] }}</label>
        </div>

        <div class="col-7">
            <classification-select v-model="geographic.lang"
                                   :id="id+'language'"
                                   :empty-label="i18n['mir.editor.subject.editor.language.choose']"
                                   :url="`${webApplicationBaseURL}api/v2/classifications/rfc5646`"/>
        </div>
    </div>
</template>

<script setup lang="ts">

import {defineProps, defineEmits, watch, computed, reactive} from "vue";
import {Geographic} from "@/api/Subject";
import AuthorityBadge from "@/components/display/authority-badge.vue";
import {useVModel} from "@vueuse/core";
import {provideTranslations} from "@/api/I18N";
import ClassificationSelect from "@/components/editor/classification-select.vue";

const emit = defineEmits(['update:modelValue', "invalid:data", "valid:data"])

const id = "geographic" + Math.random().toString(36).substring(2, 15);

const props = defineProps<{
    modelValue: Geographic
}>();

const webApplicationBaseURL = (window as any)['webApplicationBaseURL'];

const geographic = useVModel(props, 'modelValue', emit)

watch(geographic, (value) => {
    if (valid(geographic.value.text)) {
        emit("valid:data", value);
    } else {
        emit("invalid:data", value);
    }
}, {deep: true});

const i18n = provideTranslations([
    "mir.editor.subject.geographic.editor.name",
    "mir.editor.subject.geographic.editor.invalid.name",
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
    geographic.value.authority = undefined;
    geographic.value.authorityURI = undefined;
    geographic.value.valueURI = undefined;
};


</script>

<style>

</style>