<template>
    <select class="form-control form-control-sm" v-model="model.value">
        <option v-if="props.emptyLabel" :value="undefined">{{ props.emptyLabel }}</option>
        <option v-for="option in model.options" :value="option.value">{{ option.label }}</option>
    </select>
</template>

<script lang="ts" setup>

import {defineProps, defineEmits, watch, computed, reactive, onMounted} from "vue";


const props = defineProps<{
    url: string;
    modelValue: string;
    emptyLabel?: string;
}>()

const model = reactive({
    value: props.modelValue,
    options: [] as Array<any>,
    currentLoadingURL: null as string | null
});

const emit = defineEmits(["update:modelValue"]);

watch(() => props.modelValue, (value) => {
    model.value = value;
})

watch(() => model.value, (value) => {
    emit("update:modelValue", value);
})


onMounted(() => {
    loadClassification(props.url);
});

watch(() => props.url, (classURL) => {
    loadClassification(classURL);
});

const loadClassification = async (classURL: string) => {
    if (model.currentLoadingURL == props.url) {
        return;
    }

    let remove;
    do {
        remove = model.options.pop()
    } while (remove)

    const response = await fetch(classURL, {
        headers: {
            "Accept": "application/json"
        }
    });
    const data = await response.json();

    for (const categ of data.categories) {
        model.options.push(convertCategory(categ));
    }
}

const convertCategory = (categ: any) => {
    return {
        value: (categ.ID as string).toLowerCase(),
        label: findLabel(categ)
    }
}

const findLabel = (categ: any, lang: string = (window as any).currentLang, fallback = true) => {
    for (let labelIndex in categ.labels) {
        const label = categ.labels[labelIndex];
        if (label.lang == lang) {
            return label.text;
        }
    }
    return fallback ? categ.labels[0].text : null;
}


</script>

<style>

</style>