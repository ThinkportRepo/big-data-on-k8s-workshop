# How to create Stream Mikroservice App

## Build Docker Image

```
# regular build & push
docker build -t thinkportgmbh/workshops:twitter-data-converter -f Dockerfile .
docker push  thinkportgmbh/workshops:twitter-data-converter


# crossbuild on Mac Book with M1 Chip
docker buildx build --push --platform linux/amd64 --tag thinkportgmbh/workshops:twitter-data-converter  -f Dockerfile .
```
