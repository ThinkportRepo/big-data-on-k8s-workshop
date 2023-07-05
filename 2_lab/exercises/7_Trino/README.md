# Trino Aufgaben

Trino kann über Connectoren auf eine Vielzahl von Datenquellen zugreifen.
Für diese Aufgabe verwenden wir drei Connectoren

- Delta Connector: lesen der Delta Dateien auf s3
- Hive Connector: lesen und schreiben von CSV Dateien auf s3
- Cassandra Connector: verbindung mit der noSQL Datenbank Cassandra

![Architektur Bild](/2_lab/exercises/7_Trino/architecture.png)

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
CALL delta.system.register_table(
  schema_name = > 'data',
  table_name = > 'twitter',
  table_location = > 's3a://twitter/delta'
)
```

Teste nun ob das Schema, die Tabelle und die Daten verfügbar sind. <br>

```
# Schema anzeigen
SHOW schemas FROM delta;

# Tabellen anzeigen
SHOW tables FROM delta.data;

# Inhalt der Tabellen anzeigen
SELECT * FROM delta.data.twitter
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
SELECT * FROM data.twitter WHERE language='DE'

# Filter auf berechnete Spalte
SELECT * FROM data.twitter WHERE language='DE' AND contains(hashtags,'AI')=true
```

Achte insbesondere darauf welche Zeilenanzahl Aufgrund der Metadaten geschätzt wird und wo die Filter in den Query eingehen.

Führe die Queries anschließend ohne `EXPLAIN` aber mit einem `SELECT COUNT(*) FROM ...` aus und vergleiche ob die Abschätzung der Zeilen gut war.

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
<p>

```
# alle Daten
EXPLAIN SELECT * FROM data.twitter;

# Filter auf Partitionierte Spalte
EXPLAIN SELECT * FROM data.twitter WHERE language='DE'

# Filter auf berechnete Spalte
EXPLAIN SELECT * FROM data.twitter WHERE language='DE' AND contains(hashtags,'AI')=true
```

</details>
</p>

## 5. SQL Analysen auf Dateien

Die folgenden Aufgaben können mit Hilfe von Standard SQL-Abfragen gelöst werden. <br>

Details zu den SQL Befehlen finden sich in der Trino und Connector Dokumentation<br> https://trino.io/docs/current/index.html

### 3.1 Daten

Untersuche zunächst den Datensatz um klar zu sein welche Spalten es gibt und welche Datentypen sie haben<br>

Die Datetypen stehen z.B. an linken Seite im Schema Explorer

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

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
<p>

```
SELECT * FROM data.twitter LIMIT 5
```

</details>
</p>

### 3.3 Tweets pro Stunde

Schreibe eine Group By Abfrage, um die **Anzahl** der **Tweets pro Stunde** zu zählen.

```
Beispiel Ausgabe:
+------------+------+---------------+
| Day        | Hour | TweetsPerHour |
+============+======+===============+
| 2023-08-01 | 14   | 684           |
+------------+------+---------------+
| 2023-08-01 | 15   | 394           |
+------------+------+---------------+
| 2023-08-01 | 16   | 705           |
+------------+------+---------------+
```

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
<p>

```
SELECT
  date(created_at) as "date",
  hour(date) as hour,
  count(*) as "count"
FROM
  data.twitter
GROUP BY
  date(date),
  hour(date)
ORDER BY
  date(date),
  hour(date)
```

</details>
</p>

### 3.4 Top 10 User nach Tweet-Anzahl

Schreibe eine Abfrage, die die **Top 10 User** nach ihrer **Anzahl an Tweets** ausgibt.

```
Beispiel Ausgabe:
+--------+--------------+
| User   | NumberTweets |
+========+==============+
| Mary   | 81           |
+--------+--------------+
| David  | 76           |
+--------+--------------+
| Travis | 69           |
+--------+--------------+
```

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
<p>

```
SELECT
  user,
  count(*) as "numberOfTweets"
FROM
  data.twitter
GROUP BY
  user
ORDER BY
  count(*) desc
LIMIT
  10
```

</details>
</p>

### 3.5 Array Zerlegung

Schreibe ein SQL Query um das **Hashtags** Array in einzelne Zeilen zu exploden.
Für diese Aufgaben wird die `UNNEST` Funktion benötigt (https://trino.io/docs/current/sql/select.html#unnest).

Gebe dabei die Spalten `user`, `tweet_id`, `hashtags` und die unnested `hashtags`-Spalte mit einem Limit von **20** Zeilen und ihne Duplikate aus.

```
Beispiel Ausgabe:
+--------+---------+---------+---------------+
| User   | TweetId | Tag     | Hashtags      |
+========+=========+=========+===============+
| Willie | 1       | BigData | [BigData, ML] |
+--------+---------+---------+---------------+
| Willie | 6       | ML      | [BigData, ML] |
+--------+---------+---------+---------------+
| James  | 2       | Cloud   | [Cloud]       |
+--------+---------+---------+---------------+
```

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0;">
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Hinweis</summary>
<p>
UNNEST wird am besten zusammen mit einem CROSS JOIN verwendet werden. In der Dokumentation finden sich einige Beispiele dazu.
```
SELECT student, score
FROM (
   VALUES
      ('John', ARRAY[7, 10, 9]),
      ('Mary', ARRAY[4, 8, 9])
) AS tests (student, scores)
CROSS JOIN UNNEST(scores) AS t(score);
```

</details>
</p>

Speichere dir diesen Querie ab, er kann dir später zum nachschauen nochmal nützlich sein

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
<p>

```
SELECT
  user,
  tweet_id,
  tags
FROM
  data.twitter
  CROSS JOIN UNNEST(hashtags) AS t(tags);
```

</details>
</p>

### 3.6 Top 5 Hashtags der Top 10 User

Schreibe eine komplexere SQL Abfrage, die die **Top 5 der Hashtags** der **10 User** mit den **meisten Tweets** ausgibt.

```
# Beispiel Ausgabe:
+--------+-----------------+--------------+
| User   | tags            | anzahlTweets |
+========+=================+==============+
| Timmy  | BigData         | 127          |
+--------+-----------------+--------------+
| Esther | BigData         | 114          |
+--------+-----------------+--------------+
| Angie  | MachineLearning | 102          |
+--------+-----------------+--------------+
```

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0;">
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Hinweis</summary>
<p>
kombiniere die Abfragen der beiden vorherigen Aufgabe mit einem JOIN oder einem WHERE IN Statement
</details>
</p>
</details>

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
<p>

Mit einer WHERE IN CLAUSE

```
SELECT user,tags, count(*) as anzahl_tweets
FROM data.twitter CROSS JOIN UNNEST(hashtags) AS t(tags)
where
  user in (
    SELECT a.user
    FROM (
        SELECT user, count(*) as anzahl_tweets
        FROM data.twitter a
        GROUP BY user
        ORDER BY count(*) DESC
        LIMIT 10
      ) a
  )
GROUP BY user, tags
ORDER BY count(*) DESC
LIMIT 5
```

oder alternativ mit einem LEFT JOIN

```
SELECT b.tags,a.user, count(*) AS "anzahl_tweets" FROM
(
  SELECT user, count(*) AS anzahl_tweets
  FROM data.twitter a
  GROUP BY user
  ORDER BY count(*) DESC
  LIMIT 10
) a
LEFT JOIN (
SELECT user, tags
FROM data.twitter CROSS JOIN UNNEST(hashtags) AS t(tags)
) b ON b.user=a.user
GROUP BY a.user,b.tags
ORDER BY count(*) DESC
LIMIT 5
```

</p>
</details>

### 3.7 Top 10 Influencer

Schreibe eine Abfrage, die die **Top 10 Influencer** mit den **meisten Follower** ausgibt.

```
# Beispiel Ausgabe:
+------+----------------+
| User | numberFollower |
+======+================+
| Tim  | 1399           |
+------+----------------+
| Jana | 800            |
+------+----------------+
| Max  | 10             |
+------+----------------+

```

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
<p>
```
SELECT user, max(follower) as "numberFollower"
FROM data.twitter
GROUP BY user
ORDER BY max(follower) desc
LIMIT 10;
```
</details>
</p>

### 3.7 Anzahl der Tweets der Top 10 Influencer (Bonus Aufgabe)

Schreibe eine Abfrage, die die **Top 10 Influencer**, die Anzal ihrer Follower und die **Anzahl ihrer Tweets** ausgibt. Außeredem soll das Ergebnis nach Anzahl der Follower sortiert sein.

```
Beispiel Ausgabe:
+--------+-----------------+--------------+
| User   | numberFollowers | numberTweets |
+========+=================+==============+
| Gracie | 4599            | 124          |
+--------+-----------------+--------------+
| Julia  | 3459            | 320          |
+--------+-----------------+--------------+
| James  | 1245            | 59           |
+--------+-----------------+--------------+
```

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
<p>

```
SELECT a.user, max(a.follower) AS numberFollowers, max(b.numberOfTweets) AS numberTweets
FROM data.twitter a
LEFT JOIN (
  SELECT user AS user, count(*) AS numberOfTweets
  FROM data.twitter
  GROUP BY user
) b
ON a.user = b.user
GROUP BY a.user
ORDER BY max(a.follower) DESC
LIMIT 5;

```

</details>
</p>

---

## Schreiben mit Trino

Mit Trino können auch Ergebnisse wieder in Datei basierte Tabellen geschrieben werden.
Im Folgenden soll das Ergebniss einer SQL Abfrage als CSV Datei gespeichert werden.

### 4. Schema im Hive Connector auf Bucket anlegen

Um CSV Dateien anleigen zu können wird der Hive Connector verwended. Das Schema soll auf das gleiche Bucket `twitter` wie der Delta Connector zeigen. Die Tabelle wird dann in einem anderen Prefix erstellt.
Erstelle zunächst ein neues Schema für den Hive Connector

```
CREATE SCHEMA hive.export WITH (location = 's3a://twitter/')
```

### 4. CSV Tabelle erstellen

Im Folgenden wird eine neue Tabelle auf den Pfad `s3a://twitter/csv/` mit den Tabelleneigenschaften (Spaltennamen, Typen) des darunter angefügten SELECT Statements erstellt.
Die Tabelle soll außerdem nach `hour` partitioniert werden.

```
CREATE TABLE hive.export.csv
COMMENT 'aggregation'
WITH (
  format = 'TEXTFILE',
  external_location = 's3a://twitter/csv/',
  partitioned_by = ARRAY['hour']
)
AS SELECT date, count(*) as total, hour
FROM
(
  SELECT date(created_at) AS "date", hour(created_at) as "hour"
  FROM data.twitter
)
GROUP BY date, hour
ORDER BY date, hour
```

Prüfe ob die Tabelle erstellt und mit Daten gefüllt wurde

```
select * from hive.export.csv
```

und ob das Prefix jetzt auf s3 existiert (im Terminal)

```
s3 ls s3://twitter/csv/
```

Um weitere Zeilen aus dem gleichen SELECT Statement hinzuzufügen folgendes INSERT Statemnet verwenden.

```

INSERT INTO hive.export.csv
SELECT date, count(*) as total, hour
FROM
  (
  SELECT date(created_at) as "date", hour(created_at) as "hour"
  FROM data.twitter
  )
GROUP BY date, hour
ORDER BY date, hour
```

Ergebnisse von Analysen können also wieder in Dateien abgespeichert und zur weiteren Verwendung gesichert werden.

Prinzipiell lassen sich damit auch ganze ETL Strecken schreiben. Allerdings ist dies wesentlich aufwendiger als in Spark. Zum einen können komplexe Pipelines nicht in der Ausführungsabfolge aneinander gehängt werden sondern müssen als genested SQL Queries mit Subqueries geschrieben werden und das automatisierte Shedulen, Monitoren und Überwachen ist wesentlich aufwendiger zu implementieren.

## 4. Cassandra Abfragen

Trino ist eine Multisource Query Engine, die nicht nur auf Datei basierten Daten SQL ausführen kann sondern
auch Connetoren auf viel andere Systeme wie RDBMS, noSQL, Kafka, ElasticSearch anbietet und deren spezifische Abfragensprache in SQL übersetzt.

### 4.1 Cassandra Connector konfigurieren

Um die noSQL Datenbank Cassandra in Trino einzubinden muss wieder der entsprechende Connector konfiguriert werden. Füge über das Dropdown Menu "New connection" eine weitere Verbindung mit folgenden Parametern hinzu.

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

### 4.2 JSON Struktur in Spaltenform bringen

Ziel am Ende ist es den Wert `gdp_per_capita` soweit verfügbar aus der JSON Spalte `economic_indicators` and die Twitter Daten zu joinen. Hierfür muss zunächst der korrekte Wert aus der JSON Struktur extrahiert werden. Trino bietet hierzu einige Funktionen an. Verwende die Funktion `json_value` (Doku: https://trino.io/docs/current/functions/json.html#json-value) um den Wert als `int` in einer Spalte anzuzeigen.

```
# Ergänze die Funktion korrekt
SELECT
  code,
  population,
  json_value(
    economic_indicators,
    <<RICHTIGEN CODE EINFÜGEN>>
  ) AS gdp_per_capita
FROM
  cassandra.countries.population
```

```
Beispiel Ergebnis:
+------+------------+--------------+
| Code | Population | gdpPerCapita |
+======+============+==============+
| DE   | 83240525   | 35480        |
+------+------------+--------------+
| IN   | 1380004385 | null         |
+------+------------+--------------+
| ES   | 47351567   | 23450        |
+------+------------+--------------+
```

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
<p>
```
SELECT
  code,
  population,
  json_value(
    economic_indicators,
    'lax $.gdp_per_capita.value' RETURNING int
  ) AS gdp_per_capita
FROM
  cassandra.countries.population
```
</details>
</p>

### 4.3. Joine die Delta Tabelle von s3 an die Cassandra Tabelle

Finde einen gemeinsamen Join Key und joine die Cassandra Tabelle mit einem `LEFT JOIN` and die Delta Tabelle

```
# Delta Tabelle anzeigen
SELECT * FROM delta.data.twitter

# Cassandra Tabelle anzeigen
SELECT * FROM cassandra.countries.population
```

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0;">
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Hinweis</summary>
Es gibt zwei mögliche Join Keys. Entweder twitter.language=population.code oder twitter.country=population.name
</details>

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
Es gibt zwei Möglichkeiten wobei die es mehr Matches twitter.country=population.name git
```
SELECT count(*) 
FROM delta.data.twitter d
LEFT JOIN cassandra.countries.population c
ON d.country=c.name
WHERE c.name IS NOT NULL
```
oder
```
SELECT count(\*)
FROM delta.data.twitter d
LEFT JOIN cassandra.countries.population c
ON d.language=c.code
WHERE c.code IS NOT NULL

```
</details>

### 4.4 Populärster Hashtag in Ländern mit junger Bevölkerung (Bonus)

Zeige die Anzahl der Hashtags nach Ländern aber nur für Länder in denen der Anteil der jungen Bevölkerung (unter 20 Jahren) mehr als 15% beträgt. Diese Aufgabe ist schwerer.

```

Beispiel Ergebnis:
+---------+---------+--------------+---------+
| Country | Tags | HashTagCount | Under20 |
+=========+=========+==============+=========+
| USA | BigData | 990 | 24 |
+---------+---------+--------------+---------+
| France | BigData | 253 | 23 |
+---------+---------+--------------+---------+
| India | Cloud | 64 | 34 |
+---------+---------+--------------+---------+

```

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0;">
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Hinweis</summary>
Hier muss wieder die Hashtags Spalte unnesten werden. <br>
Am besten twitter.country=
Die Spalte under_20 gibt den Prozentualen Anteil der Bevölkerung unter 20 Jahren wieder.<br>
Um für jedes dieser Länder den populärsten Hashtag zu finden wird am besten eine Window Function mit rank() oder dens_rank() verwendet (<a href=https://trino.io/docs/current/functions/window.html>https://trino.io/docs/current/functions/window.html</a>)
</details>

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
```

SELECT _ FROM
(
SELECT
b.country,
b.tags,
b.HashTagCount,
c.under_20,
dense_rank() OVER (PARTITION BY b.country ORDER BY b.HashTagCount desc) AS "rank"
FROM
(
SELECT
a.country,
tags,
count(_) as HashTagCount
FROM
data.twitter a
CROSS JOIN UNNEST(hashtags) AS t(tags)
group by
a.country,
tags
) b
LEFT JOIN (
SELECT \* FROM cassandra.countries.population
) c
ON b.country=c.name
WHERE c.under_20 > 20
) d
where rank=1
order by HashTagCount desc

```
</details>


### 4.5 Korrelation zwischen Anzahl Tweets und Bevökerungs oder Einkommen (Bonus)

Gibt es eine Korreation der Anzahl von Tweets im Bereich BigData zur Bevölkerungszahl (`population`) oder zum mittleren pro Kopf Einkommen (`gdp_per_capita`)? Also skaliert die Anzahl der Tweets direkt mit der Bevölkerungszahl oder mit eher mit dem Wohlstand?
Dies ist eine schwere Textaufgabe mit mehreren Lösungsmöglichkeiten.

```
Das Ergebnis der Korrelationsanalyse könnte z.B. so aussehen:
+---------------+----------------------+-------------------+
| corrTweetsGDP | corrTweetsPopulation | corrPopulationGDP |
+===============+======================+===================+
| 0.75 | 0.89 | 0.97 |
+---------------+----------------------+-------------------+

und die darunter liegende Tabelle:
+---------+------------+-------+------------+
| Country | Population | GDP | TweetCount |
+=========+============+=======+============+
| Spain | 47351567 | 23450 | 149 |
+---------+------------+-------+------------+
| France | 67391582 | 32530 | 179 |
+---------+------------+-------+------------+
| Germany | 83240525 | 35480 | 426 |
+---------+------------+-------+------------+
```

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0;">
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Hinweis</summary>
Hier geht es um die Tweets und nicht die Hashtags, es muss also kein UNNEST verwendet werden <br>
<b>Vorgehensweise: </b> <br>
1) Verjoine die Twitter Tabelle mit der Cassandra Tabelle
2) Extrahiere die Spalten population und gdp_per_capita
3) Zähle die Tweets
4) Verwende die Korrelatiuonsfunktion (corr) korrekt um Korrelationen zu bestimmen
 (<a href=https://trino.io/docs/current/functions/aggregate.html>https://trino.io/docs/current/functions/aggregate.html</a>)
</details>

<details style="border: 1px solid #aaa; border-radius: 4px; padding: 0.5em 0.5em 0; background-color: #00BCD4" class="solution" hidden>
<summary style="margin: -0.5em -0.5em 0; padding: 0.5em;">Lösung</summary>
```
SELECT
corr(tweets,gdp) as "corr_tweets_gdp",
corr(tweets,population) as "corr_tweets_population",
corr(population,gdp) as "corr_population_gdp"
FROM (
SELECT
a.country as "country", a.population, a.gdp_per_capita as "gdp", count(\*) as "tweets"
FROM
(
SELECT d.user, d.date, d.country, d.language, c.population, c.gdp_per_capita
FROM delta.data.twitter d
LEFT JOIN (
SELECT name,code,population,
json_value(economic_indicators,'lax $.gdp_per_capita.value' RETURNING int) AS gdp_per_capita
FROM cassandra.countries.population
) c ON d.country = c.name
) a
WHERE a.gdp_per_capita IS NOT NULL AND a.population IS NOT NULL
GROUP BY a.country, a.population, a.gdp_per_capita
ORDER BY a.population
) f

```
</details>
