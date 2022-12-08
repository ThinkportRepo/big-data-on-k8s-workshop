# Kubernetes Excercices

## Explore Kubernetes Setup

In this exercise we explore the setup of our Big Data Plattform on Kubernetes

Open the web Terminal and run the following commands to solve the tasks

### Nodes

** Tasks **

1. How much nodes to your cluster have?
2. Which OS run on the nodes?
3. How much memory (RAM) do the nodes have?

```
kubectl get nodes

# get more information about the nodes
kubectl get nodes -o wide

# details about one node
kubectl describe node <node-name>
```

### Namespaces

check which namespaces exits and whats in there

```
kubectl get namespaces

# look into the resources of one namespace
kubectl get pod --namespace <namespace>

# or
kubectl get all -n <namespace>
```

### Ingress Routes

1. check the ingress routes that map to a public dns name
2. test that the urls can be reached

```
# show ingress in all namespaces
kubectl get ingress --all-namespaces
# or short
kubectl get ingress -A

# -A  is short for --all-namespaces
```

### Further Investigations of Resources

```
# Services (eindeutige dns Name innerhalb des Clusters)
kubectl get services -n frontend

# Storage (Persistent Volume Claims, Reservierter Festplattenspeicher
# der in einen Pod gemounted werden kann)
kubectl get pvc -n frontend

# Deployments (Definieren Replicas von Pods)
kubectl get deploy -n frontend

# Configurationen (Zentral abgelegte Configurationen, die von jedem Pod geladen werden können)
kubectl get configmaps -n frontend

# Secrets (Zentral abgelegte Secrets/Passwörter/Certificate, die von jedem Pod geladen werden können)
kubectl get secret -n hive
```

### Deep Dive into Pods

```
# get pod names
kubectl get pod -n frontend

# show pod definiton
kubectl get pod <terminal-pod/vscode-pod/juypter-pod> -o yaml -n frontend

# or filter out for one pod with jsonpath for the first pod
kubectl get pods -o jsonpath='{.items[0].spec.containers[0].volumeMounts[0]}'

# or for all pods
kubectl get pods -o jsonpath='{.items[*].spec.containers[0].volumeMounts[0]}'

# or with
kubectl get po  -o custom-columns=POD:.metadata.name,VOLUMES:.spec.containers[*].volumeMounts[0].name,MOUNTPATH:spec.containers[*].volumeMounts[0].mountPath
# or all volumes per pod
kubectl get po  -o custom-columns=POD:.metadata.name,VOLUMES:.spec.containers[*].volumeMounts[*].name,MOUNTPATH:spec.containers[*].volumeMounts[*].mountPath
```

### Share a file

Open the VSCode UI and create a new file in the folder `/exercices`
Open the Terminal or Jupyter UI and see if the file did arrive there

### Tunneln into Pod

Exec into the `admin` Pod and check if you find the file in the mouted volume

```
kubectl exec -it admin -- sh

# and
ls /workshop/exercises
```
