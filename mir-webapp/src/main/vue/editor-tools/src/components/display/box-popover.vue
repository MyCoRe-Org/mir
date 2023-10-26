<template>
    <a ref="popoverTrigger" class="popover-trigger ml-1">
        <i class="fa fa-info-circle"> </i>
    </a>
    <div ref="popoverContent" class="popover-content d-none">
        <slot></slot>
    </div>
</template>

<script lang="ts" setup>
import {nextTick, onMounted, onUnmounted, ref} from "vue";

const popoverTrigger = ref<HTMLElement | null>(null);
const popoverContent = ref<HTMLElement | null>(null);

const props = defineProps<{
    title: string;
}>();

const slots = defineSlots<{
    default: void;
}>();

let content$: any = null;
let trigger$: any = null;

onMounted(() => {
    nextTick(()=> {
        setTimeout(() => {
            const jq = (window as any)["$"];
            content$ = jq(popoverContent.value);
            content$.detach();
            content$.removeClass("d-none");

            trigger$ = jq(popoverTrigger.value);

            // this is a hack to get add a close button to the popover, which is not supported by bootstrap
            trigger$.popover({
                html: true,
                content: content$,
                placement: "right",
                title: function () {
                    const el = jq("<div><div>"+props.title+"</div><div class='popoverclose btn btn-xs'><i class='fa fa-times'></i></div></div>");

                    el.click(() => {
                        content$.parents(".popover-trigger").popover("hide");
                    });
                    return el;
                }
            });
        }, 1000);
    });
});

onUnmounted( () => {
    if(trigger$ != null) {
        trigger$.popover("dispose");
    }
});



</script>

<style>

</style>