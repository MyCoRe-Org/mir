<template>
    <div>
        <i v-if="props.mode == 'search' && props.name.nameType == 'family'" class="fas fa-people-roof fa-fw mr-1"> </i>
        <i v-else-if="props.mode == 'search' && props.name.nameType == 'corporate'" class="fas fa-building fa-fw mr-1"> </i>
        <i v-else-if="props.mode == 'search' && props.name.nameType == 'personal'" class="fas fa-person fa-fw mr-1"> </i>
        <i v-else-if="props.mode == 'search' && props.name.nameType == 'conference'" class="fas fa-people-line fa-fw mr-1"> </i>
        <a v-if="props.name.valueURI"
           :href="props.name.valueURI"
           target="_blank">
            <span v-if="props.name.displayForm">{{ props.name.displayForm }}</span>
        </a>
        <span v-else>{{ props.name.displayForm }}</span>
        <box-popover v-if="props.mode == 'editor'" :title="i18n['mir.details.popover.title']">
            <dl>
                <dt>{{ i18n["mir.details.popover.type"]}}</dt>
                <dd>
                    <i v-if="props.name.nameType == 'family'" class="fas fa-people-roof fa-fw mr-1"> </i>
                    <i v-else-if="props.name.nameType == 'corporate'" class="fas fa-building fa-fw mr-1"> </i>
                    <i v-else-if="props.name.nameType == 'personal'" class="fas fa-person fa-fw mr-1"> </i>
                    <i v-else-if="props.name.nameType == 'conference'" class="fas fa-people-line fa-fw mr-1"> </i>
                    {{ i18n["mir.details.popover.type." + props.name.nameType] }}
                </dd>
                <name-identifier-display :type="(id as any).type" :value="id.text" v-for="id in props.name.nameIdentifier" />
            </dl>
        </box-popover>
    </div>
</template>

<script setup lang="ts">

import {defineProps} from "vue";
import {Name} from "@/api/Subject";
import BoxPopover from "@/components/display/box-popover.vue";
import {provideTranslations} from "@/api/I18N";
import NameIdentifierDisplay from "@/components/display/name-identifier-display.vue";

const props = defineProps<{
    name: Name,
    mode: "search" | "editor";
}>();

const i18n = provideTranslations([
    "mir.details.popover.title",
    "mir.details.popover.type",
    "mir.details.popover.type.personal",
    "mir.details.popover.type.family",
    "mir.details.popover.type.corporate",
    "mir.details.popover.type.conference"
]);

</script>