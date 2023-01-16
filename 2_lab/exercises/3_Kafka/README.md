# Kafka Aufgaben
> Diese Aufgaben werden alle im Texteditor oder Terminal von VSCode bearbeitet.  
VSCode über den Dashboard Link im linken Menu unter Apps öffnen.  

## Architektur

![BigDataLab-Architecture-Kafka](https://user-images.githubusercontent.com/16557412/212669833-e1a77d40-5245-42a8-a45f-0eed2b9e4522.png)


## 1. Kafka Connector zu Twitter API
**Aufgabe:**
Erstelle einen Kafka Connector zum auslesen der Twitter API und schreibe die Twitter Stream Daten in ein Kafka Topic `twitter-raw`.  

Kakfa Connect bietet vordefinierte Mikroservice für typische Datenquellen (Sources) und Datenziele ((Sinks) die nur noch konfiguriert werden müssen. Dies erstpart die Arbeit ein eigenes Java/Python Programm zu schreiben, was die Daten von der Twitter API ziehen und nach Kafka schreiben würde.

Schau Dir in Kubernetes zunächst nochmal alle Service an, die im Kafka Namespace laufen:

```bash
kubectl get pod -n kafka

kubectl get services -n kafka
```

Jeder Pod in Kubernetes, also auch der Kafka Connect Pod kann über seinen Service und die URL Definition  
`<service-name>.<namespace>.svc.cluster.local` innerhalb Kubernetes angesprochen werden. 
Kafka Connect wird über eine REST API angesteuert und konfiguriert. Eine einfache Abfrage ist die bestehenden Connectoren zu listen.   
Frage die bestehenden Connectoren über das Terminal mit folgendem Befehl ab. Trage hierzu den richtigen Namen für den *Service* und *Namespace* ein, den du in der vorherigen Aufgabe gefunden hast.

```bash
curl http://<service-name>.<namespace>.svc.cluster.local:8083/connectors/
```


<details>
<summary>Lösung</summary>

```bash
curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/
```
</details>


Der Connector wird über ein JSON definiert. Dieses muss nun zunächst mit den korrekten Twitter Daten ausgefüllt werden.  
Lege eine neue JSON Datei `twitter_connector.json` im Verzeichnis `exercises/3_Kafka/` an, kopiere folgende Konfiguration in die Datei und ersetzte die Felder, die ein XXXXX enthalten mit den korrekten Werten und Zugangsdaten. Die Zugangsdaten werden dir in Rahmen des Workshops zur Verfügung gestellt.

**Weitere Parameter:**
**Topics:** `twitter-raw`  
**Filter Keyword:** `BigData`  

```json
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

  "topics": "XXXXX",
  "process.deletes": "true",
  "filter.keywords": "XXXXX",
  "kafka.status.topic": "twitter-raw",
  "kafka.delete.topic": "twitter-raw-deletions",
  "twitter.oauth.accessTokenSecret": "XXXXX",
  "twitter.oauth.consumerSecret": "XXXXX",
  "twitter.oauth.accessToken": "XXXXX",
  "twitter.oauth.consumerKey": "XXXXX",
  "key.converter": "org.apache.kafka.connect.json.JsonConverter",
  "value.converter": "org.apache.kafka.connect.json.JsonConverter"
}

```

Die API des Kafka Connector Pods wird über den `curl` Befehle gesteuert.
Erstelle mit folgenden Befehlen einen neuen Connector und prüfe ob er erfolgreich erstellt und konfiguriert wurde
```bash
# Erstelle einen neuen Connector aus dem twitter_connector.json
curl -i -X PUT -H  "Content-Type:application/json" http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-stream/config -d @twitter_connector.json

# Prüfe ob der neue Connector erstellt wurde
curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/


# Überprüfe die Konfiguration des neuen Connectors
curl http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-stream/config

# Wenn ein Fehler beim Konfigurieren unterlaufen ist, kann der Connector gelöscht werden
curl -X DELETE http://kafka-cp-kafka-connect.kafka.svc.cluster.local:8083/connectors/twitter-stream

# für die Fehlersuche können die Logs des Kafka Connect Pods hilfreich sein
kubectl logs <kafka-connect-pod> -n kafka -f
```



## 2. Kafka Topics 

**Aufgabe:** Überprüfe mit der Kafka CLI ob das Topic erstellt wurde und ob Twitter Daten in den Stream fließen.  


Im Terminal folgenden Befehlen prüfen, ob das Topic für die Twitter Rohdaten erstellt wurde. Hierzu zunächst wieder den Service Namen des Kafka Brokers herrausfinden.

```
kubectl get po -n kafka

kubectl get services -n kafka
```
Anschließend können die Kafka Tpoics mit folgendem Shell Befehl angezeigt werden (korrekten Werte für Host und Port einfügen)
```
kafka-topics.sh --list --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port>
```

Wenn das Topic erzeugt wurde, kann sich auf das Topic subscribed werden. Jetzt sollten nach und nach Twitternachrichten zu sehen sein.
 
```
kafka-console-consumer.sh --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name> --from-beginning

```
mit der Flag `--from-beginning` werden alle Nachrichten aus dem Topic gelesen, auch die, die bereits in der Vergangenheit liegen, mit der Flag `--max-messages 5` kann die Ausgaben der Nachrichten limitiert werden



## 3. Streaming App (Mikroservice)


App zur Reduzierung der Twitter Rohdaten starten
Erstelle ein Topic in den verarbeitete Daten gespeichert werden können mit folgenden Konfigurationen:

**name:** `twitter-table`  
**partition:** `2`  
**replication:** `2`  
**retention-time:** `86400000` (1 Tag in ms)  
**cleanup policy:** `delete`  
**retention-bytes:** `10000000`  
```

```
kafka-topics.sh --create --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name> --partitions <partition-number> --replication-factor <replication-number> --config retention.ms=<retention-time> --config cleanup.policy=<policy> --config retention.bytes=<retention-bytes>
```

Schau ob das Topic richtig erstellt wurde.<br>

```
kafka-topics.sh --list --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port>

# checke ob die Konfigurationen funktioniert haben
kafka-topics.sh --describe --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name>
```


Falls das Topic fehlerhaft erstellt wurde gibt es die Möglichkeit es zu löschen.

```
kafka-topics.sh --delete --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092 --topic twitter-table
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


Checke ob Daten in Target Topic ankommen.<br>

```
kafka-console-consumer.sh --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name> --from-beginning
```



