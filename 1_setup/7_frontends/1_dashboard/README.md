# Dashboard App

Die Dashboard App ist ein Frontend um die verschiedenen UI der Big Data Anwendungen die auf Kubernetes laufen zu öffnen.
Die App hat im Wesentlichen 3 Funktionalitäten
* Links auf die UIs
* Live Status der Pods (via Backend und Kube Proxy im Sidecar)
* Rendering der Markdown Dateien aus Github für die Lab Instructions

## Docker Image

https://moreillon.medium.com/environment-variables-for-containerized-vue-js-applications-f0aa943cb962
Dieser Anleitung () gefolgt um ein Dockerimage zu bauen in dem dynamisch eine Variable, der DNS Name des K8S Clusters ausgetauscht werden kann

Der Docker build Befehl muss außerhalb des `docker` Verzeichnisses ausgeführt werden, damit der code entsprechend aus dem code Verzeichnis kopiert werden kann.
Das Shell Script `substitute_environment_variables` ersetzt die Key Words im Java Script Code mit dem Wert der Env Variable

```
docker build -t thinkportgmbh/workshops:dashboard -f docker/Dockerfile.vue .

# bzw.
docker buildx build --push --platform linux/amd64,linux/arm64 -t thinkportgmbh/workshops:dashboard -f docker/Dockerfile.frontend .

docker buildx build --push --platform linux/amd64,linux/arm64 -t thinkportgmbh/workshops:backend -f docker/Dockerfile.backend .

docker buildx build --push --platform linux/amd64,linux/arm64 -t thinkportgmbh/workshops:kubeproxy -f docker/Dockerfile.sidecar .

# testen auf docker
docker run  -e K8S_HOST=k8s-cluster.io -p 8081:80 thinkportgmbh/workshops:dashboard

docker run  -e K8S_HOST=k8s-cluster.io -p 3030:3030 thinkportgmbh/workshops:backend


# öffnen unter http://localhost:8081

```

## Helm Chart

Der Helm Chart wird aus dem chart Verzeichnis installiert über

```
helm upgrade --install -f values.yaml  dashboard -n frontend .
```

## Architectur

![frontendArchitecutr drawio](https://user-images.githubusercontent.com/16557412/210658017-6423e9a7-5d88-4a0d-8cdb-b08ad777a431.png)

Das Frontend ist eine Vue bzw. Vuetify App die via Websocket (socket.io) auf ein Backend zugreift und von dort die Kubernetes API abfragt. 
Das Backend ist nötig, da wegen CORS Policy kein Zugriff direkt aus dem Frontend auf die Kubernetes API möglich ist.
Um die ganze Authentifizierung via Token auf die Kubernetes API zu vermeiden wird kubectl proxy in einem sidecar Container verwendet (in der Kubernetes Doku empfohlenes Vorgehen). 



Inspiriert von 
https://medium.com/@barnie_M/accessing-kubernetes-api-from-a-pod-using-kubectl-proxy-sidecar-fbb85781969f

## Verzeichnisstruktur
##### /backend
einfacher Express Server, der die Kubernetes API abfragt
##### /frontend
Vue App
##### /docker
Docker files für das Frontend, Backend und das Sidecar sowie startup Scripte, die die Variablen für jeden Cluster substituieren
##### /helm
Helm Chart um alles zu deployen

