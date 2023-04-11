# Headlamp Dashboard

Kubernetes UI to monitor the cluster

## Helm Install

```
helm upgrade --install -f values.yaml heatlamp -n frontend .
```

## Get token

kubectl get secret headlamp-admin --template=\{\{.data.token\}\} | base64 --decode
