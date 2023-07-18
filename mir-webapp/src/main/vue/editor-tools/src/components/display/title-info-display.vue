<template>
  <div>
      <i class="fa fa-newspaper"></i>
      <span class="ml-2" v-for="title in props.titleInfo.title">{{ title }}</span>
      <span class="ml-2" v-for="subtitle in props.titleInfo.subTitle">{{ subtitle }}</span>
      <span class="ml-2" v-for="partNumber in props.titleInfo.partNumber">{{ partNumber }}</span>
      <span class="ml-2" v-for="partName in props.titleInfo.partName">{{ partName }}</span>
      <span class="ml-2" v-for="nonSort in props.titleInfo.nonSort">{{ nonSort }}</span>
      <authority-badge v-if="props.titleInfo.authority" :authority="props.titleInfo.authority" :valueURI="props.titleInfo.valueURI" />
  </div>

</template>


<script lang="ts" setup>
import {defineProps} from "vue";
import { TitleInfo} from "@/api/Subject";
import AuthorityBadge from "@/components/display/authority-badge.vue";

const props = defineProps<{ titleInfo: TitleInfo }>();


</script>


<style scoped>

</style>
