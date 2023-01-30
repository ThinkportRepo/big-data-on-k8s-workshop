# Install Kafka via Confluent Operator

The setup follows two steps

1. Install Confluent Operator via official Helm chart
2. Create custom resources to spin up Zookeeper, Kafka broker, Connect server, ksql server and schema registry
3. As Tasks in the Lab create custom resources to create connectors and topics

## Install Confluent Operator

First add the repositories

```
helm repo add confluentinc https://packages.confluent.io/helm
helm repo update
```

Second install the operator

```
helm upgrade --install kafka-operator confluentinc/confluent-for-kubernetes
```

## Create Kafka Cluster

The kafka Cluster consist of several parts

- Zookeeper
- Brokers
- Connect
- Ksql
- SchemaRegistry

These resourses are created with custom resources definitions of the Operator which are packed into a simple helm chart in the folder crds.
It is important to know that helm can't delete or update them. To spin up this workshop lab this might be ok but there is no possiblitly to run an update over it via helm

```
helm upgrade --install -f values.yaml  kafka-resources -n kafka .
```

## Add Connectors do Connect

Connectors that are available in the Confluent Hub can directly be integrated in an init Pod of the operator-connect resource definition like

```
apiVersion: platform.confluent.io/v1beta1
kind: Connect
metadata:
  name: connect
  namespace: kafka
spec:
  replicas: 1
  image:
    application: confluentinc/cp-server-connect:7.3.0
    init: confluentinc/confluent-init-container:2.5.0
  build:
    type: onDemand
    onDemand:
      plugins:
        locationType: confluentHub
        confluentHub:
          - name: kafka-connect-twitter
            owner: jcustenborder
            version: 0.3.34
          - name: kafka-connect-s3
            owner: confluentinc
            version: 10.3.0
          - name: kafka-connect-cassandra
            owner: confluentinc
            version: latest
  dependencies:
    kafka:
      bootstrapEndpoint: kafka:9071
```

## Create Topics

Topics can be created via crd
A topics uses a yaml like

```
apiVersion: platform.confluent.io/v1beta1
kind: KafkaTopic
metadata:
  # name des Topics
  name: twitter-raw
  namespace: kafka
spec:
  # Anzahl Replica
  replicas: 1
  # Anzahl Partitionen
  partitionCount: 2
  configs:
    # wie lange sollen Messages gespeichert werden (1Tag)
    retention.ms: "86400000"
    # wieviel Bytes an Messages sollen maximal gespeichert werden (100MB)
    retention.bytes: "10000000"
    # was soll mit den alten Nachrichten passieren wenn den Retention Bedinung überschritten wird (löschen)
    cleanup.policy: "delete"
```

and can be applied with

```
kubeclt apply -f topic.yaml

kubectl get topic
```

## Create Connectors

Also Connectors can be created via crds
A connector looks like

```
apiVersion: platform.confluent.io/v1beta1
kind: Connector
metadata:
  name: twitter-stream
  namespace: kafka
spec:
  # Name of Connector
  name: twitter-stream
  class: "com.github.jcustenborder.kafka.connect.twitter.TwitterSourceConnector"
  taskMax: 1
  configs:
    # target topic to write in tweets
    kafka.status.topic: "twitter-raw"
    # filter on tweets
    filter.keywords: "BigData"
    process.deletes: "false"
    value.converter: "org.apache.kafka.connect.json.JsonConverter"
    # activte debugging
    errors.tolerance: "all"
    errors.log.enable": "true"
    errors.log.include.messages": "true"
    twitter.oauth.accessTokenSecret: "iN98gtMncFZ81r2BbQchNK59cynUBKiQjV3BNrzKUXAMX"
    twitter.oauth.consumerSecret: "pszPFw8GmKLAhBObEWKXokT4Rwkr1o2UgjVd8Pq6XXuTrkW6Cr"
    twitter.oauth.accessToken: "892314144589963264-spfqOaqpzc04JfX128XPB4GzZIczM2A"
    twitter.oauth.consumerKey: "LaNg9Dqdvjq7tRUIyX6vqbr4R"
    twitter.debug": "true"
  restartPolicy:
    type: OnFailure
    maxRetry: 2
```

and can be deployed and checked via

```
kubectl apply -f connector.yaml

kubectl get connectors
```

## Ksql Stream Processing

#### Access ksql via Controlcenter

#### Access ksql via cli

The cli can be accessed directly on the ksqldb pod

```
kubectl exec -it ksqldb-0 -- ksql
```

Usefull commands

```
show topics;
show streams;
show tables;

# live view on topic
print 'twitter-reduced'

SET 'auto.offset.reset' = 'earliest';
```

create stream on topic

```
CREATE STREAM twitter (tweet_id VARCHAR KEY, created_at VARCHAR, tweet_message VARCHAR, user_name VARCHAR,user_location VARCHAR, user_follower_count INT,user_friends_count INT, retweet_count INT,language VARCHAR, hashtags ARRAY<VARCHAR>) WITH (kafka_topic='twitter-reduced', value_format='json', partitions=2);
```

create aggregation on stream. Stream view on data

```
select language,count(*) as total from twitter group by language emit changes;
```

create table on stream

```
CREATE TABLE twitter_country AS
  SELECT language,count(*) as TOTAL
  FROM twitter
  GROUP BY language
  EMIT CHANGES;
```

ksql:
https://www.youtube.com/watch?v=EtNZYIrOgHo&ab_channel=UpDegree

https://towardsdatascience.com/introduction-to-kafka-stream-processing-in-python-e30d34bf3a12
