# Monitoring

## 1. Grafana

Öffne Grafana und klicke oben rechts auf das `+`-Symbol. Wähle `Import dashboard` aus und wähle `1_setup/11_prometheus_grafana/Dashboard.json` aus.

TODO:

* es ist nicht möglich, eine incomplete application anzuschauen. Führt zu einem Umleitungsfehler
* Dauert, bis man die Complete Applications sich anschauen kann, ohne auf den gleichen Umleitungsfehler wie oben zu stoßen
* Dataflint Integration funktioniert nicht -> Executor lost


## 2. Was ist Shuffling?
Beim Shuffeln werden die Daten über alle Maschinen neu verteilt bzw. organisiert. Dies geschieht dann, wenn Daten zwischen Partitionen ausgetauscht werden müssen.

### Beispiel
Wir haben einen DataFrame, in der eine Spalte die Werte "A" und "B" hat. Wir nehmen an, dass wir zwei Partitionen haben, in denen auch "A" und "B" hinterlegt sind. Nun wollen wir nach dieser Spalte gruppieren. Da "A" und "B" jedoch über die zwei Partionen hinweg verteilt sind, muss ein Shuffle stattfinden.

### Wann wird geshuffelt? 
* Bei Transformationen, bei denen alle Partitionen benötigt werden  (*wide transformations*)
* Bei Operationen wie z.B. join(), aggregate(), repartition(), groupBy(), sort()
### Wann wird nicht geshuffelt?
* Bei Transformationen, die pro Partition ausgeführt werden können, unabhängig von anderen Partitionen (*narrow transformations*)
* Bei Operationen wie z.B. filter(), select(), map()

### Probleme
* Teuer, da Daten über alle Executoren und Maschinen hinweg kopiert werden müssen, um die Daten neu zu verteilen
* Das resultiert z.B. in vielen Disk I/O und Network I/O Operationen, eine stärkere Auslastung
  des Garbage Collectors und kann viel Heap Memory belegen

### Ziel
Da Shuffeln viele Ressourcen und auch Zeit verbraucht, möchte man unnötiges Shuffling vermeiden.

## 3. Spark History Server

Mit dem Spark History Server können Spark-Applikationen überwacht werden. Der Spark History Server ist über das Workshop
Dashboard zu erreichen.

### 3.1 Sich vertraut machen mit dem Spark History Server

Führe mit `kubectl apply -f pi_example.yaml` ein kleine Sparkanwendung aus, die Pi berechnet. Der Source-Code kann
[hier](https://github.com/apache/spark/blob/master/examples/src/main/python/pi.py) gefunden werden.

Nachdem der Status auf `COMPLETE` springt (`kubectl get sparkapp -n spark`), sollte die Anwendung im History Server auftauchen,
ansonsten ist sie im History Server unter `Show incomplete applications` zu finden.

Gehe die verschiedenen Reiter durch, vor allem `Jobs`, `Stages` und `Executors`. 

#### Executors

`Executors` werden von der Spark-Applikation erstellt, die die Verarbeitung übernehmen.  
In dem Reiter erhälst du eine Gesamtübersicht über den Status der Tasks, sowie wie viel Speicher verwendet wurde und wie viele Shuffles es gab.

**Fragen**:
Wie viele Executors gibt es für unser Beispiel?

#### Jobs und Stages

- **Action**: Gibt einen Wert zurück, nachdem etwas auf einem Datenset berechnet wurde. Beispiele sind `collect`, `count`, `reduce`
- **Job**: Eine Spark-Applikation besteht aus Jobs. Für jede Action entsteht ein Job.
  Ein Job ist eine Sequenz an Transformationen, die ausgeführt werden muss, um bis zur Action zu kommen und diese selbst auszuführen. 
- **Stage**: Ein Job kann in Stages unterteilt sein. Eine Stage ist eine Sequenz an Tasks, welche parallel ausgeführt
  werden können ohne Shuffle. D.h. mit jedem Shuffle entsteht eine neue Stage.
- **Task**: Ein Task kann als eine Arbeitseinheit gesehen werden, die an einen Executor geschickt wird (gleich mit der Anzahl
  an Partitionen)

Schaue dir nun den Source-Code und den Job-Reiter genauer an. 

**Fragen**:
- Was davon sind Transformationen? 
- Was davon sind Actions? 
- Wieso haben wir nur einen Job und eine Stage?

### 3.2 Die Details einer Stage verstehen

Klicke nun auf die Stage, um die Details dazu zu sehen.

**Fragen**:
- Aus welchen Schritten besteht der DAG?
- Wie lange haben die Tasks jeweils ingesamt gedauert? Wie lange war jeweils der `Executor Computing Time`? 
  Betrachte dazu die Task-Tabelle und den bunten Balkengraphen.

## 4. Optimierungstechniken

### 4.1 Vorbereitung

Überprüfe mit `s3 ls`, ob der `data`-Bucket vorhanden ist. Falls nicht, führe folgende Befehle aus in VSCode:

```shell
s3 mb s3://data
s3 put /home/coder/git/2_lab/data/ s3://data --recursive
```

Für das Ausführen der folgenden Fälle wird folgender Befehl benötigt:

```
kubectl apply -f performance_test.yaml
```

Zusätzlich muss noch der Wert der Variable `app_name` jeweils angepasst werden.

### 4.2 Broadcasting

`broadcast` kann benutzt werden, um Variablen oder DataFrames in den Arbeitsspeicher von jedem Executor zu schicken.
Dies kann die Performance erhöhen, da dann nicht mit jeder Task eine Kopie mitgegeben werden muss.

Ein Anwendungfall wäre, wenn man einen großen DataFrame soll mit einem kleinen DataFrame joinen möchte.

Spark kann anhand von `spark.sql.autoBroadcastJoinThreshold` selbst entscheiden, wann ein DataFrame bei einem Join
gebroadcastet wird. Standardmäßig liegt der Wert bei 10MB. Dennoch kann es sich manchmal lohnen manuell zu broadcasten.

#### 4.2.1 Ausführen und vergleichen

Führe `performance_test.yaml` einmal mit `with_broadcast` und `without_broadcast` bei `app_name` aus. Bei `with_broadcast`
wird ein DataFrame explizit gebroadcastet, während bei `without_broadcast` der automatische Broadcast ausgeschaltet wurde.

**Fragen:**

- Was für Jobs sind jeweils entstanden?
- Gehe zum `SQL / DataFrame` Reiter und schaue dir jeweils den Eintrag dort an. Wo fand ein Shuffle statt und wo nicht?
- Was für ein Join wurde benutzt?

Tue nochmal das gleiche mit `auto_broadcast` als `app_name`. Schaue dir auch den Code an in `performance_test.py`,
um die Änderungen nachzuvollziehen.
Was hat sich bei `auto_broadcast` geändert?

### 4.3 Cache / Persist

Normalerweise werden RDDs und DataFrames immer neu berechnet. Mit den `.cache()` und `.persist()` Befehlen ist es
jedoch möglich diese in Speicher zu halten und somit die RDDs und DataFrames wiederzuverwenden, ohne dass eine erneute
Berechnung erfolgt. Der Unterschied zwischen den Befehlen ist, dass mit `.persist()` ausgewählt werden kann, welcher
Speicher benutzt wird. Mit `.unpersist()` kann dann der Speicher manuell wieder freigegeben werden.

Cachen kann sich dann lohnen, wenn auf einem RDD oder DataFrame viele Transformationen stattfinden und
man mit dem Endergebnis oft weiterarbeiten möchte. 

### 4.3.1 Ausführen und vergleichen

Führe `performance_test.yaml` bei `app_name` mit folgenden Werten aus:

- `with_cache_count`
- `without_cache_count`
- `with_cache_show`
- `without_cache_show`

Schaue dir die DAGs und die Zeiten im `SQL/DataFrame` Reiter an.

**Fragen**:

- Inwiefern unterscheiden sich die DAGs, wenn ein Cachen stattgefunden hat und wenn nicht?
- Wo hat sich das Cachen gelohnt und wo nicht?
- Inwiefern gab es Unterschiede, wenn statt `.count` `.show` ausgeführt wurde auf den finalen DataFrame?

### 4.4 Repartition / Coalesce

- **Repartition**: Wie der Name schon impliziert, werden mit diesem Befehl die Partitionen neu geshuffelt. Man kann 
  die Anzahl festlegen als auch Spalten, die zum Partitionieren genutzt werden sollen.
- **Coalesce**: Mit diesem Befehl kann die Anzahl der Partitionen reduziert werden, indem welche zusammengelegt werden.
  Es findet kein vollständiger Shuffle statt.

Mögliche Anwendungsfälle:

- Die Partitionen sind sehr unterschiedlich groß
- Die Daten der Spalten, auf denen man joinen möchte, sind nicht gleich verteilt
- Das Filtern bzw. Sortieren von bestimmten Spalten soll beschleunigt werden

#### 4.4.1 Ausführen und vergleichen

Führe `performance_test.yaml` aus mit `without_repartition` und `with_repartition` bei `app_name`.

Schaue dir die DAGs und die Zeiten im `SQL/DataFrame` Reiter an.

**Fragen**:

- Inwiefern unterscheiden sich die DAGs, wenn ein Repartition stattgefunden hat und wenn nicht?
