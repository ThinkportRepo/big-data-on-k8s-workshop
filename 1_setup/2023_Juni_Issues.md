- Jupyter Notebooks haben falsche Version von Spark. Alles auf spark-3.3.2 nachziehen
- wundert mich, weil ich dachte ich habe alles auf Spark 3.3.2 gehoben

- Spark Data Format Aufgaben in Frontend einbinden
- Cassandra Aufgaben in Frontend einbinden und glatt ziehen
- Alte Cassandra Anleitung entferne mit insert data via SELECT und insert automatisieren

- Spark SQL Aufgben entschlacken und Delta raus nehmen

- Iceberg Tagging and Branching hinbekommen
- Iceberg CALL system functions hinbekommen

  - cleanup

- Delta Vacuum

### Iceberg: Tagging und Branching

Funktioniert nicht

#### Tagging

Iceberg bietet die Möglickeit Snapshots mit einem bestimmten Tag zu versehen und diese später damit schneller zu finden.  
Beispiel: Immer am Monatsende wird ein Snapshot erstellt mit dem Tag EOM_April_2023, EOM_May_2023. Ab und zu wird die ganze Historie ausgedünnt und alle Snapshots entfernt die älter als 3 Monate sind außer die mit EOM getaggten. Damit liegt eine exakte Historie aller Operationen auf den Daten für die letzten 3 Monate vor und für ältere Zeitpunkte nur noch ein Snapshot pro Monat. Dies spart Speicher und das Tagging ermöglicht es den Clean up Jobs nicht alles zu entferen.

https://iceberg.apache.org/docs/latest/branching/
