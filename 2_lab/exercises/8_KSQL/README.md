# Kafka SQL (KSQL) Aufgaben

Entweder als Demo oder Bonusaufgabe wenn Zeit

SQL Auswertungen auf den Topics bzw. einem Stream Objekt

### KSQL CLI

KSQL kann aktuell nur über die `Kafka Streams` Java Bibliothek, die ksql-cli oder die Weboberfläche von Confluent angesprochen werden.
Die ksql-cli läuft direkt auf dem KSQL-Server und kann aus dem VSCode Terminal gestartet werden

```
kubectl exec -it ksqldb-0 -n kafka -- ksql


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
CREATE TABLE twitter_country AS
  SELECT language,count(*) as TOTAL
  FROM twitter
  GROUP BY language
  EMIT CHANGES;
```

```
SELECT * FROM twitter_country;

SELECT * FROM twitter_country emit changes;
```

Probiere die Tabelle zu sortieren, geht das überhaubt bei einme Stream, wenn ja wie würde das aussehen?

https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/quick-reference
