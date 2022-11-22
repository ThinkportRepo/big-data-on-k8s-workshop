# Spark Setup on Kubernetes

## Build and push Docker image

First build and push the correct Spark image as exlained in the docker/Readme

## Install the Spark Operator

Details for the Spark Operator can be found at https://github.com/GoogleCloudPlatform/spark-on-k8s-operator
First ad the repo

```
helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
```

Then create a namespace for the spark jobs and a service account

```
# create the namespace for spark
k create namespace spark

# create serviceaccount
k create sa spark
```

And finally install the Spark Operator with the following options

```
helm upgrade spark spark-operator/spark-operator \
  --namespace spark-operator \
  --install \
  --create-namespace \
  --set webhook.enable=true \
  --set sparkJobNamespace=spark \
  --set image.tag=v1beta2-1.3.3-3.1.1 \
  --set serviceAccounts.spark.name=spark \
  --set ingress-url-format="\{\{$appName\}\}.4c13e49defa742168ff1.northeurope.aksapp.io"
```

### Test the Spark Operator

```
apiVersion: "sparkoperator.k8s.io/v1beta2"
kind: SparkApplication
metadata:
  name: sparktest
  namespace: spark
spec:
  serviceAccount: spark
  type: Python
  pythonVersion: "3"
  mode: cluster
  image: "docker.io/thinkportgmbh/workshops:spark-3.3.1"
  imagePullPolicy: Always
  mainApplicationFile: local:///opt/spark/examples/src/main/python/pi.py
  sparkVersion: "3.3.1"
  restartPolicy:
    type: OnFailure
    onFailureRetries: 0
    onFailureRetryInterval: 10
    onSubmissionFailureRetries: 1
    onSubmissionFailureRetryInterval: 20
  sparkConf:
    "spark.default.parallelism": "400"
    "spark.sql.shuffle.partitions": "400"
    "spark.serializer": "org.apache.spark.serializer.KryoSerializer"
    "spark.sql.debug.maxToStringFields": "1000"
    "spark.ui.port": "4045"
    "spark.storage.level": "MEMORY "
    "spark.driver.maxResultSize": "0"
    "spark.kryoserializer.buffer.max": "512"
  driver:
    cores: 1
    coreLimit: "1200m"
    memory: "512m"
    labels:
      version: 3.3.1
    serviceAccount: spark
  executor:
    cores: 1
    instances: 2
    memory: "512m"
    labels:
      version: 3.3.1
```
