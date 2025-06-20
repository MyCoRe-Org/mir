<template>
    <div class="row mt-2">
        <div class="col-12" v-for="(object, i) in model.value">
            <div class="row mt-2">
                <div class="col-3">
                    <slot name="label" :object="object" :index="i"></slot>
                </div>
                <div class="col-7">
                    <slot name="displayContent" :object="object" :index="i"/>
                </div>
                <div class="col-2">
                    <repeater :plusEnabled="true"
                              :minusEnabled="true"
                              :plusVisible="true"
                              :minusVisible="true"
                              :upEnabled="i > 0"
                              :upVisible="true"
                              :downEnabled="i < model.value.length - 1"
                              :downVisible="true"
                              :editEnabled="false"
                              :editVisible="false"
                              v-on:plusClicked="addChild(i)"
                              v-on:minusClicked="removeChild(object,i)"
                              v-on:upClicked="moveChildUp(object,i)"
                              v-on:downClicked="moveChildDown(object,i)"
                    />
                </div>
            </div>
        </div>

        <div class="col-12" v-if="model.value.length==0">
            <div class="row mt-2">
                <div class="col-3">
                    <slot name="label" :object="null" :index="0"></slot>
                </div>

                <div class="offset-7 col-2">
                     <!--**TODO button ist hier redundant, kann entfernt werden -->
                    <button :class="`btn btn-sm btn-secondary`"
                            type="button"
                            aria-label="Plus Button"
                            v-on:click.prevent="addChild(0)">
                        <i class="fas fa-plus"/>
                    </button>
                    <slot name="addButton">
                        <button class="btn btn-sm btn-secondary"
                                type="button"
                                aria-label="Add"
                                @click.prevent="addChild(0)">
                          <i class="fas fa-plus"></i>
                        </button>
                    </slot>
                  
                </div>
            </div>
        </div>

    </div>
</template>

<script setup lang="ts">
import {reactive, watch} from "vue";
import repeater from "@/components/editor/repeater.vue";

interface Props {
    defaultContent: any,
    modelValue: Array<any>,
}

const props = defineProps<Props>();

const emit = defineEmits(['update:modelValue', 'addDefault']);

const slots = defineSlots<{
    label: { object?: any, index: number }
    displayContent: { object: any, index: number },
    addButton: {}

}>();

const model = reactive({
    value: props.modelValue
});

watch(() => props.modelValue, (newValue) => {
    model.value = newValue;
}, {
    deep: true
});

const removeChild = (subjectChild: any, i: number) => {
    model.value.splice(i, 1);
    emit('update:modelValue', model.value);
}

const moveChildUp = (subjectChild: any, i: number) => {
    model.value.splice(i, 1);
    model.value.splice(i - 1, 0, subjectChild);
    emit('update:modelValue', model.value);
}

const moveChildDown = (subjectChild: any, i: number) => {
    model.value.splice(i, 1);
    model.value.splice(i + 1, 0, subjectChild);
    emit('update:modelValue', model.value);
}

const addChild = (i: number) => {
    model.value.splice(i + 1, 0, JSON.parse(JSON.stringify(props.defaultContent)));
    emit('update:modelValue', model.value);
}

</script>