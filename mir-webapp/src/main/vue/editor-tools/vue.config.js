const { defineConfig } = require('@vue/cli-service')
const path = require('path')

module.exports = defineConfig({
  transpileDependencies: true,


  /* TODO: Remove this when the following issue is fixed: https://github.com/MelihAltintas/vue3-openlayers/issues/216 */
  chainWebpack(config) {
    config.resolve.symlinks(false)
    config.resolve.alias.set( 'vue', path.resolve('./node_modules/vue'))
  },
})
