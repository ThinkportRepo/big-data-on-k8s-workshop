# Kafka SQL (KSQL) Aufgaben

Entweder als Demo oder Bonusaufgabe wenn Zeit

SQL Auswertungen auf den Topics bzw. einem Stream Objekt

A Stream is an unbounded sequence of events

A table is a materialized view of events with only the latest value for each key

### KSQL CLI

KSQL kann aktuell nur über die `Kafka Streams` Java Bibliothek, die ksql-cli oder die Weboberfläche von Confluent angesprochen werden.
Die ksql-cli läuft direkt auf dem KSQL-Server und kann aus dem VSCode Terminal gestartet werden

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

Erkunde zunächst ksql mit folgenden Befehlen

```
show topics;
show streams;
show tables;

# live view on topic
print 'twitter-table';
print 'twitter-raw';
```

## Stream auf Topic

Um für die weiteren Aufgaben immer alle Daten aus dem Stream von Anfang an zu lesen einmalig in der Session folgende Flag setzen

```
SET 'auto.offset.reset' = 'earliest';
```

Ein Stream ist eine Abstraktion auf das Topic mit einem Schema, was dynamische SQL Abfragen auf die Zeitreihe der Daten im Stream ermöglicht

```
CREATE STREAM twitter (tweet_id VARCHAR KEY, created_at VARCHAR, tweet_message VARCHAR, user_name VARCHAR,user_location VARCHAR, user_follower_count INT,user_friends_count INT, retweet_count INT,language VARCHAR, hashtags ARRAY<VARCHAR>) WITH (kafka_topic='twitter-table', value_format='json', partitions=2);
```

Jetzt können auf den Stream SQL Abfragen und Aggregation gemacht werden. Dabei gibt es zwei Modi. Ein einfaches SELECT gibt die Daten die im Aktuellen Fenster vom Stream sind wieder. Da wir zu Begin den Offset auf `earliest` gesetzt haben, werden alle Daten von Anfang bis jetzt im Stream einmal ausgegeben, wie in einer statischen Tabelle. Fügt man am Ende ein `emit changes` an bleibt die Abfrage offen und wird bei jedem neuen Event aktualisisert. Einige SQL Befehle funktionieren nur mit der Flag `emit changes`.
Probiere folgende Beispiele

### Aufgabe 3

Zeige Name, Land und Hashtags der Tweets an einmal statisch und einmal in Echtzeit an

<details>
<summary>Lösung</summary>
<p>

```
select user_name, user_location, hashtags from twitter;

select user_name, user_location, hashtags from twitter emit changes;
```

</details>
</p>

### Aufgabe 4

Schreibe eine Aggregationsabfrge die in Echtzeit die Anzahl der Tweets pro Land anzeigt.

<details>
<summary>Lösung</summary>
<p>

```
select language,count(*) as total from twitter group by language emit changes;
```

</details>
</p>

## Tabelle auf Stream

Eine Tabelle manifestiert eine Abfrage auf einen Stream

```
CREATE TABLE tweets_per_country AS
  SELECT language,count(*) as TOTAL
  FROM twitter
  GROUP BY language
  EMIT CHANGES;
```

```
SELECT * FROM tweets_per_country;

SELECT * FROM tweets_per_country emit changes;
```

Probiere die Tabelle zu sortieren, geht das überhaubt bei einme Stream, wenn ja wie würde das aussehen?

https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/quick-reference

### Aufgabe 5

Joine zwei Topics miteinander

Hierzu erstellen wir zuerst ein neues Topic über eine statische Tabelle

Erstelle eine Tabell (unter der Haube auch ein neues Topci)
Wichtig ist, dass beide topics die joined werden sollen die gleiche Anzahl an Partitionen haben

```
CREATE TABLE country_details (
  country VARCHAR PRIMARY KEY,
  population BIGINT
) WITH (topic = 'country-details',
   kafka_topic = 'country-details',
  value_format = 'JSON',
  partitions = 2
 );
```

und lade ein paar Werte hinein (messages)

```
 INSERINSERT INTO country_details (country, population) VALUES ('Germany', 83200000);
>INSERT INTO country_details (country, population) VALUES ('USA', 331000000);67200000);
>INSERT INTO country_details (country, population) VALUES ('United Kingdom', 67200000);
>INSERT INTO country_details (country, population) VALUES ('France', 67000000);;
>INSERT INTO country_details (country, population) VALUES ('India', 1393000000);
>INSERT INTO country_details (country, population) VALUES ('Spain', 47300000););
 INSERT INTO country_details (country, population) VALUES ('Brasil', 213000000);
```

Prüfe ob die Tabelle gefüllt ist

```
SELECT * FROM country_details EMIT CHANGES;
```

Prüfe ob das topic dazu erstellt wurde (dauert kurz bis sichtbar)

```
show topics;
```

sollte dann als `TWITTER_COUNTRY` sichtbar sein

```
Erzeuge jetzt einen neuen Stream enriched_tweets der die twitter tablle mit der country_details tabele anreichert.

```

CREATE STREAM enriched_tweets AS
SELECT
t.user_name,
t.user_location AS country,
c.population,
'all' as join_key
FROM twitter t
LEFT JOIN country_details c
ON t.user_location = c.country
EMIT CHANGES;

````
SELECT * FROM enriched_tweets EMIT CHANGES;


### Aufgabe 5 (Expert)

Eine komplexere Aufgabe.
Erzeuge eine Tabelle in der immer die Prozentuale Verteilung der Anzahl der Tweets über alle Länder dargestellt wird

Schritt 1: Erzeuge einen Helfer stream der für jede Nachricht eine Zeile erzeugt

```
CREATE STREAM tweet_counter AS
SELECT
'all' total_key,
1 dummy_value,
FROM enriched_tweets
EMIT CHANGES;
```
Check
```
SELECT * FROM tweet_counter EMIT CHANGES;
````

Schritt 2: Erzeuge eine Tabelle (Snappshot des letzten Zustandes) die alle Zeilen aggregiert und immer die Summe aller Tweets zeigt

CREATE TABLE total_tweet_count AS
SELECT
total_key,
COUNT(\*) AS total_tweets
FROM tweet_counter
GROUP BY total_key
EMIT CHANGES;

Schritt 3:
Jetzt können wir die beiden Tabellen zusammen joinen und den Prozentwert berechenn

SELECT
a.country,
a.tweet_count,
b.total_tweets,
a.tweet_count\*100/b.total_tweets as tweet_percentage  
FROM test1 a  
LEFT JOIN TOTAL_TWEET_COUNT b  
ON a.TOTAL_KEY = b.TOTAL_KEY
WHERE COUNTRY='Spain'
EMIT CHANGES;

### Aufgabe 6 (Expert)

Aggregation über ein Floating Window
Anstatt die Tweets per Country aggregation über den gesamten Stream laufen zu lassen (Historie) soll er diesmal nur über ein Zeitfenster von 30 Sekunden laufen
Es gibt 3 Arten von Zeitfenster
Tumbling window = fixed-sized and non-overlapping windows based on record timestamp
Hopping window = fixed-sized but possibly overlapping windows based on record timestamp
session window = Period of activity with gaps in between

```
  SELECT language,count(*) as total
  FROM twitter
  WINDOW TUMBLING (size 30 second)
  GROUP BY language
  EMIT CHANGES;
```

jetzt sollte die Anzahl nie besonders hoch werden pro Land da der Wert alle 30 Sekunden wieder zurückgesetzt wird.

### Aufgabe 7 (Expert)

Analysiere die Streams und Tabellen mit

```
DESCRIBE TABLE EXTENDED;
DESCRIBE STREAM EXTENDED;
```

Alle Streams und Tabellen die auf einer anderen Tabelle aufbauen (also alle außer dem ersten Stream TWITTER der direkt auf das bestehende Topic aufsetzt) sind im Prinzip Stream Processing Anwendungen die jede neue Nachricht aus einem Topic auslesen und dann wieder in ein neues Topic schreiben.
Die Topics die zu jedem Stream und jeder Tabelle erzeugt wurden sieht man über

SHOW TOPICS;

Die "Anwendungen" über
SHOW QUERIES;

d.h auf dem KSQL Server laufen nun zahlreiche Stream Processing Apps, die konstant alle Topics füllen

Da jetzt so schnell CPU und Memory voll laufen müssen wir diese wieder löschen und zwar nicht nur die App (Table oder Stream) sondern auch das damit erzeugte Topic.

Dies geht über

````
DROP STREAM <stream_name> DELETE TOPIC;
DROP TABLE <stream_name> DELETE TOPIC;
```
Wenn man nur den SELECT abschickt wird nur kurz ein SQL Prozes laufen gelassen und kein Topic erzeugt, dies nennt man auch non-persistent Queries. Sobald auf einem SQL aber einen Stream oder eine Tabelle erzeugt wird daraus ein persistent Querie mit einem Topic darunter


## Erläuterungern

LATEST_BY_OFFSET wird benötigt, um bei einer Aggregation auf den letzten bekannten Wert eines Feldes (z. B. population) zuzugreifen, da dieser sonst nicht in der SELECT-Liste erlaubt ist, wenn er nicht aggregiert oder gruppiert wird.


REQUEST-PIPELINING ON; kann nötig sein, wenn z.b. beim Löschen eines topics es etwas länger dauert und man Fehler bekommt bei einem neuen Query, dann kann man sich damit in der Execution Reihenfolge nach vorne drängeln


AM Ende DESCRIBE TWITTER EXTENDED; sehen wer den Stream verwendet

SHOW QUERIES - Persistant Background Queries are written in a new topic
````
