# Cassandra Aufgaben

Diese Aufgaben dienen zum Vertrautwerden mit der noSQL Datenbank Cassandra. Das Hauptmerkmal von Cassandra ist seine Skalierbarkeit und Geschwindigkeit für sehr große Datenmengen und viele Zugriffe.
Desweiteren ist Cassandra schemafrei. Es können alle Datenformen und Typen gespeichert werden.

### 1. Cassandra auf Kubernetes

Der Cassandra Cluster läuft im Namespace `nosql`. Prüfe mit `kubectl` nach mit wie vielen Knoten der Cluster aktuell gestartet ist und finde den Service Endpunkt (interne URL) heraus.

### 2. Cassandra Shell

Cassandra hat eine eigene Abfragesprache ähnlich der SQL Sprache, die CQL (Cassadra Query Language).
Mit der CQL-Shell (cqlsh) kann der Cassandra Cluster gemanaged und CQL ausgeführt werden.

Die CQL-Shell kann aus dem VSCode Terminal direkt gestartet werden über

```
cqlsh <cassandra-service-name>.<namespace>.svc.cluster.local
```

Jetzt kann Cassandra erkundet werden. Unter folgendem Link findet sich eine Übersicht aller CQL Commands

https://cassandra.apache.org/doc/latest/cassandra/tools/cqlsh.html

Mit folgende Abfragen kann sich ein Überblick über den Cluster verschafft werden:

```
DESCRIBE CLUSTER

DESCRIBE KEYSPACES

DESCRIBE TABLES

# Daten aus einer Tabelle können über (fast) standard SQL abgefragt werden
SELECT * FROM <keyspace-name>.<table-name>
```

### 2. Keyspace und Tabelle erstellen

In Cassandra sind die Daten in Keyspaces und Tabellen organisiert.
Ein Keyspace entspricht hierbei einem Schema auf einem traditionellen Datenbank.

Erstelle einen Keyspace **countries**:

```SQL
CREATE KEYSPACE IF NOT EXISTS countries
WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };

-- Prüfe ob der Keyspace korrekt angelegt wurde
DESCRIBE KEYSPACES;
DESCRIBE countries;
```

Die Warnung `schema version mismatch detected; ` kann hierbei ignoriert werden.

Anders als bei relationalen Datenbanken, ist Cassandra für sehr große Datenmengen und parallelisierte Abfragen ausgelegt. Dies wird durch eine Partitionierung der Daten erreicht. Alle Daten, die zu einer Partition gehören, werden zusammen auf einen Cassandra Knoten abgelegt. Partitionen werden in Cassandra über den `PRIMARY KEY` gesetzt. Dieser besteht aus 2 Teilen. Mindestens einer Spalte, nach der partitioniert werden soll (Partition Key), und optional einem Set aus Clustering Spalten. Die Clustering Spalten definieren zusätzlich die Reihenfolge wie die Daten pro Partition gespeichert sind und ermöglichen so ein schnelleres Abfragen und Sortieren.
Aus diesem Grund sollte der `PRIMARY KEY` immer so angelegt werden wie am Ende die Daten abgefragt werden, nicht wie sie aus Sicht der Datenstruktur sinnvoll erscheinen. Denn die korrekte Wahl der Partitionen und Clusters hat den größten Einfluss auf die Abfrage Performance.

Lege eine neue Tabelle **population** mit `name` als Partition und `population` als Cluster Spalte an:

```
CREATE TABLE IF NOT EXISTS countries.population (
    id int,
    name text,
    code text,
    population bigint,
    under_20 int,
    urban int,
    working_age int,
    economic_indicators frozen<map<text,map<text,text>>>,
    PRIMARY KEY ((name),population)
    );

-- Prüfe ob die Tabelle angelegt wurde
DESCRIBE TABLES;
DESCRIBE countries.population;
SELECT * FROM countries.population;
```

### 3. Stammdaten nach Cassandra laden

Im nächsten Schritt soll diese Tabelle mit einigen Stammdaten, welche die Twitter Daten ergänzen, nach Cassandra geladen werden. Diese Daten werden mit Python in einem Jupyter Notebook generiert und nach Cassandra geschrieben.

Öffne hierzu das Notebook in `git/2_lab/exercises/Insert_Country_Data_Cassandra.ipynb`. Finde und ergänze dort die richtige Kubernetes interne Adresse des Cassandra Clusters (wie das Pattern geht, wurde bereits in den Kafka Aufgaben viel geübt).

Führe die Zellen aus und überprüfe mit der CQL-Shell, ob die Daten korrekt in die Datenbank geschrieben wurden.

Die cqlsh kann anschließend verlassen werden mit

```
exit;
```
