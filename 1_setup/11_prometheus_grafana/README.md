# Prometheus & Grafana 

Helm Chart von Prometheus Community https://prometheus-community.github.io/helm-charts

## Helm Install

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm upgrade --install -f values.yaml -n monitoring prometheus-stack prometheus-community/kube-prometheus-stack  
```

## Grafana

### Password
- standard - defined in terraform helm release
- also stored in: k get secret kube-prometheus-grafana -o yaml

### Dashboards
- included from https://github.com/dotdc/grafana-dashboards-kubernetes (corresponding post https://medium.com/@dotdc/a-set-of-modern-grafana-dashboards-for-kubernetes-4b989c72a4b2)

