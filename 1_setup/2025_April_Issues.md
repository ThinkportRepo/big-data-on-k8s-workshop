# Probleme und Verbesserungen

## Issues

- VisualCode nicht mehr Dark
  - Option in Configmap setzten - Done

## Features

- Iceberg Tagging and Branching hinbekommen
- Hudie richtig zum laufen bekommen

- SparkStreaming an Prometheus anschließen

- History Server auf s3 mounten und in allen Apps zu laufen bekommen

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
