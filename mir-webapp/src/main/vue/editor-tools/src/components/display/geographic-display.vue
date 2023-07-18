<template>
    <i class="fas fa-map-location-dot mr-2"> </i>
    {{ props.geographic.text }}
    <authority-badge v-if="props.geographic.authority" :authority="props.geographic.authority" :valueURI="props.geographic.valueURI" />
</template>

<script lang="ts" setup>
import {Geographic} from "@/api/Subject";
import AuthorityBadge from "@/components/display/authority-badge.vue";

const props = defineProps<{
    geographic: Geographic
}>();
</script>

<style scoped>

</style>
