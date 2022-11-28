# Kubernetes Excercices

## Explore Kubernetes Setup

In this exercise we explore the setup of our Big Data Plattform on Kubernetes

Open the web Terminal and run the following commands to solve the tasks

### Nodes

- Tasks \*
  a) how much nodes to your cluster have?
  b) which OS run on the nodes?
  c) how much memory (RAM) do the nodes have?

- Commands \*

```
kubectl get nodes

# get more information about the noes
kubectl get nodes -o wide

# details about on enode
kubectl describe node <node-name>
```

### Namespaces

<Bild Technisches Setup>
a) check which namespaces exits and whats in there

```
kubectl get namespaces

# look into the resources of one namespace
kubectl get pod --namespace <namespace>

# or
kubectl get all -n <namespace>
```

### Ingress Routes

a) check the ingress routes that map to a public dns name
b) test that the urls can be reached

```
# show ingress in all namespaces
kubectl get ingress --all-namespaces
# or short
kubectl get ingress -A

# -A  is short for --all-namespaces
```

### Shared Volumes

show which persisten volume clais exists and where they are mounted

```
kubectl get pvc -n frontend
```

The pvc `workshop` is sharing code between all pods
Check via

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
k get po  -o custom-columns=POD:.metadata.name,VOLUMES:.spec.containers[*].volumeMounts[0].name,MOUNTPATH:spec.containers[*].volumeMounts[0].mountPath
# or all volumes per pod
k get po  -o custom-columns=POD:.metadata.name,VOLUMES:.spec.containers[*].volumeMounts[*].name,MOUNTPATH:spec.containers[*].volumeMounts[*].mountPath
```

### Share a file

Open the VSCode UI and create a new file in the folder `/exercices`
Open the Terminal or Jupyter UI and see if the file did arrive there

### Tunneln into Pod

Exec into the `admin` Pod and check if you find the file in the mouted volume

```
k exec -it admin -- sh

# and
ls /workshop/exercises
```
