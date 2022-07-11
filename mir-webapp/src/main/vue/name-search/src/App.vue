<template>
  <div ref="root" class="form-group" v-click-outside="closeDrops">
    <template v-if="i18nLoaded && classesLoaded">
      <div ref="input" class="input-group">
        <input type="text" class="form-control" :id="`personLabel-${this.nameIndex}`" :placeholder="personPlaceholder" v-model="search"
               v-on:keydown.enter.prevent="startSearch()">
        <div class="input-group-append">
          <button class="btn btn-secondary"
                  v-on:click.prevent="currentIdentifierClicked()">
            <i class="fas fa-address-card"></i>
            <span class="identifier-count">{{ currentIdentifier.length }}</span>
          </button>
          <button :id="`search-${this.nameIndex}`" type="button" class="btn btn-outline-secondary"
                  v-on:click.prevent="startSearch()">
            {{ searchLabel }}
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
            <li v-for="obj in results" :class="`nav-item`" :key="obj.name">
              <a :class="`nav-link${currentProvider===obj.name?' active':''}${obj.searching===true || obj.nameList.length === 0?' disabled':''}`"
                 v-on:click.prevent="currentProvider=obj.name">
                {{ obj.name }}
                <span v-if="obj.searching===true" class="spinner-border spinner-border-sm">
              </span>
              </a>
            </li>
          </ul>

          <template v-for="searchResult in getCurrentResults(currentProvider).nameList">
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

  results: Array<{ name: string; searching: boolean, nameList: NameSearchResult[] }> = []

  currentIdentifier: Identifier[] = [];

  dropVisible = 0;

  currentProvider = "";

  i18nLoaded = false;

  classesLoaded = false;

  currentOwnIdentifierType = "";
  currentOwnIdentifierValue = "";

  possibleIdentifierTypes: Array<IdentifierType> = [];

  private personPlaceholder?: string;
  private searchLabel?: string;
  private addLabel?: string;
  private selectLabel?: string;
  private currentSearch?: number;


  @Watch('currentIdentifier')
  identifierChanged() {
    if (!this.isDevMode() && this.nameIndex !== undefined) {
      storeIdentifiers(this.nameIndex, this.currentIdentifier);
    }
  }

  @Watch('search')
  searchChanged() {
    if (!this.isDevMode() && this.nameIndex !== undefined) {
      storeName(this.nameIndex, this.search);
    }
  }

  @Watch('isPerson')
  isPersonChanged() {
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

  getCurrentResults(currentProvider: string) {
    const result = this.results.filter(prov => prov.name === currentProvider)[0];
    console.log(["Getting current results of ", currentProvider, result]);
    return result;
  }

  startSearch() {
    console.log("Start Search!");
    let currentSearchID = Math.random();
    this.currentSearch = currentSearchID;
    this.currentProvider = SearchProviderRegistry.getProviders()[0].name;
    while (this.results.length > 0) {
      this.results.pop();
    }

    this.currentProvider = SearchProviderRegistry.getProviders()[0].name;
    for (const provider of SearchProviderRegistry.getProviders()) {
      const currentSearch = {
        name: provider.name,
        searching: true,
        nameList: [] as NameSearchResult[]
      };
      this.results.push(currentSearch);
      console.time(provider.name,);
      provider.searchPerson(this.search).then((nameSearchResults => {
        if (this.currentSearch == currentSearchID) {
          currentSearch.nameList = nameSearchResults;
          console.log(["Results", nameSearchResults]);
          console.timeEnd(provider.name);
          currentSearch.searching = false;
        } else {
          console.log("Old Search!");
        }
      }), (err) => {
        if (this.currentSearch == currentSearchID) {
          console.error(["Error", err])
          currentSearch.searching = false;
        } else {
          console.log("Old Search!");
        }
      });
    }

    this.dropVisible = 1;
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
    console.log("Clicked outside!")
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
