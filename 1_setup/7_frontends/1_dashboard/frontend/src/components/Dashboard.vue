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
          text="Editor and Terminal"
          url_label="Open VSCode"
          subdomain="vscode"
          image="vscode_logo.png"
          :status_color="appStatusColor('vscode')"></Card
      ></v-col>
      <v-col cols="mb-4" v-if="show_jupyter">
        <Card
          title="Jupyter"
          text="Spark with Python & SQL"
          url_label="Open Jupyter"
          subdomain="jupyter"
          image="jupyter_logo.png"
          :status_color="appStatusColor('jupyter')"></Card
      ></v-col>

      <v-col cols="mb-4" v-if="show_zeppelin">
        <Card
          title="Zeppelin"
          text="Spark with Scala & SQL"
          url_label="Open Zeppelin"
          subdomain="zeppelin"
          image="zeppelin_logo.png"
          :status_color="appStatusColor('zeppelin')"></Card
      ></v-col>
    </v-row>
    <v-row>
      <v-col cols="mb-4" v-if="show_sqlpad">
        <Card
          title="SQL Pad"
          text="SQL Editor & Trino access "
          url_label="Open SQLPad"
          subdomain="sqlpad"
          image="sql_logo.png"
          :status_color="appStatusColor('sqlpad')"></Card
      ></v-col>
      <v-col cols="mb-4" v-if="show_metabase">
        <Card
          title="Metabase"
          text="BI tool for data visualization"
          url_label="Open Metabase"
          subdomain="metabase"
          image="metabase_logo.png"
          :status_color="appStatusColor('metabase')"></Card
      ></v-col>

      <v-col cols="mb-4" v-if="show_minio">
        <Card
          title="Minio UI"
          text="s3 Data Lake"
          url_label="Open Minio"
          subdomain="minio"
          image="minio_logo.png"
          :status_color="appStatusColor('minio')"></Card
      ></v-col>
    </v-row>
    <v-row>
      <v-col cols="mb-4" v-if="show_trino">
        <Card
          title="Trino UI"
          text="Trino Query Monitoring"
          url_label="Open Trino UI"
          subdomain="trino"
          image="trino2_logo.png"
          :status_color="appStatusColor('trino')"></Card
      ></v-col>

      <v-col cols="mb-4" v-if="show_spark">
        <Card
          title="Spark UI"
          text="Spark history server"
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
    <v-row>
      <v-col cols="mb-4" v-if="show_kubernetes">
        <Card
          title="Kubernetes UI"
          text="Kubernetes Cluster Overview"
          url_label="Open K8S"
          subdomain="headlamp"
          image="kubernetes_logo.png"
          :status_color="appStatusColor('headlamp')"></Card
      ></v-col>
      <v-col cols="mb-4" v-if="show_prometheus">
        <Card
          title="Prometheus UI"
          text="Alerts & Monitoring "
          url_label="Open Prometheus"
          subdomain="prometheus"
          image="prometheus_logo.png"
          :status_color="appStatusColor('prometheus')"></Card
      ></v-col>

      <v-col cols="mb-4" v-if="show_grafana">
        <Card
          title="Grafana UI"
          text="Monitoring Dashboard"
          url_label="Open Grafana"
          subdomain="grafana"
          image="grafana_logo.jpeg"
          :status_color="appStatusColor('grafana')"></Card
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
    serverOutput: {},
    serverOutputStatus: true,
    host: "VUE_APP_K8S_HOST",
    show_terminal: false,
    show_vscode: true,
    show_jupyter: true,
    show_zeppelin: true,
    show_sqlpad: true,
    show_metabase: true,
    show_spark: true,
    show_trino: true,
    show_kafka: true,
    show_minio: true,
    show_kubernetes: true,
    show_grafana: true,
    show_prometheus: true,
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
      } else if (app_key == "prometheus") {
        status = this.serverOutput.monitoring.status;
      } else if (app_key == "grafana") {
        status = this.serverOutput.monitoring.grafana.status;
      } else if (app_key == "zeppelin") {
        status = "Deactivated";
      } else {
        status = this.serverOutput.frontend[app_key].status;
      }
      if (status == "Running") {
        return "green";
      } else if (status == "Deactivated") {
        return "grey";
      } else {
        return "red";
      }
    },
  },
};
</script>
