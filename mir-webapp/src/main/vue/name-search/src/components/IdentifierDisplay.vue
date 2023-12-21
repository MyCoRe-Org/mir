<!--
  -  This file is part of ***  M y C o R e  ***
  -  See http://www.mycore.de/ for details.
  -
  -  MyCoRe is free software: you can redistribute it and/or modify
  -  it under the terms of the GNU General Public License as published by
  -  the Free Software Foundation, either version 3 of the License, or
  -  (at your option) any later version.
  -
  -  MyCoRe is distributed in the hope that it will be useful,
  -  but WITHOUT ANY WARRANTY; without even the implied warranty of
  -  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  -  GNU General Public License for more details.
  -
  -  You should have received a copy of the GNU General Public License
  -  along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
  -->

<template>
  <span><span class="identifier-key">{{ type }}</span><a class="identifier-value" :href="url">{{ value }}</a> </span>
</template>

<script setup lang="ts">

import { computed, defineProps } from "vue";

const props = defineProps< {
    value: string,
    type: string
}>();

const url = computed(() => {
    switch (props.type.toLowerCase()) {
        case "orcid":
            return `https://orcid.org/${props.value}`;
        case "gnd":
            return `http://d-nb.info/gnd/${props.value}`;
        case "viaf":
            return `https://viaf.org/viaf/${props.value}/`;
        case "loc":
            return `https://id.loc.gov/authorities/names/${props.value}.html`
        case "grid":
            return `https://www.grid.ac/institutes/${props.value}`;
        case "isni":
            return `https://isni.org/isni/${props.value.replaceAll(/ /g, '')}`;
        case "wikidata":
            return `https://www.wikidata.org/wiki/${props.value}`;
        case "ror":
            return `https://ror.org/${props.value}`;
        default:
            return props.value;
    }

});
</script>

<style scoped>
span {
  display: inline-block;
}

.identifier-key {
  text-transform: uppercase;
}

.identifier-key::after {
  content: ':';
}

.identifier-value {
  padding-left: 3px;
}
</style>