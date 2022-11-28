# Metabase BI Tool

## Build Docker Image

Need to build the image in order to add the starburst trino driver
https://github.com/starburstdata/metabase-driver

```
# regular build & push
docker build -t thinkportgmbh/workshops:metabase -f Dockerfile.connect .
docker push  thinkportgmbh/workshops:metabase


# crossbuild on Mac Book with M1 Chip
docker buildx build --push --platform linux/amd64,linux/arm64 --tag thinkportgmbh/workshops:metabase -f Dockerfile.metabase .
```

```
helm upgrade --install metabase -f values.yaml .
```
