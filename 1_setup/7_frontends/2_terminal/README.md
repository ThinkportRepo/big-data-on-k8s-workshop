# Terminal

We using the Web based Terminal xtermjs and in particular modifing the Docker Image from https://hub.docker.com/r/prairielearn/workspace-xtermjs/dockerfile with a new entry point script and some additional tools installed (kubectl, s3cmd, diagnostics)

## Docker Image

The s3cmd config is hard coded and copied into the container. This works well as only refered to fix service names
The kube config is dynamically created as secret and first mounted and then copied by the entrypoint.sh into the user folder
It has to be copied to allow it to be editable. We need a config file that can be edited to change default context and namespace

```
# build regular
docker build -t thinkportgmbh/workshops:terminal -f Dockerfile.terminal
docker push -t thinkportgmbh/workshops:terminal

# crossbuild on mac m1 arm64
docker buildx build --push --platform linux/amd64,linux/arm64 --tag thinkportgmbh/workshops:terminal  -f docker/Dockerfile.terminal .
```

## Helm Install

```
helm upgrade --install -f values.yaml terminal -n frontend .
```
