## Helm installation

https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus


```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus  --create-namespace -n prometheus
```

´´´
helm upgrade --install -f values.yaml  prometheus prometheus-community/prometheus -n prometheus
´´´

helm install kube-prometheus -f values.yaml -n prometheus prometheus-community/kube-prometheus-stack

 k get secret kube-prometheus-grafana -o yaml


#######

example minio
- pfad auf yaml
- set values: for premoethois

wie secret überschreiben

449 k8s_clutser_role_bindung
github secret

The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.frontend.svc.cluster.local


Get the Prometheus server URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace frontend -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace frontend port-forward $POD_NAME 9090
