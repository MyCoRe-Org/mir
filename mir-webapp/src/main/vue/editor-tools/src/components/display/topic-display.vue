<template>
    <div>
        <i class="fas fa-tag"> </i>
        <span class="ml-2">{{ props.topic.text }}</span>
        <authority-badge v-if="props.topic.authority" :authority="props.topic.authority" :valueURI="props.topic.valueURI" />
    </div>
</template>

<script setup lang="ts">
import {Topic} from "@/api/Subject";
import AuthorityBadge from "@/components/display/authority-badge.vue";


const props = defineProps<{
    topic: Topic
}>();



</script>

<style>

</style>