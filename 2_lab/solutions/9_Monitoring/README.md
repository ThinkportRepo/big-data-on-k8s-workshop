# Monitoring

### 3.1 Sich vertraut machen mit dem Spark History Server

**Fragen**:
- Wie viele Executors gibt es für unser Beispiel?
- Was davon sind Transformationen?
- Was davon sind Actions?
- Wieso haben wir nur einen Job und eine Stage?
- Aus welchen Schritten besteht der DAG?
- Wie lange haben die Tasks jeweils ingesamt gedauert? Wie lange war jeweils der `Executor Computing Time`?

<details>
<summary>Lösung</summary>
<p>

- Wie viele Executors gibt es für unser Beispiel?
  - 1 
- Was davon sind Transformationen?
  - parallelize, map
- Was davon sind Actions?
  - reduce
- Wieso haben wir nur einen Job und eine Stage?
  - Es gibt nur eine Action und es gibt kein Shuffle
- Aus welchen Schritten besteht der DAG?
  - Parallellize - Reduce
- Wie lange haben die Tasks jeweils ingesamt gedauert? Wie lange war jeweils der `Executor Computing Time`?
  - Insgesamt ~5s
  - Task 1: ~2s, Task 2: ~0.3s (grüner Balken)
</p>
</details>


## 4.2 Broadcasting

#### 4.2.1 Ausführen und vergleichen

Führe `performance_test.yaml` einmal mit `with_broadcast` und `without_broadcast` bei `app_name` aus. Bei `with_broadcast`
wird ein DataFrame explizit gebroadcastet, während bei `without_broadcast` der automatische Broadcast ausgeschaltet wurde.

**Fragen:**

- Was für Jobs sind jeweils entstanden?
- Gehe zum `SQL / DataFrame` Reiter und schaue dir jeweils den Eintrag dort an. Wo fand ein Shuffle statt und wo nicht?
- Was für ein Join wurde benutzt?

Tue nochmal das gleiche mit `auto_broadcast` als `app_name`. Was hat sich bei `auto_broadcast` geändert?

<details>
<summary>Lösung</summary>
<p>

- Was für Jobs sind jeweils entstanden?
  - `without_broadcast`: 3 Jobs (3x `showString`)
  - `with_broadcast`: 2 Jobs (`broadcast exchange` und `showString`)
- Wo fand ein Shuffle statt und wo nicht?
  - `without_broadcast`: Beide DFs werden geshuffelt
  - `with_broadcast`: Kein Shuffle
- Was für ein Join wurde benutzt?
  - `without_broadcast`: SortMergeJoin
  - `with_broadcast`: BroadcastHashJoin
- Was hat sich bei `auto_broadcast` geändert?
  - Beide Pläne verwenden nun BroadcastHashJoin, aber es finden immer noch Shuffles statt, wenn nicht explizit
  `broadcast` angegeben wurde.
</p>
</details>


### 4.3 Cache / Persist

### 4.3.1 Ausführen und vergleichen

**Fragen**:

- Inwiefern unterscheiden sich die DAGs, wenn ein Cachen stattgefunden hat und wenn nicht?
- Wo hat sich das Cachen gelohnt und wo nicht?
- Inwiefern gab es Unterschiede, wenn statt `.count` `.show` ausgeführt wurde auf den finalen DataFrame?

<details>
<summary>Lösung</summary>
<p>

- Inwiefern unterscheiden sich die DAGs, wenn ein Cachen stattgefunden hat und wenn nicht?
  - Wenn gecached wurde, wird bei nachfolgenden Transformation auf das gecachte DF im Speicher zurückgegriffen (InMemoryTableScan)
- Wo hat sich das Cachen gelohnt und wo nicht? 
  - Cachen hat sich bei allen 4 Fällen nicht gelohnt bei `transformed_df.count()`, da es sogar länger dauert das DF
    in den Speicher zu laden als alles neu zu berechnen.
- Inwiefern gab es Unterschiede, wenn statt `.count` `.show` ausgeführt wurde auf den finalen DataFrame?
  - Beim Cachen mit `.count` gab es auch bei der finalen Operation keine besonderen Unterschiede was die Geschwindigkeit angeht,
  jedoch bei `.show` schon, wenn nur 1 Executor existiert.
  - Bei `.count` wird bei beiden Plänen (Cache und Nicht-Cache) das komplette kartesische Produkt ermittelt.
  - Bei `.show` wird bei beiden Plänen (Cache und Nicht-Cache) nicht das komplette kartesische Produkt ermittelt, da das
    nicht nötig ist, um ein paar Zeilen anzuzeigen.

</p>
</details>

### 4.4 Repartition / Coalesce

#### 4.4.1 Ausführen und vergleichen

**Fragen**:

- Inwiefern unterscheiden sich die DAGs, wenn ein Repartition stattgefunden hat und wenn nicht?

<details>
<summary>Lösung</summary>
<p>

`without_partition`:

- Die CSV wird nicht komplett eingelesen
- Es werden 200 Partitions geshuffelt und dann zu einer zusammengelegt

`with_partition`:

- Die CSV wird komplett eingelesen
- Es entstehen 5 Partitionen

Keine Änderung bei der Geschwindigkeit. Hier ist es schlauer nicht zu partitionieren

</p>
</details>
