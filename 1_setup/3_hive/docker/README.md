# Build Hive Metastore Image

to build run

```
docker build -t thinkportgmbh/workshops:hive-metastore -f Dockerfile.hive .
```

to push run

```
docker push  thinkportgmbh/workshops:hive-metastore
```

to build and push the arm64 image on a Mac Book with m1 chip (arm64) build the image via crossbuild

```
docker buildx build --push --platform linux/amd64,linux/arm64 --tag thinkportgmbh/workshops:hive-metastore  -f Dockerfile.hive .
```
