<template>
  <div ref="root" class="form-group" v-click-outside="closeDrops">
    <template v-if="i18nLoaded && classesLoaded">
      <div ref="input" class="input-group">
        <input type="text" ref="searchBox" class="form-control" :id="`personLabel-${this.nameIndex}`"
               :placeholder="personPlaceholder" v-model="search"
               v-on:keydown.enter.prevent="startSearch()">
        <div class="input-group-append">
          <button ref="identifierOpenButton" class="btn btn-secondary"
                  v-on:click.prevent="currentIdentifierClicked()">
            <i class="fas fa-address-card"></i>
            <span class="identifier-count">{{ currentIdentifier.length }}</span>
          </button>
          <button :id="`search-${this.nameIndex}`" type="button" class="btn btn-secondary"
                  v-on:click.prevent="startSearch()">
            {{ searchLabel }}
          </button>
        </div>
      </div>

      <!-- List of selected identifiers -->
      <div v-if="(currentIdentifier.length>0 || defineOwnIdentifier ) && dropVisible===2"
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
      <div v-if="dropVisible===1" class="card search-completion"
           :style="`width: ${getGroupSize()}px`">
        <div class="card-body">

          <ul class="nav nav-tabs">
            <li v-for="obj in results" :class="`nav-item`" :key="obj.name">
              <a :class="`nav-link${currentProvider===obj.name?' active':''}${obj.searching===true || obj.nameList.length === 0?' initalism disabled':''}`"
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
                <i class="applyPerson fas fa-check text-info" v-on:click="applyName(searchResult, $event)"
                   :title="applyPersonTitle"></i>
              </div>
            </div>
            <div class="row" :key="`row2-${searchResult.id}`">
              <div class="col-12">
                <div class="identifier" v-for="identifier in searchResult.identifier"
                     :key="`${identifier.type}-${identifier.value}`">
                  <identifier-display :type="identifier.type" :value="identifier.value"/>
                  <i class="identifier-add fas fa-plus-circle text-info"
                     :title="addLabel"
                     v-on:click="addIdentifier(identifier, $event)"></i>
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
import {LocalSearchProvider} from "@/api/LocalSearchProvider";

Vue.use(vClickOutside)
LocalSearchProvider.init();
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
  private applyPersonTitle?: string;

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
    this.personPlaceholder = `${await i18n("mir.namePart.family")}, ${await i18n("mir.namePart.given")}`;
    [
      this.searchLabel,
      this.addLabel,
      this.selectLabel,
      this.applyPersonTitle
    ] = await Promise.all([
      i18n("mir.editor.person.search"),
      i18n("mir.editor.addIdentifier"),
      i18n("mir.select"),
      i18n("mir.editor.person.applyPerson")
    ]);
  }

  private initializeXEditorConnection() {
    if (!this.isDevMode() && this.$refs.root instanceof Element) {
      this.nameIndex = findNameIndex(this.$refs.root);
      this.search = retrieveDisplayName(this.nameIndex);
      this.currentIdentifier = retrieveIdentifiers(this.nameIndex);
      this.isPerson = retrieveIsPerson(this.nameIndex);
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
    return this.results.filter(prov => prov.name === currentProvider)[0];
  }

  startSearch() {
    let currentSearchID = Math.random();
    this.currentSearch = currentSearchID;
    while (this.results.length > 0) {
      this.results.pop();
    }

    this.currentProvider = "";
    for (const provider of SearchProviderRegistry.getProviders()) {
      const currentSearch = {
        name: provider.name,
        searching: true,
        nameList: [] as NameSearchResult[]
      };
      this.results.push(currentSearch);
      provider.searchPerson(this.search).then((nameSearchResults => {
        if (this.currentSearch == currentSearchID) {
          currentSearch.nameList = nameSearchResults;
          currentSearch.searching = false;
          if (this.currentProvider == "" && currentSearch.nameList.length > 0) {
            // the first tabs with results is shown
            this.currentProvider = provider.name;
          }
        }
      }), (err) => {
        if (this.currentSearch == currentSearchID) {
          currentSearch.searching = false;
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

  async addIdentifier(identifier: Identifier, event?: PointerEvent) {
    // if the function is caused by user action, we do a fancy animation
    if (event) {
      const clickTarget = event.currentTarget as HTMLElement;
      const identifier = (clickTarget.parentElement as HTMLElement).firstElementChild as HTMLElement;
      const identifierOpenButton = this.$refs.identifierOpenButton as HTMLElement;
      const animation = this.animateElementToElement(identifier, identifierOpenButton);
      await animation.finished;
    }

    if (this.currentIdentifier.filter(id => id.type == identifier.type && id.value == identifier.value).length == 0) {
      this.currentIdentifier.push(identifier);
    }
  }

  animateElementToElement(from: HTMLElement, to: HTMLElement): Animation {
    const yMove = -1 * (from.getBoundingClientRect().y - to.getBoundingClientRect().y);
    const xMove = -1 * (from.getBoundingClientRect().x - to.getBoundingClientRect().x);

    const timing = {
      duration: 500,
      interations: 1
    };

    const movement = [
      {transform: `translate(0px,0px)`, opacity: 0.8},
      {transform: `translate(${xMove}px,${yMove}px)`, opacity: 0.4}
    ];

    return from.animate(movement, timing);
  }

  removeIdentifier(identifier: Identifier) {
    let number = this.currentIdentifier.indexOf(identifier);
    this.currentIdentifier.splice(number, 1);
  }

  async applyName(name: NameSearchResult, event: PointerEvent) {
    const clickTarget = event.currentTarget as HTMLElement;
    const clickParent = clickTarget.parentElement?.parentElement;
    const resultTitle = (clickParent?.querySelector(".result-title") as HTMLElement | undefined);
    const identifiers = clickParent?.nextElementSibling?.querySelectorAll('.identifier');
    const identifierOpenButton = this.$refs.identifierOpenButton as HTMLElement;
    const searchBox = this.$refs.searchBox as HTMLElement;

    if (resultTitle != undefined && identifiers != undefined) {
      const identifierElements = Array.from(identifiers);
      const animations = identifierElements
          .map(el => this.animateElementToElement(el as HTMLElement, identifierOpenButton))
          .concat(this.animateElementToElement(resultTitle, searchBox))
          .map(anim => anim.finished);

      await Promise.all(animations);
    }

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

.search-completion .nav-link {
  padding: 0.5rem 1rem;
}

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
  display: inline-block; /* required for the animation */
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
