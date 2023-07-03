import Vue from "vue";
import VueRouter from "vue-router";

import Navbar from "@/components/Navbar.vue";
import Dashboard from "@/components/Dashboard.vue";
import Status from "@/components/Status.vue";
import Lab_1_Kubernetes from "@/components/Lab_1_Kubernetes.vue";
import Lab_2_SparkBasics from "@/components/Lab_2_SparkBasics.vue";
import Lab_3_Kafka from "@/components/Lab_3_Kafka.vue";
import Lab_4_SparkStreaming from "@/components/Lab_4_SparkStreaming.vue";
import Lab_5_SparkSQL from "@/components/Lab_5_SparkSQL.vue";
import Lab_6_Cassandra from "@/components/Lab_6_Cassandra.vue";
import Lab_7_Trino from "@/components/Lab_7_Trino.vue";

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
    name: "Status",
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
    path: "/lab-spark-basics",
    name: "Lab_2_SparkBasics",
    components: {
      default: Lab_2_SparkBasics,
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
  {
    path: "/lab-spark-streaming",
    name: "Lab_4_SparkStreaming",
    components: {
      default: Lab_4_SparkStreaming,
      navigation: Navbar,
    },
  },
  {
    path: "/lab-spark-sql",
    name: "Lab_5_SparkSQL",
    components: {
      default: Lab_5_SparkSQL,
      navigation: Navbar,
    },
  },
  {
    path: "/lab-cassandra",
    name: "Lab_6_Cassandra",
    components: {
      default: Lab_6_Cassandra,
      navigation: Navbar,
    },
  },
  {
    path: "/lab-trino",
    name: "Lab_7_Trino",
    components: {
      default: Lab_7_Trino,
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
