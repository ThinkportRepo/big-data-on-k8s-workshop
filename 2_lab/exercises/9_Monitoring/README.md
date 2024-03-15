# Monitoring

## Spark History Server

Folgendes hinzufügen zur `sparkConf`:

```
    "spark.eventLog.enabled": "true"
    "spark.eventLog.dir": "file:/tmp/spark-events"
```

Zur `spec` muss das hinzugefügt werden:

```
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: spark-history-server
```

Und zu `driver` und `executor`:

```
    volumeMounts:
      - name: data
        # default path the spark history server looks for logs
        mountPath: /tmp/spark-events
```

Siehe `pi_history_server.yaml` als Beispiel.

## Grafana

Öffne Grafana und klicke oben rechts auf das `+`-Symbol. Wähle `Import dashboard` aus und wähle `1_setup/11_prometheus_grafana/Dashboard.json` aus.

TODO:

* es ist nicht möglich, eine incomplete application anzuschauen. Führt zu einem Umleitungsfehler
* Dauert, bis man die Complete Applications sich anschauen kann, ohne auf den gleichen Umleitungsfehler wie oben zu stoßen
* Dataflint Integration funktioniert nicht -> Executor lost
