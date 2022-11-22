# Jupyter Notebook Server

## Docker Images

The Spark Image we build is ready to be started with Jupyter.
Only thing to add is to start with a different entrypoint in order to start Jupyter instead of Spark
This is directly added in the deployment code?

```
# regular on amd64
docker build -t thinkportgmbh/workshops:jupyter -f Dockerfile.jupyter
docker push -t thinkportgmbh/workshops:jupyter

# crossbuild on mac m1 arm64
docker buildx build --push --platform linux/amd64 --tag thinkportgmbh/workshops:jupyter  -f Dockerfile.jupyter .
```

## Helm Install

```
helm upgrade --install -f values.yaml  jupyter -n frontend .
```
