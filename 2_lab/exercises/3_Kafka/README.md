# Kafka Aufgaben
Diese Aufgaben werden alle in VSCode und dem VSCode Terminal berabeitet.
Bitte VSCode über das Dashboard öffnen.



## 1. Erstelle ein Connector um von der Twitter API zu lesen
Als erste Aufgabe erstellen wir einen Mikroservice der als Stream App in Echtzeit neue Tweets von Twitter in unser Kafka Topic schreibt.
Um diesen Mikroservice zu erstellen nutzen wir Kafka Connect.

Schau dir in Kubernetes zunächst nochmal alle Service die im Kafka Namespace laufen an
```
kubectl get pod -n kafka

#und

kubectl get services -n kafka
```
Jeder Pod in Kubernetes, also auch der Kafka Connect Pod kann über seinen Service und die URL definition `<service-name><namespace>.svc.cluster.local` innerhalb Kubernetes angesprochen werden. 
Kafka Connect wird über eine REST API angesteuert und konfiguriert. Eine einfache Abfrage ist die bestehenden Connektoren zu listen. Teste dies über den Terminal mit folgendem Befehl
```
# Checke die verfügbaren Connectoren
curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/
```

Der Connector wird über ein JSON definiert. Dieses muss nun zunächst mit den korrekten Twitter Daten ausgefüllt werden.  

Speicher diese Datei als `twitter.json` im Verzeichnis `exercises/3_Kafka/`und befülle die XXX Felder mit deinen jeweiligen Zugangsdaten. <br>
Desweitern fülle an den passenden Stellen folgene values ein:


**Topics:** twitter-raw <br>
**Filter Keyword:** BigData


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

  "topics": "XXX",
  "process.deletes": "true",
  "filter.keywords": "XXX",
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

Der Kafka Connector Server verfügt über eine REST API um die Connectoren zu erstellen und zu konfigurieren.
Hier verwenden wir `curl` Befehle um die API anzusteuern.

```
# Checke die verfügbaren Connectoren
curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/

# Erstelle einen neuen Connector
curl -i -X PUT -H  "Content-Type:application/json" http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-stream/config -d @twitter.json

# Überprüfe die Konfiguration der existierenden Connectoren
curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-stream/config

# Wenn ein Fehler beim Konfigurieren unterlaufen ist, kann der Connector gelöscht werden
curl -X DELETE http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-stream

# für die Fehlersuche können sich die Logs angeschaut werden
kubectl logs <kafka-connect-pod> -n kafka -f
```

---

## 2. Kafka Topics anschauen

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
# oder etwas gefiltert mit grep twitter
kafka-topics.sh --list --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092 | grep twitter
```

</p>
</details> <br>
Wenn das Topic erzeugt wurde, können wir uns auf das Topic subscriben und schauen ob gerade getwittert wird.

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

</details>
</p>

---

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

Falls das Topic fehlerhaft erstellt wurde gibt es die Möglichkeit es zu löschen.

```
kafka-topics.sh --delete --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092 --topic twitter-raw
```


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


