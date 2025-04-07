# Kafka SQL (KSQL) Aufgaben

Entweder als Demo oder Bonusaufgabe wenn Zeit

In diesen Aufgaben wirst du mit Kafka Streams und KSQL arbeiten, um Daten zu analysieren, zu aggregieren und miteinander zu verknüpfen. KSQL ermöglicht es, Echtzeit-Datenströme zu verarbeiten, ohne den gesamten Datenbestand abfragen zu müssen, und ist perfekt für Event-Driven-Architekturen geeignet.

#### Wichtige Konzepte:

    •	Stream: Ein unbegrenzter Strom von Ereignissen (unbounded stream), der kontinuierlich neue Daten empfängt.
    •	Tabelle: Eine materialisierte Ansicht von Ereignissen, die für jeden Schlüssel den letzten Wert speichert (Stateful).

⸻

## Setup und erste Schritte:

Um mit KSQL zu arbeiten, verwenden wir die ksql-cli. Um KSQL im Terminal zu starten, führe folgenden Befehl aus:

```
kubectl exec -it ksqldb-0 -c ksqldb -n kafka -- ksql

===========================================
=       _              _ ____  ____       =
=      | | _____  __ _| |  _ \| __ )      =
=      | |/ / __|/ _` | | | | |  _ \      =
=      |   <\__ \ (_| | | |_| | |_) |     =
=      |_|\_\___/\__, |_|____/|____/      =
=                   |_|                   =
=        The Database purpose-built       =
=        for stream processing apps       =
===========================================

```

Sobald du in der KSQL-Shell bist, kannst du mit folgenden Befehlen die Themen und Streams inspizieren:

```
show topics;
show streams;
show tables;
```

Jeder Befehl muss mit einem Semikolon beendet werden.
Mit dem Befehl print `twitter-table;` kannst du eine Live-Ansicht der Daten eines Topics anzeigen.

Um für die weiteren Aufgaben immer alle Daten aus dem Stream von Anfang an zu lesen einmalig in der Session folgende Flag setzen

```
SET 'auto.offset.reset' = 'earliest';
```

## 1. Erstellen eines Streams auf einem Topic

Ein Stream repräsentiert eine Abstraktion auf ein Kafka-Topic und ermöglicht es dir, dynamische SQL-Abfragen auf die Zeitreihe der Daten im Stream auszuführen.

#### Aufgabe 1: Erstelle einen Stream

```
CREATE STREAM twitter
    (tweet_id VARCHAR KEY, created_at VARCHAR, tweet_message VARCHAR, user_name VARCHAR, user_location VARCHAR, user_follower_count INT, user_friends_count INT, retweet_count INT, language VARCHAR, hashtags ARRAY<VARCHAR>)
WITH (kafka_topic='twitter-table', value_format='json', partitions=2);
```

Nun kannst du SQL-Abfragen und Aggregationen auf diesem Stream vornehmen. Beachte, dass bei Verwendung von emit changes die Abfrage kontinuierlich aktualisiert wird, während ohne dieses Flag nur die aktuellen Daten angezeigt werden.

## 2. Abfragen und Aggregationen

Probiere folgende Beispiele

#### Aufgabe 2: Anzeige von Tweets

Zeige den Namen des Nutzers, das Land und die Hashtags der Tweets an, einmal als statische Ansicht und einmal in Echtzeit. Mit dem Prefix `EMIT CHANGES` wird eine Echtzeitansicht auf den Stream geöfnet. Diese Ansicht kann mit `strg + c` wieder verlassen werden

```
select user_name, user_location, hashtags from twitter;
select user_name, user_location, hashtags from twitter emit changes;
```

#### Aufgabe 3: Aggregation der Tweets pro Land

```
select language, count(*) as total from twitter group by language emit changes;
```

#### Aufgabe 4: Erstellen einer Tabelle aus einem Stream

Erstelle eine Tabelle, die die Anzahl der Tweets pro Land aggregiert. Eine Tabelle ist eine materialisierte Ansicht auf einen Stream und speichert den neuesten Wert für jede Gruppe.

```
CREATE TABLE tweets_per_country AS
SELECT language, count(*) as TOTAL
FROM twitter
GROUP BY language
EMIT CHANGES;
```

## 3. Joins zwischen Topics

Erstelle eine Tabelle country_details und lade einige Werte (Bevölkerungszahlen der Länder) hinein. Dann führe einen Join mit dem Twitter-Stream durch, um diesen mit den Bevölkerungsdaten anzureichern.

#### Aufgabe 5: Statische Tabelle in Topic anlgen

Leere Tabelle auf einem Topic anlegen

```
CREATE TABLE country_details (
  country VARCHAR PRIMARY KEY,
  population BIGINT
) WITH (topic = 'country-details', kafka_topic = 'country-details', value_format = 'JSON', partitions = 2);
```

Werte in die Tabelle, das Topic schreiben

```
INSERT INTO country_details (country, population) VALUES ('Germany', 83200000);
INSERT INTO country_details (country, population) VALUES ('USA', 331000000);
INSERT INTO country_details (country, population) VALUES ('United Kingdom', 67200000);
INSERT INTO country_details (country, population) VALUES ('France', 67000000);
INSERT INTO country_details (country, population) VALUES ('India', 1393000000);
INSERT INTO country_details (country, population) VALUES ('Spain', 47300000);
INSERT INTO country_details (country, population) VALUES ('Brasil', 213000000);
```

#### Aufgabe 6: Stream mit Tabelle joinen und anreichern

```
CREATE STREAM enriched_tweets AS
SELECT
  t.user_name,
  t.user_location AS country,
  c.population,
  'all' AS join_key
FROM twitter t
LEFT JOIN country_details c
  ON t.user_location = c.country
EMIT CHANGES;
```

Jetzt einmal alles anschauen über

```
show streams;
show tables:
show topics;

select * from country_details
select * from enriched_tweets
```

## 6. Komplexers Stream Processing

#### Aufgabe 7 (Bonus): Prozentuale Verteilung der Tweets

Berechne die Prozentuale Verteilung der Tweets über die Länder in Echtzeit
Erzeuge eine Tabelle, die immer die prozentuale Verteilung der Anzahl der Tweets über alle Länder darstellt.

**Schritt 1: Helfer-Stream tweet_counter erstellen:**

```
CREATE STREAM tweet_counter AS
SELECT 'all' total_key, 1 dummy_value
FROM enriched_tweets
EMIT CHANGES;
```

**Schritt 2: Aggregierte Tabelle total_tweet_count erstellen:**

```
CREATE TABLE total_tweet_count AS
SELECT total_key, COUNT(*) AS total_tweets
FROM tweet_counter
GROUP BY total_key
EMIT CHANGES;
```

**Schritt 3: Berechnung der Tweet-Prozentsätze pro Land:**

```
SELECT
  a.country,
  a.tweet_count,
  b.total_tweets,
  (a.tweet_count * 100.0) / b.total_tweets AS tweet_percentage
FROM tweets_per_country a
LEFT JOIN total_tweet_count b
  ON a.TOTAL_KEY = b.TOTAL_KEY
WHERE COUNTRY = 'Germany'
EMIT CHANGES;
```

## 7. Aggregationen über ein Zeitfenster

#### Aufgabe 6 (Bonus): Aggregation über ein Zeitfenster

Erstelle eine Aggregation, die nicht über den gesamten Stream läuft, sondern nur über ein 30-Sekunden-Zeitfenster. Dies hilft, die Verarbeitung von Events innerhalb eines bestimmten Zeitrahmens zu simulieren.

```
SELECT language, count(*) as total
FROM twitter
WINDOW TUMBLING (size 30 SECOND)
GROUP BY language
EMIT CHANGES;
```

In diesem Beispiel wird die Anzahl der Tweets pro Land alle 30 Sekunden neu berechnet.

## 8. Streams und Tabellen analysieren

Verwende die folgenden Befehle, um Streams und Tabellen zu analysieren. Hier können die Stream Defintionen mit Schema und darunterliegenden Topics angeschaut werden sowie die Abhängigkeiten von weiteren Topics die darauf aufbauen.
**Streams und Tabellen beschreiben:**

```
DESCRIBE TABLE <table_name> EXTENDED;
DESCRIBE STREAM <stream_name> EXTENDED;
```

#### Stream Processing Anwendungen = SHOW QUERIES

SHOW QUERIES zeigt alle laufenden, persistenten Queries an, die auf dem KSQL-Server ausgeführt werden. Diese Queries entsprechen Stream Processing Anwendungen, die kontinuierlich neue Daten aus einem oder mehreren Kafka-Topics lesen und die Ergebnisse in neuen Topics schreiben.

Ein Stream Processing Query ist eine dauerhafte Abfrage, die so lange läuft, bis sie explizit gestoppt wird. Diese Queries sind persistent, was bedeutet, dass sie ständig neue Ereignisse verarbeiten und die Daten in die entsprechenden Kafka-Topics zurückschreiben.

**Ein wichtiger Punkt:**

- Wenn du eine Stream oder eine Table in KSQL erstellst, wird die zugehörige Query im Hintergrund ausgeführt und als persistente Query betrachtet. Sie wird auch in der SHOW QUERIES-Ausgabe erscheinen.

Das bedeutet, dass du mit SHOW QUERIES alle aktiven Stream Processing-Apps (Queries) überwachen kannst, die in KSQL auf den Datenströmen basieren. Das bedeutet aber auch, dass jeder persistente Query der im Hintergrund läuft CPU und Memory Resourcen benötigt.

**Beispiel:**
Wenn du eine Query erstellst, die die Tweets pro Land zählt und die Ergebnisse in einem neuen Topic speichert, läuft diese Query kontinuierlich und zählt neue Tweets, die ankommen. Diese laufende Query siehst du mit SHOW QUERIES. Sie ist dann Teil deiner Stream Processing Architektur.

**Was passiert, wenn eine Query gestoppt wird?**

- Wenn du eine non-persistent Query ausführst, die nur einmal die aktuellen Daten abfragt, erscheint sie nicht in SHOW QUERIES, da sie keine fortlaufende Stream-Verarbeitung darstellt.
- Wenn du jedoch eine Stream- oder Tabellen-Abfrage mit EMIT CHANGES erstellst (d.h. eine persistent query), die ständig neue Daten verarbeitet, dann erscheint diese Query in der SHOW QUERIES-Liste.

Erklärung von weitere Funktionen:

- `LATEST_BY_OFFSET`: Diese Funktion ist besonders wichtig, um bei einer Aggregation den letzten bekannten Wert eines Feldes zu erhalten, z. B. die aktuelle Bevölkerungszahl eines Landes. Andernfalls kann dieser Wert nicht in einer SELECT-Liste verwendet werden, wenn er nicht aggregiert oder gruppiert wird.
- `REQUEST-PIPELINING ON`: Wenn bei einem langen Vorgang, z. B. beim Löschen eines Topics, Probleme auftreten, kannst du mit diesem Befehl die Ausführungsreihenfolge optimieren und Fehler vermeiden.
