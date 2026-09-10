# editor-tools

## Project setup
```
yarn install
```

### Compiles and hot-reloads for development
```
yarn serve
```

### Compiles and minifies for production
```
yarn build
```

### Run your unit tests
```
yarn test:unit
```

### Lints and fixes files
```
yarn lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).

## Provider Setup

As standard to search for topics, the LobidProvider is set. To extend or change this behaviour the user can register 
other providers using one of the editor templates. To have multiple vocabularies inside one Dante provider, 
you can seperate them with "|". Alternatively multiple providers of the same type are supported. 

```
          <div class="editorToolsApp"
               data-searchable="*"
               data-editor="*"
               data-search-filter-default="*"
               data-admin="true"
               data-required="false"
               
               data-provider-lobid-label="Lobid"
               data-provider-lobid-enabled="true"
               data-provider-lobid-base-url="https://lobid.org/gnd/search"

               data-provider-dante-enabled="true"
               data-provider-dante-label="Dante"
               data-provider-dante-type="dante"
               data-provider-dante-vocabulary="foo|bar"
               data-provider-dante-base-url="https://api.dante.gbv.de/search"
               data-provider-dante-keys="inScheme,notation,altLabel"

          >
          </div>
```
Other providers may be added from your project using the SearchProviderRegistry.
When using the DanteSearchProvider you can add additional properties from the result that should be displayed.
To display them they need a message language property.
