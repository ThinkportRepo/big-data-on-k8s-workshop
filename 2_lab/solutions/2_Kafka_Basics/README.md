# Kafka Basics

## Kafka Shell Commands

```
# list topics
kafka-topics --zookeeper kafka-cp-zookeeper.kafka.svc.cluster.local:2181 --list

# delete topic (only works if config parameter delete.topic.enable  is set)
kafka-topics --zookeeper kafka-cp-zookeeper.kafka.svc.cluster.local:2181 --topic twitter-table2 --delete

# subscribe to a topic
kafka-console-consumer --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092 --topic twitter-table4 --from-beginning --max-messages 2

```
