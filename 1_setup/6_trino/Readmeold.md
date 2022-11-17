# Deploy trino with additional catalog settings
```console
helm install --create-namespace -n trino-helm -f trino-values.yaml test trino/trino

helm upgrade --install  -n trino -f values.yaml trino .
```
Custom catalogs can be specified in the values.yaml of the helm chart directly.
Take a look on the trino-values.yaml in this repo as example. 
