<template>
    <!--
        <div class="row">
            <div class="col-3">
                <label :for="id+'titleType'">Typ</label>
            </div>

            <div class="col-7">
                <select :id="id+'titleType'" v-model="titleInfo.titleType"
                        class="form-control form-control-sm form-select">
                    <option :value="undefined">Keine Angabe</option>
                    <option value="uniform">Einheitssachtitel</option>
                    <option value="abbreviated">Kurztitel</option>
                    <option value="translated">Übersetzung</option>
                    <option value="alternative">Alternativer Titel</option>
                </select>
            </div>

            <div class="col-2">
                <authority-badge v-if="titleInfo.authority"
                                 :authority="titleInfo.authority"
                                 :editable="true"
                                 :valueURI="titleInfo.valueURI"
                                 @removeAuthority="removeLink" />
            </div>
        </div>
    -->

        <div class="row mt-2">
            <div class="col-3">
                <label :for="id+'language'">{{ i18n["mir.editor.subject.editor.language"] }}</label>
            </div>

            <div class="col-7">
                <classification-select v-model="titleInfo.lang"
                                       :id="id+'language'"
                                       :empty-label="i18n['mir.editor.subject.editor.language.choose']"
                                       :url="`${webApplicationBaseURL}api/v2/classifications/rfc5646`"/>
            </div>
        </div>

        <array-repeater v-model="titleInfo.title" :default-content="''">
            <template #label="content">
                <label :for="titleInfo.title.length == 0 ? null : `${id}id${content.index}`">{{ i18n["mir.editor.subject.titleInfo.editor.title"] }}</label>
            </template>
            <template #displayContent="content">
                <input :id="`${id}id${content.index}`"
                    v-model.trim.lazy="titleInfo.title[content.index]"
                    :class="'form-control form-control-sm' + validClass(titleInfo.title[content.index])">
                <div class="invalid-feedback">
                    {{ i18n["mir.editor.subject.titleInfo.editor.invalid.title"] }}
                </div>
            </template>
        </array-repeater>

    <array-repeater v-model="titleInfo.subTitle" :default-content="''">
        <template #label="content">
            <label :for="titleInfo.subTitle.length == 0 ? null : `${id}id${content.index}`">{{ i18n["mir.editor.subject.titleInfo.editor.subtitle"] }}</label>
        </template>
        <template #displayContent="content">
              <input :id="`${id}id${content.index}`"
                           v-model.trim.lazy="titleInfo.subTitle[content.index]"
                           :class="'form-control form-control-sm' + validClass(titleInfo.subTitle[content.index])">
            <div class="invalid-feedback">
                {{ i18n["mir.editor.subject.titleInfo.editor.invalid.subtitle"] }}
            </div>
        </template>
    </array-repeater>


    <array-repeater v-model="titleInfo.partNumber" :default-content="''">
        <template #label="content">
            <label :for="titleInfo.partNumber.length == 0 ? null :` ${id}id${content.index}`">{{ i18n["mir.editor.subject.titleInfo.editor.partNumber"] }}</label>
        </template>
        <template #displayContent="content">
              <input :id="`${id}id${content.index}`"
                           v-model.trim.lazy="titleInfo.partNumber[content.index]"
                           :class="'form-control form-control-sm' + validClass(titleInfo.partNumber[content.index])">
            <div class="invalid-feedback">
                {{ i18n["mir.editor.subject.titleInfo.editor.invalid.partNumber"] }}
            </div>
        </template>
    </array-repeater>

    <array-repeater v-model="titleInfo.partName" :default-content="''">
        <template #label="content">
            <label :for="titleInfo.partName.length == 0 ? null: ` ${id}id${content.index}`">{{ i18n["mir.editor.subject.titleInfo.editor.partName"] }} </label>
        </template>
        <template #displayContent="content">
            <input :id="`${id}id${content.index}`"
                   v-model.trim.lazy="titleInfo.partName[content.index]"
                   :class="'form-control form-control-sm' + validClass(titleInfo.partName[content.index])">
            <div class="invalid-feedback">
                {{ i18n["mir.editor.subject.titleInfo.editor.invalid.partName"] }}
            </div>
        </template>
    </array-repeater>

</template>

<script lang="ts" setup>
import {defineEmits, defineProps, watch} from "vue";

import ArrayRepeater from "@/components/editor/array-repeater.vue";
import {TitleInfo} from "@/api/Subject";
import {useVModel} from "@vueuse/core";
import {provideTranslations} from "@/api/I18N";
import ClassificationSelect from "@/components/editor/classification-select.vue";

const emit = defineEmits(['update:modelValue', "invalid:data", "valid:data"]);

const id = "name" + Math.random().toString(36).substring(2, 15);

const props = defineProps<{
    modelValue: TitleInfo
}>();

const titleInfo = useVModel(props, 'modelValue', emit, {
    deep: true
});

watch(titleInfo, (value) => {
    if (allValid(value)) {
        emit("valid:data", value);
    } else {
        emit("invalid:data", value);
    }
}, {deep: true});

const i18n = provideTranslations([
    "mir.editor.subject.titleInfo.editor.title",
    "mir.editor.subject.titleInfo.editor.invalid.title",
    "mir.editor.subject.titleInfo.editor.subtitle",
    "mir.editor.subject.titleInfo.editor.invalid.subtitle",
    "mir.editor.subject.titleInfo.editor.partNumber",
    "mir.editor.subject.titleInfo.editor.invalid.partNumber",
    "mir.editor.subject.titleInfo.editor.partName",
    "mir.editor.subject.titleInfo.editor.invalid.partName",
    "mir.editor.subject.editor.language",
    "mir.editor.subject.editor.language.choose",
]);

const webApplicationBaseURL = (window as any)['webApplicationBaseURL'];

function allValid(titleInfo_: TitleInfo = titleInfo.value) {
    return titleInfo_.title.filter((t) => !valid(t)).length == 0 &&
        titleInfo_.subTitle.filter((t) => !valid(t)).length == 0 &&
        titleInfo_.partNumber.filter((t) => !valid(t)).length == 0 &&
        titleInfo_.partName.filter((t) => !valid(t)).length == 0;
}

const removeLink = () => {
    titleInfo.value.authority = undefined;
    titleInfo.value.authorityURI = undefined;
    titleInfo.value.valueURI = undefined;
};

const validClass = (value: string) => {
    return valid(value) ? ' is-valid' : ' is-invalid';
};

const valid = (value: string) => {
    return !(value === undefined || value === null || value.trim() === '');
};

</script>

<style scoped>


</style>
