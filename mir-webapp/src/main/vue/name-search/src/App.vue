<template>
  <div ref="root" class="form-group" v-click-outside="closeDrops">
    <template v-if="i18nLoaded && classesLoaded">
      <div ref="input" class="input-group">
        <input type="text" class="form-control" id="personLabel" :placeholder="personPlaceholder" v-model="search"
               v-on:keydown.enter.prevent="startSearch()">
        <div class="input-group-append">
          <button class="btn btn-secondary"
                  v-on:click.prevent="currentIdentifierClicked()">
            <i class="fas fa-address-card"></i>
            <span class="identifier-count">{{ currentIdentifier.length }}</span>
          </button>
          <button type="button" class="btn btn-outline-secondary" v-if="!searching" v-on:click.prevent="startSearch()">
            {{ searchLabel }}
          </button>
          <button type="button" class="btn btn-outline-secondary" v-else><span
              class="spinner-border spinner-border-sm"></span> {{ searchingLabel }}
          </button>
        </div>
      </div>

      <!-- List of selected identifiers -->
      <div v-if="$refs.input && (currentIdentifier.length>0 || defineOwnIdentifier ) && dropVisible===2"
           class="card current-identifier-list"
           :style="`width: ${getGroupSize()}px;`">
        <div class="card-body">
          <template v-if="defineOwnIdentifier">
            <div class="form-group row">
              <div class="col-4">
                <select class="form-control " v-model="currentOwnIdentifierType">
                  <option selected="selected" value="">{{ selectLabel }}</option>
                  <option v-for="identifierType in possibleIdentifierTypes" :key="identifierType.value">
                    {{ identifierType.label }}
                  </option>
                </select>
              </div>
              <div class="col-6">
                <input class="form-control" type="text" v-model="currentOwnIdentifierValue"/>
              </div>
              <div class="col-2">
                <button class="btn btn-secondary" v-on:click.prevent="addOwnIdentifier()" :title="addLabel">
                  <span class="fas fa-plus-circle"> </span>
                </button>
              </div>
            </div>
            <hr/>
          </template>
          <div v-for="identifier in currentIdentifier" :key="`${identifier.type}-${identifier.value}`"
               v-on:click.prevent="removeIdentifier(identifier)"
               class="identifier">
            <identifier-display :type="identifier.type" :value="identifier.value"/>
            <i class="identifier-remover fas fa-minus-circle text-info" v-on:click="addIdentifier(identifier)"></i>
          </div>

        </div>
      </div>
      <!-- Search results -->
      <div v-if="$refs.input && dropVisible===1" class="card search-completion"
           :style="`width: ${getGroupSize()}px`">
        <div class="card-body">

          <ul class="nav nav-tabs">
            <li v-for="(obj, provider) in results" :class="`nav-item`" :key="provider">
              <a :class="`nav-link${currentProvider===provider?' active':''}${obj.searching===true || obj.nameList.length === 0?' disabled':''}`"
                 v-on:click.prevent="currentProvider=provider">
                {{ provider }}
                <span v-if="obj.searching===true" class="spinner-border spinner-border-sm">
              </span>
              </a>
            </li>
          </ul>

          <template v-for="searchResult in results[currentProvider].nameList">
            <div class="row" :key="`row-${searchResult.id}`">
              <div class="col-10">
                <span class="result-title">{{ searchResult.displayForm }}</span>
                <i v-if="searchResult.person" class="fas fa-user"></i>
                <i v-else class="fas fa-building"> </i>
                <ul class="metadata-list">
                  <li v-for="meta in searchResult.metadata" :key="meta.id">
                    <span class="metadata-label">{{ meta.label }}</span><span class="metadata-value">{{
                      meta.value
                    }}</span>
                  </li>
                </ul>
              </div>
              <div class="col-2 applyPersonDiv">
                <i class="applyPerson fas fa-check text-info" v-on:click="applyName(searchResult)"></i>
              </div>
            </div>
            <div class="row" :key="`row2-${searchResult.id}`">
              <div class="col-12">
                <div class="identifier" v-for="identifier in searchResult.identifier"
                     :key="`${identifier.type}-${identifier.value}`">
                  <identifier-display :type="identifier.type" :value="identifier.value"/>
                  <i class="identifier-add fas fa-plus-circle text-info" v-on:click="addIdentifier(identifier)"></i>
                </div>
              </div>
            </div>
            <hr :key="`hr-${searchResult.id}`"/>
          </template>

        </div>
      </div>
    </template>
  </div>
</template>

<script lang="ts">
import {Component, Prop, Vue, Watch} from 'vue-property-decorator';
import {Identifier, NameSearchResult, SearchProviderRegistry} from "@/api/SearchProvider";
import {
  findNameIndex,
  retrieveDisplayName,
  retrieveIdentifiers,
  retrieveIsPerson,
  storeIdentifiers,
  storeIsPerson,
  storeName
} from "@/api/XEditorConnector";
import {LobidSearchProvider} from "@/api/LobidSearchProvider";
import {ViafSearchProvider} from "@/api/ViafSearchProvider";
import {ProxiedOrcidProvider} from "@/api/ProxiedOrcidProvider";
import IdentifierDisplay from "@/components/IdentifierDisplay.vue";
import vClickOutside from 'v-click-outside';
import {i18n} from "@/api/I18N";
import {RorSearchProvider} from "@/api/RorSearchProvider";

Vue.use(vClickOutside)
LobidSearchProvider.init();
ViafSearchProvider.init();
ProxiedOrcidProvider.init();
RorSearchProvider.init();

interface IdentifierType {
  value: string;
  label: string;
}

@Component({
  components: {IdentifierDisplay}
})
export default class PersonSearch extends Vue {

  @Prop()
  defineOwnIdentifier = false;

  nameIndex?: number;

  search = "";

  isPerson = true;

  results: Record<string, { searching: boolean, nameList: NameSearchResult[] }> = {};

  currentIdentifier: Identifier[] = [];

  dropVisible = 0;

  searching = false;

  currentProvider = "";

  i18nLoaded = false;

  classesLoaded = false;

  currentOwnIdentifierType = "";
  currentOwnIdentifierValue = "";

  possibleIdentifierTypes: Array<IdentifierType> = [];

  private personPlaceholder?: string;
  private searchLabel?: string;
  private searchingLabel?: string;
  private addLabel?: string;
  private selectLabel?: string;


  @Watch('currentIdentifier')
  identifierChanged() {
    console.log("Watch currentIdentifier")
    if (!this.isDevMode() && this.nameIndex !== undefined) {
      storeIdentifiers(this.nameIndex, this.currentIdentifier);
    }
  }

  @Watch('search')
  searchChanged() {
    console.log("Watch search")
    if (!this.isDevMode() && this.nameIndex !== undefined) {
      storeName(this.nameIndex, this.search);
    }
  }

  @Watch('isPerson')
  isPersonChanged() {
    console.log("Watch search")
    if (!this.isDevMode() && this.nameIndex !== undefined) {
      storeIsPerson(this.nameIndex, this.isPerson);
    }
  }

  isDevMode() {
    return process.env.NODE_ENV === 'development';
  }

  async mounted() {
    await this.loadLanguage();
    this.i18nLoaded = true;
    await this.loadIdentifierTypeClass();
    this.classesLoaded = true;

    this.initializeXEditorConnection();
  }

  private async loadIdentifierTypeClass() {
    if (this.defineOwnIdentifier) {
      const baseURL = (window as any) ["webApplicationBaseURL"];

      const classificationRESP = await fetch(`${baseURL}api/v2/classifications/nameIdentifier`, {
        headers: {
          "Accept": "application/json"
        }
      });
      const classificationJSON = await classificationRESP.json();

      for (const categ of classificationJSON.categories) {
        this.possibleIdentifierTypes.push(this.convertCategory(categ));
      }
    }
  }

  private async loadLanguage() {
    this.searchingLabel = await i18n("button.search");
    this.searchLabel = await i18n("editor.search.search");
    this.personPlaceholder = `${await i18n("mir.namePart.family")}, ${await i18n("mir.namePart.given")}`;
    this.addLabel = await i18n("mir.editor.addIdentifier");
    this.selectLabel = await i18n("mir.select");
  }

  private initializeXEditorConnection() {
    console.log(["devmode is ", this.isDevMode()]);
    console.log(["Element is ", this.$refs.root]);
    if (!this.isDevMode() && this.$refs.root instanceof Element) {
      this.nameIndex = findNameIndex(this.$refs.root);
      this.search = retrieveDisplayName(this.nameIndex);
      this.currentIdentifier = retrieveIdentifiers(this.nameIndex);
      this.isPerson = retrieveIsPerson(this.nameIndex);
      console.log("Name Index is " + this.nameIndex);
      console.log(["Identifiers are ", this.currentIdentifier])
    }
  }

  private convertCategory(categ: any) {
    return {
      value: (categ.ID as string).toLowerCase(),
      label: this.findLabel(categ)
    }
  }

  private findLabel(categ: any) {
    const currentLanguage = (window as any).currentLang;
    for (let labelIndex in categ.labels) {
      const label = categ.labels[labelIndex];
      if (label.lang == currentLanguage) {
        return label.text;
      }
    }
    return categ.labels[0].text;
  }

  addOwnIdentifier() {
    if (this.currentOwnIdentifierType != "" && this.currentOwnIdentifierValue != "") {
      const identifier: Identifier = {type: this.currentOwnIdentifierType, value: this.currentOwnIdentifierValue};
      this.currentIdentifier.push(identifier);
      this.currentOwnIdentifierValue = "";
      this.currentOwnIdentifierType = "";
    }
  }

  async startSearch() {
    console.log("Start Search!");
    if (this.searching) {
      console.log("Abort Search, already Searching!")
      return;
    }
    this.searching = true;

    this.currentProvider = SearchProviderRegistry.getProviders()[0].name;

    for (const provider of SearchProviderRegistry.getProviders()) {

      if (!(provider.name in this.results)) {
        this.results[provider.name] = {nameList: [], searching: true};
      }

      while (this.results[provider.name].nameList.length > 0) {
        this.results[provider.name].nameList.pop()
      }

      this.results[provider.name].searching = true;
    }

    for (const provider of SearchProviderRegistry.getProviders()) {
      try {
        (await provider.searchPerson(this.search)).forEach(pers => this.results[provider.name].nameList.push(pers));
      } catch (e) {
        console.error(["Error ", e]);
      } finally {
        this.results[provider.name].searching = false;
        this.dropVisible = 1;
      }
    }

    this.searching = false;
  }


  currentIdentifierClicked() {
    if (this.dropVisible == 2) {
      this.dropVisible = 0;
    } else {
      this.dropVisible = 2;
    }
  }


  getGroupSize() {
    return (this.$refs.input instanceof Element ? this.$refs.input.clientWidth : 0);
  }

  addIdentifier(identifier: Identifier) {
    if (this.currentIdentifier.filter(id => id.type == identifier.type && id.value == identifier.value).length == 0) {
      this.currentIdentifier.push(identifier);
    }
    this.dropVisible = 0;
  }

  removeIdentifier(identifier: Identifier) {
    let number = this.currentIdentifier.indexOf(identifier);
    this.currentIdentifier.splice(number, 1);
  }

  applyName(name: NameSearchResult) {
    while (this.currentIdentifier.length > 0) {
      this.currentIdentifier.pop();
    }
    name.identifier.forEach(identifier => this.addIdentifier(identifier));
    this.search = name.displayForm;
    this.isPerson = name.person;
  }

  closeDrops() {
    this.dropVisible = 0;
  }
}
</script>

<style scoped>

.disabled {
  color: gray !important;
}

.current-identifier-list {
  position: absolute;
  overflow-y: hidden;
  overflow-x: hidden;
  z-index: 100;
}

.search-completion {
  position: absolute;
  height: 400px;
  overflow-y: scroll;
  overflow-x: hidden;
  z-index: 100;
}

.metadata-list {
  padding-left: 0px;
}

.metadata-list li {
  list-style: none;
  margin-top: 0.5em;
}

.metadata-label {
  margin-right: 0.5em;
}

.metadata-label:after {
  content: ': ';
}

.result-title {
  font-weight: bold;
  margin-right: 0.5em;
}


.search-completion .row:first-of-type {
  margin-top: 1em;
}

.identifier-add {
  margin-left: 3px;
  cursor: pointer;
}

.identifier-remover {
  margin-left: 3px;
  cursor: pointer;
}

.identifier-count {
  font-size: 0.6em;
  margin-left: 4px;
  vertical-align: bottom;
}

.applyPerson {
  cursor: pointer;
}

.applyPersonDiv {
  align-items: center;
  display: inline-flex;
  justify-content: end;
}
</style>
