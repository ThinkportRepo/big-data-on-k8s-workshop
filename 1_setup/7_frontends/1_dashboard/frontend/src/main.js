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

Vue.directive("mdstyle", (parentElement) => {
  const els = parentElement.querySelectorAll("h1");

  els.forEach((el) => {
    el.style.fintSize = "200px";
  });
});

Vue.directive("default-classes", (parentElement) => {
  const els = parentElement.querySelectorAll("h1");

  els.forEach((el) => {
    el.classList.add("custom");
  });
});

new Vue({
  router,
  vuetify,
  render: (h) => h(App),
}).$mount("#app");
