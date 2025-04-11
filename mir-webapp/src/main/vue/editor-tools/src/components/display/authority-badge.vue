<template>
    <span v-if="props.authority && !props.valueURI" class="badge rounded-pill bg-info">
        {{ model.label }}
    </span>
    <a v-else-if="props.authority && props.valueURI"
       :href="props.valueURI"
       class="badge rounded-pill bg-info"
       target="_blank">{{ i18n["mir.subject.bagde." + props.authority] }} <i
            class="fas fa-external-link"> </i>
    </a>
    <a class="badge rounded-pill bg-danger" v-if="editable" href="#empty" @click.prevent="removeBadge">
      <span class="fas fa-remove"></span>
    </a>
</template>

<script lang="ts" setup>
import {defineProps, reactive} from "vue";
import {provideTranslations} from "@/api/I18N";

const props = defineProps<{
    authority?: string
    authorityURI?: string
    valueURI?: string
    editable?: boolean
}>();


const model = reactive({
    label: ""
});

const i18n = provideTranslations([
    "mir.subject.bagde.wikidata",
    "mir.subject.bagde.gnd",
    "mir.subject.bagde.lcsh",
    "mir.subject.bagde.viaf"
]);

const emit = defineEmits<{ (e: 'removeAuthority'): void}>();


const removeBadge = () => {
  emit('removeAuthority');
};

</script>

<style>

</style>
