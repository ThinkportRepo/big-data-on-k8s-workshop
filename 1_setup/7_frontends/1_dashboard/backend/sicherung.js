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

socketio.on("connection", (socket) => {
  setInterval(function () {
    console.log("###################################################");
    let url = "http://localhost:8001/api/v1/namespaces/kafka/pods/";
    axios
      .get(url)
      .then(function (response) {
        var arrayLength = response.data.items.length;
        for (var i = 0; i < arrayLength; i++) {
          item = response.data.items[i];
          if (item.metadata.namespace == "kafka") {
            console.log(item.metadata.name);
            console.log(item.status.phase);
          }
          //Do something
        }

        let message = {};
        message.eventTime = Date.now();
        message.kafka = {};
        message.kafka.status = "running";
        message.kafka.brokers = "running";
        message.kafka.ksql = "failed";
        console.log(socket.id, message);
        socket.emit("news_by_server", message);
      })
      .catch(function (error) {
        // handle error
        console.log(error);
      });
  }, 1000);
});

http.listen(port, () => {
  console.log("Server started on port", port);
});



for (var i = 0; i < response.data.items.length; i++) {
      item = response.data.items[i];
      if (item.metadata.namespace == "kafka") {
        console.log(item.metadata.name);
        console.log(item.status.phase);
      }

      message.eventTime = Date.now();
      message.kafka = {};
      message.kafka.status = "running";
      message.kafka.brokers = "running";
    message.kafka.ksql = "failed";
    









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

// ##################################
// alle funktionen
// ##################################

// async delay function
async function delay(ms) {
  // return await for better async stack trace support in case of errors.
  return await new Promise((resolve) => setTimeout(resolve, ms));
}

async function kafkaStatus(apiUrl, message) {
  try {
    console.log("here");
    const response = await axios.get(apiUrl);
    console.log("da");
    for (var i = 0; i < response.data.items.length; i++) {
      item = response.data.items[i];
      if (item.metadata.namespace == "kafka") {
        console.log(item.metadata.name);
        console.log(item.status.phase);
      }

      message.eventTime = Date.now();
      message.kafka = {};
      message.kafka.status = "running";
      message.kafka.brokers = "running";
      message.kafka.ksql = "failed";
      return message;
    }
  } catch (error) {
    console.error(error);
    message = "ERROR";
    return message;
  }
}

async function messageWrapper(socket) {
  let message = {};
  let kafkaUrl = "http://localhost:8001/api/v1/namespaces/kafka/pods/";
  message = await kafkaStatus(kafkaUrl, message);

  console.log(socket.id, message);
  socket.emit("news_by_server", message);

  await delay(1000);
}

socketio.on("connection", (socket) => {
  while (true) {
    messageWrapper(socket);
  }
});

http.listen(port, () => {
  console.log("Server started on port", port);
});




axios
      // get kafka status
      .get("http://localhost:8001/api/v1/namespaces/kafka/pods/")
      .then(function (response) {
        message = parseKafka(message, response);
        return message;
      })
      .then((message) => {
        axios
          .get("http://localhost:8001/api/v1/namespaces/hive/pods/")
          .then(function (response, message) {
            message.trino = {};
            for (var i = 0; i < response.data.items.length; i++) {
              item = response.data.items[i];
              //console.log(item);
              // check if brokers are running
              if (item.metadata.name == "hive-metastore-0") {
                message.trino.hive = {
                  status: item.status.phase,
                  restarts: item.status.containerStatuses[0].restartCount,
                };
              }
            }

            return message;
          })
          .catch(function (error) {
            console.log(error);
          });
      })
      .then((message) => {
        console.log(socket.id, message);
      })
      .catch(function (error) {
        console.log(error);
      });