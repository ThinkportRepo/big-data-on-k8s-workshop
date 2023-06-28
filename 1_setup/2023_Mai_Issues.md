# Issues found during Workshop

1. Im Chart/TF wird latest Minio Version verwendet. Die aktuell funktioniert aber nicht mehr
   INTERIMS LÖSUNG: Mit alter Version via Tag explizit geladen
   TODO: Überoprüfen ob es auch mit aktueller Version funktionert

2. Zertifikat für Student10 fehlt (PRIO 1)
   DONE: Zertifikat neu erstellen, alle neu oder einzelnes neu

3. kn geht nicht wegen Schreibrechte Problem (PRIO 1)
   DONE: gefixed durch copy nach .kube statt mounten einer configmap (no write on cm)

4. Abweichungen von README in git zu README in UI (PRIO 1)
   Aufgabe 4 Kafka z.B. nimmt Ergebnisse schon vorweg
   TODO: Überprüfen und fixen

5. Jupyter Image neu bauen mit korrekten Driver Jars und Cassandra Modul (PRIO 1)
   DONE: alles auf Spark 3.3.2 gehoben, alle Jars angepasst

6. Delta Driver für Spark Image checken, versionen falsch? (PRIO 1)
   DONE: alles auf Spark 3.3.2 gehoben, alle Jars angepasst

7. Versionsfehler von Kafka-Client in dem Spark-Streaming Notebook? (PRIO 1)
   DONE: alles auf Spark 3.3.2 gehoben, alle Jars angepasst

8. History Server zu Notebook Spark hinzufügen (PRIO 1)
   TODO: mounten und verproben für SparkSQL Aufgabe

9. BigData Aufgabe mit Performance Optimierung erstellen

   - Big Data Set erzeugen mit typischen Problemen (skew, zu viele kleine, zu große Dateien)
   - History Server Analyse
   - Grafana Analyse
   - Verschieden Optimierungen und Zeitersparnis testen

10. Perfektes Monitoring Dashboard erstellen und in Aufgaben einbinden

    - CPU absolut sicht auf den gesamten Cluster und per Node auf einen Blick um zu sehen ob die Spark Pods noch vergrößert werden können

11. Beispiel Lab für History Server Analyse

12. Beispiel für Job Scheduling

    - Sheduling Spark via Operator
    - Spark via Airflow
    - Trino SQL via Airflow

13. User Dashboard

    - Neue Aufgaben einbinden
    - Warte Screen auf Landing Page

14. Admin Dashboard Erstellen

    - Online oder Lokale Erweiterung
    - Ein Blick auf alle Cluster
    - Cluster Status, erzeugt, an, aus
    - App Status sind alle grün
    - Probe tests durchgelaufen wie
      - geht s3 ls
      - geht kubectl get po
      - geht kn
      - geht kafka
      - geht cassandra
      - geht ksql
    - Costen Anzeige, Gesamtkosten Worksop, jeder Teilnehmer
    - Architektur:
      - Ordner mit Resourcen nur für Admin Cluster
      - Ingress für Kafka Broker/Rest Endpunkt 9092
      - Topic für Cluster Infos
      - Crawler Pod auf jedem Cluster
      - Pod sendet Status aller Pods an Topic (Python und Sidecar?)
      - Backend muss Topic aus Rest Endpunkt des Trainer Clusters holen
      - Auf Trainer Cluster Pod mit AWS CLI und korrekter Authentifizierung um az Status abzurufen
      - AKS Status an weiteres Topic senden
      - Alles in zwei Dashboards visualisieren nur für Admins
    - Vorgehen für PoC:
      - Checken ob von außen über Ingress und 8080:9092 auf Kafka geschrieben werden kann
      - Checken vom JavaScript Backend auf den RestEndpunkt zugegriffen werden kann

15. Admin Helper

    - git pull bei allen auslösen (shell script)
    - spezielles kubectl command auf allen Clustern ausführen (delete po)

16. alle Branches platt machen, neuen dev aus checken

chfolgend sende ich Ihnen die Teilnehmerliste für das Seminar Big Data Praxis Vertiefung vom 15.05.-16.05.23 für DB Systel, Trainer Alex Ortner.

Performance Tuning Case

Datenquelle eventuell
https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
Fake Datenset: https://medium.com/@danny.bharat/polars-and-spark-100-million-row-dataset-18fd29f46d2c
Join Optimierung: https://medium.com/@guediagael/optimizing-pyspark-dataframe-joins-for-large-data-sets-e63eed349bcd
Partitionierung https://medium.com/data-engineer-things/supercharging-performance-with-partitioning-in-databricks-and-spark-part-1-3-aebcfb48c3b
Salting: https://towardsdev.com/salting-for-data-skew-58fa59d65def
