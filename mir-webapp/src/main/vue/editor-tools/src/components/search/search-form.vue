<template>
    <form>
        <div class="mir-form-group">
            <div class="input-group input-group-sm mb-3">
                <input v-model="model.inputValue"
                :id="model.inputId|| undefined"
                :disabled="searchEnabled ? null : ''"
                :aria-label="model.inputId ? null : i18n['mir.editor.subject.search.placeholder']"
                @submit.prevent type="text" :placeholder="i18n['mir.editor.subject.search.placeholder']" class="form-control search-topic">
                <button class="btn btn-sm btn-primary" type="submit" :disabled="searchEnabled?null:''" @click.prevent="search" >{{ i18n['mir.editor.subject.search'] }}</button>
            </div>
        </div>
    </form>
</template>

<script lang="ts" setup>

import {reactive, defineProps, watch, onMounted, getCurrentInstance} from "vue";
import {provideTranslations} from "@/api/I18N";

interface SearchFormProps {
    searchEnabled: boolean,
    searchTerm: string,
}

const emit = defineEmits(["searchSubmitted"]);
const props = defineProps<SearchFormProps>();

const model = reactive({
    inputValue: "",
    inputId: "",
});

watch(()=> props.searchTerm, (newValue) => {
  model.inputValue = newValue;
}, {
  deep: true
});

onMounted(() => {
    const root = getCurrentInstance()?.appContext.app._container;
    const container = root?.closest(".editorToolsApp");

    model.inputId = container?.getAttribute("data-labelledby") || "";
});
const i18n = provideTranslations([
    "mir.editor.subject.search",
    "mir.editor.subject.search.placeholder",
]);

const search = () => {
    if(props.searchEnabled){
        emit("searchSubmitted", model.inputValue);
    }
};


</script>

<script>

</script>
