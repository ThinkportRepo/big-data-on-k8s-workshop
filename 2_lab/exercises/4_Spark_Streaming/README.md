# Aufgabe zu Spark Streaming

## 1. Streaming Code in Jupyter validieren

Öffne Notebook `exercises/4_Spark_Streaming/notebook_stream_app.ipynb` und führe die einzelnen Code Blöcke aus. <br>

Führe die Zelle "For Debugging: write stream to console" aus um zu sehen was wieder in das nächste Topic geschrieben werden würde. <br> Die Zelle mit Klicken auf das schwarze Viereck stoppen. <br>

Anschließend die Zelle "Write Stream to Avro" ausführen. Jetzt werden die Daten in ein s3 Bucket geschrieben. <br>

Im Terminal von VSCode mit dem Befehl checken, ob dort auch Dateien angekommen sind.<br>

```
s3 ls s3://twitter/avro/
```

Jetzt die Zelle über das schwarze Viereck stoppen und ganz **wichtig** die Zelle mit `spark.stop()` ausführen um die Spark Session wieder zu beenden. <br>

## 2. Spark Streaming App via Spark Operator

### 2.1 Python Code nach s3 kopieren
PySpark Code in der Datei `exercises/4_Spark_Streaming/spark_stream_to_s3.py` validieren. <br>
Finde heraus was die Unterschiede zu dem Code im Jupyter Notebook sind. <br>


Der Spark Operator kann dieses Python Script von s3 lesen, nicht von lokal.
Deswegen muss zunächst die Python Datei nach S3 hochgeladen werden.

Gehe hierzu im VSCode Terminal in das richtige Verzeichnis. (4_Spark_Streaming Ordner) <br>

und lade die Datei folgendermaßen hoch
```
# schauen ob es schon ein Bucket scripts gibt
s3 ls

# Bucket erstellen, falls es noch nicht existiert
s3 mb s3://scripts

# Datei nach s3 laden
s3 put spark_stream_to_s3.py s3://scripts/

# Prüfen ob angekommen
s3 ls s3://scripts/
```

### 2.2 Spark App Yaml vervollständigen
Prüfe die Spark App Definition `exercises/4_Spark_Streaming/sparkapp_stream_to_s3.yaml` und füge an den richtigen Stellen in die YAML folgene Werte ein.

```
executor cores: 1
mainApplicationFile: s3a://<bucket>/<python-script>.py
```
<details>
<summary>Tipp </summary>
<p>

```
bucket: scripts
python-script: spark_stream_to_s3
```

</details>
</p>


### 2.3 Spark App erstellen
Starte anschließend die Sparkapp und schau in den Pod Logs ob sie korrekt läuft. <br>

```
# anwenden der manifest yaml (im ordner wo die Datei liegt)
kubectl apply -f sparkapp_stream_to_s3.yaml

# spark app anzeigen
kubectl get sparkapp -n spark

# Anzeigen ob der Treiber und Executor pod läuft (-w ist die abkürzung für --watch und zeigt immer wieder STATUS veränderungen eines Pods an, beenden mit STRG+C)

kubectl get po -n spark -w

# anzeigen der Ergebnisse mit Hilfe der logs
kubectl logs stream-to-s3-driver -n spark

# live logs anschauen während der pod läuft (-f ist die Abkürzung für follow, exit mit STRG+c)
kubectl logs stream-to-s3-driver -f -n spark
```

Überprüfe ob weitere Dateien nach s3 geschrieben werden. <br>

```
s3 ls s3://twitter/avro/
```

Wenn du möchtest kannst du dir eine AVRO Datei anschauen, bedenke dabei, dass AVRO nur bedingt humanreadable ist.

```
s3 get s3://twitter/avro/part-<individueller-string>.avro .
```

Super, die Spark Streaming Aufgabe hast du erfolgreich gemeistert.
