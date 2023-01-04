const express = require("express");
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

function parseKafka(message, response) {
  message.kafka = {};
  message.kafka.status = "Error";
  message.kafka.broker0 = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.kafka.broker1 = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.kafka.broker2 = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.kafka.schemaRegistry = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.kafka.kafkaConnect = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.kafka.ksqlServer = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.kafka.zookeeper = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };

  for (var i = 0; i < response.data.items.length; i++) {
    item = response.data.items[i];
    //console.log(item);
    // check if brokers are running
    if (item.metadata.name == "kafka-cp-kafka-0") {
      message.kafka.broker0 = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    if (item.metadata.name == "kafka-cp-kafka-1") {
      message.kafka.broker1 = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    if (item.metadata.name == "kafka-cp-kafka-2") {
      message.kafka.broker2 = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    // check schema registry
    if (item.metadata.name.includes("kafka-cp-schema-registry")) {
      message.kafka.schemaRegistry = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    // check kafka connect
    if (item.metadata.name.includes("kafka-cp-kafka-connect")) {
      message.kafka.kafkaConnect = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    // check ksql server
    if (item.metadata.name.includes("kafka-cp-ksql-server")) {
      message.kafka.ksqlServer = {
        status: item.status.phase,
        restarts: item.status.containerStatuses[0].restartCount,
        pod: item.metadata.name,
      };
    }
    // check zookeeper
    if (item.metadata.name == "kafka-cp-zookeeper-0") {
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
  message.trino = {};
  message.trino.status = "Error";
  message.trino.hive = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.trino.postgres = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
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
  message.trino.coordinator = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.trino.worker1 = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.trino.worker2 = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
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
  message.minio = {};
  message.minio.status = "Error";
  message.minio.minio1 = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.minio.minio2 = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
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
  message.spark = {};
  message.spark.status = "Error";
  message.spark.operator = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.spark.history = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  for (var i = 0; i < response.data.items.length; i++) {
    item = response.data.items[i];
    if (item.metadata.name.includes("spark-operator")) {
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

function parseFrontend(message, response) {
  message.frontend = {};
  message.frontend.status = "Error";
  message.frontend.dashboard = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.frontend.terminal = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.frontend.vscode = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.frontend.jupyter = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.frontend.zeppelin = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.frontend.sqlpad = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
  message.frontend.metabase = {
    status: "Missing",
    restarts: 0,
    pod: "",
  };
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
  }

  if (
    message.frontend.dashboard.status == "Running" &&
    message.frontend.terminal.status == "Running" &&
    message.frontend.vscode.status == "Running" &&
    message.frontend.jupyter.status == "Running" &&
    message.frontend.zeppelin.status == "Running" &&
    message.frontend.sqlpad.status == "Running" &&
    message.frontend.metabase.status == "Running"
  ) {
    message.frontend.status = "Running";
  }

  return message;
}

socketio.on("connection", (socket) => {
  setInterval(function () {
    //console.log("###################################################");
    let message = {};
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
        prom_frontend,
      ])
      .then(
        axios.spread((...responses) => {
          const res_kakfa = responses[0];
          const res_hive = responses[1];
          const res_trino = responses[2];
          const res_minio = responses[3];
          const res_spark = responses[4];
          const res_frontend = responses[5];
          message = parseKafka(message, res_kakfa);
          message = parseHive(message, res_hive);
          message = parseTrino(message, res_trino);
          message = parseMinio(message, res_minio);
          message = parseSpark(message, res_spark);
          message = parseFrontend(message, res_frontend);

          socket.emit("cluster", message);
        })
      )
      .catch((errors) => {
        console.log(errors);
      });
  }, 3000);
});

http.listen(port, () => {
  console.log("Server started on port", port);
});
