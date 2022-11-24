# Spark History Server

## Docker Image

need to add a new layer to the spark image in order to start the history server instead of the application server.

```
# regular on amd64
docker build -t thinkportgmbh/workshops:spark-history -f Dockerfile.history
docker push -t thinkportgmbh/workshops:spark-history

# crossbuild on mac m1 arm64
docker buildx build --push --platform linux/amd64 --tag thinkportgmbh/workshops:spark-history  -f Dockerfile.history .
```

## Create PersistentVolumeClaim

part of the init script in 0_initialisation

## Install Helm Chart

Jetzt den Helm Chart installieren

```
helm upgrade --install -f values.yaml  history-server -n spark .
```

Der Helm Chart erzeugt folgende Maninfeste

#### Deployment

Um den Pod zu erzeugen und auch im Falle eines crashes sofort wieder neu zu erzeugen wird dafür ein Kubernetes Deployment verwendet was im YAML `deploy-spark-history-server.yaml` spezifiziert ist.
Hier muss das pvc gemounted werden und als Parameter dem spark-history-server Programm mitgeteilt werden.

#### Service

Damit der Pod immer über einen Service, also einen fixen dns Namen erreichbar wird noch ein Service erstellt (`svc-spark-history-server.yaml`)

```
# create service to expose history server for ingress
apiVersion: v1
kind: Service
metadata:
  name: spark-history-server
  namespace: spark-poc
spec:
  selector:
    app: spark-history-server
  ports:
  - port: 18080
    protocol: TCP
    targetPort: 18080
  type: ClusterIP
```

#### Ingress

Dieser Service wird dann auf einen speziellen Sub Pfad der ParcIT Racher Hostadresse mit einem Ingress gemapped (`ingress-spark-history-server.yaml`)

```
# create ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: spark-history-server
  namespace: spark-poc
spec:
  rules:
  - host: spark-history.k8s-prod1.local.parcit
    http:
      paths:
      - backend:
          service:
            name: spark-history-server
            port:
              number: 18080
        pathType: ImplementationSpecific
```

#### Configmap

Hier sind einige Spark Configurationen gesetzt die es für den History Server zur Auswahl gibt
https://spark.apache.org/docs/latest/monitoring.html#spark-history-server-configuration-options
Aktuell sind hier die Werte für das automatische löschen alter Logs gesetzt
Einmal am Tag läuft ein clean up job der alles löscht was älter als 7 Tage ist und falls es mehr als 40 Logs gibt nur die neuesten 40 behält

```
data:
  spark-defaults.conf: |-
    spark.history.fs.cleaner.enabled=true
    spark.history.fs.cleaner.interval=1d
    spark.history.fs.cleaner.maxAge=7d
    spark.history.fs.cleaner.maxNum=40
```

## Clean up

via the debug pod delete old logs via

```
find /spark-logs/ -mindepth  1 -mtime +10  -delete
```
