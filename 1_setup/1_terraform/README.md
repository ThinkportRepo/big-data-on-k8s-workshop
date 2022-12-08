# Azure Lab Setup via Teraform

## Login at Azure

You should login to azure by using `az` command first.
Check the correct subscription by using `az account show`. Keep in mind to select the correct subscription `az account set --subscription <subscriptionname>`.

### Required settings

Copy the example terraform.tfvars.template to terraform.tfvars. 
The following parameters can be set: 

| Parameter              | Description                                                                                                            |
|------------------------|------------------------------------------------------------------------------------------------------------------------|
| UniquePrefix           | Should be empty                                                                                                        |
| SharedPrefix           | Will be included in the name of all clusters (e.g. customer or workshop name)                                          |
| ResourceGroupName      | Resource Group in Azure (needs to be created before)                                                                   |
| Location               | Location to deploy the clusters to                                                                                     |
| NodeCount              | Number of cluster nodes                                                                                                |
| NodeSize               | Azure VM Size                                                                                                          |
| NodeDiskSize           | Disk size in Gibibytes                                                                                                 |
| HttpApplicationRouting | Enables the [AKS HttpApplicationRouting feature](https://learn.microsoft.com/de-de/azure/aks/http-application-routing) |
| GitHubUsername         | Your GitHub username                                                                                                   |
| GitHubRepoToken        | A fine grained PAT to clone the workshop repository                                                                    |
| DockerhubUser          | Your Dockerhub username                                                                                                |
| DockerhubPAT           | Your Dockerhub PAT to extend the pull limit to 200 requests                                                            |

### Terraform Deployment

Use the helper scripts to use terraform for the deployment. 
Create a cluster.txt (or any other name) with the names of your clusters. 
#### create workspaces
To create and configure the aks cluster at the same time, we need to a workspace for each cluster.

Use `terraform_create_workspace.sh clusters.txt` to create the workspaces. 

#### create clusters
Run `terraform_plan.sh clusters.txt` to generate terraform plans (if desired), can be skipped. 
Use `terraform_apply.sh clusters.txt`to create your clusters. Check the creates log files. 

#### do something on a single cluster
If you need to fix a single cluster you can use `terraform select workspace <clustername>` and `terraform apply` for changes. 

#### stop your clusters
If you need to stop your clusters (e.g. because there are several days between your workshop days), you can use `stop_clusters.sh cluster.txt`. 

#### start your clusters
The clusters can be started again by runinng `start_clusters.sh clusters.txt`


### Kubeconfig

For each cluster the corresponding kubeconfig will be created in the current working directory. They are identified by the pet name (e.g. `delicate-ladybird.config`). Those kubeconfig files can then be distrubted to e.g. workshop participants.

You can use them directly with `kubectl` by setting the `KUBECONFIG` enviornment variable.

### DNS Configuration

If `httpApplicationRouting` is enabled, the name of the Azure DNS Zone of the cluster is written into the file `name-of-the-cluster-dns.txt` (e.g. `delicate-ladybird-dns.config`). This dns can be used for ingress controllers.
If `httpApplicationRouting` is set to false, the file will be empty.

```bash
export KUBECONFIG=./delicate-ladybird.config
kubectl cluster-info
````
