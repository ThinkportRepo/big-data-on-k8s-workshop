# Spark Basics Exercises

** Goal: Get an understanding of how Spark Jobs can be started on Kubernetes **

1. Jupyter: Interactive with Jupyter Notebooks
2. Spark-Submit: Classical way with Kubernetes as Resource Manager
3. Spark-Operator: Kubernetes way using yaml files for job definition

## Spark-Operator

The Spark-Operator offers the possibility to config a Spark Application via a custom Kubernetes resources. Advantage here is that all Kubernetes features (e.g. secrets, certificates, volumes) can be used within the Spark driver and executor Pods

### Task 1: run the Pi example

check if there are currently Spark Jobs running in the `spark` namespace

```
# show running pods
kubectl get po -n spark

# show special sparkapp resource group
kubectl get sparkapp -n spark
```

start the example app that calculates Pi and confirm that the calculation was correct
(should be something like 3.14)

```
# apply manifest yaml (from the folder where the file resides)
kubectl apply -f spark-pi-app.yaml

# show spark app
kubectl get sparkapp -n spark
kubectl describe sparkapp spark-pi -n spark

# show if driver and executor pods are spinning up (-w stands for watch, exit with ctr+c)
# and wait until driver pod is completed
kubectl get po -n spark -w -n spark

# show result in the logs via
kubectl logs spark-pi-driver -n spark
# or look at the live logs during run time (-f stands for follow, exit with ctr+c)
kubectl logs spark-pi-driver -f -n spark
```

Clean up everythin at the end

```
kubectl delete sparkapp spark-pi
```

### Task 2: configure a simple app

have a look at the Python code and

1. upload the script to the s3 bucket `scripts`

edit the yaml file `spark-simple-app` and complete the follwing tasks

2. set the correct path to the python script

```
mainApplicationFile: s3a://<bucket>/<python-script>.py
```

3. find and set the correct s3 endpoint in the hadoop configs
   check out the services from minio via

```
kubectl get services -n minio
```

use the service called `minio`
put togehter the internal Kubernets path to the minio(s3) service(s3 endpoint). The path to a service in a namespace follows the pattern `<service-name>.<namespace>.svc.cluster.local:<port>`
fill in the correct values in the yaml fike

```
"fs.s3a.endpoint": "<service-name>.<namespace>.svc.cluster.local:<port>"
"fs.s3a.access.key": "<standard user>"
"fs.s3a.secret.key": "<standard password>"
```

4. increase the number of executors (executor instances) to 2

5. start the app and check if she runs and have a look at the logs for the results (similar commands as used for the Pi example)
   check if there are two executor pods running

6. If there are errors check them and find a solution to get the job running
