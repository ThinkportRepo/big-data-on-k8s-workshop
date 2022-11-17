# Minio and s3 Setup on Kubernetes

Using the official Minio Helm Chart to setup s3 endpoint on Kubernetes

Official Repository: https://github.com/minio/minio/tree/master/helm/minio

# Installation Steps

Download values yaml file from Chart Repo to modify

```
curl https://raw.githubusercontent.com/minio/minio/master/helm/minio/values.yaml -O
```

change values accordingly to the requirements. Important settings

- set rootUser and rootPassword
- set memory request correctly to the node size
- set replicas correctly to the node size
- set k8s host
- set ingress route for console service
- set user
- set buckets

Create Namespace

```
kubectl create namespace minio
```

Add Helm Repo and install Chart with custum values

```
helm repo add minio https://charts.min.io/
helm repo update

helm upgrade --install -f values.yaml minio minio/minio -n minio

helm uninstall minio -n minio
```

Installation should finish with

```
MinIO can be accessed via port 9000 on the following DNS name from within your cluster:
minio.minio.svc.cluster.local

To access MinIO from localhost, run the below commands:

  1. export POD_NAME=$(kubectl get pods --namespace minio -l "release=minio" -o jsonpath="{.items[0].metadata.name}")

  2. kubectl port-forward $POD_NAME 9000 --namespace minio

Read more about port forwarding here: http://kubernetes.io/docs/user-guide/kubectl/kubectl_port-forward/

You can now access MinIO server on http://localhost:9000. Follow the below steps to connect to MinIO server with mc client:

  1. Download the MinIO mc client - https://min.io/docs/minio/linux/reference/minio-mc.html#quickstart

  2. export MC_HOST_minio-local=http://$(kubectl get secret --namespace minio minio -o jsonpath="{.data.rootUser}" | base64 --decode):$(kubectl get secret --namespace minio minio -o jsonpath="{.data.rootPassword}" | base64 --decode)@localhost:9000

  3. mc ls minio-local
```
