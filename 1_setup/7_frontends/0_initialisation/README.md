# Note
All those steps are done automatically when using the terraform deployment. 
# Create PVC clone git Repo and upload data to s3

1. Create Secret with git token and git user

```
kubectl create secret generic github --from-file=git_token -n frontend --from-file=git_user -n frontend

kubectl create configmap s3cmd --from-file=s3cfg -n frontend


or

source 2_secret.sh

```

2. Create Pvc
   the pvc has to be a `ReadWriteMany` and the appropriate storage class has to be selected from Azure storage classes (e.g. `azurefile`)

```
kubectl apply -f pvc.yaml -n frontend
```

3. Create service account for kubectl
   in order to be able to access the cluster via kubectl from varios pods we need a service account with appropriate rights

```
kubectl apply -f serviceaccount.yaml -n frontend
```

4. Create clusster role Binding

```
kubectl apply -f clusterrolebinding.yaml -n frontend
```

5. Run initialisation Pod

```
kubectl apply -f init_pod.yaml
```

# read write: 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

# read only: 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
