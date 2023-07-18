<template>
        <div class="row">
            <div class="col-3">
                <label :for="id+'titleType'">Typ</label>
            </div>

            <div class="col-7">
                <select :id="id+'titleType'" v-model="titleInfo.titleType"
                        class="form-control form-control-sm">
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


        <array-repeater v-model="titleInfo.title" :default-content="''">
            <template #label="content">
                <label :for="titleInfo.title.length == 0 ? null : `${id}id${content.index}`">Titel</label>
            </template>
            <template #displayContent="content">
                <input :id="`${id}id${content.index}`"
                    v-model.trim.lazy="titleInfo.title[content.index]"
                    :class="'form-control form-control-sm' + validClass(titleInfo.title[content.index])">
                <div class="invalid-feedback">
                    Please provide a title.
                </div>
            </template>
        </array-repeater>

    <array-repeater v-model="titleInfo.subTitle" :default-content="''">
        <template #label="content">
            <label :for="titleInfo.subTitle.length == 0 ? null : `${id}id${content.index}`">Untertitel</label>
        </template>
        <template #displayContent="content">
              <input :id="`${id}id${content.index}`"
                           v-model.trim.lazy="titleInfo.subTitle[content.index]"
                           :class="'form-control form-control-sm' + validClass(titleInfo.subTitle[content.index])">
            <div class="invalid-feedback">
                Please provide a subtitle.
            </div>
        </template>
    </array-repeater>


    <array-repeater v-model="titleInfo.partNumber" :default-content="''">
        <template #label="content">
            <label :for="titleInfo.partNumber.length == 0 ? null :` ${id}id${content.index}`">Teilnummer</label>
        </template>
        <template #displayContent="content">
              <input :id="`${id}id${content.index}`"
                           v-model.trim.lazy="titleInfo.partNumber[content.index]"
                           :class="'form-control form-control-sm' + validClass(titleInfo.partNumber[content.index])">
            <div class="invalid-feedback">
                Please provide a part number.
            </div>
        </template>
    </array-repeater>

    <array-repeater v-model="titleInfo.partName" :default-content="''">
        <template #label="content">
            <label :for="titleInfo.partName.length == 0 ? null: ` ${id}id${content.index}`">Teilname</label>
        </template>
        <template #displayContent="content">
            <input :id="`${id}id${content.index}`"
                   v-model.trim.lazy="titleInfo.partName[content.index]"
                   :class="'form-control form-control-sm' + validClass(titleInfo.partName[content.index])">
            <div class="invalid-feedback">
                Please provide a part name.
            </div>
        </template>
    </array-repeater>

</template>

<script lang="ts" setup>
import {defineEmits, defineProps, watch} from "vue";

import ArrayRepeater from "@/components/editor/array-repeater.vue";
import {TitleInfo} from "@/api/Subject";
import {useVModel} from "@vueuse/core";
import AuthorityBadge from "@/components/display/authority-badge.vue";

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
