# Aufgaben zu Trino

Trino kann über Connectoren auf eine Vielzahl von Datenquellen zugreifen.
Für dieses Lab ist ein Connector für Delta Files auf s3 eingerichtet.

In einem s3 Bucket können verschiedene Tabellen abgelegt werden.
Eine Sammlung von Tabellen entspricht einem Schema

Die Dateien liegen als Delta Datei in s3 unter `s3://twitter/delta`
also im Bucket `twitter` unter dem Prefix `delta`

## 1. Connection zu Trino anlegen

Öffne den SQL Browser SQLPad und logge dich mit den Standard Credentials ein und gehe oben Links auf das Dropdown "New connection"

Eine neue Connection mit
Name: Delta
Driver: Trino
Host: trino.trino.svc.cluster.local
Database User: trino
Catalog: delta
Schema: data
erstellen.
Connection zuerst mit dem Button Test prüfen und dann speichern

Eventuell tauchen links noch keine Schema auf,
über folgende Befehle schauen was bei Trino verfügbar ist

```
# connectoren=cataloge anzeigen
show catalogs;
# schemas in catalog anzeigen;
show schemas from delta;

# tabellen in schema anzeigen;
show tables from delta.data;
```

## 2. Aufgabe: Schema für das Bucket anlegen

(geht nur wenn die Connection schon existiert, bin ich mir gerade nicht sicher ob die korrekt erzeugt wird)
Öffne den SQL Browser SQLPad und logge dich mit den Standard Credentials ein

Erstelle ein Schema für den Delta Connector auf das Bucket `twitter` mit folgendem Query

```
CREATE SCHEMA IF NOT EXISTS delta.data WITH (location='s3a://twitter/');
```

Als nächstes erzeugen wir eine Tabelle die auf das Prefix (den Unterordner) zeigt.
Hier muss kein Schema definiert werden, da sich der Connector das Schema aus dem Schema der Delta Datei zieht.

```
CREATE TABLE delta.data.twitter (
  dummy bigint
)
WITH (
  location = 's3a://twitter/delta'
);
```

Teste ob die Daten verfügbar sind

```
# Tabellen anzeigen
show tables from delta.data;

# Inhalt der Tabellen anzeigen
select * from delta.data.twitter

# Um Queries zu beschleunigen kann die Analyse Funktion angewendet werden. Sie reichert den Metastore um weitere Daten an
ANALYZE data.twitter;
ALTER TABLE data.twitter EXECUTE optimize;

EXPLAIN SELECT * FROM data.twitter;

```

Folgende Aufgaben in SQL formuleren

```
select date, hour, count(*) as total
from
  (
    select date(created_at) as "date", hour(created_at) as "hour"
    from data.twitter
  )
group by date, hour
order by date, hour
```

Hier alle weiterne Aufgaben anfügen

Schreiben mit Trino
Ziel wir schreiben ein aggregat als csv nach s3

dafür

1. Schema in hive auf dem gleichen Bucket aber hive connector erstelen

```
CREATE SCHEMA hive.export
WITH (location = 's3a://twitter/')
```

2. Tabelle aus dem Ergebniss einer Abfrage auf bucket erstellen

CREATE TABLE hive.export.csv
COMMENT 'aggregation'
WITH (
format = 'TEXTFILE',
external_location = 's3a://twitter/csv/',
partitioned_by = ARRAY['hour']
)
AS
select date, count(\*) as total, hour
from
(
select date(created_at) as "date", hour(created_at) as "hour"
from data.twitter
)
group by date, hour
order by date, hour

```
check ob es funktionoiert hat
select * from hive.export.csv

und auf s3

s3 ls s3://twitter/csv






```

CREATE TABLE hive.export.csv (
hour int,
total int,
date timestamp
)
WITH (
format = 'TEXTFILE',
external_location = 's3a://twitter/csv/',
partitioned_by = ARRAY['date']
)

```

```
