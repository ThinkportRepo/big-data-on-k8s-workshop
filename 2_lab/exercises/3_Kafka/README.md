# Kafka Aufgaben

> Diese Aufgaben werden alle im Texteditor oder Terminal von VSCode bearbeitet.  
> VSCode über den Dashboard Link im linken Menu unter Apps öffnen.

## Architektur

![BigDataWorkshop-UseCase-Kafka](https://user-images.githubusercontent.com/16557412/227127231-f741be8f-67e4-42a2-be36-6fb5b9e24040.png)

## 1. Kafka Topics

In den Kafka Topics werden die einzelnen Streaming Nachrichten hineingeschrieben, gespeichert und wieder ausgelesen. Die Topics können via CLI, grafischer Oberfläche oder mit Kubernetes Resource Definitionen verwaltet werden.

### Aufgabe 1) Erstelle ein Topic über die graphische Oberfläche

Es gibt mehrere graphische Oberflächen um Kafka zu konfigurieren. Wir verwenden hier die [UI von Confluent, dem Anbieter der Kafka Enterprise Version](https://docs.confluent.io/platform/current/control-center/index.html).

Gehe über das Dashboard auf die Kafka UI und suche dort den Punkt um ein Topic zu erstellen. Erstelle dann ein Topic mit dem Namen `test`, publiziere dort eine Nachricht, z.B. `"Hallo nach Kafka"` und verifizieren, dass diese Nachricht auch angekommen ist.

### Aufgabe 2) Verwende die Kakfa CLI zum managen, senden und empfangen von Nachrichten

Kafka kann auch über eigene CLI Tools bedient werden. Neben dem anzeigen und erstellen von Topics können dort auch Daten nach Kafka geschrieben und gelesen werden. Die CLI eignet sich vor allem bei der Fehlersuche und beim Automatisieren.

Um die CLI verwenden zu können muss die Kubernetes interne Adresse des Kafka Clusters angegebgen werden (`bootstrap-server`). Suche diese zunächst in den Servicen des Kafka Namespaces

```
kubectl get services -n kafka
```

Und verwende dann folgenden Befehl im VS Code Terminal um alle bereits existierenden Topics anzuzeigen

```
kafka-topics.sh --list --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port>

# checke ob die Konfigurationen angewendet wurden
kafka-topics.sh --describe --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name>
```

Nachrichten können nun mit einem Producer Script direkt in das Topic geschrieben werden.
Verwende folgenden Befehl um eine weitere Nachricht in das Topic `test` zu schreiben.

```
kafka-console-producer.sh --bootstrap-server kafka.kafka.svc.cluster.local:9092 --topic test
```

Das Consumer Programm kann über `strg+c` gestoppt werden.

Lausche anschließend auf das Topic mit der Flag alle Nachrichten seit Beginn anzuzeigen um zu sehen ob die Nachricht ankam. Verifizieren die Nachricht ebenfalls in der UI

```
kafka-console-consumer.sh --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name> --from-beginning
```

mit der Flag `--from-beginning` werden alle Nachrichten aus dem Topic gelesen, auch die, die bereits in der Vergangenheit liegen, mit der Flag `--max-messages 5` kann die Ausgaben der Nachrichten limitiert werden. Das Consumer Programm kann über `strg+c` gestoppt werden.

Lösche das Topic nun und überprüfe mit dem `list` Befehl op es auch tatsächlich entfernt wurde.

```
kafka-topics.sh --delete --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic test
```

<details>
<summary>Lösung</summary>
Der korrekte Service für die Kafka Broker (den Boostrapserver) ist `kafka`
Damit lautet die volle Kubernetes interne DNS-Adresse des Bootstrap servers
  
```shell
kafka.kafka.svc.cluster.local:9092
```
Und die Befehle der Aufgabe sind folglich

```shell
# list topics
kafka-topics.sh --list --bootstrap-server kafka.kafka.svc.cluster.local:9092

# describe topic details

kafka-topics.sh --describe --bootstrap-server kafka.kafka.svc.cluster.local:9092 --topic test

# publish to topic

kafka-console-producer.sh --bootstrap-server kafka.kafka.svc.cluster.local:9092 --topic test

# subscribe to topic

kafka-console-consumer.sh --bootstrap-server kafka.kafka.svc.cluster.local:9092 --topic test --from-beginning

# delete topic

kafka-topics.sh --delete --bootstrap-server kafka.kafka.svc.cluster.local:9092 --topic test

```

</details>

### Aufgabe 3) Erstelle ein Topic für die Twitter Daten mit einer Kubernetes Custom Resource Definition

Der Kafka Operator ermöglicht es ein Kafka Topic als Kubernetes Resource, also mit einer Yaml Konfiguration zu managen. Dass hat den großen Vorteil, dass sämtliche Topics und ihre Konfiguration als versionierbarer Code gespeichert und jederzeit wieder reproduziert werden können sowie keine langen CLI Befehle zum Topic management verwendet werden müssen.

Im Ordner `/3_Kafka/Producer/` befindet sich die Datei `TOPIC_twitter-raw.yaml`.
Öffne diese Datei und füge den Topic Namen `twitter_raw` ein.

Erstelle das Topic in Kafka anschließend durch

```

kubectl apply -f TOPIC_twitter-raw.yaml

```

und überprüfe ob das Topic in Kubernetes als Custom Resource erzeugt wurde

```

kubectl get topic

# oder

kubectl get kafkatopics

```

Überprüfe zusätzlich über die Kafka UI oder CLI ob das Topic tatsächlich auch in Kafka mit den in Yaml spezifizierten Parametern erzeugt wurde.

<details>
<summary>Lösung</summary>

```yaml
apiVersion: platform.confluent.io/v1beta1
kind: KafkaTopic
metadata:
  # name des Topics
  name: twitter-raw
  namespace: kafka
spec:
  # Anzahl Replica
  replicas: 2
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

und

```
# list topics
kafka-topics.sh --list --bootstrap-server kafka.kafka.svc.cluster.local:9092

# describe topic details

kafka-topics.sh --describe --bootstrap-server kafka.kafka.svc.cluster.local:9092 --topic twitter-raw
```

</details>

## 2. Kafka Producer

Seit Februar 2023 ist die offizielle Twitter API nicht mehr kostenlos verfügbar. Aus diesem Grund verwenden wir Mock Producer der die Daten für das weitere Lab erzeugt.

### Aufgabe 4) Starte den Twitter Daten Producer als Kubernetes Pod

Der Daten Producer läuft als Deloyment in Kubernetes und schreibt die Daten in das Topic `twitter-raw`

Ersetze das richtige Kafka Topic in der Konfigurations Yaml `3_Kafka/Producer/DEPLOY_twitter_data_producer.yaml` und starte den Pod mit

```
kubectl apply -f DEPLOY_twitter_data_producer.yaml
```

Überprüfe mit einem Tool deiner Wahl ob die Daten im Topic ankommen

<details>
<summary>Lösungen</summary>

```bash
kafka-console-consumer.sh --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092 --topic twitter-raw --from-beginning --max-messages 10

```

</details>

## 3. Stream Processing

Sobald die Daten in einem Topic sind sollen sie üblicherweise transformiert werden und verschiedenen Systemen wieder in weiteren Topics zu Verfügung gestellt werden. Dies nennt man Stream Processing. Eine typische Architektur ist es dafür Container basierte Mikroservices zu verwenden. Diese laufen evenfalls auf Kubernetes und können bei hoher Last einfach horizontal skalliert werden. Da nicht alle Daten aus dem Twitter Stream benötigt werden, wird jetzt eine Streaming App gestartet, die die Daten reduziert und nur einige Attribute in das nächste Topic weiter reicht.

### Aufgabe 5) erstelle ein neues Topic für die reduzierten Daten

Erstelle zunächst ein neues Topic via Custom Resource Definition mit folgenden Parametern:

**name:** `twitter-table`  
**partition:** `2`  
**replication:** `2`  
**retention-time:** `86400000` (1 Tag in ms)  
**retention-bytes:** `10000000`
**cleanup policy:** `delete`

Erstelle hierfür eine neue Yaml Datei in `3_Kafka/2_Converter/TOPIC_twitter-table.yaml` mit den passenden Parametern. Verwende als Vorlage die Yaml Datei für das `twitter-raw` Topic (`3_Kafka/1_Producer/TOPIC_twitter-raw.yaml`)

Prüfe ob das Topic richtig erstellt wurde.<br>

```
kubectl get topics

# und/oder via cli

kafka-topics.sh --list --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port>

# checke ob die Konfigurationen funktioniert haben
kafka-topics.sh --describe --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name>
```

Falls das Topic fehlerhaft erstellt wurde gibt es die Möglichkeit es zu löschen.

```
kafka-topics.sh --delete --bootstrap-server kafka-cp-kafka.kafka.svc.cluster.local:9092 --topic twitter-table
```

und starte eine containerisierten Python/Java Mikroservice in einem Kubernetes Pod, der die Daten aus dem ersten Topic ausliest, reduziert und wieder in das zweite Topic rausschreibt.

<details>
<summary>Lösung</summary>
Die Topic Definition sollte folgendermaßen aussehen

```yaml
apiVersion: platform.confluent.io/v1beta1
kind: KafkaTopic
metadata:
  # name des Topics
  name: twitter-table
  namespace: kafka
spec:
  # Anzahl Replica
  replicas: 2
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

</details>

### Aufgabe 4) starte eine containerisierte Streaming App (Mikroservice in Python/Java)

Der Microservice für das Stream Processing, also die Anwendung welche die Daten aus dem `twitter-raw` Topic ausliest, vereinfacht und weiter nach `twitter-table` schreibt, ist bereits vorprogrammiert und in ein Container Image gepackt. Schaue dir zum besseren Verständnisses trotzdem den Quellcode des Programmes an. Er ist in VSCode unter `exercices/3_Kafka/2_Converter/twitter_data_converter.py` zu finden. Die Pod Definition zum starten dieses Scriptes findet sich in `exercices/3_Kafka/2_Converter/pod_twitter_data_converter.yaml`.

Ersetzte hier zunächst die `XXXXXXXX` mit den korrekten Werten und starte den Pod in Kubernetes.

Erzeuge und starte den Pod mit dem Kubernetes Command (dazu im Terminal zuerst in das Verzeichnis `exercices/3_Kafka/2_Converter/` gehen)

```
kubectl apply -f pod_twitter_data_converter.yaml
```

Anschlißend überprüfe ob der Pod erfolgreich gestartartet ist und Twitterdaten verarbeitet.

```
kubectl get pod -n <namespace>

kubectl logs <pod-name> -n <namespace> -f

```

Die Flag `-f` gibt fortlaufend die logs aus. Beende die _Float_ Ansicht auf die Logs mit `strg+c`

Prüfe anschließend ob die reduzierten Daten auch im neuen Kafka Topic ankommen

```
kafka-console-consumer.sh --bootstrap-server <service-name>.<namespace>.svc.cluster.local:<port> --topic <topic-name> --from-beginning
```

<details>
<summary>Lösung</summary>
Die Pod Definition sollte folgendermaßen aussehen

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: twitter-data-converter
  namespace: kafka
spec:
  containers:
    - name: python
      image: thinkportgmbh/workshops:twitter-data-converter
      imagePullPolicy: Always
      command:
        - sh
        - "-c"
        - |
          echo "##############################################";
          echo $KAFKA_SERVER;
          echo $KAFKA_SOURCE_TOPIC;
          echo $KAFKA_TARGET_TOPIC;
          python3 twitter_data_converter.py;
      env:
        - name: KAFKA_SERVER
          value: "kafka.kafka.svc.cluster.local:9092"
        - name: KAFKA_SOURCE_TOPIC
          value: "twitter-raw"
        - name: KAFKA_TARGET_TOPIC
          value: "twitter-table"
```

```
kafka-console-consumer.sh --bootstrap-server kafka.kafka.svc.cluster.local:9092 --topic twitter-raw
```

</details>
