<template>
    <div>
        <TransitionGroup class="list-group" name="child-list" tag="ol">
            <li v-for="(subjectChild, i) in model.subject.children" :key="(subjectChild as any).key"
                class="list-group-item subject-child">
                <div class="row">
                    <div class="col-10 col-md-9">
                        <div v-if="subjectChild.type == 'Topic'">
                            <topic-display :topic="subjectChild as Topic"/>
                        </div>
                        <div v-else-if="subjectChild.type == 'Name'">
                            <name-display :name="subjectChild as Name"/>
                        </div>
                        <div v-else-if="subjectChild.type == 'Geographic'">
                            <geographic-display :geographic="subjectChild as Geographic"/>
                        </div>
                        <div v-else-if="subjectChild.type == 'TitleInfo'">
                            <title-info-display :titleInfo="subjectChild as TitleInfo"/>
                        </div>
                        <div v-else-if="subjectChild.type == 'Cartographics'">
                            <cartographics-display :cartographics="subjectChild as Cartographics"/>
                        </div>
                    </div>
                    <div class="col-2 col-md-3">
                        <repeater
                                :downEnabled="i < model.subject.children.length - 1"
                                :downVisible="!props.settings.simple && !simpleAndMultipleChilds"
                                :editEnabled="true"
                                :editPressed="model.editingObject == subjectChild"
                                :editVisible="(!props.settings.simple || props.settings.simple=='geographicPair') && !simpleAndMultipleChilds"
                                :minusEnabled="true"
                                :minusVisible="(!props.settings.simple || props.settings.simple=='geographicPair') && !simpleAndMultipleChilds "
                                :plusEnabled="false"
                                :plusVisible="false"
                                :upEnabled="i > 0 && !!simpleAndMultipleChilds"
                                :upVisible="!props.settings.simple"
                                v-on:downClicked="moveChildDown(subjectChild,i)"
                                v-on:editClicked="editChild(subjectChild,i)"
                                v-on:minusClicked="removeChild(subjectChild,i)"
                                v-on:upClicked="moveChildUp(subjectChild,i)"
                        />
                    </div>
                </div>
            </li>
        </TransitionGroup>
        <div ref="editDialog" class="modal" role="dialog" tabindex="-1">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Bearbeiten</h5>
                        <button aria-label="Close" class="close" data-dismiss="modal" type="button">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body" style="overflow: scroll">
                        <div v-if="model.editingObject != null">
                            <div v-if="model.editingObject.type == 'Topic'">
                                <topic-editor v-model="model.editingObjectCopy"
                                              @invalid:data="markInvalid"
                                              @valid:data="markValid"
                                />
                            </div>
                            <div v-else-if="model.editingObject.type == 'Name'">
                                <name-editor v-model="model.editingObjectCopy"
                                             @invalid:data="markInvalid"
                                             @valid:data="markValid"
                                />
                            </div>
                            <div v-else-if="model.editingObject.type == 'Geographic'">
                                <geographic-editor v-model="model.editingObjectCopy"
                                             @invalid:data="markInvalid"
                                             @valid:data="markValid"
                                />
                            </div>
                            <div v-else-if="model.editingObject.type == 'TitleInfo'">
                                <title-info-editor v-model="model.editingObjectCopy"
                                                   @invalid:data="markInvalid"
                                                   @valid:data="markValid"
                                />
                            </div>
                            <div v-else-if="model.editingObject.type == 'Cartographics'">
                                <cartographics-editor v-model="model.editingObjectCopy"
                                                    @invalid:data="markInvalid"
                                                    @valid:data="markValid"
                                />
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" type="button" @click.prevent="abortEdit()">
                            Abbrechen
                        </button>
                        <button :class="'btn btn-primary' + (!model.valid ? ' disabled':'')" type="button" @click.prevent="applyEdit()">
                            Speichern
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts" setup>

import {Cartographics, Geographic, Name, Subject, SubjectChild, TitleInfo, Topic} from "@/api/Subject";
import TopicEditor from "@/components/editor/topic-editor.vue";
import repeater from "@/components/editor/repeater.vue";
import {computed, defineProps, onMounted, reactive, ref, watch} from "vue";
import NameEditor from "@/components/editor/name-editor.vue";
import NameDisplay from "@/components/display/name-display.vue";
import GeographicDisplay from "@/components/display/geographic-display.vue";
import GeographicEditor from "@/components/editor/geographic-editor.vue";
import TopicDisplay from "@/components/display/topic-display.vue";
import TitleInfoEditor from "@/components/editor/title-info-editor.vue";
import TitleInfoDisplay from "@/components/display/title-info-display.vue";
import CartographicsDisplay from "@/components/display/cartographics-display.vue";
import CartographicsEditor from "@/components/editor/cartographic-editor.vue";
import {EditorSettings} from "@/api/XEditorConnector";

const props = defineProps<{
    modelValue: Subject,
    settings: EditorSettings
}>();

const emit = defineEmits(['update:modelValue'])

const editDialog = ref(null as any);

const model = reactive({
    subject: props.modelValue,
    editingObject: null as SubjectChild<any> | null,
    editingObjectCopy: null as SubjectChild<any> | null,
    valid: false,
});

watch(() => props.modelValue, (newValue) => {
    addKeys(newValue);
    model.subject = newValue;
}, {
    deep: true
});

watch(() => model.subject, (newValue) => {
    emit('update:modelValue', newValue)
}, {
    deep: true
});

const simpleAndMultipleChilds = computed(() => {
   return props.settings.simple===true && model.subject.children.length > 1
});

const removeChild = (subjectChild: SubjectChild<any>, i: number) => {
    console.log("Removing topic", subjectChild, i)
    model.subject.children.splice(i, 1);
}

const moveChildUp = (subjectChild: SubjectChild<any>, i: number) => {
    console.log("Moving topic up", subjectChild, i)
    model.subject.children.splice(i, 1);
    model.subject.children.splice(i - 1, 0, subjectChild);
}

const moveChildDown = (subjectChild: SubjectChild<any>, i: number) => {
    console.log("Moving topic down", subjectChild, i)
    model.subject.children.splice(i, 1);
    model.subject.children.splice(i + 1, 0, subjectChild);
}

const editChild = (subjectChild: SubjectChild<any>, i: number) => {
    const jq = (window as any).$;
    jq(editDialog.value).modal("show");
    model.editingObject = subjectChild;
    model.editingObjectCopy = JSON.parse(JSON.stringify(subjectChild));
}


const addKeys = (subject: Subject) => {
    subject.children.filter(val => !("key" in val)).forEach(val => {
        (val as any)["key"] = Math.random().toString(36).substring(2, 15);
    });
}

const removeKeys = (subject: Subject) => {
    subject.children.forEach(val => {
        delete (val as any)["key"];
    });
}

onMounted(() => {
    const jq = (window as any).$;
    jq(editDialog.value).modal({show: false});
    jq(editDialog.value).on('hidden.bs.modal', function () {
        abortEdit();
    })
});


const applyEdit = () => {
    if (model.editingObject && model.editingObjectCopy && model.valid) {
        const index = model.subject.children.indexOf(model.editingObject)
        model.subject.children[index] = model.editingObjectCopy;
        model.editingObject = null;
        model.editingObjectCopy = null;
        model.valid = true;

        const jq = (window as any).$;
        jq(editDialog.value).modal("hide");
    }
}

const abortEdit = () => {
    model.editingObject = null;
    model.editingObjectCopy = null;
    model.valid = true;

    const jq = (window as any).$;
    jq(editDialog.value).modal("hide");
}

const markInvalid = () => {
    model.valid = false;
}

const markValid = () => {
    model.valid = true;
}

</script>

<style scoped>

.modal-dialog {
    max-width: 90%;
}

.child-list-enter, .child-list-move, .child-list-leave {
    transition: all 1s;
}

</style>