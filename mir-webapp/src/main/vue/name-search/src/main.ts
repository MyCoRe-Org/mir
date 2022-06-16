import Vue from 'vue'
import PersonSearch from './App.vue'

Vue.config.productionTip = false

new Vue({
  render: h => h(PersonSearch),
}).$mount('#app')

