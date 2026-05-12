<template>
    <form>
        <div class="mir-form-group">
            <div class="input-group input-group-sm mb-3">
                <input :id="id" v-model="model.inputValue" :disabled="searchEnabled?null:''" @submit.prevent type="text" :placeholder="i18n['mir.editor.subject.search.placeholder']" class="form-control search-topic">
                <button class="btn btn-sm btn-primary" type="submit" :disabled="searchEnabled?null:''" @click.prevent="search" >{{ i18n['mir.editor.subject.search'] }}</button>
            </div>
        </div>
    </form>
</template>

<script lang="ts" setup>

import {ref, getCurrentInstance, onMounted, reactive, defineProps, watch} from "vue";
import {provideTranslations} from "@/api/I18N";

interface SearchFormProps {
    searchEnabled: boolean,
    searchTerm: string,
}
const id = ref('');
const emit = defineEmits(["searchSubmitted"]);
const props = defineProps<SearchFormProps>();

const model = reactive({
    inputValue: "",
});
onMounted(() => {
 const el = getCurrentInstance()?.proxy?.$el as HTMLElement;

  // Suche nach dem nächsten umgebenden container mit der ID
  const container = el?.closest('.editorToolsApp') as HTMLElement;

  if (container && container.dataset.inputId) {
    id.value = container.dataset.inputId;
  } 
});
watch(()=> props.searchTerm, (newValue) => {
  model.inputValue = newValue;
}, {
  deep: true
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
