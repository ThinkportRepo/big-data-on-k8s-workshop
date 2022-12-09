# VSCode on Kubernetes

This Setup is forked from https://github.com/gashirar/code-server-on-kubernetes and runs the Theia IDE with VS Code Web from https://github.com/cdr/code-server

The executable is only available for amd64, so it can't be build running on docker on mac

## Build and push Docker Image

```
# regular on amd64
docker build -t thinkportgmbh/workshops:vscode -f Dockerfile.vscode
docker push -t thinkportgmbh/workshops:vscode

# crossbuild on mac m1 arm64
docker buildx build --push --platform linux/amd64 --tag thinkportgmbh/workshops:vscode  -f Dockerfile.vscode .
```

Authentication default password is `P@ssw0rd`.
You can overwrite password by environment variables.(`PASSWORD`)

### Install on Kubernetes

check if namespace `frontent` exists and if not create

```
k create namespace frontend
```

set values in `value.yaml` file of the chart in case they should be changed.
Install Helm Chart

```
cd chart
helm upgrade --install -f values.yaml  vscode -n frontend .
```

### Add Secrets and Configmaps

kubectl create secret generic kube-config --from-file=config -n frontend

### local test on amd64 linux

This script pulls the image and runs Theia IDE on https://localhost:8443 with the current directory as a workspace.

```
docker run -it -p 127.0.0.1:8080:8080 -v "$PWD:/home/coderi/project" -u "$(id -u):$(id -g)" thinkportgmbh/workshops:vscode
```

### Fehler fixen

Sollte die auto vervollständigung nicht funktionieren und den Fehler
`podbash: _get_comp_words_by_ref: command not found` schmeißen, kann dieser behoben werden durch

```
source /usr/share/bash-completion/
```
