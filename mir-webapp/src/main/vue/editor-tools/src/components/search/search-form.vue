<template>
    <form>
        <div class="form-group">
            <div class="input-group input-group-sm mb-3">
                <input v-model="model.inputValue" :disabled="searchEnabled?null:''" @submit.prevent type="text" class="form-control">

                <div class="input-group-append ">
                    <button class="btn btn-sm btn-secondary" type="button" @click.prevent="openSearchSettings"><i class="fas fa-gear" /></button>
                    <button class="btn btn-sm btn-primary" type="submit" :disabled="searchEnabled?null:''" @click.prevent="search" >{{ props.searchButton }}</button>
                    <button class="btn btn-sm btn-primary" v-if="addCustomEnabled" type="button" @click.prevent="addCustom" ><i class="fas fa-plus" /> </button>
                </div>
            </div>
        </div>
    </form>
</template>

<script lang="ts" setup>

import {watch, reactive, defineProps, ref} from "vue";

interface SearchFormProps {
    searchButton: string,
    searchEnabled: boolean,
    addCustomEnabled: boolean,
}

const emit = defineEmits(["searchSubmitted", "openSearchSettings", "addCustom"]);
const props = defineProps<SearchFormProps>();

const model = reactive({
    inputValue: "",
});

const search = () => {
    if(props.searchEnabled){
        emit("searchSubmitted", model.inputValue);
    }
};

const openSearchSettings = () => {
    emit("openSearchSettings");
}

const addCustom = () => {
    emit("addCustom");
}

</script>

<script>

</script>