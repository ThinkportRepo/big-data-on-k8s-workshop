# Install Confluent Kafka

## Build Docker Image

We need to add the Twitter Connector into the kafka-connect Pod
https://www.confluent.io/hub/jcustenborder/kafka-connect-twitter

```
# regular build & push
docker build -t thinkportgmbh/workshops:kafka-connect -f Dockerfile.connect .
docker push  thinkportgmbh/workshops:kafka-connect


# crossbuild on Mac Book with M1 Chip
docker buildx build --push --platform linux/amd64,linux/arm64 --tag thinkportgmbh/workshops:kafka-connect -f Dockerfile.connect .
```

## Install Helm

```
# add repo
helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm repo update    #(2)

helm upgrade --install kafka -f values.yaml  -n kafka confluentinc/cp-helm-charts
```

#### Helm output

```
## ------------------------------------------------------
## Zookeeper
## ------------------------------------------------------
Connection string for Confluent Kafka:
  kafka-cp-zookeeper-0.kafka-cp-zookeeper-headless:2181,kafka-cp-zookeeper-1.kafka-cp-zookeeper-headless:2181,...

To connect from a client pod:

1. Deploy a zookeeper client pod with configuration:

    apiVersion: v1
    kind: Pod
    metadata:
      name: zookeeper-client
      namespace: kafka
    spec:
      containers:
      - name: zookeeper-client
        image: confluentinc/cp-zookeeper:6.1.0
        command:
          - sh
          - -c
          - "exec tail -f /dev/null"

2. Log into the Pod

  kubectl exec -it zookeeper-client -- /bin/bash

3. Use zookeeper-shell to connect in the zookeeper-client Pod:

  zookeeper-shell kafka-cp-zookeeper:2181

4. Explore with zookeeper commands, for example:

  # Gives the list of active brokers
  ls /brokers/ids

  # Gives the list of topics
  ls /brokers/topics

  # Gives more detailed information of the broker id '0'
  get /brokers/ids/0## ------------------------------------------------------
## Kafka
## ------------------------------------------------------
To connect from a client pod:

1. Deploy a kafka client pod with configuration:

    apiVersion: v1
    kind: Pod
    metadata:
      name: kafka-client
      namespace: kafka
    spec:
      containers:
      - name: kafka-client
        image: confluentinc/cp-enterprise-kafka:6.1.0
        command:
          - sh
          - -c
          - "exec tail -f /dev/null"

2. Log into the Pod

  kubectl exec -it kafka-client -- /bin/bash

3. Explore with kafka commands:

  # Create the topic
  kafka-topics --zookeeper kafka-cp-zookeeper-headless:2181 --topic kafka-topic --create --partitions 1 --replication-factor 1 --if-not-exists

  # Create a message
  MESSAGE="`date -u`"

  # Produce a test message to the topic
  echo "$MESSAGE" | kafka-console-producer --broker-list kafka-cp-kafka-headless:9092 --topic alex

  # Consume a test message from the topic
  kafka-console-consumer --bootstrap-server kafka-cp-kafka-headless:9092 --topic alex --from-beginning --timeout-ms 2000 --max-messages 1 | grep "$MESSAGE"
```

https://github.com/confluentinc/cp-helm-charts/blob/master/charts/cp-kafka-connect/values.yaml
Andere Lösung.
Python Programm das in Pod läuft
https://sites.google.com/a/ku.th/big-data/pyspart

https://strimzi.io/documentation/

kafka-topics --zookeeper kafka-cp-zookeeper.kafka.svc.cluster.local:2181 --alter --topic twitter_raw --config retention.bytes=10000000
