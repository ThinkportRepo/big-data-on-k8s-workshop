import Vue from "vue";
import VueRouter from "vue-router";

import Navbar from "@/components/Navbar.vue";
import Dashboard from "@/components/Dashboard.vue";
import Status from "@/components/Status.vue";
import Lab_1_Kubernetes from "@/components/Lab_1_Kubernetes.vue";
import Lab_2_SparkSimple from "@/components/Lab_2_SparkSimple.vue";
import Lab_3_Kafka from "@/components/Lab_3_Kafka.vue";

Vue.use(VueRouter);

const routes = [
  {
    path: "/",
    name: "Home",
    components: {
      default: Dashboard,
      navigation: Navbar,
    },
  },
  {
    path: "/status",
    name: "Statzs",
    components: {
      default: Status,
      navigation: Navbar,
    },
  },
  {
    path: "/lab-kubernetes",
    name: "Lab_1_Kubernetes",
    components: {
      default: Lab_1_Kubernetes,
      navigation: Navbar,
    },
  },
  {
    path: "/lab-spark-simple",
    name: "Lab_2_SparkSimple",
    components: {
      default: Lab_2_SparkSimple,
      navigation: Navbar,
    },
  },
  {
    path: "/lab-kafka",
    name: "Lab_3_Kafka",
    components: {
      default: Lab_3_Kafka,
      navigation: Navbar,
    },
  },
  // catch all 404 route that are not defined
  {
    path: "/:catchAll(.*)",
    name: "Notfound",
    components: {
      default: Dashboard,
      navigation: Navbar,
    },
  },
];

const router = new VueRouter({
  mode: "history",
  base: process.env.BASE_URL,
  routes,
});

export default router;
