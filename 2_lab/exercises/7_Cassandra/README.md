# Cassandra Aufgaben

### 1) Cassandra Shell CQL

Cassandra hat eine eigene Abfrage Sprache änlich der SQL Sprache die CQL (Cassadra Query Language).
Mit der CQL-Shell (cqlsh) kann der Cassandra Cluster gemanaged werden und die Daten abgefragt werden.

Die CQL-Shell aus dem VSCode Terminal direkt gestartet werden über

```
cqlsh <cassandra-service-name>.<namespace>.svc.cluster.local
```

Jetzt kann Cassandra erkundet werden. Unter folgendem Link findet sich eine Übersicht aller CQL Commands

https://cassandra.apache.org/doc/latest/cassandra/tools/cqlsh.html

Probiere folgende Abfragen

```
DESCRIBE CLUSTER

DESCRIBE KEYSPACES

DESCRIBE TABLES

# Daten aus einer Tabelle können über (fast) standard SQL abgefragt werden
SELECT * FROM <keyspace-name>.<table-name>
```

Verlassen von cql via

```
exit
```

### 2) Stammdaten nach Cassandra laden

Im nächsten Schritt sollen einige Stammdaten, welche die Twitter Daten ergänzen sollen nach Cassandra geladen.
Diese Daten werden mit einem Jupyter Notebook erzeugt und nach Cassandra geschrieben.

Öffne hierzu das Notebook in `git/2_lab/exercises/Insert_Country_Data_Cassandra.ipynb` und finde und ergänze die richtige Kubernetes interne Adresse des Cassandra Clusters (wie das Patern geht wurde bereits in den Kafka Aufgaben viel geübt)

Führe die Zellen aus und überprüfe mit der CQL-Shell ob die Daten korrekt in die Datenbank geschrieben wurden

### 3) Mit Trino auf Cassandra zugreifen

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
SELECT * FROM countries.country_population

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
SELECT a.user_location as "country", a.population, a.gdp_per_capita as "gdp" , count(*) as "TweetCount" FROM
(
    SELECT delta.user_name,delta.created_at,delta.user_location,delta.language, cassandra.population, cassandra.gdp_per_capita FROM delta.data.twitter delta
    LEFT JOIN (
        SELECT
        code,
        population,
        json_value(economic_indicators,'lax $.gdp_per_capita.value' RETURNING int) AS gdp_per_capita
        FROM cassandra.countries.country_population
    ) cassandra
    ON delta.language=cassandra.code
    ) a
GROUP BY a.user_location, a.population, a.gdp_per_capita
ORDER BY a.population
```

</details>
</p>
