# Spark-Streaming Aufgaben

Die Spark Streaming Aufgaben werden zunächst in einem Jupyter Notebook ausgeführt und anschließend mit dem Spark Operator dauerhaft gestartet.

## Architektur

![BigDataLab-Architecture-SparkStreaming drawio](https://user-images.githubusercontent.com/16557412/212683374-676acaba-c4d6-4944-844d-ce43c2878421.png)

## 1. Jupyter Prototyping

Starte Jupyter über den Link im Menu unter Apps.

Öffne dort das Notebook aus dem Verzeichnis `exercises/4_Spark_Streaming/notebook_stream_app.ipynb` und führe die einzelnen Code Blöcke nacheinander aus.  
Führe die Zelle **For Debugging: write stream to console** aus um zu sehen was wieder in das nächste Topic geschrieben werden würde.  
Die Ausführung der Zelle mit Klicken auf das schwarze Viereck in der Menüleiste abbrechen.

Anschließend die Zelle **Write Stream to Avro** ausführen. Jetzt werden die Daten in ein s3 Bucket geschrieben. <br>

Wechsle nun in das Terminal von VSCode und überprüfe mit der s3 CLI ob die Daten auch angekommen sind:

```bash
s3 ls s3://twitter/avro/
```

Jetzt die Zelle wieder über das schwarze Viereck stoppen und dann (**GANZ WICHTIG**) die Spark Session mit ausführen der letzten Zelle mit dem Command `spark.stop()` beenden. Dies ist wichtig um den Stream zu stoppen und die Resourcen (cpu, ram) wieder frei zu geben.

<hr>

## 2. Spark Streaming via Spark Operator

Als nächstes soll der gleiche Spark Code über den Spark Operator als Kubernetes Deployment gestartet werden.

### 2.1 Python Code nach s3 kopieren

Validiere zunächst den PySpark Code in der Datei `exercises/4_Spark_Streaming/spark_stream_to_s3.py`.  
Finde heraus was die Unterschiede zu dem Code im Jupyter Notebook sind. <br>

Der Spark Operator kann dieses Python Script nur von s3 lesen, nicht von lokal. Deswegen muss zunächst die Python Datei nach s3 kopiert werden.

Gehe hierzu im VSCode Terminal in das Verzeichnis `exercises/4_Spark_Streaming/` und lade die Datei folgendermaßen hoch:

```bash
# überprüfen ob es schon ein Bucket scripts gibt
s3 ls

# Bucket erstellen, falls es noch nicht existiert
s3 mb s3://scripts

# Datei nach s3 kopieren
s3 put spark_stream_to_s3.py s3://scripts/

# überprüfen ob die Datei angekommen ist
s3 ls s3://scripts/
```

### 2.2 SparkApp Yaml vervollständigen

Prüfe die Spark App Definition in der Datei `exercises/4_Spark_Streaming/spark_stream_to_s3.yaml` und füge an den richtigen Stellen in der YAML folgene Werte ein, wobei die Werte in der spitzen Klammer ersetzt werden müssen.

```yaml
# Pfad zum Python Script in S3
mainApplicationFile: s3a://<bucket>/<python-script>.py

# Kafka Broker und Topic
- name: KAFKA_SERVER
          value: "<service>.<namespace>.svc.cluster.local:9092"
      - name: KAFKA_TOPIC
          value: "<Topic mit reduzierten Daten>"

# cpu des executors auf 1 setzten
executor:
    cores: <cores>
```

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>

```yaml
# Pfad zum Python Script in S3
mainApplicationFile: s3a://scripts/spark_stream_to_s3.py

# Kafka Broker und Topic

- name: KAFKA_SERVER
  value: "kafka.kafka.svc.cluster.local:9092" - name: KAFKA_TOPIC
  value: "twitter-table"

# cpu des executors auf 1 setzten

executor:
cores: 1

```

</details>

### 2.3 SparkApp starten

Starte anschließend die SparkApp und schau in den Pod Logs ob sie korrekt läuft. <br>

```bash
# anwenden der manifest yaml (aus dem Verzeichnis in welchem die Datei liegt)
kubectl apply -f spark_stream_to_s3.yaml

# SparkApp anzeigen
kubectl get sparkapp -n spark

# anzeigen ob der Driver und Executor pod läuft (-w ist die Abkürzung für --watch und zeigt immer wieder STATUS Veränderungen eines Pods an, beenden mit STRG+C)
kubectl get po -n spark -w

# anzeigen der Ergebnisse mit Hilfe der logs
kubectl logs stream-to-s3-driver -n spark

# live logs anschauen während der pod läuft (-f ist die Abkürzung für follow, exit mit STRG+c)
kubectl logs stream-to-s3-driver -f -n spark
```

Überprüfe ob weitere Dateien nach s3 geschrieben werden.

```
s3 ls s3://twitter/avro/
```

Wenn du möchtest kannst du dir eine AVRO Datei herunterladen und anschauen, bedenke dabei aber, dass AVRO nur bedingt humanreadable ist.

```
s3 get s3://twitter/avro/part-<individueller-string>.avro .
```

### 2.4 SparkApp im Spark History Server analysieren

Gehe auf die Spark UI (History Server) und finde deine laufende Anwendung unter `Show incomplete applications` an. Schaue dir die Metriken an, insbesondere die im Tab `SQL / Dataframe` und `Structured Streaming`

<hr>
Super, die Spark Streaming Aufgabe hast du erfolgreich gemeistert.
