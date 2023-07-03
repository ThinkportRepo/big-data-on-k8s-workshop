# Trino Aufgaben

Trino kann über Connectoren auf eine Vielzahl von Datenquellen zugreifen.
Für diese Aufgabe verwenden wir drei Connectoren

- Delta Connector: lesen der Delta Dateien auf s3
- Hive Connector: lesen und schreiben von CSV Dateien auf s3
- Cassandra Connector: verbindung mit der noSQL Datenbank Cassandra

![TrinoAufgabe](https://github.com/ThinkportRepo/big-data-on-k8s-workshop/assets/16557412/05a2db36-f70c-4c5e-81ef-a3e42f146468)

---

## 1. Delta Connector konfigurieren

Öffne den SQL Browser SQLPad, logge dich mit dem standard User und Passwort ein und gehe oben Links auf das Dropdown Menu "New connection".

Erstelle eine Connection mit folgenen Parametern:

```
Name: Delta
Driver: Trino
Host: trino.trino.svc.cluster.local
Port: 8080
Database User: trino
Catalog: delta
Schema: data
```

Teste die neue Connection mit dem Button Test und speichere sie dann ab.

Wenn alles geklappt hatte sollten in der linken Seitenleiste bereits das Schema angezeigt werden.
Alternativ, bzw um den vollen Überblick über die Cataloge, Schemas und Tabellen zu bekommen folgende Befehle aus: <br>

```
# connectoren=cataloge anzeigen
show catalogs;

# Schemas, also angelegte Verbindungen auf s3 oder Datenbank im Catalog anzeigen;
show schemas from delta;

# Tabellen in schema anzeigen;
show tables from delta.data;
```

Nicht wundern, es sollte noch keine Schema für den Catalog Delta existieren

---

## 2. Schema im Delta Connector auf Bucket anlegen

Zunächst wird ein Schema angelegt was auf das `twitter` Bucket zeigt.

Erstelle ein Schema mit folgendem Query:

```
CREATE SCHEMA IF NOT EXISTS delta.data WITH (location='s3a://twitter/');
```

Da alle Schema Information bereits im Delta Log enthalten sind, kann die Tabellen definition von Trino direkt von dort ausgelesen und im Metastore abgelegt werden. Die bestehende Delta Datei (Prefix, Unterordner) wird mit folgendem Befehl im Metastore registriert:

```
CALL delta.system.register_table(schema_name => 'data', table_name => 'twitter', table_location => 's3a://twitter/delta')
```

Teste nun ob das Schema, die Tabelle und die Daten verfügbar sind. <br>

```
# Schema anzeigen
show schemas from delta;

# Tabellen anzeigen
show tables from delta.data;

# Inhalt der Tabellen anzeigen
select * from delta.data.twitter
```

## 3. Metadaten optimieren

Um Queries zu beschleunigen kann Trino die Dateien (Delta Logs und Parquet Dateien) analysieren und damit den Metastore anreichern.
Außerdem können die Daten automatisch optimiert werden, indem z.b. viele kleine Dateien in weniger aber Dateien idealer Größe zusammengefasst werden.

```
# Analyse Funktion aufrufen um den Metastore zu befüllen
ANALYZE data.twitter;

Tabellen Optimierung aufrufen um die Datenstruktur zu verbessern
ALTER TABLE data.twitter EXECUTE optimize;

```

## 4. Query Plan analysieren

Der Query Plan eines SQL Statement lässt sich über das Prefix `EXPLAIN` anzeigen. Zur Erstellung wurde noch keine Abfrage auf echte Daten durchgeführt sondern nur der Metastore konsultiert.
Vergleiche die Query Pläne für folgende Abfragen.

```
# alle Daten
SELECT * FROM data.twitter;

# Filter auf Partitionierte Spalte
SELECT * FROM data.twitter where language='DE'

# Filter auf berechnete Spalte
SELECT * FROM data.twitter where language='DE' and contains(hashtags,'AI')=true
```

Achte insbesondere darauf welche Zeilenanzahl Aufgrund der Metadaten geschätzt wird und wo die Filter in den Query eingehen.

Führe die Queries anschließend ohne `EXPLAIN` aber mit einem `SELECT COUNT(*) FROM ...` aus und vergleiche ob die Abschätzung der Zeilen gut war.

## 5. SQL Analysen

Die folgenden Aufgaben können mit Hilfe von Standard SQL-Abfragen gelöst werden. <br>

Details zu den SQL Befehlen finden sich in der Trino und Connector Dokumentation<br> https://trino.io/docs/current/index.html

Relvante SQL Funktionen für die folgenden Aufgaben:

```

# Datetime Funktionen

Datum aus Timestame extrahieren = date(<timestamp>)
Stunde, Monat, Jahr aus Timestamp extrahieren = hour(<timestamp>), month(<timestamp>), year(<timestamp>)

# Array Feld in einzelne Zeilen exploden

select tags from <dataset> cross join unnest(<hashtags-array>) AS t (tags)

```

### 3.1 Daten

Untersuche zunächst den Datensatz um klar zu sein welche Spalten gibt es und welche Datentypen sie haben<br>

Das Schema steht im SQL Pad links an der Seite.

```

tweet_id: varchar
date: timestamp(3) with time zone
user: varchar
follower: integer
friends: integer
retweets: integer
language: varchar
country: varchar
hashtags: array(varchar)
hashtag_count: integer

```

### 3.2 Daten checken

Schau dir **1-2 Tweets** und die dazugehörigen **Hashtags** an.

<details hidden>
<summary>Lösung</summary>
<p>

```
SELECT * FROM data.twitter limit 5
```

</details>
</p>

### 3.3 Tweets pro Stunde

Schreibe eine Group By Abfrage, um die **Anzahl** der **Tweets pro Stunde** zu zählen.

<details hidden>
<summary>Lösung</summary>
<p>

```
SELECT date(created_at) as "date", hour(date) as hour, count(*) as "count" FROM data.twitter group by date(date),hour(date) order by date(date),hour(date)
```

</details>
</p>

### 3.4 Top 10 User nach Tweet-Anzahl

Schreibe eine Abfrage, die die **Top 10 User** nach ihrer **Anzahl an Tweets** ausgibt.

<details hidden>
<summary>Lösung</summary>
<p>

```
SELECT user, count(*) as "numberOfTweets" FROM data.twitter group by user order by count(*) desc limit 10

```

</details>
</p>

### 3.5 Array Zerlegung

Schreibe ein SQL Query um das **Hashtags** Array in einzelne Zeilen zu exploden.
Für diese Aufgaben wird die `unnest` Funktion benötigt (https://trino.io/docs/current/sql/select.html#unnest).

Gebe dabei die Spalten `user_name`, `tweet_id` und die unnested `hashtags`-Spalte mit einem Limit von **20** Zeilen aus.

<details hidden>
<summary>Tipp</summary>
<p>

```

select
<user>,
<tweet>,
tags
from
<dataset>
cross join unnest(<hashtags-array>) AS t (tags)
limit
20;

```

</details>
</p>

### 3.6 Top 5 Hashtags der Top 10 User

Schreibe eine komplexe SQL Abfrage, die die **Top 5 der Hashtags** der **10 User** mit den **meisten Tweets** ausgibt.

<details>
<summary>Tipp</summary>
<p>
Eine Möglichkeit ist es einen Cross Join um das <b>Hastag Array</b> zu unnesten mit einem inner Join zu kombinieren und darum ein Group By zu setzten (<a href="https://trino.io/docs/current/sql/select.html#cross-join">https://trino.io/docs/current/sql/select.html#cross-join</a>)
</details>
</p>
</details>

<details hidden>
<summary>Tipp</summary>
<p>

```

SELECT
tags,
count(<tweet>)
FROM
twitter
CROSS JOIN UNNEST(<hashtags-array>) AS t (tags)
INNER JOIN (
SELECT
<user> AS user,
max(<follower>) as follower
FROM
<data>
GROUP BY
<user>
ORDER BY
max(<follower>) desc
LIMIT
<number>
) ON <dataset>.<user> = user
GROUP BY
tags
ORDER BY
count(<tweet>) desc
LIMIT
<number>;

```

</p>
</details>

### 3.7 Top 10 Influencer

Schreibe eine Abfrage, die die **Top 10 Influencer** mit den **meisten Follower** zählt und sortiert anzeigt.

```

select
<user>,
max(<follower>) as follower
from
<dataset>
group by
<user>
order by
max(<follower>) desc
limit
<number>;

```

</details>
</p>

### 3.7 Anzahl der Tweets der Top 10 Influencer

Schreibe eine Abfrage, die die **Top 10 Influencer**, ihre Follower und die **Anzahl ihrer Tweets** ausgibt. Außeredem soll es sortiert nach den Anzahl ihrer Follower sein.

<details hidden>
<summary>Tipp</summary>
<p>

```

SELECT
<user>,
max(<follower>) AS number_of_followers,
max(numberOfTweets) AS number_of_Tweets
FROM
twitter
LEFT JOIN (
select
<user> AS user,
count(<tweet>) as numberOfTweets
from
<dataset>
group by
<user>
) ON user = <user>
GROUP BY
<user>
ORDER BY
max(<follower>) DESC
LIMIT
<number>;

```

</details>
</p>

---

## Schreiben mit Trino

Mit Trino können auch Ergebnisse wieder in Datei basierte Tabellen geschrieben werden.
Im Folgenden soll das Ergebniss einer SQL Abfrage als CSV Datei gespeichert werden.

### 4. Schema im Hive Connector auf Bucket anlegen

Um CSV Dateien anleigen zu können wird der Hive Connector verwended. Das Schema soll auf das gleiche Bucket `twitter` wie der Delta Connector zeigen. Die Tabelle wird dann in einem anderen Prefix erstellt

```

CREATE SCHEMA hive.export WITH (location = 's3a://twitter/')

```

### 4. CSV Tabelle erstellen

Im Folgenden erstellen wir eine neue Tabelle auf den Pfad `s3a://twitter/csv/` mit den Tabelleneigenschaften des darunter angefügten SELECT Statements.

```

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

Prüfe ob die Tabelle erstellt wurde

```

select \* from hive.export.csv

```

und ob das Prefix jetzt auf s3 existiert (im Terminal)

```

s3 ls s3://twitter/csv/

```

Um weitere Zeilen aus dem gleichen SELECT Statement hinzuzufügen folgendes INSERT Statemnet verwenden.

```

INSERT INTO hive.export.csv
select date, count(\*) as total, hour
from
(
select date(created_at) as "date", hour(created_at) as "hour"
from data.twitter
)
group by date, hour
order by date, hour

```

---

## 4. Cassandra Connector konfigurieren

Um die noSQL Datenbank Cassandra in Trino einzubinden muss wieder der entsprechende Connector konfiguriert werden. Füge über das Dropdown Menu "New connection" eine weitere Verbindung hinzu.

```

Name: Cassandra
Driver: Trino
Host: trino.trino.svc.cluster.local
Port: 8080
Database User: trino
Catalog: cassandra

```

Der Keyspace (das Schema pendant) und die Tabelle wurde bereits in der Cassandra Aufgabe angelegt. Deswegen sollte in der linken Leiste bereits das Schema `countries` zu sehen sein und der Zugriff auf die Tabelle direkt funktionieren.

```

show tables from <keyspace>;

```

Lese die Daten mit dem richtigen Select Statement aus.

## 2. Joine die Delta Daten von s3 mit den Cassandra Daten

**Aufgabe**: Verstehen, welche Länder mit einem höheren Anteil junger Menschen (unter 20 Jahren) Interesse an einer bestimmten Technologie zeigen (basierend auf einem Hashtag, z. B. "#BigData"), um die Marketingmaßnahmen entsprechend zu optimieren.

1. Joine Twitter Tabelle aus S3 (Delta Catalog) mit der country_population Tabelle aus Cassandra Catalog und filter nach einem bestimmten Hashtag. Tipp: hier wird die `unnest` Funktion für die Hashtags benötigt.
2. Zeige die Gesamtzahl der Tweets und Retweets für diesen Hashtag, die durchschnittlichen Retweets und den Prozentsatz der jungen Bevölkerung für jedes Land. Zeige nur Daten aus Ländern, in denen die junge Bevölkerung mehr als 20% beträgt

<details>
<summary>Tipp</summary>
<p>

```

SELECT
<country_table>.name as country_name,
<country_table>.population,
<country_table>.pct_under_20,
COUNT(\*) as big_data_tag_count,
SUM(<twitter_table>.retweet_count) AS total_retweets,
ROUND(AVG(<twitter_table>.retweet_count)) AS avg_retweets_per_tweet
FROM <twitter_table>
cross join unnest(hashtags) AS <twitter_table> (tags)
JOIN <country_table> ON <twitter_table>.user_location = <country_table>.name
WHERE
<twitter_table>.tags LIKE <'hashtag'> AND <country_table>.pct_under_20 > 20
GROUP BY
<country_table>.name, <country_table>.population, <country_table>.pct_under_20
ORDER BY
big_data_tag_count DESC;

```

</details>
</p>

###

### 4. Mit Trino auf Cassandra zugreifen

Als nächstes legen wir eine Connection auf Trino zu Cassandra an (Unter Verwendung des SQL Browsers SQLPad)

Hierzu in SQL Pad auf `New Connection` gehen und folgendes eintragen

```

Name: Cassandra
Driver: Trino (NICHT Cassandra, da wir über die Trino Engine auf Cassandra gehen wollen um Multi Source Joins zu machen)
Host: trino.trino.svc.cluster.local
Port: 8080
Database User: trino
Catalog: cassandra
Schema:

```

### 4) Nosql (JSON) Struktur in Spaltenform bringen

Ziel am Ende ist es den Wert `gdp_per_capita` soweit verfügbar aus der JSON Spalte `economic_indicators` and die Twitter Daten zu joinen.
Hierfür muss zunächst der korrekte Wert aus der JSON Struktur extrahiert werden. Trino bietet hierzu einige Funktionen an.
Verwende die Funktion `json_value` (Doku: https://trino.io/docs/current/functions/json.html#json-value) um den Wert als `int` in einer Spalte anzuzeigen.

```

# erstmal testen ob Daten erreichbar sind

SELECT \* FROM countries.country_population

# dann die Funktion richtig verwenden

SELECT json_code(<richtigen Code einsetzen>) AS gdp_per_capita FROM countries.country_population

```

<details>
<summary>Lösung</summary>
<p>

```

select
code,
population,
json_value(economic_indicators,'lax $.gdp_per_capita.value' RETURNING int) AS gdp_per_capita
from countries.country_population

```

</details>
</p>

### 5) Joine die Twitter Daten mit den Cassandra Daten via Trino

Aufgabe: Gibt es eine Korrelation zwischen der Anzahl der Bewohner eines Staates (population) und der Anzahl der Tweets?

Für diese Aufgabe müssen die Delta Daten mit den Twitter Daten gejoint werden durch Verwendung einer Subquery Struktur

<details>
<summary>Lösung</summary>
<p>

```

SELECT a.user_location as "country", a.population, a.gdp_per_capita as "gdp" , count(\*) as "TweetCount" FROM
(
SELECT delta.user_name,delta.created_at,delta.user_location,delta.language, cassandra.population, cassandra.gdp_per_capita FROM delta.data.twitter delta
LEFT JOIN (
SELECT
name,
code,
population,
json_value(economic_indicators,'lax $.gdp_per_capita.value' RETURNING int) AS gdp_per_capita
FROM cassandra.countries.country_population
) cassandra
ON delta.user_location=cassandra.name
) a
GROUP BY a.user_location, a.population, a.gdp_per_capita
ORDER BY a.population

```

</details>
</p>

### 6) Bonus: Visualisiere diesen Query in Metabase

Dazu muss zunächst Metabase korrekt mit Trino verbunden werden wie in den Metabase Aufgaben beschrieben

```

```
