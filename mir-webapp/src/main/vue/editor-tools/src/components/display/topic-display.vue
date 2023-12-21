<template>
    <div>
        <i v-if="props.mode == 'search'" class="fas fa-tag fa-fw mr-1"> </i>
        <a v-if="props.topic.valueURI"
           :href="props.topic.valueURI"
           target="_blank">
            {{ props.topic.text }}
        </a>
        <span v-else>
            {{ props.topic.text }}
        </span>

        <box-popover v-if="props.mode == 'editor'" :title="i18n['mir.details.popover.title']">
            <dl>
                <dt>{{ i18n["mir.details.popover.type"]}}</dt>
                <dd>
                    <i class="fas fa-tag ml-1"> </i>
                    {{ i18n["mir.details.popover.type.topic"] }}
                </dd>
            </dl>
        </box-popover>
    </div>
</template>

<script setup lang="ts">
import {Topic} from "@/api/Subject";
import BoxPopover from "@/components/display/box-popover.vue";
import {provideTranslations} from "@/api/I18N";


const props = defineProps<{
    topic: Topic,
    mode: "search" | "editor";
}>();

const i18n = provideTranslations([
    "mir.details.popover.title",
    "mir.details.popover.type",
    "mir.details.popover.type.topic"
]);


</script>

<style>

</style>