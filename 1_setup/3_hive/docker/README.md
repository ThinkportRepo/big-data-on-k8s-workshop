# Build Hive Metastore Image

The Hive standalone Metastore image (`docker/Dockerfile.hive`) is completely self-made and needs to be build and pushed to a repository that can be referred from Kubernetes.

to build the image run one of the following commands

```
# regular build & push
docker build -t thinkportgmbh/workshops:hive-metastore -f Dockerfile.hive .
docker push  thinkportgmbh/workshops:hive-metastore


# crossbuild on Mac Book with M1 Chip
docker buildx build --push --platform linux/amd64,linux/arm64 --tag thinkportgmbh/workshops:hive-metastore  -f Dockerfile.hive .
```

The Docker image  is inspired from https://techjogging.com/standalone-hive-metastore-presto-docker.html
