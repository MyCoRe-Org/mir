<template>
  <div class="card" :class="cardClass">
    <div class="card-header">
      <ul class="nav nav-tabs card-header-tabs">
        <li v-for="tab in tabs" class="nav-item">
          <a class="nav-link"
             :class="tab === model.currentTab ? 'active' : ''"
             v-on:click="changeToTab(tab)"
             href="#">{{ tab.title }}</a>
        </li>
          <li class="close-btn nav-item ms-auto" v-if="closeBtn">
              <a class="nav-link" href="#" v-on:click="emit('closeButtonPressed')"><i class="fas fa-times"></i></a>
          </li>
      </ul>
    </div>
    <div class="card-body" v-if="model.currentTab">
      <h5 v-if="!model.currentTab.noTitle" class="card-title">{{ model.currentTab.title }}</h5>
      <slot :name="model.currentTab.id"></slot>
    </div>
  </div>
</template>

<script setup lang="ts">

import {watch, reactive, defineProps} from "vue";


const props = defineProps<{
    tabs: Tab[],
    current: string,
    cardClass?: string,
    closeBtn?: boolean
}>();

interface Tab {
  id: string;
  title?: string;
  noTitle?: boolean
}

const emit = defineEmits(['tabChanged', 'closeButtonPressed']);
const model = reactive({
  currentTab: props.tabs.filter((tab:Tab) => tab.id === props.current)[0]
});

watch(() => props.current, (newCurrent) => model.currentTab = props.tabs.filter((tab:Tab) => tab.id === newCurrent)[0]);

function changeToTab(tab: Tab) {
  const old = model.currentTab;
  model.currentTab = tab;
  emit('tabChanged', {old: old, _new: model.currentTab});
}

</script>

<style scoped>
.close-btn a {
    border: 0;
}
</style>