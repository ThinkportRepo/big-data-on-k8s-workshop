<template>
  <nav>
    <v-app-bar app color="indigo darken-3" dark clipped-left>
      <v-app-bar-nav-icon @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
      <div class="d-flex align-center">
        <v-btn href="http://dashboard.REPLACE_K8S_HOST" text>
          <span class="mr-2">Lab Big Data on Kubernetes </span>
        </v-btn>
      </div>

      <v-spacer></v-spacer>

      <v-btn href="https://www.thinkport.digital" target="_blank" text>
        <span class="mr-2">thinkport.digital</span>
        <v-icon>mdi-open-in-new</v-icon>
      </v-btn>
    </v-app-bar>
    <v-navigation-drawer app v-model="drawer" clipped width="300">
      <template v-slot:prepend>
        <v-list-item
          two-line
          href="http://dashboard.REPLACE_K8S_HOST"
          target="_blank"
        >
          <v-list-item-avatar>
            <img src="@/assets/thinkport_logo.png" />
          </v-list-item-avatar>

          <v-list-item-content class="ma-0">
            <v-list-item-title>REPLACE_LAB_USER</v-list-item-title>
            <v-list-item-subtitle>Practice Lab</v-list-item-subtitle>
          </v-list-item-content>
        </v-list-item>
        <v-divider></v-divider>
        <v-list-item two-line>
          <v-list-item-content>
            <v-list-item-subtitle><b>User:</b> trainadm </v-list-item-subtitle>
            <v-list-item-subtitle
              ><b>Password:</b> train@thinkport</v-list-item-subtitle
            >
          </v-list-item-content>
        </v-list-item>
      </template>
      <v-divider></v-divider>
      <v-list>
        <v-list-item router to="/">
          <v-list-item-icon>
            <v-icon>mdi-home</v-icon>
          </v-list-item-icon>

          <v-list-item-title>Home</v-list-item-title>
        </v-list-item>
        <v-list-group no-action prepend-icon="mdi-view-dashboard">
          <template v-slot:activator>
            <v-list-item-content>
              <v-list-item-title>Apps</v-list-item-title>
            </v-list-item-content>
          </template>

          <v-list-item
            v-if="show_terminal"
            class="pl-5 ml-5"
            href="http://terminal.REPLACE_K8S_HOST"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/terminal_logo.png" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>Terminal</v-list-item-title>
              <v-list-item-subtitle
                >Terminal with k8s access</v-list-item-subtitle
              >
            </v-list-item-content>
          </v-list-item>
          <v-list-item
            v-if="show_vscode"
            class="pl-5 ml-5"
            href="http://vscode.REPLACE_K8S_HOST"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/vscode_logo.png" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>VSCode</v-list-item-title>
              <v-list-item-subtitle
                >Visual Studio Code Editor</v-list-item-subtitle
              >
            </v-list-item-content>
          </v-list-item>
          <v-list-item
            v-if="show_jupyter"
            class="pl-5 ml-5"
            href="http://jupyter.REPLACE_K8S_HOST/jupyter/tree"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/jupyter_logo.png" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>Jupyter</v-list-item-title>
              <v-list-item-subtitle>Notebook for Python</v-list-item-subtitle>
            </v-list-item-content>
          </v-list-item>
          <v-list-item
            v-if="show_zeppelin"
            class="pl-5 ml-5"
            href="http://zeppelin.REPLACE_K8S_HOST"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/zeppelin_logo.png" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>Zeppelin</v-list-item-title>
              <v-list-item-subtitle
                >Notebook for Scala, Java, SQL</v-list-item-subtitle
              >
            </v-list-item-content>
          </v-list-item>
          <v-divider></v-divider>
          <v-list-item
            v-if="show_sqlpad"
            class="pl-5 ml-5"
            href="http://sqlpad.REPLACE_K8S_HOST"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/sql_logo.png" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>SQL Pad</v-list-item-title>
              <v-list-item-subtitle>Universal SQL Browser</v-list-item-subtitle>
            </v-list-item-content>
          </v-list-item>
          <v-list-item
            v-if="show_metabase"
            class="pl-5 ml-5"
            href="http://metabase.REPLACE_K8S_HOST"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/metabase_logo.png" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>Metabase</v-list-item-title>
              <v-list-item-subtitle
                >BI Tool for Visualisation</v-list-item-subtitle
              >
            </v-list-item-content>
          </v-list-item>

          <v-divider></v-divider>
          <v-list-item
            v-if="show_spark"
            class="pl-5 ml-5"
            href="http://spark.REPLACE_K8S_HOST"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/spark_logo.png" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>Spark UI</v-list-item-title>
              <v-list-item-subtitle>Spark Job Details</v-list-item-subtitle>
            </v-list-item-content>
          </v-list-item>
          <v-list-item
            v-if="show_trino"
            class="pl-5 ml-5"
            href="http://trino.REPLACE_K8S_HOST"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/trino_logo.png" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>Trino UI</v-list-item-title>
              <v-list-item-subtitle>Trino Query Details</v-list-item-subtitle>
            </v-list-item-content>
          </v-list-item>
          <v-list-item
            v-if="show_kafka"
            class="pl-5 ml-5"
            href="http://kafka.REPLACE_K8S_HOST"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/kafka_logo.png" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>Kafka UI</v-list-item-title>
              <v-list-item-subtitle>Kafka Topics Details</v-list-item-subtitle>
            </v-list-item-content>
          </v-list-item>
          <v-list-item
            v-if="show_kubernetes"
            class="pl-5 ml-5"
            href="http://k8s.REPLACE_K8S_HOST"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/kubernetes_logo.png" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>Kubernetes UI</v-list-item-title>
              <v-list-item-subtitle
                >Kubernets Cluster Overview</v-list-item-subtitle
              >
            </v-list-item-content>
          </v-list-item>
          <v-list-item
            v-if="show_grafana"
            class="pl-5 ml-5"
            href="http://grafana.REPLACE_K8S_HOST"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/grafana_logo.jpeg" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>Grafana</v-list-item-title>
              <v-list-item-subtitle>Monitoring Dashboards</v-list-item-subtitle>
            </v-list-item-content>
          </v-list-item>
          <v-list-item
            v-if="show_minio"
            class="pl-5 ml-5"
            href="http://minio.REPLACE_K8S_HOST"
            target="_blank"
          >
            <v-list-item-avatar tile size="30">
              <img src="@/assets/minio_logo.png" />
            </v-list-item-avatar>

            <v-list-item-content>
              <v-list-item-title>Minio</v-list-item-title>
              <v-list-item-subtitle>S3 Object Store</v-list-item-subtitle>
            </v-list-item-content>
          </v-list-item>
        </v-list-group>
        <v-list-item router to="/status">
          <v-list-item-icon>
            <v-icon>mdi-clipboard-pulse</v-icon>
          </v-list-item-icon>

          <v-list-item-title>Cluster Health</v-list-item-title>
        </v-list-item>
      </v-list>

      <!--
      <v-divider></v-divider>
      <v-list>
        <v-list-group no-action prepend-icon="mdi-checkbox-blank-outline">
          <template v-slot:activator>
            <v-list-item-content>
              <v-list-item-title>Exercises</v-list-item-title>
            </v-list-item-content>
          </template>

          <v-list-item class="pl-5 ml-5" router to="/lab-kubernetes"
            >1. Kubernetes</v-list-item
          >
          <v-list-item class="pl-5 ml-5" router to="/lab-kafka"
            >2. Kafka</v-list-item
          >
          <v-list-item class="pl-5 ml-5" router to="/lab-sparkstreaming"
            >3. Spark Streaming</v-list-item
          >
          <v-list-item class="pl-5 ml-5" router to="/lab-spark"
            >4. Spark</v-list-item
          >
          <v-list-item class="pl-5 ml-5" router to="/lab-trino"
            >5. Trino</v-list-item
          >
          <v-list-item class="pl-5 ml-5" router to="/lab-visualisation"
            >6. Metabase</v-list-item
          >
        </v-list-group>
      </v-list>
      <v-divider></v-divider>
      <v-list>
        <v-list-group no-action prepend-icon="mdi-checkbox-marked-outline">
          <template v-slot:activator>
            <v-list-item-content>
              <v-list-item-title>Solutions</v-list-item-title>
            </v-list-item-content>
          </template>

          <v-list-item class="pl-5 ml-5">BLABLA</v-list-item>
          <v-list-item class="pl-5 ml-5">BLABLA</v-list-item>
        </v-list-group>
      </v-list>
      -->

      <v-divider></v-divider>
    </v-navigation-drawer>
  </nav>
</template>

<script>
// @ is an alias to /src

export default {
  name: "Navbar",

  data: () => ({
    drawer: true,
    group: null,
    show_terminal: false,
    show_vscode: true,
    show_jupyter: true,
    show_zeppelin: false,
    show_sqlpad: true,
    show_metabase: true,
    show_spark: true,
    show_trino: true,
    show_kafka: false,
    show_minio: true,
    show_kubernetes: false,
    show_grafana: false,
  }),
  watch: {
    group() {
      this.drawer = false;
    },
  },
};
</script>
