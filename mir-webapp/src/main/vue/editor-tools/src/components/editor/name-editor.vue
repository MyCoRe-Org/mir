<template>

    <div class="row">
        <div class="col-3">
            <label :for="id+'displayForm'">{{ i18n["mir.editor.subject.name.editor.displayForm"] }}</label>
        </div>

        <div class="col-7">
            <input :id="id+'displayForm'"
                   v-model="name.displayForm" :class="'form-control form-control-sm' + validClass(name.displayForm)"
                   type="text">
            <div class="invalid-feedback">
                {{ i18n["mir.editor.subject.name.editor.invalid.displayForm"] }}
            </div>
        </div>

        <div class="col-2">
            <authority-badge v-if="name.authority"
                             :authority="name.authority"
                             :editable="true"
                             :valueURI="name.valueURI"
                             @removeAuthority="removeLink" />
        </div>
    </div>

    <div class="row mt-2">
        <div class="col-3">
            <label :for="id+'language'">{{ i18n["mir.editor.subject.editor.language"] }}</label>
        </div>

        <div class="col-7">
            <classification-select v-model="name.lang"
                                   :id="id+'language'"
                                   :empty-label="i18n['mir.editor.subject.editor.language.choose']"
                                   :url="`${webApplicationBaseURL}api/v2/classifications/rfc5646`"/>
        </div>
    </div>

    <array-repeater
        v-if="name.nameParts.length>0 || name.nameType=='personal' || name.nameType=='family'"
       v-model="name.nameParts" :default-content="{ type: 'given',text: '' }">
        <template #label="content">
            <label :for="content.object? `${id}name${content.index}`: null">{{ i18n["mir.editor.subject.name.editor.namePart"] }}</label>
        </template>
        <template #displayContent="content">
            <div class="row">
                <div class="col-6">
                    <select v-model="content.object.type" class="form-control form-control-sm form-select">
                        <option value="given">{{ i18n["mir.editor.subject.name.editor.namePart.type.given"] }}</option>
                        <option value="family">{{ i18n["mir.editor.subject.name.editor.namePart.type.family"] }}</option>
                        <option value="termsOfAddress">{{ i18n["mir.editor.subject.name.editor.namePart.type.termsOfAddress"] }}</option>
                    </select>
                </div>
                <div class="col-6">
                    <input :id="`${id}name${content.index}`" v-model="content.object.text"
                           :class="'form-control form-control-sm' + validClass(content.object.text)">
                    <div class="invalid-feedback">
                        {{ i18n["mir.editor.subject.name.editor.invalid.namePart"] }}
                    </div>
                </div>
            </div>
        </template>
    </array-repeater>

    <array-repeater v-model="name.nameIdentifier"
                    :default-content="{ type: 'gnd', text: ''}">
        <template #label="content">
            <label :for="content.object ? `${id}id${content.index}`:null">{{ i18n["mir.editor.subject.name.editor.identifier"] }}</label>
        </template>
        <template #displayContent="content">
            <div class="row">
                <div class="col-6">
                    <classification-select v-model="content.object.type"
                                           :url="`${webApplicationBaseURL}api/v2/classifications/nameIdentifier`"/>
                </div>
                <div class="col-6">
                    <input :id="`${id}id${content.index}`" v-model="content.object.text"
                           :class="'form-control form-control-sm' + validClass(content.object.text)">
                    <div class="invalid-feedback">
                        {{ i18n["mir.editor.subject.name.editor.invalid.identifier"] }}
                    </div>
                </div>
            </div>
        </template>
    </array-repeater>

    <array-repeater
            v-if="name.affiliation.length>0 || name.nameType=='personal' || name.nameType=='family'"
            v-model="name.affiliation"
            :default-content="''">
        <template #label="content">
            <label :for="`${id}affiliation${content.index}`">{{ i18n["mir.editor.subject.name.editor.affiliation"] }}</label>
        </template>
        <template #displayContent="content">
            <div class="row">
                <div class="col-12">
                    <input :id="`${id}affiliation${content.index}`" v-model="name.affiliation[content.index]"
                           :class="'form-control form-control-sm' + validClass(name.affiliation[content.index])">
                    <div class="invalid-feedback">
                        {{ i18n["mir.editor.subject.name.editor.invalid.affiliation"] }}
                    </div>
                </div>
            </div>
        </template>
    </array-repeater>


</template>

<script lang="ts" setup>

import {defineEmits, defineProps, watch} from "vue";
import {useVModel} from '@vueuse/core';
import {Name} from "@/api/Subject";
import ArrayRepeater from "@/components/editor/array-repeater.vue";
import ClassificationSelect from "@/components/editor/classification-select.vue";
import AuthorityBadge from "@/components/display/authority-badge.vue";
import {provideTranslations} from "@/api/I18N";

const emit = defineEmits(['update:modelValue', "invalid:data", "valid:data"])

const id = "name" + Math.random().toString(36).substring(2, 15);

const props = defineProps<{
    modelValue: Name
}>();

const webApplicationBaseURL = (window as any)['webApplicationBaseURL'];

const name = useVModel(props, 'modelValue', emit)

watch(() => name.value, (value) => {

    if (allValid(value)) {
        emit("valid:data", value)
    } else {
        emit("invalid:data", value)
    }
}, {deep: true});

const i18n = provideTranslations([
    "mir.editor.subject.name.editor.displayForm",
    "mir.editor.subject.name.editor.invalid.displayForm",
    "mir.editor.subject.name.editor.namePart",
    "mir.editor.subject.name.editor.invalid.namePart",
    "mir.editor.subject.name.editor.namePart.type.given",
    "mir.editor.subject.name.editor.namePart.type.family",
    "mir.editor.subject.name.editor.namePart.type.termsOfAddress",
    "mir.editor.subject.name.editor.namePart.type.date",
    "mir.editor.subject.name.editor.identifier",
    "mir.editor.subject.name.editor.invalid.identifier",
    "mir.editor.subject.name.editor.affiliation",
    "mir.editor.subject.name.editor.invalid.affiliation",
    "mir.editor.subject.editor.language",
    "mir.editor.subject.editor.language.choose",
])

function allValid(name_: Name = name.value) {
    return name_.nameIdentifier.filter((t) => !valid(t.text)).length == 0 &&
        name_.nameParts.filter((t) => !valid(t.text)).length == 0 &&
        name_.affiliation.filter((t) => !valid(t)).length == 0 && valid(name_.displayForm) ;
}

const validClass = (value?: string) => {
    return valid(value) ? ' is-valid' : ' is-invalid';
};

const valid = (value?: string) => {
    return !(value === undefined || value === null || value.trim() === '');
};
const removeLink = () => {
    name.value.authority = undefined;
    name.value.authorityURI = undefined;
    name.value.valueURI = undefined;
};

</script>

<style>

</style>