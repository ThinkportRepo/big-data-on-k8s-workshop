# How to Setup Twitter Data Converter App

## Resources

1. Python Script: twitter_data_converter.py
2. Kafka Raw Topic: TOPIC_twitter-table.yaml
3. Dockerfile: build the image with the python file
4. Deployment: Yaml to create the producer pod

## Build Docker Image

```
# regular build & push
docker build -t thinkportgmbh/workshops:twitter-data-converter -f Dockerfile .
docker push  thinkportgmbh/workshops:twitter-data-converter


# crossbuild on Mac Book with M1 Chip
docker buildx build --push --platform linux/amd64 --tag thinkportgmbh/workshops:twitter-data-converter -f Dockerfile.converter .
```

## Create Topic

Create the raw topic

```
kubectl apply -f TOPIC_twitter-table.yaml
```

## Create Deployment

Create the raw topic

```
kubectl apply -f POD_twitter_data_converter.yaml
```
