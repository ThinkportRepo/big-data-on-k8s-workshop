# Dashboard App

Kleine Webapp um schnell auf alle Frontends des Labs zu kommen

## Webapp

Der Code liegt im Verzeichnis code und ist eine auf node bzw vue und vuetify basierende app
Details siehe in der README.md der app

## Docker Image

https://moreillon.medium.com/environment-variables-for-containerized-vue-js-applications-f0aa943cb962
Dieser Anleitung () gefolgt um ein Dockerimage zu bauen in dem dynamisch eine Variable, der DNS Name des K8S Clusters ausgetauscht werden kann

Der Docker build Befehl muss außerhalb des `docker` Verzeichnisses ausgeführt werden, damit der code entsprechend aus dem code Verzeichnis kopiert werden kann.
Das Shell Script `substitute_environment_variables` ersetzt die Key Words im Java Script Code mit dem Wert der Env Variable

```
docker build -t thinkportgmbh/workshops:dashboard -f docker/Dockerfile.vue .

# bzw.
docker buildx build --push --platform linux/amd64,linux/arm64 -t thinkportgmbh/workshops:dashboard -f docker/Dockerfile.vue .

# testen auf docker
docker run  -e K8S_HOST=k8s-cluster.io -p 8081:80 thinkportgmbh/workshops:dashboard

# öffnen unter http://localhost:8081

```

## Helm Chart

Der Helm Chart wird aus dem chart Verzeichnis installiert über

```
helm upgrade --install -f values.yaml  dashboard -n frontend .
```
