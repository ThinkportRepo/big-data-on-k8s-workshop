<template>
  <v-container>
    <v-row>
      <v-col cols="mb-4">
        <Card
          title="Terminal"
          text="Terminal with Kubernetes access"
          url_label="Open Terminal"
          subdomain="terminal"
          image="terminal_logo.png"
        ></Card
      ></v-col>
      <v-col cols="mb-4">
        <Card
          title="VSCode"
          text="Visual Studio Code Editor"
          url_label="Open VSCode"
          subdomain="vscode"
          image="vscode_logo.png"
        ></Card
      ></v-col>
      <v-col cols="mb-4">
        <Card
          title="Jupyter"
          text="Notebook for Python & PySpark"
          url_label="Open Jupyter"
          subdomain="jupyter"
          image="jupyter_logo.png"
        ></Card
      ></v-col>
    </v-row>
    <v-row><v-divider></v-divider> </v-row>
    <v-row>
      <v-col cols="mb-4">
        <Card
          title="Zeppelin"
          text="Notebook for Scala, Java, Sql"
          url_label="Open Zeppelin"
          subdomain="zeppelin"
          image="zeppelin_logo.png"
        ></Card
      ></v-col>
      <v-col cols="mb-4">
        <Card
          title="SQL Pad"
          text="SQL Browser for running SQL queries and visualizing results "
          url_label="Open SQLPad"
          subdomain="sqlpad"
          image="sql_logo.png"
        ></Card
      ></v-col>
      <v-col cols="mb-4">
        <Card
          title="Metabase"
          text="BI Tool for dashboards and data visualization"
          url_label="Open Metabase"
          subdomain="metabase"
          image="metabase_logo.png"
        ></Card
      ></v-col>
    </v-row>
    <v-row><v-divider></v-divider> </v-row>
    <v-row>
      <v-col cols="mb-4">
        <Card
          title="Spark UI"
          text="Spark history server for all running and completed jobs"
          url_label="Open SparkUI"
          subdomain="spark"
          image="spark_logo.png"
        ></Card
      ></v-col>
      <v-col cols="mb-4">
        <Card
          title="Trino UI"
          text="Overview and performance analysis of Trino queries"
          url_label="Open Trino UI"
          subdomain="trino"
          image="trino2_logo.png"
        ></Card
      ></v-col>
      <v-col cols="mb-4">
        <Card
          title="Kafka UI"
          text="UI for managing Kafka topics"
          url_label="Open Zeppelin"
          subdomain="https://github.com/provectus/kafka-ui/blob/master/charts/kafka-ui/README.md"
          image="kafka_logo.png"
        ></Card
      ></v-col>
    </v-row>
    <v-row><v-divider></v-divider> </v-row>
    <v-row>
      <v-col cols="mb-4">
        <Card
          title="Kubernetes UI"
          text="Kubernetes Cluster Overview"
          url_label="Open K8S"
          subdomain="k8s"
          image="kubernetes_logo.png"
        ></Card
      ></v-col>
      <v-col cols="mb-4">
        <Card
          title="Grafana UI"
          text="Analytics & monitoring "
          url_label="Open Grafana"
          subdomain="grafana"
          image="grafana_logo.jpeg"
        ></Card
      ></v-col>
      <v-col cols="mb-4">
        <Card
          title="Minio UI"
          text="s3 compatiple object storage"
          url_label="Open Minio"
          subdomain="minio"
          image="minio_logo.png"
        ></Card
      ></v-col>
    </v-row>
  </v-container>
</template>

<script>
import Card from "@/components/Card";
export default {
  name: "Dashboard",
  components: {
    Card,
  },

  data: () => ({
    host: "VUE_APP_K8S_HOST",
  }),
};
</script>
