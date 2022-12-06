<template>
  <v-container>
    <v-row>
      <v-col cols="mb-12">
        <div class="text-h3">Kubernetes Aufgaben</div>

        <div class="text-body-1">
          In diesem Lab erkunden wird den Kubernetes Cluster und seine Resourcen
          <br />
          Öffne die App VSCode und dort das Terminal für die folgenden Aufgaben
        </div>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="mb-12">
        <div class="text-h6 mt-5">1. Nodes</div>
        Beantworte mit den unten geannten <code>kubectl</code>-Befehlen folgende
        Fragen:
        <ol class="ma-2">
          <li>Wieviele Knoten hat der Cluster</li>
          <li>Welches Betriebssystem läuft auf den Nodes</li>
          <li>Wieviele Arbeitsspeicher hat jeder Knoten</li>
        </ol>

        <pre>
# Nodes anzeigen
kubectl get nodes 

# Nodes mit erweiterten Informationen anzeigen
kubectl get nodes -o wide     
        </pre>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="mb-12">
        <div class="text-h6 mt-5">2. Namespaces</div>
        Die Anwendungen in diesem Lab sind in verschiedenen Namespaces
        grupiert.<br />
        Verschaffe dir mit folgenden Befehlen einen Überblick über die
        Namespaces und welche Pods darin laufen

        <pre>
# alle Namespaces anzeigen
kubectl get namespaces

# Resourcen, hier Pods in einem bestimmtem Namespace anzeigen
kubectl get pod --namespace _NAMESPACE_

# oder alles Resourcen in einem Namespace anzeigen
kubectl get all -n _NAMESPACE_  </pre
        >
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="mb-12">
        <div class="text-h6 mt-5">3. Ingress Routes</div>
        Erkunde die DNS Adressen die auf die verschiedenen Service und Pods
        mappen<br />
        Verschaffe dir mit folgenden Befehlen einen Überblick über die Routen im
        Namespace <code>frontend</code>
        <pre>
# show ingress
kubectl get ingress -n frontend</pre
        >
      </v-col></v-row
    >
    <v-row>
      <v-col cols="mb-12">
        <div class="text-h6 mt-5">4. Weitere Resourcen</div>
        Erkunde mit dem gleichen Prinzip weitere Resourcen im Namespace
        frontend<br />
        <pre>
# Services (eindeutige dns Name innerhalb des Clusters)
kubectl get services -n frontend

# Storage (Persistent Volume Claims, Reservierter Festplattenspeicher 
# der in einen Pod gemounted werden kann)
kubectl get pvc -n frontend

# Deployments (Definieren Replicas von Pods)
kubectl get deploy -n frontend

# Configurationen (Zentral abgelegte Configurationen, die von jedem Pod geladen werden können)
kubectl get configmaps -n frontend

# Secrets (Zentral abgelegte Secrets/Passwörter/Certificate, die von jedem Pod geladen werden können)
kubectl get secret -n hive
</pre
        >
      </v-col></v-row
    >

    <v-row>
      <v-col cols="mb-12">
        <div class="text-h6 mt-5">5. Detailbetrachtung eines Pods</div>
        Ein paar Befehle um die Kubernetes Resourcen detailierter zu analysieren
        <br />
        <pre>
# get pod names
kubectl get pod -n frontend

# show pod definiton
kubectl get pod __POD_NAME__ -o yaml -n frontend

# or filter out for one pod with jsonpath for the first pod
kubectl get pods -o jsonpath='{.items[0].spec.containers[0].volumeMounts[0]}'

# or for all pods
kubectl get pods -o jsonpath='{.items[*].spec.containers[0].volumeMounts[0]}'

# or select only some columns
k get po  -o custom-columns=POD:.metadata.name,VOLUMES:.spec.containers[*].volumeMounts[0].name,MOUNTPATH:spec.containers[*].volumeMounts[0].mountPath

# or all volumes per pod
k get po  -o custom-columns=POD:.metadata.name,VOLUMES:.spec.containers[*].volumeMounts[*].name,MOUNTPATH:spec.containers[*].volumeMounts[*].mountPath
        </pre>
      </v-col>
    </v-row>

    <v-row>
      <v-col cols="mb-12">
        <div class="text-h6 mt-5">6. Erstellen eines Pods</div>
        Ein Pods entspricht einer Anwendungen die auf Kubernetes läuft. <br />
        Pods können entweder direkt oder über Deployments erstellt werden.<br />
        Deployments managen Replikationen und Ausfallsicherheit. Erstelle hierzu
        eine neue Datei <code>mypod.yaml</code> in VSCode mit folgendem Inhalt
        erstellen
        <br />
        <pre>
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  namespace: frontend
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
     </pre
        >
        Anschließend diesen Pod erstellen und die Logs ansehen
        <pre>
# Pod erstellen (im default namespace)
kubectl create -f mypod.yaml 

# Schauen ob der Pod läuft
kubectl get pop

# Pod Logs checken 
kubectl logs mypod 

# Am Ende Pod wieder löschen
kubectl delete pod mypod
     </pre
        >
      </v-col>
    </v-row>

    <v-row>
      <v-col cols="mb-12">
        <div class="text-h6 mt-5">7. Deployment erstellen und skalieren</div>
        Um einen Pod zu replizieren und immer eine vorgegebene Anzahl von Pods
        am laufen zu haben <br />
        wird die Resource Deployment erstellt. Im folgenden erstellen wir ein
        Deplyment und skalieren dies. <br />
        Erstelle hierzu eine neue Datei <code>mydeploy.yaml</code> in VSCode mit
        folgendem Inhalt erstellen
        <br />
        <pre>
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
     </pre
        >
        Anschließend folgendes Deployment erstellen und mit den Befehlen spielen
        <pre>
# Deployment erstellen (im default namespace)
kubectl create -f mydeploy.yaml 

# Schauen ob das Deployment und der Pod laufen
kubectl get deploy
kubectl get pod

# Pod Logs checken 
kubectl logs mypod-xxxx

# Deployment neu skallieren
kubectl scale deploy mydeploy --replicas=1

# Und prüfen ob die Pods auch heruntergefahren werden
kubectl get pod

# Am Ende das Deployment wieder löschen
kubectl delete deploy mydeploy
     </pre
        >
      </v-col></v-row
    >
  </v-container>
</template>

<script>
export default {
  name: "Excersises",

  data: () => ({
    host: "VUE_APP_K8S_HOST",
  }),
};
</script>
<style scoped>
pre {
  background: #f4f4f4;
  border: 1px solid #ddd;
  border-left: 3px solid #f36d33;
  color: #666;
  page-break-inside: avoid;
  font-family: monospace;
  font-size: 15px;
  line-height: 1.6;
  margin-bottom: 1.6em;
  max-width: 80%;
  overflow: auto;
  padding: 1em 1.5em;
  display: block;
  word-wrap: break-word;
}
</style>
