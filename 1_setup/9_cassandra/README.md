# Cassandra 

Helm Chart von Bitnami https://github.com/bitnami/charts/tree/main/bitnami/cassandra

## Helm Install

```
helm repo add bitnami https://charts.bitnami.com/bitnami

helm upgrade --install -f values.yaml -n nosql cassandra bitnami/cassandra
```

## Cassandra CLI 
Ein extra Pod mit der Cassandra CLI kann gestartet werden über
```
kubectl run -n nosql cassandra-client --rm --tty -i --restart='Never' --env CASSANDRA_PASSWORD=train@thinkport --image docker.io/bitnami/cassandra:4.1.1-debian-11-r3 -- bash

# und dann im Pod
cqlsh -u trainadm -p train@thinkport cassandra

show schemas;
show tables;
```
## Trino Configuration via SQLPAD

Mit Trino Treiber und Catalog Cassandra



Direkte Verbindung von SQLPAD funktioniert nicht

Driver: Cassandra
ContactPoint: cassandra.nosql.svc.cluster.local
LocalDataCenter: datacenter1
Keyspace: store
DatabaseUser: trainadm
DatabasePassword: train@thinkport

Erste Beispiele
https://cassandra.apache.org/_/quickstart.html

### CQL Befehle
https://cassandra.apache.org/doc/latest/cassandra/tools/cqlsh.html

