# Aufgaben zu Trino

Trino kann über Connectoren auf eine Vielzahl von Datenquellen zugreifen.
Für dieses Lab ist ein Connector für Delta Files auf s3 eingerichtet.<br>

In einem s3 Bucket können verschiedene Tabellen abgelegt werden.
Eine Sammlung von Tabellen entspricht einem Schema.

Die Dateien liegen als Delta Datei in s3 unter `s3://twitter/delta`, also im Bucket `twitter` unter dem Prefix `delta`.

---

## 1. Connection zu Trino anlegen

Öffne den SQL Browser SQLPad und logge dich mit den Standard Credentials ein und gehe oben Links auf das Dropdown "New connection".

Eine neue Connection erstellen mit:

```
Name: Delta
Driver: Trino
Host: trino.trino.svc.cluster.local
Port: 8080
Database User: trino
Catalog: delta
Schema: data
```

Connection zuerst mit dem Button Test prüfen und dann speichern

Eventuell tauchen links noch keine Schema auf. Schau mit folgenden Befehlen was bei Trino verfügbar ist. <br>

```
# connectoren=cataloge anzeigen
show catalogs;

# Schemas in catalog anzeigen;
show schemas from delta;

# Tabellen in schema anzeigen;
show tables from delta.data;
```

---

## 2. Aufgabe: Schema für das Bucket anlegen

> Funktioniert nur wenn Schritt 1 durchgeführt werden.

Öffne den SQL Browser SQLPad und logge dich mit den Standard Credentials ein.

Erstelle ein Schema für den Delta Connector auf das Bucket `twitter` mit folgendem Query.

```
CREATE SCHEMA IF NOT EXISTS delta.data WITH (location='s3a://twitter/');
```

Als nächstes erzeugen wir eine Tabelle, die auf das Prefix (den Unterordner) zeigt.
Hier muss kein Schema definiert werden, da sich der Connector das Schema aus dem Schema der Delta Datei zieht.

```
CREATE TABLE delta.data.twitter (
  dummy bigint
)
WITH (
  location = 's3a://twitter/delta'
);
```

Teste ob die Daten verfügbar sind. <br>

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

---

## 3. Aufgaben in SQL formulieren

Die folgenden Aufgaben können mit Hilfe von SQL-Abfragen gelöst werden. <br>

> Die Trino Dokumentation kann dabei sehr gut behilflich sein. <br> https://trino.io/docs/current/index.html

### 1. Datensatzes

Schau dir den Datensatz einmal genau an. Welche Spalten gibt es? Welche Datentypen sind vorhanden?

<details>
<summary>Lösung</summary>
<p>

```
select
  *
from
  twitter
limit 10;
```

Das Schema steht im SQL Pad links an der Seite.

```
tweet_id: varchar
created_at: timestamp(3) with time zone
tweet_message: varchar
user_name: varchar
user_location: varchar
user_follower_count: integer
user_friends_count: integer
retweet_count: integer
language: varchar
hashtags: array(varchar)
```

</details>
</p>

### 2. Tweets

Schau dir mal **1-2 Tweets** und die dazugehörigen **Hashtags** an.

<details>
<summary>Tipp</summary>
<p>

```
select
  <tweet-message>,
  <hashtags-array>
from
  <dataset>
limit
<number>;
```

</details>
</p>

<details>
<summary>Lösung</summary>
<p>

```
select
  tweet_message,
  hashtags
from
  twitter
limit
2;
```

</details>
</p>

### 3. Tweets pro Stunde

Schreibe eine Abfrage, die die **Anzahl** der **Tweets pro Stunde** zählt.

<details>
<summary>Tipp</summary>
<p>

```
select date, <stunde>, count(*) as total
from
  (
    select date(<timestamp>) as "date", hour(<timestamp>) as "hour"
    from <dataset>
  )
group by date, <stunde>
order by date, <stunde>;
```

</details>
</p>

<details>
<summary>Lösung</summary>
<p>

```
select date, hour, count(*) as total
from
  (
    select date(created_at) as "date", hour(created_at) as "hour"
    from twitter
  )
group by date, hour
order by date, hour;
```

</details>
</p>

### 4. Top 10 User nach Tweet-Anzahl

Schreibe eine Abfrage, die die **Top User** nach ihrer **Anzahl an Tweets** ausgibt. Bedenke dabei, deine Ausgabe auf **10** Einträge zu limitieren.

<details>
<summary>Tipp</summary>
<p>

```
select
  <user>,
  count(<tweet>) as numberOfTweets
from
  <dataset>
group by
  <user>
order by
  count(<tweet>) desc
limit
  <number>;
```

</details>
</p>

<details>
<summary>Lösung</summary>
<p>

```
select
  user_name,
  count(tweet_id) as numberOfTweets
from
  twitter
group by
  user_name
order by
  count(tweet_id) desc
limit
  10;
```

</details>
</p>

### 5. Unnest

Für die folgenden Aufgaben wird die `unnest` Funktion benötigt. Schreibe eine Abfrage die das Hashtag-array mit `unnest` teilt.
Gebe dabei die Spalten `user_name`, `tweet_id` und die unnested `hashtags`-Spalte mit einem Limit von **20** Zeilen aus.

<details>
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

<details>
<summary>Lösung</summary>
<p>

```
select
  user_name,
  tweet_id,
  tags
from
  twitter
  cross join unnest(hashtags) AS t (tags)
limit
  20;
```

</details>
</p>

### 6. Top 5 Hashtags der Top 10 User

Schreibe eine Abfrage, die die **Top 5 der Hashtags** der **10 User** mit den **meisten Tweets** ausgibt.

<details>
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

</details>
</p>

<details>
<summary>Lösung</summary>
<p>

```
SELECT
  tags,
  count(tweet_id)
FROM
  twitter
  CROSS JOIN UNNEST(hashtags) AS t (tags)
  INNER JOIN (
    SELECT
      user_name AS user,
      max(user_follower_count) as follower
    FROM
      twitter
    GROUP BY
      user_name
    ORDER BY
      max(user_follower_count) desc
    LIMIT
      10
  ) ON twitter.user_name = user
GROUP BY
  tags
ORDER BY
  count(tweet_id) desc
LIMIT
  5;
```

</details>
</p>

### 7. Top 10 Influencer

Schreibe eine Abfrage, die die **Top 10 Influencer** mit den **meisten Follower** zählt und sortiert anzeigt.

<details>
<summary>Tipp</summary>
<p>

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

<details>
<summary>Lösung</summary>
<p>

```
select
  user_name,
  max(user_follower_count) as follower
from
  twitter
group by
  user_name
order by
  max(user_follower_count) desc
limit
  10;
```

</details>
</p>

### 8. Anzahl der Tweets der Top 10 Influencer

Schreibe eine Abfrage, die die **Top 10 Influencer**, ihre Follower und die **Anzahl ihrer Tweets** ausgibt. Außeredem soll es sortiert nach den Anzahl ihrer Follower sein.

<details>
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

<details>
<summary>Lösung</summary>
<p>

```
SELECT
  user_name,
  max(user_follower_count) AS number_of_followers,
  max(numberOfTweets) AS number_of_Tweets
FROM
  twitter
  LEFT JOIN (
    select
      user_name AS user,
      count(tweet_id) as numberOfTweets
    from
      twitter
    group by
      user_name
  ) ON user = user_name
GROUP BY
  user_name
ORDER BY
  max(user_follower_count) DESC
LIMIT
  10;
```

</details>
</p>

---

## 4. Schreiben mit Trino

Ziel ist, wir schreiben ein Aggregat als csv Datei nach s3.

Dafür: <br>

### 1. Schema in hive auf dem gleichen Bucket aber hive connector erstellen

```
CREATE SCHEMA hive.export
WITH (location = 's3a://twitter/')
```

### 2. Tabelle aus dem Ergebniss einer Abfrage auf bucket erstellen

```
CREATE TABLE hive.export.csv
COMMENT 'aggregation'
WITH (
format = 'TEXTFILE',
external_location = 's3a://twitter/csv/',
partitioned_by = ARRAY['hour']
)
AS
select date, count(*) as total, hour
from
(
select date(created_at) as "date", hour(created_at) as "hour"
from data.twitter
)
group by date, hour
order by date, hour

```

Checke ob es funktioniert hat. <br>

```
select * from hive.export.csv
```

Checke genauso s3. <br>

```
s3 ls s3://twitter/csv/
```

Wenn später weitere Zeilen hinzugefügt werden sollen, geht das mit:

```
INSERT INTO hive.export.csv
select date, count(*) as total, hour
from
(
select date(created_at) as "date", hour(created_at) as "hour"
from data.twitter
)
group by date, hour
order by date, hour
```

## 5. Daten aus dem Cassandra-Catalog lesen

Eine neue Connection erstellen:

```
Name: Cassandra
Driver: Trino
Host: trino.trino.svc.cluster.local
Port: 8080
Database User: trino
Catalog: cassandra
```

Ein Keyspace ist ein äußerstes Objekt in einem Cassandra-Cluster, das steuert, wie Daten auf den Nodes repliziert werden.
Die Tabellen, die wir benötigen, werden im `countries` Keyspace erstellt und daher über das Muster `<keyspace>.<table>` aufgerufen, zum Beispiel `countries.country_population`.

### 1. Cassandra Tables

Erstelle eine `countries` Keyspace und eine `country_population` Tabelle. Gebe dabei die Spalten `id`, `name`, `code`, `population`, `pct_under_20`, `pct_urban`, `pct_working_age`.

<details>
<summary>Lösung</summary>
<p>

```
CREATE KEYSPACE IF NOT EXISTS countries
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };

CREATE TABLE IF NOT EXISTS countries.country_population (id int PRIMARY KEY, name text, code text, population bigint, pct_under_20 int, pct_urban int, pct_working_age int);
```

</details>
</p>

Füge Daten in die Tabelle ein

<details>
<summary>Lösung</summary>
<p>

```
INSERT INTO countries.country_population (id, name, code, population, pct_under_20, pct_urban, pct_working_age)
VALUES (1, 'USA', 'US', 329484123, 24, 83, 64);

INSERT INTO countries.country_population (id, name, code, population, pct_under_20, pct_urban, pct_working_age)
VALUES (2, 'Brazil', 'BR', 212559409, 28, 88, 69);

INSERT INTO countries.country_population (id, name, code, population, pct_under_20, pct_urban, pct_working_age)
VALUES (3, 'Spain', 'ES', 47351567, 19, 80, 66);

INSERT INTO countries.country_population (id, name, code, population, pct_under_20, pct_urban, pct_working_age)
VALUES (4, 'Germany', 'DE', 83240525, 18, 76, 64);

INSERT INTO countries.country_population (id, name, code, population, pct_under_20, pct_urban, pct_working_age)
VALUES (5, 'United Kingdom', 'UK', 67215293, 23, 83, 63);

INSERT INTO countries.country_population (id, name, code, population, pct_under_20, pct_urban, pct_working_age)
VALUES (6, 'India', 'IN', 1380004385, 34, 35, 69);

INSERT INTO countries.country_population (id, name, code, population, pct_under_20, pct_urban, pct_working_age)
VALUES (7, 'France', 'FR', 67391582, 23, 82, 61);
```

</details>
</p>

Schau dir die verfügbaren Tabellen in der Datenbank

<details>
<summary>Lösung</summary>
<p>

```
show tables from countries;
```

</details>
</p>

Schau dir mal die `country_population` Tabelle und mit dem Befehl `describe` auch die Informationen über die Tabelle.

<details>
<summary>Lösung</summary>
<p>

```
SELECT * FROM
  countries.country_population
  ;
```

```
describe countries.country_population;
```

</details>
</p>

<details>
<summary>Lösung</summary>
<p>

```
SELECT
    c.name as country_name,
    c.population,
    c.pct_under_20,
    COUNT(*) as big_data_tag_count
FROM delta.data.twitter twit
  cross join unnest(hashtags) AS twit (tags)
  JOIN cassandra.countries.country_population c ON twit.user_location = c.name
WHERE
    twit.tags LIKE 'BigData'
GROUP BY
    c.name, c.population, c.pct_under_20
ORDER BY
   big_data_tag_count DESC;
```

</details>
</p>

## 2. Business Case - Analyze Tweets zusammen mit Länderdaten

Business Case: Verstehen, welche Länder mit einem höheren Anteil junger Menschen (unter 20 Jahren) Interesse an einer bestimmten Technologie zeigen (basierend auf einem Hashtag, z. B. "#BigData"), um die Marketingmaßnahmen entsprechend zu optimieren.

1. Joine Twitter Tabelle aus S3 (Delta Catalog) mit der country_population Tabelle aus Cassandra Catalog und filter nach einem bestimmten Hashtag. Tipp: hier wird die `unnest` Funktion für die Hashtags benötigt.
2. Zeige die Gesamtzahl der Tweets und Retweets für diesen Hashtag, die durchschnittlichen Retweets und den Prozentsatz der jungen Bevölkerung für jedes Land. Zeige nur Daten aus Ländern, in denen die junge Bevölkerung mehr als 20% beträgt

<details>
<summary>Lösung</summary>
<p>

```
SELECT
    c.name as country_name,
    c.population,
    c.pct_under_20,
    COUNT(*) as big_data_tag_count,
    SUM(twit.retweet_count) AS total_retweets,
    ROUND(AVG(twit.retweet_count)) AS avg_retweets_per_tweet
FROM delta.data.twitter twit
  cross join unnest(hashtags) AS twit (tags)
  JOIN countries.country_population c ON twit.user_location = c.name
WHERE
    twit.tags LIKE 'BigData' AND c.pct_under_20 > 20
GROUP BY
    c.name, c.population, c.pct_under_20
ORDER BY
   big_data_tag_count DESC;
```

</details>
</p>

Unnest Jos
SELECT
code,
population,
CAST(json_value(
economic_indicators,
'lax $.gdp_per_capita.value'
) AS gdp_per_capita
AS JSON)
economic_indicators
FROM
cassandra.countries.population
