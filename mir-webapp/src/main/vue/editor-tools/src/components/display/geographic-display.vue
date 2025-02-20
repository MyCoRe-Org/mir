<template>
    <i v-if="props.mode == 'search'" class="fas fa-map-location-dotme-2"> </i>
    <a v-if="props.geographic.valueURI"
       :href="props.geographic.valueURI"
       target="_blank">
        {{ props.geographic.text }}
    </a>
    <span v-else>
        {{ props.geographic.text }}
    </span>
    <box-popover v-if="props.mode == 'editor'" :title="i18n['mir.details.popover.title']">
        <dl>
            <dt>{{ i18n["mir.details.popover.type"]}}</dt>
            <dd>
                <i class="fas fa-map-location-dot ms-1"> </i>
                {{ i18n["mir.details.popover.type.geographic"] }}
            </dd>
        </dl>
    </box-popover>
</template>

<script lang="ts" setup>
import {Geographic} from "@/api/Subject";
import AuthorityBadge from "@/components/display/authority-badge.vue";
import {provideTranslations} from "@/api/I18N";
import BoxPopover from "@/components/display/box-popover.vue";

const props = defineProps<{
    geographic: Geographic,
    mode: "search" | "editor";
}>();

const i18n = provideTranslations([
    "mir.details.popover.title",
    "mir.details.popover.type",
    "mir.details.popover.type.geographic"
]);

</script>

<style scoped>

</style>
