<template>
    <div class="row">
        <div>

        </div>
        <label class="col-3" :for="id">Ort</label>

        <div class="col-7">
            <input :class="'form-control form-control-sm' + validClass(geographic.text)"
                   type="text"
                   :id="id"
                   v-model="geographic.text">
            <div class="invalid-feedback">
                Please provide a name.
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
</template>

<script setup lang="ts">

import {defineProps, defineEmits, watch, computed, reactive} from "vue";
import {Geographic} from "@/api/Subject";
import AuthorityBadge from "@/components/display/authority-badge.vue";
import {useVModel} from "@vueuse/core";

const emit = defineEmits(['update:modelValue', "invalid:data", "valid:data"])

const id = "geographic" + Math.random().toString(36).substring(2, 15);

const props = defineProps<{
    modelValue: Geographic
}>();

const geographic = useVModel(props, 'modelValue', emit)

watch(geographic, (value) => {
    if (valid(geographic.value.text)) {
        emit("valid:data", value);
    } else {
        emit("invalid:data", value);
    }
}, {deep: true});

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