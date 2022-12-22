import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import vuetify from "./plugins/vuetify";
import VueResource from "vue-resource";

Vue.config.productionTip = false;
Vue.use(VueResource, {
  // set default flavor of showdown
  flavor: "github",
});

new Vue({
  router,
  vuetify,
  render: (h) => h(App),
}).$mount("#app");
