import { createApp } from 'vue'
import App from './App.vue'

document.querySelectorAll(".editorToolsApp").forEach((el) => {
    createApp(App).mount(el);
});
