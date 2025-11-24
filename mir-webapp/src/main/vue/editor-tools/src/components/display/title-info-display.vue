<template>
  <div>
      <i v-if="props.mode == 'search'" class="fas fa-newspaper fa-fw me-1"></i>
      <a v-if="props.titleInfo.valueURI"
         :href="props.titleInfo.valueURI"
         target="_blank">
        <span v-for="title in props.titleInfo.title" class="me-1">{{ title }}</span>
        <span v-for="subtitle in props.titleInfo.subTitle" class="me-1">{{ subtitle }}</span>
        <span v-for="partNumber in props.titleInfo.partNumber" class="me-1">{{ partNumber }}</span>
        <span v-for="partName in props.titleInfo.partName" class="me-1">{{ partName }}</span>
        <span v-for="nonSort in props.titleInfo.nonSort" class="me-1">{{ nonSort }}</span>
      </a>
      <span v-else>
        <span v-for="title in props.titleInfo.title" class="me-1">{{ title }}</span>
        <span v-for="subtitle in props.titleInfo.subTitle" class="me-1">{{ subtitle }}</span>
        <span v-for="partNumber in props.titleInfo.partNumber" class="me-1">{{ partNumber }}</span>
        <span v-for="partName in props.titleInfo.partName" class="me-1">{{ partName }}</span>
        <span v-for="nonSort in props.titleInfo.nonSort" class="me-1">{{ nonSort }}</span>
      </span>
      <box-popover v-if="props.mode == 'editor'" :title="i18n['mir.details.popover.title']">
          <dl>
              <dt>{{ i18n["mir.details.popover.type"]}}</dt>
              <dd>
                  <i class="fas fa-newspaper ms-1"> </i>
                  {{ i18n["mir.details.popover.type.titleInfo"] }}
              </dd>
          </dl>
      </box-popover>
  </div>
</template>


<script lang="ts" setup>
import {defineProps} from "vue";
import {TitleInfo} from "@/api/Subject";
import BoxPopover from "@/components/display/box-popover.vue";
import {provideTranslations} from "@/api/I18N";

const props = defineProps<{
    titleInfo: TitleInfo;
    mode: "search" | "editor";
}>();

const i18n = provideTranslations([
    "mir.details.popover.title",
    "mir.details.popover.type",
    "mir.details.popover.type.titleInfo"
]);

</script>


<style scoped>

</style>
