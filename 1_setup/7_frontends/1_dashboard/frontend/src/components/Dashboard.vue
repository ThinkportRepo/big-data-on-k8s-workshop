<template>
  <v-container>
    <v-row v-if="serverOutputStatus">
      <v-col>
        <v-progress-linear indeterminate color="deep-orange" height="25"
          >connecting to Kubernetes Cluster ...</v-progress-linear
        >
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="mb-4" v-if="show_terminal">
        <Card
          title="Terminal"
          text="Terminal with Kubernetes access"
          url_label="Open Terminal"
          subdomain="terminal"
          image="terminal_logo.png"></Card
      ></v-col>
      <v-col cols="mb-4" v-if="show_vscode">
        <Card
          title="VSCode"
          text="Visual Studio Code Editor"
          url_label="Open VSCode"
          subdomain="vscode"
          image="vscode_logo.png"
          :status_color="appStatusColor('vscode')"></Card
      ></v-col>
      <v-col cols="mb-4" v-if="show_jupyter">
        <Card
          title="Jupyter"
          text="Notebook for Python & PySpark"
          url_label="Open Jupyter"
          subdomain="jupyter"
          image="jupyter_logo.png"
          :status_color="appStatusColor('jupyter')"></Card
      ></v-col>
      <v-col cols="mb-4" v-if="show_zeppelin">
        <Card
          title="Zeppelin"
          text="Notebook for Scala, Java, Sql"
          url_label="Open Zeppelin"
          subdomain="zeppelin"
          image="zeppelin_logo.png"></Card
      ></v-col>
      <v-col cols="mb-4" v-if="show_sqlpad">
        <Card
          title="SQL Pad"
          text="SQL Browser for running SQL queries and visualizing results "
          url_label="Open SQLPad"
          subdomain="sqlpad"
          image="sql_logo.png"
          :status_color="appStatusColor('sqlpad')"></Card
      ></v-col>
    </v-row>

    <v-row>
      <v-col cols="mb-4" v-if="show_metabase">
        <Card
          title="Metabase"
          text="BI Tool for dashboards and data visualization"
          url_label="Open Metabase"
          subdomain="metabase"
          image="metabase_logo.png"
          :status_color="appStatusColor('metabase')"></Card
      ></v-col>
      <v-col cols="mb-4" v-if="show_minio">
        <Card
          title="Minio UI"
          text="s3 compatiple object storage"
          url_label="Open Minio"
          subdomain="minio"
          image="minio_logo.png"
          :status_color="appStatusColor('minio')"></Card
      ></v-col>
      <v-col cols="mb-4" v-if="show_trino">
        <Card
          title="Trino UI"
          text="Overview and performance analysis of Trino queries"
          url_label="Open Trino UI"
          subdomain="trino"
          image="trino2_logo.png"
          :status_color="appStatusColor('trino')"></Card
      ></v-col>
    </v-row>
    <v-row>
      <v-col cols="mb-4" v-if="show_spark">
        <Card
          title="Spark UI"
          text="Spark history server for all running and completed jobs"
          url_label="Open SparkUI"
          subdomain="spark"
          image="spark_logo.png"
          :status_color="appStatusColor('spark')"></Card
      ></v-col>

      <v-col cols="mb-4" v-if="show_kafka">
        <Card
          title="Kafka UI"
          text="UI for managing Kafka topics"
          url_label="Open Kafka UI"
          subdomain="kafka"
          image="kafka_logo.png"
          :status_color="appStatusColor('kafka')"></Card
      ></v-col>
    </v-row>

    <v-row><v-divider></v-divider> </v-row>
    <v-row>
      <v-col cols="mb-4" v-if="show_kubernetes">
        <Card
          title="Kubernetes UI"
          text="Kubernetes Cluster Overview"
          url_label="Open K8S"
          subdomain="k8s"
          image="kubernetes_logo.png"></Card
      ></v-col>
      <v-col cols="mb-4" v-if="show_grafana">
        <Card
          title="Grafana UI"
          text="Analytics & monitoring "
          url_label="Open Grafana"
          subdomain="grafana"
          image="grafana_logo.jpeg"></Card
      ></v-col>
    </v-row>
  </v-container>
</template>

<script>
import Card from "@/components/Card";
import * as socketio from "@/plugins/socketio";

export default {
  name: "Dashboard",
  components: {
    Card,
  },

  data: () => ({
    serverOutput: {kafka: {status: "error"}, spark: {status: "error"}},
    serverOutputStatus: true,
    host: "VUE_APP_K8S_HOST",
    show_terminal: false,
    show_vscode: true,
    show_jupyter: true,
    show_zeppelin: false,
    show_sqlpad: true,
    show_metabase: true,
    show_spark: true,
    show_trino: true,
    show_kafka: true,
    show_minio: true,
    show_kubernetes: false,
    show_grafana: false,
  }),
  created() {
    //this.getApplicationInfo();
    //setInterval(this.apiCallWrapper, 6000);
  },
  //the mounted lifecycle hook
  mounted() {
    socketio.addEventListener({
      type: "cluster",
      callback: (message) => {
        this.serverOutput = message;
        this.serverOutputStatus = false;
      },
    });
  },
  computed: {},
  methods: {
    appStatusColor(app_key) {
      let status = "";
      if (app_key == "minio") {
        status = this.serverOutput.minio.status;
      } else if (app_key == "trino") {
        status = this.serverOutput.trino.status;
      } else if (app_key == "kafka") {
        status = this.serverOutput.kafka.status;
      } else if (app_key == "spark") {
        status = this.serverOutput.spark.status;
      } else {
        status = this.serverOutput.frontend[app_key].status;
      }

      if (status == "Running") {
        return "green";
      } else {
        return "red";
      }
    },
  },
};
</script>
