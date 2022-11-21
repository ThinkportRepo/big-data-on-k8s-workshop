# Kafka Setup on Kubernetes

helm repo add kafka-repo https://charts.bitnami.com/bitnami

first create a new namespace

```consol
create namespace kafka
```

then run helm

```consol
helm install my-release

helm upgrade --install kafka -f values.yaml  -n kafka kafka-repo/kafka

```

helm repo add my-repo https://charts.bitnami.com/bitnami
helm install kafka
