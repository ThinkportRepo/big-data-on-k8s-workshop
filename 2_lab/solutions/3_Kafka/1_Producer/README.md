# How to Setup Twitter Data Producer App

update from March 2023. The Twitter API has been turned down and we are currently working with a Mock Up Python based producer

## Resources

1. Python Script: twitter_data_producer.py
2. Kafka Raw Topic: TOPIC_twitter-raw.yaml
3. Dockerfile: build the image with the python file
4. Deployment: Yaml to create the producer pod

## Build Docker Image

```
# regular build & push
docker build -t thinkportgmbh/workshops:twitter-data-producer -f Dockerfile .
docker push  thinkportgmbh/workshops:twitter-data-producer


# crossbuild on Mac Book with M1 Chip
docker buildx build --push --platform linux/amd64 --tag thinkportgmbh/workshops:twitter-data-producer  -f Dockerfile.producer .
```

## Create Topic

Create the raw topic

```
kubectl apply -f TOPIC_twitter-raw.yaml
```

## Create Deployment

Create the raw topic

```
kubectl apply -f DEPLOY_twitter_data_producer.yaml
```
