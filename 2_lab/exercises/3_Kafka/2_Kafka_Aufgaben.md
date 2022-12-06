# Kafka Aufgaben

# Create a Connector to read from Twitter API

ALEX: Hier müssen wir ergänzen, dass jeder seine Credentials reinfüllen muss

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

### Kafka Topics anschauen

Im Terminal von VS Code mit folgendem Befehl prüfen ob das Topic für die Twitter Rohdaten erstellt wurde.
Dazu zunächst den Service Namen des Kafka Brokers herrausfinden

```
# Service und Pods im Kafka Namespace anschauen
kubectl get po -n kafka
kubectl get services -n kafka

# Host Adresse zusammefügen
kafka-topics.sh  --list --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port>
```

HINT: kafka-topics.sh --list --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092

Wenn das Topic erzeugt wurde können wir uns auf das Topic subscriben und schauen ob gerde getwittert wird

```
kafka-console-consumer --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name> --from-beginning

HINT: kafka-console-consumer.sh --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092 --topic twitter-json --from-beginning --max-messages 5

# mit den flags --from-beginning werden alle Nachrichten aus dem Topic gelesen, auch die, die bereits in der Vergangenheit liegen, mit --max-messages 5 kann die Ausgaben der Nachrichten limitiert werden
```

Mikroservice App zur Reduzierung der Twitter Rohdante starten

Aufgabe an Markus, Steffi, Melissa zum erweitern

1. Code anschauen was der macht `exercices/3_Kafka/Stream-Mikroservice/twitter_data_converter.py`
2. Target Topic erstellen mit Befehl (immer mit .sh in VSCode)
3. Pod/Deployment mit diesem Code starten
4. checke ob Pod läuft (Logs)
5. checken ob Daten in Target Topic ankommen
