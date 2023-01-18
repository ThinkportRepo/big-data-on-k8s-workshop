# Connector configuration

```
Prerequisites:
  kubernetes Cluster with kafka (special image for connect pod which installs TwitterSourceConnector and s3 plugin)

  running Kafka-cluster with 1 zookeeper, 3 Kafka-broker, 1 connect, and 1 schema-registry (our setup)

  check if the TwitterSourceConnector is in one of the folders documented in the plugin paths (describe pod)

  kubectl exec -it <podname> -n <namespace> -- bash

  then look into the plugin path to see if plugins e.g. jcustenborder exists, if yes - top - that's how it should be
```

## Configuration

### Control-Center (example for TwitterSourceConnector)

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

## Terminal

## TwitterSourceConnector

```
  Step 1: Open terminal (e.g. in vscode) 

  Step 2: create JSON file (e.g. in vscode or vim)

  {
    "connector.class": "com.github.jcustenborder.kafka.connect.twitter.TwitterSourceConnector",
    "tasks.max": "1",
    
    # keep the logs from overfilling the storage
    "log.cleanup.policy": "delete", 
    "log.retention.hours": "24",
    "log.retention.bytes": "10000000",

    # for automatic topic creation: 
    "topic.creation.default.replication.factor": 1,  
    "topic.creation.default.partitions": 2,  
    "topic.creation.default.cleanup.policy": "delete",  
    "topic.creation.default.retention.ms": "86400000", # 1 Day
    "topic.creation.default.retention.bytes": "10000000",

    "topics": "twitter-json",    
    "process.deletes": "true",
    "filter.keywords": "BigData", # hashtags to look for
    "kafka.status.topic": "twitter-json", # in which topic to write
    "kafka.delete.topic": "twitter-json-deletions",
    
    # add tokens here, only max of 2 connectors which the same credentials work at the same time
    "twitter.oauth.accessTokenSecret": "iN98gtMncFZ81r2BbQchNK59cynUBKiQjV3BNrzKUXAMX",
    "twitter.oauth.consumerSecret": "pszPFw8GmKLAhBObEWKXokT4Rwkr1o2UgjVd8Pq6XXuTrkW6Cr",
    "twitter.oauth.accessToken": "892314144589963264-spfqOaqpzc04JfX128XPB4GzZIczM2A",
    "twitter.oauth.consumerKey": "LaNg9Dqdvjq7tRUIyX6vqbr4R",

    # in which format the data is written, options are: JSON, avro, 
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter"
  }

  Step 3: check if you can get information from the Kafka-connect service
    curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/
    should be empty ("[]") if no connector is configurated

  Step 4: configure connector
    ou can change the connector name if you edit the string between connector/***/config
    curl -i -X PUT -H  "Content-Type:application/json" http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-source-connector/config -d @<filename>.json

    check if it was created:
    curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/
    curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/config

    you can check the logs in the Kafka-connect pod
    kubectl logs <pod-name> -n kafka -f

  Step 5: check topic for messages
        
    kubectl exec -it <broker-podname> -n <namespace> -- bash

    kafka-console-consumer --bootstrap-server  localhost:9092 --topic <topicname> --from-beginning

    add <--max-messages 5> to reduce the output to 5 messages

```

Example for a TwitterSourceConnector with avro

```
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
  
    "topics": "twitter-avroConverter",    
    "process.deletes": "true",
    "filter.keywords": "BigData",
    "kafka.status.topic": "twitter-avroConverter",
    "kafka.delete.topic": "twitter-avroConverter-deletions",
    "twitter.oauth.accessTokenSecret": "dUlvqYhYXQwranxOis2gAQYjErSdIZwHO9yLj8aq7Fxax",
    "twitter.oauth.consumerSecret": "wjj3sc9NnTgLAf31CNIDnZ2XFBN7dqp8lONwzUK3N2M6hw6zrM",
    "twitter.oauth.accessToken": "892314144589963264-Orw7RV7JiKytiuWajCUdnFmyDMourln",
    "twitter.oauth.consumerKey": "b1sWC7WUdHPeElPO1Ht3ehBa0",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schemas.enable": true,
    "value.converter.schemas.enable": true,
    "key.converter.schema.registry.url": "http://kafka-cp-schema-registry.kafka.svc.cluster.local:8081",
    "value.converter.schema.registry.url": "http://kafka-cp-schema-registry.kafka.svc.cluster.local:8081"
}
```

### S3 Sink connector to minIO

```
  Step 1: Create the following JSON file

  {
      "connector.class": "io.confluent.connect.s3.S3SinkConnector",
      "tasks.max": "1",
      "topics": "twitter-table", # has to be existing before configurating

      "s3.bucket.name": "kafka-bucket", # needs to be created before configurating
      "s3.part.size": 5242880,
      "flush.size": 1, # how much messages should be written in one file

      "storage.class": "io.confluent.connect.s3.storage.S3Storage",
      "format.class": "io.confluent.connect.s3.format.json.JsonFormat", # ormat class to use when writing data to the store, option are: Json, Avro, Parquet RawBytes
      "schema.generator.class": "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator",
      "schemas.enable": false, # if you want to disable the schema e.g. if there is no schema
      "partitioner.class": "io.confluent.connect.storage.partitioner.DefaultPartitioner",
      "schema.compatibility": "NONE",

      # credentials for acessing s3 storage - in this example minIO
      "aws.secret.access.key": "train@thinkport",
      "aws.access.key.id": "trainadm",
      "store.url":"http://minio.minio.svc.cluster.local:9000"

      "key.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "key.converter.schemas.enable": false, # if you want to disable the schema e.g. if there is no schema. if not set = true
      "value.converter.schemas.enable": false, # if you want to disable the schema e.g. if there is no schema
      
    }
    for more details: https://docs.confluent.io/kafka-connectors/s3-sink/current/overview.html#s3-object-uploads
    or: https://docs.confluent.io/kafka-connectors/s3-sink/current/configuration_options.html#connector

  Step 2: Check if all values fit your implemented system (e.g. topics, bucket names)
    !!IMPORTANT: The bucket and topic have to be created before configuring.!!

  Step 3: configure connector
    curl -i -X PUT -H  "Content-Type:application/json" http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/minio-dump/config -d @<filename>.json

  Step 4: check if everything works

    kubectl logs <pod-name> -n kafka -f

    logs should look somewhat like this:
    INFO Starting commit and rotation for topic partition twitter-table-0 with start offset {partition=0=681} (io.confluent.connect.s3.TopicPartitionWriter)
    INFO Files committed to S3. Target commit offset for twitter-table-0 is 682 (io.confluent.connect.s3.TopicPartitionWriter)

    check the bucket in your s3 storage e.g. minIO
```

Example for dumping avro with a schema

   ```
   {
    "connector.class": "io.confluent.connect.s3.S3SinkConnector",
    "tasks.max": "1",
    "topics": "twitter-avroConverter",
    "s3.bucket.name": "arvo-100",
    "s3.part.size": 5242880,
    "flush.size": 100,
    "storage.class": "io.confluent.connect.s3.storage.S3Storage",
    "format.class": "io.confluent.connect.s3.format.avro.AvroFormat",
    "schema.generator.class": "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator",
    "partitioner.class": "io.confluent.connect.storage.partitioner.DefaultPartitioner",
    "schema.compatibility": "NONE",
    "aws.secret.access.key": "train@thinkport",
    "aws.access.key.id": "trainadm",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "store.url":"http://minio.minio.svc.cluster.local:9000",
    "key.converter.schema.registry.url": "http://kafka-cp-schema-registry.kafka.svc.cluster.local:8081",
    "value.converter.schema.registry.url": "http://kafka-cp-schema-registry.kafka.svc.cluster.local:8081"
  } ```
