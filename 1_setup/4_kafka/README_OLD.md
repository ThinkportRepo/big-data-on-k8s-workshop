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
  kafka-topics --zookeeper kafka-cp-zookeeper-headless:2181 --topic bernd --create --partitions 1 --replication-factor 1 --if-not-exists

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

## Connector configuration

```

Prerequisites:
  running Kafka-cluster with 1 zookeeper, 3 Kafka-broker, 1 connect, and 1 schema-registry (our setup)
  check if the TwitterSourceConnector is in one of the folders documented in the plugin paths (describe pod)

  kubectl exec pod <podname> -n <namespace> -- bash

  then look into the plugin path to see if jcustenborder exists if yes - top that's how it should be
```

### Configuration

#### Control-Center

```

  Step 1: Open the control center: http://kafka.4c13e49defa742168ff1.northeurope.aksapp.io/clusters

  Step 2: Navigate to the right place:
    Click on the wanted cluster (controlcenter.cluster)
    go to Connect
    then connect-default
    then add-connector

  Step 3:
    Either choose TwitterSourceConnect and manually add a connector by filling in the data/arguments needed
    or upload a config file

  Step 4: launch the connector
  Congratulations! Now look into topics and click on the topic name *** in messages should be arriving tweets
```

### Terminal

```
  Step 1: Open terminal



  Step 2 create JSON file (e.g. in vscode or vim)

  {
    "connector.class": "com.github.jcustenborder.kafka.connect.twitter.TwitterSourceConnector",
    "tasks.max": "1",
   
    "log.cleanup.policy": "delete",
    "log.retention.hours": "24",
    "log.retention.bytes": "10000000",

    "topic.creation.default.replication.factor": 1,  
    "topic.creation.default.partitions": 2,  
    "topic.creation.default.cleanup.policy": "delete",  
    "topic.creation.default.retention.ms": "86400000",
    "topic.creation.default.retention.bytes": "10000000",

    "topics": "twitter-json",    
    "process.deletes": "true",
    "filter.keywords": "BigData",
    "kafka.status.topic": "twitter-json",
    "kafka.delete.topic": "twitter-json-deletions",
    "twitter.oauth.accessTokenSecret": "iN98gtMncFZ81r2BbQchNK59cynUBKiQjV3BNrzKUXAMX",
    "twitter.oauth.consumerSecret": "pszPFw8GmKLAhBObEWKXokT4Rwkr1o2UgjVd8Pq6XXuTrkW6Cr",
    "twitter.oauth.accessToken": "892314144589963264-spfqOaqpzc04JfX128XPB4GzZIczM2A",
    "twitter.oauth.consumerKey": "LaNg9Dqdvjq7tRUIyX6vqbr4R",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter"
  }



  Step 3: check if you can get information from the Kafka-connect service
    curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/
    should be empty if no connector is configurated

  Step 4:
    curl -i -X PUT -H  "Content-Type:application/json" http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-source-connector/config -d @<filename>.json

    check if it was created:
    curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/
    curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/config
    you can check the logs in the Kafka-connect pod

    kubectl logs <pod-name> -n kafka -f
```

### S3 Sink connector to minIO

````

  Step 1: Create the following JSON file

  {
      "connector.class": "io.confluent.connect.s3.S3SinkConnector",
      "tasks.max": "1",
      "topics": "twitter-table",
      "s3.bucket.name": "kafka-bucket",
      "s3.part.size": 5242880,
      "flush.size": 1,
      "storage.class": "io.confluent.connect.s3.storage.S3Storage",
      "format.class": "io.confluent.connect.s3.format.json.JsonFormat",
      "schema.generator.class": "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator",
      "schemas.enable": false,
      "partitioner.class": "io.confluent.connect.storage.partitioner.DefaultPartitioner",
      "schema.compatibility": "NONE",
      "aws.secret.access.key": "train@thinkport",
      "aws.access.key.id": "trainadm",
      "key.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "key.converter.schemas.enable": false,
      "value.converter.schemas.enable": false,
      "store.url":"http://minio.minio.svc.cluster.local:9000"
    }

  Step 2: Check if all values fit your implemented system (e.g. topics, bucket names)
    !!IMPORTANT: The bucket and topic have to be created before configuring.!!

  Step 3:
    curl -i -X PUT -H  "Content-Type:application/json" http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/minio-dump/config -d @<filename>.json

  Step 4:
    check if everything works:
    kubectl logs <pod-name> -n kafka -f

    logs should look somewhat like this:
    INFO Starting commit and rotation for topic partition twitter-table-0 with start offset {partition=0=681} (io.confluent.connect.s3.TopicPartitionWriter)
    INFO Files committed to S3. Target commit offset for twitter-table-0 is 682 (io.confluent.connect.s3.TopicPartitionWriter)
    ```


  ## Streamingkette die Funktioniert

  Daten aus dem Twitter Connector der
  --> Topic: twitter-json
  --> Schema aus: dump dieses Topics nach s3 und wieder einlesen mit Spark
  --> Einlesen mit to_json und konvertieren
  --> Schreiben als JSON nach Kafka --> spark-target-schema3
  --> Sink schreibt nach S3 Bucket --> spark-target-schema3
  --> Spark kann wieder alles von s3 einlesen
````

### Fehlerbehebung cp-ksql

1. in den ksgl pod execen
2. Fehlerhafte Environmentvariable über `unset JMX_PORT` entfernen.
3. ksql shell über `ksql` starten

## ksql getrennt installieren

helm install --set kafka.enabled=false --set kafka.bootstrapServers=kafka-cp-kafka.kafka.svc.cluster.local:9092 --set schema-registry.enabled=false --set schema-registry.url=kafka-cp-schema-registry.kafka.svc.cluster.local:8081 --set kafka-connect.enabled=false --set kafka-connect.url=kafka-cp-kafka-connect.kafka.svc.cluster.local:8083 ktool rhcharts/ksqldb

## ksql Aufgabe

1. in den ksgl pod execen
2. Fehlerhafte Environmentvariable über `unset JMX_PORT` entfernen.
3. ksql shell über `ksql` starten

```
kubectl exec -it <ksql-pod-name> -- bash
```

im Pod folgende Befehle ausführen um in ksql zu kommen

```
# bei jedem login auf die Shell wieder entfernen
unset JMX_PORT

# ksql starten
ksql
```

In ksql zunächst eine Stream Abstraktion auf das Topic `twitter-table` erstellen

```
# anzeigen ob die Topics erkannt wurden
show topics;

CREATE STREAM twitter (tweet_id VARCHAR, created_at VARCHAR, tweet_message VARCHAR, user_name VARCHAR,user_location VARCHAR, user_follower_count INT,user_friends_count INT, retweet_count INT,language VARCHAR, hashtags ARRAY<VARCHAR>) WITH (kafka_topic='twitter-table', value_format='json', partitions=2);

# checken ob der Stream erzeugt wurde
show streams;

# create table
CREATE TABLE twittertable (tweet_id VARCHAR primary key, created_at VARCHAR, tweet_message VARCHAR, user_name VARCHAR,user_location VARCHAR, user_follower_count INT,user_friends_count INT, retweet_count INT,language VARCHAR, hashtags ARRAY<VARCHAR>)  WITH (kafka_topic='twitter-table', value_format='json', partitions=2);

# check table
show tables;


```

Jetzt können Abfragen und Aggretationen auf den Stream gemacht werden

```
# select all
SELECT * FROM TWITTER EMIT CHANGES;

# select some column
SELECT TWEET_ID,CREATED_AT,USER_LOCATION,LANGUAGE from TWITTER EMIT CHANGES;

# select aggregation
SELECT LANGUAGE,COUNT(*) as TOTAL from TWITTER GROUP BY LANGUAGE EMIT CHANGES;


# select aggregation
SELECT LANGUAGE,COUNT(*) as TOTAL from TWITTERTABLE GROUP BY LANGUAGE EMIT CHANGES;

```

SELECT
TWITTER.USER_LOCATION USER_LOCATION,
COUNT(\*) NUMBER_TWEETS
FROM TWITTER TWITTER
GROUP BY TWITTER.USER_LOCATION
EMIT CHANGES;

TWITTER.LANGUAGE COUNTRY,

> COUNT(\*) NUMBER_TWEETS
> FROM TWITTER TWITTER
> GROUP BY TWITTER.LANGUAGE
> EMIT CHANGES;
