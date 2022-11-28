# Kafka Aufgaben

# Create a Connector to read from Twitter API

Save this Json to a `twitter.json` file

```
{
    "connector.class": "com.github.jcustenborder.kafka.connect.twitter.TwitterSourceConnector",
    "tasks.max": "1",
    "topics": "twitter_raw",
    "delete.retention.ms": "20000000",
    "twitter.oauth.accessTokenSecret": "vEXmxJV4j50xKFip849RdEsBR4NsGyVWfoqOIZclSnYOC",
    "process.deletes": "true",
    "filter.keywords": "BigData",
    "kafka.status.topic": "twitter_raw",
    "kafka.delete.topic": "twitter_raw-deletions",
    "twitter.oauth.consumerSecret": "hNJwdLCBHVSUVQE4DfCywdzQIXtTlSVM0B50BSzqA2NbhsgDIQ",
    "twitter.oauth.accessToken": "892314144589963264-1oV0FZuDCrPqYrt8Q0Xgl8GescppWtM",
    "twitter.oauth.consumerKey": "6Mt4KvnyJheQSkWBgssvx3I5X"
}
```

```
#check available connectors
curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/

# create new connector
curl -i -X PUT -H  "Content-Type:application/json" http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-stream/config -d @twitter.json

# check config of existing connector
curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-stream/config
```
