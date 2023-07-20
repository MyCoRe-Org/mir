<template>
    <div>
        <i v-if="props.name.nameType == 'family'" class="fas fa-people-roof"> </i>
        <i v-else-if="props.name.nameType == 'corporate'" class="fas fa-building"> </i>
        <i v-else-if="props.name.nameType == 'personal'" class="fas fa-person"> </i>
        <i v-else-if="props.name.nameType == 'conference'" class="fas fa-people-line"> </i>
        <span class="ml-2" v-if="props.name.displayForm">{{ props.name.displayForm }}</span>
        <authority-badge v-if="props.name.authority" :authority="props.name.authority" :valueURI="props.name.valueURI" />
    </div>
</template>

<script setup lang="ts">

import {defineProps} from "vue";
import {Name} from "@/api/Subject";
import AuthorityBadge from "@/components/display/authority-badge.vue";

const props = defineProps<{ name: Name }>();

</script>