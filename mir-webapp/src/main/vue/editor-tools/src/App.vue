<template>
    <editor-wrapper :labelledby="labelledby"></editor-wrapper>
</template>

<script lang="ts" setup>
import EditorWrapper from "@/components/editor-wrapper.vue";

defineProps<{
    labelledby?: string;
}>();

</script>

<style>

</style>
