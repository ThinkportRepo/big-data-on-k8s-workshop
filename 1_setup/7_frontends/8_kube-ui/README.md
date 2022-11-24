# Kubernetes Dashboard

Using the default dashboard with bearer token
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
https://github.com/kubernetes/dashboard/blob/master/docs/user/accessing-dashboard/README.md#login-not-available

Install via Helm

```
# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart

helm upgrade --install kubernetes-dashboard -f values.yaml -n frontend  kubernetes-dashboard/kubernetes-dashboard



```

Install via

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml

kubectl delete namespace kubernetes-dashboard
```
