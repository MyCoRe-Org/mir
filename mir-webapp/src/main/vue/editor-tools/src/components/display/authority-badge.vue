<template>
    <span v-if="props.authority && !props.valueURI" class="badge badge-pill badge-info">
        {{ model.label }}
    </span>
    <a v-else-if="props.authority && props.valueURI"
       :href="props.valueURI"
       class="badge badge-pill badge-info"
       target="_blank">{{ model.label }} <i
            class="fas fa-external-link"> </i>
    </a>
    <a class="badge badge-pill badge-danger" v-if="editable" href="#empty" @click.prevent="removeBadge">
      <span class="fas fa-remove"></span>
    </a>
</template>

<script lang="ts" setup>
import {defineProps, reactive, onMounted} from "vue";
import {getAuthorityBadgeName} from "@/api/Utils";

const props = defineProps<{
    authority?: string
    authorityURI?: string
    valueURI?: string
    editable?: boolean
}>();


const model = reactive({
    label: ""
});

const emit = defineEmits<{ (e: 'removeAuthority'): void}>();

onMounted(() => {
    if (props.authority) {
        getAuthorityBadgeName(props.authority).then((label) => {
            model.label = label;
        });
    }
})

const removeBadge = () => {
  emit('removeAuthority');
};

</script>

<style>

</style>
