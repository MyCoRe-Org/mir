<template>
    <div class="row">
        <div class="col-10">
            <slot name="editContent" v-if="model.edit"/>
            <slot name="displayContent" v-else />
        </div>
        <div class="col-2" v-if="model.edit">
            <button class="btn btn-primary btn-sm" @click="model.edit = false; emit('apply')">
                Ok
            </button>
        </div>
        <div class="col-2" v-else>
            <button class="btn btn-primary btn-sm" @click="model.edit = true; emit('edit')">
                Bearbeiten
            </button>
        </div>
    </div>
</template>

<script setup lang="ts">

import {reactive} from "vue";

const emit = defineEmits(["apply", "abort", "edit"]);

const model = reactive({
    edit: false
});

</script>

<style>

</style>