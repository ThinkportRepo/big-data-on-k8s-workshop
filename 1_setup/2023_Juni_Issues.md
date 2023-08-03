- Jupyter Notebooks haben falsche Version von Spark. Alles auf spark-3.3.2 nachziehen - Done
- wundert mich, weil ich dachte ich habe alles auf Spark 3.3.2 gehoben - Done

# Spark Aufgaben
- Spark Data Format Aufgaben in Frontend einbinden - Done
- Spark Data Format Notebook erstellen - Done
- Spark SQL Aufgben entschlacken und Delta raus nehmen - Done


- Iceberg Tagging and Branching hinbekommen
- Iceberg CALL system functions hinbekommen
- Iceberg cleanup

- Spark Performance Noteboook erstellen 

# Cassandra
- Cassandra Aufgaben in Frontend einbinden und glatt ziehen - Done
- Alte Cassandra Anleitung entferne mit insert data via SELECT und insert automatisieren - Done


# Spark Streaming
- SparkStreaming an Prometheus anschließen

# Trino
- Delta Vacuum --> in Trino Done
- Cassandra Aufgabe auf Trino neu Aufgaben -> Done

# Allgemein:
- Lösungen ein und ausblenden - Done
- dynamisch network lokal beim build setzten

![TrinoAufgabe](
  
https://github.com/ThinkportRepo/big-data-on-k8s-workshop/assets/16557412/05a2db36-f70c-4c5e-81ef-a3e42f146468)

https://user-images.githubusercontent.com/16557412/227127231-f741be8f-67e4-42a2-be36-6fb5b9e24040.png

https://user-images.githubusercontent.com/16557412/05a2db36-f70c-4c5e-81ef-a3e42f146468.png


### Iceberg: Tagging und Branching

Funktioniert nicht

#### Tagging

Iceberg bietet die Möglickeit Snapshots mit einem bestimmten Tag zu versehen und diese später damit schneller zu finden.  
Beispiel: Immer am Monatsende wird ein Snapshot erstellt mit dem Tag EOM_April_2023, EOM_May_2023. Ab und zu wird die ganze Historie ausgedünnt und alle Snapshots entfernt die älter als 3 Monate sind außer die mit EOM getaggten. Damit liegt eine exakte Historie aller Operationen auf den Daten für die letzten 3 Monate vor und für ältere Zeitpunkte nur noch ein Snapshot pro Monat. Dies spart Speicher und das Tagging ermöglicht es den Clean up Jobs nicht alles zu entferen.

https://iceberg.apache.org/docs/latest/branching/
