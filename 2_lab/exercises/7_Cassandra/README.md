# Cassandra Aufgaben

### 1) Cassandra Shell CQL

Cassandra hat eine eigene Abfrage Sprache änlich der SQL Sprache die CQL (Cassadra Query Language).
Mit der cqlsh kann der Cassandra Cluster gemanaged werden und die Daten abgefragt werden.

Die Cassandra Shell kann gestartet werden über

```
cqlsh cassandra.nosql.svc.cluster.local
```

Jetzt kann Cassandra erkundet werden. Unter folgendem Link findet sich eine Übersicht aller CQL Commands

https://cassandra.apache.org/doc/latest/cassandra/tools/cqlsh.html

Probiere folgende Abfragen

```
DESCRIBE CLUSTER

DESCRIBE KEYSPACES

DESCRIBE TABLES
```

Verlassen von cql via

```
exit
```
