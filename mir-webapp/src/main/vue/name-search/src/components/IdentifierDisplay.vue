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

<script>
import {Component, Prop, Vue} from "vue-property-decorator";

@Component({})
export default class IdentifierDisplay extends Vue {

  @Prop()
  value;

  @Prop()
  type;

  get url() {
    switch (this.type.toLowerCase()) {
      case "orcid":
        return `https://orcid.org/${this.value}`;
      case "gnd":
        return `http://d-nb.info/gnd/${this.value}`;
      case "viaf":
        return `https://viaf.org/viaf/${this.value}/`;
      case "loc":
        return `https://id.loc.gov/authorities/names/${this.value}.html`
      case "grid":
        return `https://www.grid.ac/institutes/${this.value}`;
      case "isni":
        return `https://isni.org/isni/${this.value.replaceAll(/ /g, '')}`;
      case "wikidata":
        return `https://www.wikidata.org/wiki/${this.value}`;
      case "ror":
        return `https://ror.org/${this.value}`;
      default:
        return this.value;
    }
  }

}
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