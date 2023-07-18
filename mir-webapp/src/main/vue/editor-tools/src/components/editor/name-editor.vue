<template>

    <div class="row">
        <div class="col-3">
            <label :for="id+'displayForm'">Darstellungsform</label>
        </div>

        <div class="col-7">
            <input :id="id+'displayForm'"
                   v-model="name.displayForm" :class="'form-control form-control-sm' + validClass(name.displayForm)"
                   type="text">
            <div class="invalid-feedback">
                Please provide a display form.
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

    <array-repeater
        v-if="name.nameParts.length>0 || name.nameType=='personal' || name.nameType=='family'"
       v-model="name.nameParts" :default-content="{ type: 'given',text: '' }">
        <template #label="content">
            <label :for="content.object? `${id}name${content.index}`: null">Name</label>
        </template>
        <template #displayContent="content">
            <div class="row">
                <div class="col-6">
                    <select v-model="content.object.type" class="form-control form-control-sm">
                        <option value="given">Vorname</option>
                        <option value="family">Nachname</option>
                        <option value="termsOfAddress">Anrede</option>
                    </select>
                </div>
                <div class="col-6">
                    <input :id="`${id}name${content.index}`" v-model="content.object.text"
                           :class="'form-control form-control-sm' + validClass(content.object.text)">
                    <div class="invalid-feedback">
                        Please provide a name.
                    </div>
                </div>
            </div>
        </template>
    </array-repeater>

    <array-repeater v-model="name.nameIdentifier"
                    :default-content="{ type: 'gnd', text: ''}">
        <template #label="content">
            <label :for="content.object ? `${id}id${content.index}`:null">Identifikatoren</label>
        </template>
        <template #displayContent="content">
            <div class="row">
                <div class="col-6">
                    <!-- TODO: change -->
                    <classification-select v-model="content.object.type"
                                           url="https://www.openagrar.de/api/v2/classifications/nameIdentifier"/>
                </div>
                <div class="col-6">
                    <input :id="`${id}id${content.index}`" v-model="content.object.text"
                           :class="'form-control form-control-sm' + validClass(content.object.text)">
                    <div class="invalid-feedback">
                        Please provide an identifier.
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
            <label :for="`${id}affiliation${content.index}`">Affiliation</label>
        </template>
        <template #displayContent="content">
            <div class="row">
                <div class="col-12">
                    <input :id="`${id}affiliation${content.index}`" v-model="name.affiliation[content.index]"
                           :class="'form-control form-control-sm' + validClass(name.affiliation[content.index])">
                    <div class="invalid-feedback">
                        Please provide an affiliation.
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

const name = useVModel(props, 'modelValue', emit)

watch(() => name.value, (value) => {

    if (allValid(value)) {
        emit("valid:data", value)
    } else {
        emit("invalid:data", value)
    }
}, {deep: true})

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