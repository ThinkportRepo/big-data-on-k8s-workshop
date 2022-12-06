# Einführung Spark auf Kubernetes

Es gibt verschiedene Möglichkeiten Spark Applikationen auf Kubneretes
zu starten und verteilen.

1. **Jupyter/Zeppelin:** Starte eine Interaktive Spark Session für ad Hoc Analysen.
2. **Spark-Submit:** Schicke ein Spark Programm mit `spark-submit` mit einem Kubernetes Cluster als Resource Manager
3. **Spark-Operator:** Erzeuge mit einer speziellen Kubernetes Resource eine `sparkapp`

## Interaktives Spark

Für eine Interactive Spark Session wird eine Spark Session geöffnet in der all Commands nacheinander abgesetzt werden können

### Spark-Shell (Scala)

Starte im VSCode Terminal die Spark-Shell via

```
spark-shell

# oder falls das nicht geht
./opt/spark/bin/spark-shell.sh
```

Sobald die Scala Console geladen ist erzeuge mit folgendem Code (jede Zeile nacheinander ausführen) ein Dataframe

```
val data = Seq(("Java", "20000"), ("Python", "100000"), ("Scala", "3000"))

# Erzeuge ein RDD
val rdd = spark.sparkContext.parallelize(data)

# Schaue den Inhalt des RDD an
rdd.collect()

# Erzeuge daraus ein Dataframe mit Spalten namen
val dfFromRDD1 = rdd.toDF("language","users_count")

# Schaue das Schema an
dfFromRDD1.printSchema()

# Schaue das Dataframe an
dfFromRDD1.show()

# Exit Spark-Shell mit
:quit
```

### Jupyter (Python/Pyspark)

Wesentlich eleganter ist das explorative Programmieren in einem Notebook. Für die nächsten Aufgaben öffen über die WebUI Jupyter und wähle dort das Notebook unter dem Pfad `2_Spark_Basisc/Spark-Interactive/pyspark_interactive.ipynb`
Führe dort alle Boxen nacheinander aus (`shift`+`enter`) und versuche zu verstehen was der Code macht. Schau dir insbesondere an wie die Sparkapp am Anfang konfiguriert wird.

## Spark-Submit

Mit dem dem Spark-Submit Programm kann ein Spark Job von einem Client an eine Spark Cluster zur Ausführung übermittelt werden.  
Wir verwenden als Cluster Manager Kubernetes und der Spark Job muss damit an den Kubernetes Cluster geschickt werden.  
Die Spark Anwendung ist typischerweise komplett fertig als ein (Docker) Image gebaut oder der auszuführende Code wird dynamisch von s3 gelesen. Für diese Aufgabe starten wir eine App die bereits auf dem Image vorhanden.
Führe zunächst folgenden Befehl aus:

```
spark-submit \
--master "k8s://https://kubernetes.default.svc.cluster.local:443" \
--deploy-mode cluster \
--name spark-submit-pi \
--conf spark.kubernetes.namespace=spark \
--conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
--conf spark.kubernetes.authenticate.caCertFile=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
--conf spark.kubernetes.authenticate.oauthTokenFile=/var/run/secrets/kubernetes.io/serviceaccount/token \
--conf spark.kubernetes.container.image=thinkportgmbh/workshops:spark-3.3.1 \
--conf spark.kubernetes.container.image.pullPolicy=Always \
--conf spark.driver.host=jupyter-spark-driver.frontend.svc.cluster.local \
--conf spark.driver.port=29413 \
--conf spark.executor.instances=1 \
--conf spark.executor.memory=1G \
--conf spark.executor.cores=1 \
local:///opt/spark/examples/src/main/python/pi.py
```

!! ACHTUNG DIESER BEFEHL FUNKTIONIERT AKTUELL NICHT AUS VSCODE/TERMINAL irgendetwas mit den Zertifikaten stimmt nicht

Checke ob im Namespace `spark` Pods für den Spark Driver und den Executor erstellt wurde

```
# get pods
kubectl get pod -n spark

# show Logs. Hier sollte in der Mitte die Zahl Pi=3.14 berechnet worden sein
kubectl logs <pod-name> -n spark
```

## Spark Operator

The Spark-Operator offers the possibility to config a Spark Application via a custom Kubernetes resources. Advantage here is that all Kubernetes features (e.g. secrets, certificates, volumes) can be used within the Spark driver and executor Pods

Der Spark Operator ermöglicht es eine Spark Applikation als Custom Kubernetes Resource wie alle Kubernetes Resourcen über eine Yaml Datei zu konfigurieren und zu starten. Der Vorteil ist, dass so alle Kubernetes Resourcen (z.B. Secrets, Certificats, Volumes etc.) in den Spark Pods genutzt werden können.

#### Aufgabe 1

Zuerst schauen wir mal ob aktuell irgendwelche Pods und Sparkapps im Namespace `spark` laufen

```
# show running pods
kubectl get po -n spark

# show special sparkapp resource group
kubectl get sparkapp -n spark
```

Als nächstes konfigurieren wir die yaml Datei für unsere Sparkapp

#### Aufgabe 2

In der Sparkapp soll der gleiche Code ausgeführt werden, den wir bereits in Jupyter gesehen habe.
Öffne die Datei `exercises/Spark-Operator/pyspark-app.py` und verstehe den Code, insbesondere was der Unterschied zum Jupyter Code ist.

Der Spark Pod kann den Python Code entweder intern aus dem Image oder dynamisch us s3 einlesen. In dieser Aufgabe verwenden wir s3. Hierzu die Date mit folgenden Befehlen nach s3 laden

```
# schauen ob es schon ein Bucket scripts gibt
s3 ls

# Bucket erstellen
s3 mb scripts

# Datei nach s3 laden
s3 put pyspark-app.py s3://scripts/
```

#### Aufgabe 3

Als nächstes konfigurieren wir unsere Yaml Datei.
Editiere hierzu die Datei `pyspark-job.yaml`.

1. Setze den richtigen Pfad zum Pyspark Script auf s3

```
mainApplicationFile: s3a://<bucket>/<python-script>.py
```

2. Finde den richtigen s3 Endpunkt und Port sowie User und Passwort ein.
   Der s3 service befindet sich im namespace `minio`

```
kubectl get services -n minio
```

der Service heißt `minio`.

3. Füge die Kubernete internen Adresse nach folgendem Schema zusammen
   `<service-name>.<namespace>.svc.cluster.local:<port>`
   Schreibe die Parameter an die richtige Stelle in der Yaml Datei

```
"fs.s3a.endpoint": "<service-name>.<namespace>.svc.cluster.local:<port>"
"fs.s3a.access.key": "<standard user>"
"fs.s3a.secret.key": "<standard password>"
```

4. Erhöhe die Anzahl der Executoren auf 2 (executor instances)

5. Starte die Anwendung und prüfe ob sie mit zwei Executoren läuft und ob die Ergebnisse richtig sind

```
# apply manifest yaml (from the folder where the file resides)
kubectl apply -f spark-pi-app.yaml

# show spark app
kubectl get sparkapp -n spark
kubectl describe sparkapp spark-pi -n spark

# show if driver and executor pods are spinning up (-w stands for watch, exit with ctr+c)
# and wait until driver pod is completed
kubectl get po -n spark -w -n spark

# show result in the logs via
kubectl logs spark-pi-driver -n spark
# or look at the live logs during run time (-f stands for follow, exit with ctr+c)
kubectl logs spark-pi-driver -f -n spark
```

Clean up everythin at the end

```
kubectl delete sparkapp spark-pi
```
