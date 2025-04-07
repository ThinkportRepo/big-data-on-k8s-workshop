const express = require("express");
const fs = require("fs");
const https = require("https");
const axios = require("axios");
const http = require("http").Server(express);
const socketio = require("socket.io")(http, {
  pingTimeout: 60000,
  cors: {
    origin: ["http://localhost:8080"],
    methods: ["GET", "POST"],
    transports: ["websocket", "polling"],
    credentials: true,
  },
  allowEIO3: true,
});
const port = 3030;

let kubectl_error = false;
// Message Definition

let message = {
  kafka: {
    status: "Error",
    broker0: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    broker1: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    broker2: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    schemaRegistry: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    kafkaConnect: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    ksqlServer: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    zookeeper: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
  },
  trino: {
    status: "Error",
    hive: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    postgres: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    coordinator: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    worker1: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    worker2: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
  },
  minio: {
    status: "Error",
    minio1: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    minio2: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
  },
  spark: {
    status: "Error",
    operator: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    history: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
  },
  frontend: {
    status: "Error",
    dashboard: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    terminal: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    vscode: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    jupyter: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    zeppelin: {
      status: "Deactivated",
      restarts: 0,
      pod: "",
    },
    sqlpad: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    metabase: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    heatlamp: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    prometheus: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    grafana: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    headlamp: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
  },
  monitoring: {
    status: "Error",
    prometheus: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    operator: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    metrics: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    alertmanager: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    nodeexporter1: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    nodeexporter1: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    nodeexporter2: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    nodeexporter3: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
    grafana: {
      status: "Missing",
      restarts: 0,
      pod: "",
    },
  },
  eventTime: 1681070161563,
};

function parseKafka(message, response) {
  for (var i = 0; i < response.data.items.length; i++) {
    item = response.data.items[i];
    //console.log(item.metadata.name);
    // check if brokers are running
    if (item.metadata.name == "kafka-0") {
      message.kafka.broker0 = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    if (item.metadata.name == "kafka-1") {
      message.kafka.broker1 = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    if (item.metadata.name == "kafka-2") {
      message.kafka.broker2 = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    // check schema registry
    if (item.metadata.name.includes("schemaregistry-0")) {
      message.kafka.schemaRegistry = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    // check kafka connect
    if (item.metadata.name.includes("connect-0")) {
      message.kafka.kafkaConnect = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    // check ksql server
    if (item.metadata.name.includes("ksqldb-0")) {
      message.kafka.ksqlServer = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    // check zookeeper
    if (item.metadata.name == "zookeeper-0") {
      message.kafka.zookeeper = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
  }

  if (
    message.kafka.broker0.status == "Running" &&
    message.kafka.broker1.status == "Running" &&
    message.kafka.broker2.status == "Running" &&
    message.kafka.zookeeper.status == "Running" &&
    message.kafka.kafkaConnect.status == "Running" &&
    message.kafka.ksqlServer.status == "Running" &&
    message.kafka.schemaRegistry.status == "Running"
  ) {
    message.kafka.status = "Running";
  }
  return message;
}

function parseHive(message, response) {
  for (var i = 0; i < response.data.items.length; i++) {
    item = response.data.items[i];
    if (item.metadata.name == "hive-metastore-0") {
      message.trino.hive = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    if (item.metadata.name == "hive-metastore-postgresql-0") {
      message.trino.postgres = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
  }
  return message;
}

function parseTrino(message, response) {
  j = 1;
  for (var i = 0; i < response.data.items.length; i++) {
    item = response.data.items[i];

    //console.log(item);
    // check if brokers are running
    if (item.metadata.name.includes("trino-coordinator")) {
      message.trino.coordinator = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    if (item.metadata.name.includes("trino-worker")) {
      message.trino["worker" + j] = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
      j++;
    }
  }
  if (
    message.trino.hive.status == "Running" &&
    message.trino.postgres.status == "Running" &&
    message.trino.coordinator.status == "Running" &&
    message.trino.worker1.status == "Running" &&
    message.trino.worker2.status == "Running"
  ) {
    message.trino.status = "Running";
  }
  return message;
}

function parseMinio(message, response) {
  j = 1;

  for (var i = 0; i < response.data.items.length; i++) {
    item = response.data.items[i];

    if (item.metadata.name.includes("minio")) {
      message.minio["minio" + j] = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
      j++;
    }
  }
  if (
    message.minio.minio1.status == "Running" &&
    message.minio.minio2.status == "Running"
  ) {
    message.minio.status = "Running";
  }
  return message;
}

function parseSpark(message, response) {
  for (var i = 0; i < response.data.items.length; i++) {
    item = response.data.items[i];
    if (
      item.metadata.name.includes("spark-operator") &&
      !item.metadata.name.includes("webhook")
    ) {
      message.spark.operator = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    if (item.metadata.name.includes("history")) {
      message.spark.history = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
  }
  if (
    message.spark.operator.status == "Running" &&
    message.spark.history.status == "Running"
  ) {
    message.spark.status = "Running";
  }
  return message;
}

function parseMonitoring(message, response) {
  j = 1;
  for (var i = 0; i < response.data.items.length; i++) {
    item = response.data.items[i];
    if (
      item.metadata.name.includes(
        "prometheus-prometheus-stack-kube-prom-prometheus"
      )
    ) {
      message.monitoring.prometheus = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    if (item.metadata.name.includes("kube-prom-operator")) {
      message.monitoring.operator = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    if (item.metadata.name.includes("alertmanager")) {
      message.monitoring.alertmanager = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    if (item.metadata.name.includes("kube-state-metrics")) {
      message.monitoring.metrics = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    if (item.metadata.name.includes("prometheus-node-exporter")) {
      message.monitoring["nodeexporter" + j] = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
      j++;
    }
    if (item.metadata.name.includes("grafana")) {
      message.monitoring.grafana = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
  }
  if (
    message.monitoring.prometheus.status == "Running" &&
    message.monitoring.operator.status == "Running" &&
    message.monitoring.alertmanager.status == "Running" &&
    message.monitoring.metrics.status == "Running" &&
    message.monitoring.nodeexporter1.status == "Running" &&
    message.monitoring.nodeexporter2.status == "Running" &&
    message.monitoring.grafana.status == "Running"
  ) {
    message.monitoring.status = "Running";
  }
  return message;
}

function parseFrontend(message, response) {
  for (var i = 0; i < response.data.items.length; i++) {
    item = response.data.items[i];

    if (item.metadata.name.includes("dashboard")) {
      message.frontend.dashboard = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }

    if (item.metadata.name.includes("terminal")) {
      message.frontend.terminal = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }

    if (item.metadata.name.includes("vscode")) {
      message.frontend.vscode = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }

    if (item.metadata.name.includes("jupyter")) {
      message.frontend.jupyter = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }

    if (item.metadata.name.includes("zeppelin")) {
      message.frontend.zeppelin = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }

    if (item.metadata.name.includes("sqlpad")) {
      message.frontend.sqlpad = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }

    if (item.metadata.name.includes("metabase")) {
      message.frontend.metabase = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }

    if (item.metadata.name.includes("headlamp")) {
      message.frontend.headlamp = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
  }

  if (
    message.frontend.dashboard.status == "Running" &&
    message.frontend.terminal.status == "Running" &&
    message.frontend.vscode.status == "Running" &&
    message.frontend.jupyter.status == "Running" &&
    //message.frontend.zeppelin.status == "Running" &&
    message.frontend.sqlpad.status == "Running" &&
    message.frontend.metabase.status == "Running" &&
    message.frontend.headlamp.status == "Running"
  ) {
    message.frontend.status = "Running";
  }

  return message;
}

//function which return Promise
const read = (path, type) =>
  new Promise((resolve, reject) => {
    fs.readFile(path, type, (err, file) => {
      if (err) reject(err);
      resolve(file);
    });
  });

socketio.on("connection", (socket) => {
  setInterval(function () {
    //console.log("###################################################");

    message.eventTime = Date.now();

    prom_kafka = axios.get(
      "http://localhost:8001/api/v1/namespaces/kafka/pods/"
    );
    prom_hive = axios.get("http://localhost:8001/api/v1/namespaces/hive/pods/");
    prom_trino = axios.get(
      "http://localhost:8001/api/v1/namespaces/trino/pods/"
    );
    prom_minio = axios.get(
      "http://localhost:8001/api/v1/namespaces/minio/pods/"
    );
    prom_spark = axios.get(
      "http://localhost:8001/api/v1/namespaces/spark/pods/"
    );
    prom_monitoring = axios.get(
      "http://localhost:8001/api/v1/namespaces/monitoring/pods/"
    );
    prom_frontend = axios.get(
      "http://localhost:8001/api/v1/namespaces/frontend/pods/"
    );

    axios
      .all([
        prom_kafka,
        prom_hive,
        prom_trino,
        prom_minio,
        prom_spark,
        prom_monitoring,
        prom_frontend,
      ])
      .then(
        axios.spread((...responses) => {
          const res_kakfa = responses[0];
          const res_hive = responses[1];
          const res_trino = responses[2];
          const res_minio = responses[3];
          const res_spark = responses[4];
          const res_monitoring = responses[5];
          const res_frontend = responses[6];
          message = parseKafka(message, res_kakfa);
          message = parseHive(message, res_hive);
          message = parseTrino(message, res_trino);
          message = parseMinio(message, res_minio);
          message = parseSpark(message, res_spark);
          message = parseMonitoring(message, res_monitoring);
          message = parseFrontend(message, res_frontend);
          //console.log(message);

          //socket.emit("cluster", message);
        })
      )
      .catch((errors) => {
        //console.log(errors);
        kubectl_error = true;
      })
      .finally(async () => {
        if (kubectl_error == true) {
          console.log("Kubectl connection error");
          socket.emit("cluster", message);
        } else {
          //console.log("Connected to Cluster");
          socket.emit("cluster", message);
        }

        let markdown = {};
        let basePath = "../../../../";
        markdown.kubernetes = await read(
          basePath + "2_lab/exercises/1_Kubernetes/README.md",
          "utf8"
        );
        markdown.kafka = await read(
          basePath + "2_lab/exercises/3_Kafka/README.md",
          "utf8"
        );
        markdown.sparkbasics = await read(
          basePath + "2_lab/exercises/2_Spark_Basics/README.md",
          "utf8"
        );
        markdown.sparkstreaming = await read(
          basePath + "2_lab/exercises/4_Spark_Streaming/README.md",
          "utf8"
        );
        markdown.sparksql = await read(
          basePath + "2_lab/exercises/5_Spark_SQL/README.md",
          "utf8"
        );
        markdown.cassandra = await read(
          basePath + "2_lab/exercises/6_Cassandra/README.md",
          "utf8"
        );
        markdown.trino = await read(
          basePath + "2_lab/exercises/7_Trino/README.md",
          "utf8"
        );
        markdown.ksql = await read(
          basePath + "2_lab/exercises/8_KSQL/README.md",
          "utf8"
        );
        socket.emit("lab", markdown);
      });
    //let kubernetesMD = read_markdown();

    //console.log(kubernetesMD);
    //console.log("running every 3s ...");
    //socket.emit("lab", kubernetesMD);
  }, 3000);
});

http.listen(port, () => {
  console.log("Server started on port", port);
});
