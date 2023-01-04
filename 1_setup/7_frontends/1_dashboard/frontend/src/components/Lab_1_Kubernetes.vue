<template>
  <v-container>
    <v-row>
      <v-col cols="mb-12">
        <div class="text-h3">Kubernetes Aufgaben</div>
        <iframe
          frameborder="0"
          style="width: 100%; height: 400px"
          src="https://viewer.diagrams.net/?tags=%7B%7D&highlight=0000ff&edit=_blank&layers=1&nav=1&title=BigDataLab-BusinessCase.drawio#R7V1bd9o4EP41nLP70B5fsAOPhKTbbZM2XXK6277skW1hVIxFfQkhv34l%2BW4p4CSArG5eEizbQprRN%2FNJMxIDc7q6%2FyMC68U19mAwMDTvfmBeDAxDNwyb%2FKMl26zEMK2zrMSPkJc%2FVRXM0APMC7W8NEUejBsPJhgHCVo3C10chtBNGmUgivCm%2BdgcB81vXQMfcgUzFwR86d%2FISxZZ6cg4q8rfQ%2BQvim%2FW7XF2ZwWKh%2FOexAvg4U2tyLwcmNMI4yT7tLqfwoBKr5BL9t67R%2B6WDYtgmHR54erzx7%2F%2B%2FLL8cHHlr79ujfDhk3bxZpi3LdkWHYYe6X9%2BiaNkgX0cguCyKj2PcBp6kNaqkavqmSuM16RQJ4U%2FYJJsc2WCNMGkaJGsgvwuvEfJP7XP32hVb6386uI%2Br5ldbPMLvre5AGKcRi7c0cVi1IDIh8mO54zsOdr%2F2hfksvwD4hVMoi15IIIBSNBdc3yAfJj55XOVJsiHXBlPUExe7x0I0vybbjcoSWBECic3f3Jqaypls0AJnK0BE8yGQLOpgDkKgikOcMTeNT0LjrwhKY%2BTCC9h7c7IcEzb3iX%2BOxgl8H6nwPK7wxwHuSUY5ZebGqryokUNUMVbBxewpcrIJxKPtv%2FUL2pv0cvqNXb1csQYHRFj9goxZxxiPsw%2BfxJq%2BQo4xE81NAMC5Ifks0ukRUBmntOBjYgfmOQ3VsjzskEAY%2FQAHFYflfMaozBhnbHOB9aFUPK7RiCHoNKZ5V%2FS8BciZL3R3hJXO2rAq1BOZ9nntd%2FQ3lRVm8JKi%2FfxfB6TEdLWXNnC5yvT4JT5EcyXgBRNc0d%2FSAM4H7nQdUUG0BlZQ2snmrobQEOTZgG%2FGw%2FfgxV%2Bf3F%2F7WqXd999%2B7P%2BZvxqAfdYtroFFIqwXxbQfBQ0t3iN3IFhB6Qz5w7hELafMAHZP1PKP8%2BTjFz8G4FNVXhYkgHgaC7EmO2OoDM%2FFMnoF8sopjFyQFYB61vtzj6QVbj61oDVoUE27kgz%2BkXMxxzIJus1m5VSMaSsAg8kFHXzCK8o%2BA5H3A%2BAEH3URMgbg4eIbggwYh%2FLD%2BnGqyPa42D2OiJLFkZ2tbqGkZstUVBIyq6RG%2BEYRneI9Fs9DmfZe%2F2LEDyHcDA%2FxhM8di4f4rURLD6uIv%2B9t1KHxD0fAxaPAaEoRrIwIGzNUJepmed5%2FlNZta4aNc96ZdaKCfvz%2BbXS3PpM3gqemDe8cutHZXPWkTdIm8DuajXPrRcgYY3wUhfG9BOdpmo%2FYkYpGPPOe1oUtpEIPI%2BKzV3AFRiY76Sz8DaPkM%2FCC39VF34694FDLibVuhum85glDufITyMEiQiIiMGKSih04vWhLdt8PjfErM6zHds6UGiCmxPpmnR18CugTXUsoLtkg595Hu0OUT80W7CqlVOA2UMF8JOYhgJmxOJQe1PObDJTBah5usDukjp75fTAmaUe6GHI6WGWOqTgO6IxnAlv62OiOc0NEDVUkBitMIBRSO2UcurQtWFbH10nnMfTB%2B%2Bk9%2BjjAiQwBIRjbWMy5ddWiMKGSDqi9ouogPz9kK63iZKI0Y2W6Sr5rjQNWdpODZ3zGpp9uSK3L0MfhTDrfZzAhZqQGdtGB8hY4%2BMoRDiN5ZlViRWtmEF%2BrWROvkTzQEwdCSO7VB3uAkEPMiumXQ%2Bm5uDc9gPkLpaQqCBk7iiCYIVCP%2FNE9D3nYfOWPo6WEWXIs2zRLeb5muYjJ%2BGL26PkHKJ4TRoOWfvmrBVTSgdjxECceULmBmkXPoA7UF4wuJdtLItZ748S0ZXDG8sxVBtrtn0k8AvHGk8b91hnLq6uvNPkuOQpfaZ4Heu5Svmotip4Wi9dFU9mk8x8lgELDQTUtN5gT0F18Oxeujr4JdU96ih4Y93fZRyyvJM6GcUE6ZxCaDRT36aN%2Bgckm9Ncc3qcLbUZ2l%2FQR3HWGZeuWSgp%2FzOjLf9TzouF8n%2FyNEykEZWZPq8T6ZhQJ5PhUfnXIwu7oqx7Y3d6XmFPwrEjHi4CT8ImJodEwkmSEtreQXpSQhGZe8w53GzjXPhT7DFWFa7JhJdNZDNn%2FnkNI5AFG2K60KqkheK9tnSvoY9UsVBHzUrYabH2mzZpaQniKc3Zq05frNOhtAy6ne2u%2Bysa1jhPCYOmk5sqoaRF834DdxH%2B%2FaDW8jT7w7hgh3w3ticEWMRgWcBpisOEdl49NyWIMsn3U1K35%2FUmt0csm2FHm9avhEidX3qrZc5vIgIMpnDKxgdlDj27GZsvg9UxuNwpE3bE8tyzApNT6wkLvCK6ankL4mWsooFqx1hN6cI3XrcP76XHe%2B2TMeyVgSri5ir5nKfplE2lJ%2FRUDFIQ4hB21fMm%2FPf23Tb0rqbBQ7q%2B1bdn1zeigxXE1Hp8aDWzV0k%2FwLb2QL4Pu6q5tZV52GI51khrDZmsxmoAPW0f804sCNadsiBFmflyzCTKk6xCcVZaOn83FAT0yUikYPelCosdRbtrgPqEE%2BhgvMxSSgoiiVMWA2SriYRSegWXdLNJm2Q6yYFFPp80lNlKdnpKY3Sdchn9mnMZgnSHjstIHgwSoOQ60rBvezQNwb6W%2Bkztlh5Hw9LqspQFtp50QeVP%2F4ME0lRmFqklT4UldciyNrPE2nwnBjWAwPcj6JPBxbLSY3cRQeQoGT%2FRx53S0W2d16V%2BNGWaUvd19txMdg0Om1q%2FzCQfHb6NUIjrULuhFEI9Ut5Oh%2B6aDH08%2FChz5ODp8VPAYj9%2BpO3b3NnuZ9AMIqafKUxUJBqGoen9Ihqmwethd1KYeNtBez8IYxJZvr8DI8Aa4sMwTR6ocjcw8hgtWYIwr%2BcrilMQIEpLUppYoxz1IDpq6rYH20hMPhx5DRPggFjFk1Q4Ccv3THwycoOmT8otbJfEPDshiuNagCUj4CoO9B5ybD60tW%2FDRPwzGKidz9qOMJ50I%2BHO41cEB54smbyVMzptGVtdEx2ON9T5qUfD6FxR8tae1NfWApQf5vJjuabUhc9%2BhwmGnWck%2FQoTDPkZSWayNODMI3rm%2F4uQcwQcDKXnXAmOHOmys5888A5HK8CiLorvs%2BLDMvI3lew7iIQpYV5qoLbgm%2BfSBzD%2BVZQhHyP2q694VDZdg2Q9y7UWnDBThZS16uCSGKzWWZSGwaoINJdrW9nZP14Wt5HsXTjs9MC9CPb6%2Fl9SYeTPMywFExabhks%2FnuHqmgvTs%2Bh%2B0e4aoqYgjol5il5ogeQE7m1r2ESN4DSVE6NGsA2n24I6eeYTztbRJ2EMkgcVCVhbIaZ0J2LxcxSeDJcepYaG4mhEhQ8h4NUhfW5iSQ3m9psOW4Kz%2B0%2BUH%2F0ynQpOK3r5saLHGP%2FDrv7hEON%2FVwr8L%2FUzVe2AkC6Q8rHO%2BRYKmTf5v7rRgaH3nF0aXX%2FKatdQPtkmjep3Svfs0ygRXdSRdTl%2Fa0dFPJ9s15QJhatp%2F%2BYPcln9cGv2ePX7t%2Bblfw%3D%3D"
        ></iframe>
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
