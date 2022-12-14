# Kubernetes Aufgaben

In diesem Lab erkunden wird den Kubernetes Cluster und seine Ressourcen.
Öffne die App VSCode und dort das Terminal für die folgenden Aufgaben.

## 1. Nodes

Versuche mit den unten genannten kubectl-Befehlen folgende Fragen dir selbst zu beantworten:

- Wieviele Nodes (Knoten) hat der Cluster? <br>
- Welches Betriebssystem läuft auf den Nodes?<br>
- Wieviel Arbeitsspeicher hat jeder Node?<br>

```
# Nodes anzeigen
kubectl get nodes

# Nodes mit erweiterten Informationen anzeigen
kubectl get nodes -o wide

# Details der Nodes herausfinden
kubectl describe node <node-name>
```

---

## 2. Namespaces

Die Anwendungen in diesem Lab sind in verschiedenen Namespaces gruppiert.<br>
Verschaffe dir mit folgenden Befehlen einen Überblick über die Namespaces und welche Pods darin laufen.
Insbesondere über die Namespaces:

- mino
- kafka
- spark
- hive
- trino
- frontend

```
# alle Namespaces anzeigen
kubectl get namespaces

# Ressourcen, hier Pods in einem bestimmtem Namespace anzeigen
kubectl get pod --namespace <namespace>

# oder alles Ressourcen in einem Namespace anzeigen (-n ist die abgekürzte Version für --namespace)
kubectl get all -n <namespace>

# den namespace ändern, in dem man sich befindet (dann braucht es kein -n <spezieller-namespace> mehr)
kn default
```

---

## 3. Ingress Routes

Erkunde die DNS Adressen, die auf die verschiedenen Service und Pods mappen. <br>
Verschaffe dir mit folgenden Befehlen einen Überblick über die Routen im Namespace frontend.

```
# Ingress anzeigen
kubectl get ingress --all-namespaces

# kurz (-A ist die Abkürzung für --all-namespaces)
kubectl get ingress -A
```

---

## 4. Weitere Ressourcen

Erkunde mit dem gleichen Prinzip weitere Resourcen im Namespace frontend. <br>

```
# Services (eindeutige dns Namen innerhalb des Clusters | svc ist die Abkürzung von services)
kubectl get svc -n frontend
kubectl get services -n frontend

# Storage (Persistent Volume Claims, Reservierter Festplattenspeicher der in einen Pod gemounted werden kann | pvc ist die Abkürzung für persistenvolumeclaim)
kubectl get pvc -n frontend

# Deployments (Definieren Replikas von Pods | deploy ist die Abkürzung von deployment)
kubectl get deploy -n frontend

# Konfigurationen (Zentral abgelegte Konfigurationen, die von jedem Pod geladen werden können | cm ist die Abkürzungen von configmaps)
kubectl get cm -n frontend

# Secrets (Zentral abgelegte Secrets/Passwörter/Zertifikate, die von jedem Pod geladen werden können)
kubectl get secret -n hive
```

---

## 5. Detailbetrachtung eines Pods

Ein paar Befehle um die Kubernetes Ressourcen detailierter zu analysieren.

```
# Pods anzeigen in namespace frontend
kubectl get pod -n frontend

# Anzeigen der pod Definitionen
kubectl get pod <terminal-pod/vscode-pod/juypter-pod> -o yaml -n frontend

# oder filtern für einen Pod mit jsonpath für den ersten Pod
kubectl get pods -o jsonpath='{.items[0].spec.containers[0].volumeMounts[0]}'

# oder für alle Pods
kubectl get pods -o jsonpath='{.items[*].spec.containers[0].volumeMounts[0]}'

# oder mit (po ist die Abkürzung für pod)
kubectl get po  -o custom-columns=POD:.metadata.name,VOLUMES:.spec.containers[*].volumeMounts[0].name,MOUNTPATH:spec.containers[*].volumeMounts[0].mountPath

# oder alle Volumes pro Pod
kubectl get po  -o custom-columns=POD:.metadata.name,VOLUMES:.spec.containers[*].volumeMounts[*].name,MOUNTPATH:spec.containers[*].volumeMounts[*].mountPath
```

---

## 6. Erstellen eines Pods

Ein Pod entspricht einer Anwendungen die auf Kubernetes läuft. <br>
Pods können entweder direkt oder über Deployments erstellt werden. <br>
Deployments managen Replikationen und Ausfallsicherheit. Erstelle hierzu eine neue Datei mypod.yaml in VSCode mit folgendem Inhalt.

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  namespace: default
spec:
  restartPolicy: Never
  containers:
    - name: linux
      image: alpine:3.17
      command:
        - sh
        - "-c"
        - |
          apk add --no-cache curl;
          echo "Schauen wir mal ob wir den Service auf die Dashboard Website erreichen?";
          echo "##############################################";
          curl http://dashboard.frontend.svc.cluster.local:8081;
          echo "";
          echo "##############################################";
          echo "The End";

```

Anschließend können wir diesen Pod erstellen und die Logs ansehen. <br>

```
# Pod erstellen (im default namespace)
kubectl create -f mypod.yaml

# Schauen ob der Pod läuft (Tipp: bedenke in welchem namespace du dich befindest)
kubectl get pod

# Pod Logs checken
kubectl logs mypod

# Am Ende Pod wieder löschen
kubectl delete pod mypod
```

---

## 7. Deployment erstellen und skalieren

Um einen Pod zu replizieren und immer eine vorgegebene Anzahl von Pods am laufen zu haben wird die Resource Deployment erstellt. <br>
Im folgenden erstellen wir ein Deployment und skalieren dies. <br>
Erstelle hierzu eine neue Datei mydeploy.yaml in VSCode mit folgendem Inhalt.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mydeploy
  namespace: default
  labels:
    app: mydeploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mydeploy
  template:
    metadata:
      labels:
        app: mydeploy
    spec:
      containers:
        - name: linux
          image: alpine:3.17
          command:
            - sh
            - "-c"
            - |
              apk add --no-cache curl;
              echo "Schaun wir mal ob wir den Service auf die Dashboard Website erreichen?";
              echo "##############################################";
              curl http://dashboard.frontend.svc.cluster.local:8081;
              echo "";
              echo "##############################################";
              echo "The End";
              sleep 3000;
```

Anschließend folgendes Deployment erstellen und mit den Befehlen spielen. <br>

```
# Deployment erstellen (im default namespace)
kubectl create -f mydeploy.yaml

# Schauen ob das Deployment und der Pod laufen
kubectl get deploy
kubectl get pod

# Pod Logs checken
kubectl logs <mypod-xxxx>

# Deployment neu skallieren
kubectl scale deploy mydeploy --replicas=1

# Und prüfen ob die Pods auch heruntergefahren werden
kubectl get pod

# Am Ende das Deployment wieder löschen
kubectl delete deploy mydeploy

```
