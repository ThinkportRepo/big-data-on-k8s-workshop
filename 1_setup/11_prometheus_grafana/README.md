# Prometheus & Grafana

Helm Chart von Prometheus Community https://prometheus-community.github.io/helm-charts

## Helm Install

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm upgrade --install -f values.yaml -n monitoring prometheus-stack prometheus-community/kube-prometheus-stack
```

## Grafana

### Password

- standard - defined in terraform helm release
- also stored in: k get secret kube-prometheus-grafana -o yaml

### Dashboards

- included from https://github.com/dotdc/grafana-dashboards-kubernetes (corresponding post https://0xdc.me/blog/a-set-of-modern-grafana-dashboards-for-kubernetes/)

## Adding a Spark App to Monitoring

Um eine Spark App mit Prometheus zu monitoren muss zuerst der Daten Sink von Spark in Prometheus registriert werden
Da wir hier den Prometheus Operator verwenden kann dies einfach über eine Custom Resource, ein ServiceMonitor Yaml realisiert werden.

Spark mit dem Spark Operator bietet zwei Endpunkte an.
Einen Endpunkt des SparkOperators selber über wenige Metriken über die laufenenden Sparkapps
Und einen Endpunkt direkt auf die Daten der SparkUI mit allen Runtime Daten der App

Um eine Pod Endpunkt zu registrieren muss dieser zunächst über eine Service bereit gestellt werden
Der Service muss einen Selektor auf den Spark, Spark Operator Pod haben und auf den richtigen Port zeigen sowie ein eindeutiges Label für den Service Monitor haben

```
apiVersion: v1
kind: Service
metadata:
  # Service to expose metric port from Spark Operator
  name: service-monitor-operator
  labels:
    app: spark-operator
  namespace: spark
spec:
  ports:
    - name: metrics
      port: 8090
      targetPort: 10254
      protocol: TCP
  selector:
    app.kubernetes.io/name: spark-operator
```

Der Service Monitor kann sich dann über diesen Selektor mit dem Service und damit zum Pod verbinden

```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  # ServiceMonitor for Spark Operator
  name: monitor-sparkoperator
  namespace: spark
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: spark-operator
  endpoints:
    - port: metrics
```

Sind beide installiert sollte der Endpunkt in der Prometheus UI unter Status/Targets auftauchen

### Create a Service Monitor

###
