# Kafka Aufgaben

## 1. Erstelle ein Connector um von der Twitter API zu lesen

Speicher diese Datei als `twitter.json` und befülle die XXX Felder mit deinen jeweiligen Zugangsdaten. <br>

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

  "topics": "twitter-raw",    
  "process.deletes": "true",
  "filter.keywords": "BigData",
  "kafka.status.topic": "twitter-raw",
  "kafka.delete.topic": "twitter-raw-deletions",
  "twitter.oauth.accessTokenSecret": "XXX",
  "twitter.oauth.consumerSecret": "XXX",
  "twitter.oauth.accessToken": "XXX",
  "twitter.oauth.consumerKey": "XXX",
  "key.converter": "org.apache.kafka.connect.json.JsonConverter",
  "value.converter": "org.apache.kafka.connect.json.JsonConverter"
}

```

```
# Check die verfügbaren Connectoren
curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/

# Erstelle einen neuen Connector
curl -i -X PUT -H  "Content-Type:application/json" http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-stream/config -d @twitter.json

# Check the config des existierenden Connectoren 
curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-stream/config
```

## 2.  Kafka Topics anschauen

Im Terminal von VS Code mit folgendem Befehl prüfen, ob das Topic für die Twitter Rohdaten erstellt wurde.
Dazu zunächst den Service Namen des Kafka Brokers herrausfinden.

```
# Service und Pods im Kafka Namespace anschauen
kubectl get po -n kafka
kubectl get services -n kafka

# Host Adresse zusammefügen
kafka-topics.sh --list --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092
```
<details>
<summary>Lösung</summary>
<p>

```
kafka-topics.sh --list --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092
```

</p>
</details> <br>
Wenn das Topic erzeugt wurde, können wir uns auf das Topic subscriben und schauen ob gerde getwittert wird.

```
kafka-console-consumer.sh --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name> --from-beginning

# mit den flags --from-beginning werden alle Nachrichten aus dem Topic gelesen, auch die, die bereits in der Vergangenheit liegen, mit --max-messages 5 kann die Ausgaben der Nachrichten limitiert werden
```

<details>
<summary>Lösung</summary>
<p>

```
kafka-console-consumer.sh --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092 --topic twitter-raw --from-beginning --max-messages 5
```

</p>
</details>
<br>

## 3. Mikroservice App zur Reduzierung der Twitter Rohdaten starten

Erstelle ein Topic in den verarbeitete Daten gespeichert werden können mit folgenden Konfugurationen:

```
name: twitter-table
partition: 2
replication: 2
retention-time: 86400000 (1 Tag in ms)
cleanup policy: delete
retention-bytes: 10000000
```

```
kafka-topics.sh --create --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name> --partitions <partition-number> --replication-factor <replication-number> --config retention.ms=<retention-time> --config cleanup.policy=<policy> --config retention.bytes=<retention-bytes>
```


<details>
<summary>Lösung</summary>
<p>

```
kafka-topics.sh --create --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092 --topic twitter-table --partitions 2 --replication-factor 2 --config retention.ms=86400000 --config cleanup.policy=delete --config retention.bytes=10000000
```

</p>
</details>
<br>

Schau ob das Topic richtig erstellt wurde.<br>

```
kafka-topics.sh --list --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port>

# checke ob die Konfigurationen funktioniert haben
kafka-topics.sh --describe --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name>
```

<details>
<summary>Lösung</summary>
<p>

```
kafka-topics.sh --list --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092

kafka-topics.sh --describe --topic twitter-table --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092
```

</p>
</details>
<br>


Schau den Code an, was der macht `exercices/3_Kafka/Stream-Mikroservice/twitter_data_converter.py`.


Pod/Deployment mit diesem Code starten.<br>

```
kubectl apply -f pod_twitter_data_converter.yaml
```

Checke ob Pod läuft. (Logs)<br>


```
kubectl get pod -n <namespace>

kubectl logs <pod-name> -n <namespace> -f

# -f gibt fortlaufend die logs aus
```

<details>
<summary>Lösung</summary>
<p>

```
# Pod finden
kubectl get pod -n kafka

# logs auslesen
kubectl logs twitter-stream-converter -n kafka -f
```

</p>
</details>
<br>

Checke ob Daten in Target Topic ankommen.<br>

```
kafka-console-consumer.sh --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name> --from-beginning
```

<details>
<summary>Lösung</summary>
<p>

```
kafka-console-consumer.sh --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092 --topic twitter-table --from-beginning --max-messages 5
```

</p>
</details>
<br>
