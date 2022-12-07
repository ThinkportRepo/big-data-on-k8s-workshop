# Aufgabe zu Spark Streaming

## Streaming Code in Jupyter validieren

öffne Notebook `exercises/4_Spark_Streaming/notebook_stream_app.ipynb`
und führe die einzelnen Code Blöcke aus

Führe die Zelle "For Debugging: write stream to console"

aus um zu sehen was wieder in das nächste Topic geschrieben werden würde.
die Zelle mit klicken auf das schwarze Viereck stoppen

Anschließend die Zelle "Write Stream to Avro"
ausführen, jetzt werden die Daten in ein s3 Bucket geschrieben.

Im Terminal von VSCode mit dem Befehl

s3 ls s3://twitter/avro/

checken ob dort auch Dateien angekommen sind

Jetzt die Zelle über das schwarze Viereck stoppen und ganz wichtig die Zelle mit spark.stop() ausführen
um die Spark Session wieder zu beenden.

## Streaming über den Sparkoperator starten

Pyspark Code in der Datei `exercises/4_Spark_Streaming/spark_stream_to_s3.py` validieren.
Insbesondere die Unterschiede zu dem Code im Jupyter Notebook.

Spark App Definition prüfen `exercises/4_Spark_Streaming/sparkapp_stream_to_s3.yaml`
@TEAM: eventuell Aufgaben zum ausfüllen von Werten geben.
z.B. executor cores auf 2 setzten
in Zeile steht, dass die python Datei nach s3 geladen werden muss
mainApplicationFile: s3a://scripts/spark_stream_to_s3.py

dazu VSCode Terminal in das richtige Verzeichnis gehen

```
# schauen ob es schon ein Bucket scripts gibt
s3 ls

# Bucket erstellen, falls es noch nicht existiert
s3 mb scripts

# Datei nach s3 laden
s3 put spark_stream_to_s3.py s3://scripts/
```

anschließend die Sparkapp starten und in den Logs schauen ob sie läuft

```
# apply manifest yaml (from the folder where the file resides)
kubectl apply -f sparkapp_stream_to_s3.yaml

# show spark app
kubectl get sparkapp -n spark

# show if driver and executor pods are spinning up (-w stands for watch, exit with ctr+c)

kubectl get po -n spark -w -n spark

# show result in the logs via
kubectl logs stream-to-s3-driver -n spark
# or look at the live logs during run time (-f stands for follow, exit with ctr+c)
kubectl logs stream-to-s3-driver -f -n spark
```

nochmal prüfen ob weitere Dateien nach s3 geschrieben werden

s3 ls s3://twitter/avro/
