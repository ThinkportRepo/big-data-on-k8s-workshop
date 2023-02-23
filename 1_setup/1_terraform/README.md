# Terraform Setup for Big Data Lab

This Terraform scripts create several Kubernetes Clusters and pre install all resources that are necessary for the lab for each participant.

Therefore a list of the participants has to be provided upfront e.g. `clusters.txt`


```
trainer
student1
student2
```

## Azure Environment Preparation

Login to Azure Cloud Console and create a Resource Group in the correct subscription

## Local Environment Preparation

Azure Shell and Terraform CLI has to be installed and correctly configured

First login to azure by using `az` command first.
Check the correct subscription by using `az account show`.  
Keep in mind to select the correct subscription (schulungen) `az account set --subscription <subscriptionname>`.

## Adjust Terraform Settings

Please note that your user needs proper permissions to the Thinkport prod subscription and the required resource groups. Furthermore the DNS zone for this workshop must be created beforehand by using the terraform code at [the configuration repo](https://github.com/ThinkportRepo/thinkport-cloud-domain-mangement).
The general architecture can be viewed [here](architecture.drawio.png)

### SSL Certificates

Go to the [dns_and_ssl](./dns_and_ssl) directory.

Copy the example setting file `terraform.tfvars.template` to `terraform.tfvars` and
set the following parameters:

| Parameter              | Description                                                                                            |
|------------------------|--------------------------------------------------------------------------------------------------------|
| ACMEServer             | The server of the ACME Service you want to use (see example tfvars for Let's Encrypt prod and staging) |
| ACMEAdminEmail         | Email address for getting messages from your ACME provider                                             |
| AZ_Cert_Key_Vault_Name | Name of the key vault containing SSL certificates                                                      |
| AZ_SA_Key_Vault_Name   | Name of the key vault containing the ServiceAccount credentials                                        |
| AZ_Subscription_ID     | Thinkport's prod subscription ID                                                                       |
| AZ_RG_Name             | Resource group that contains all key vaults and DNS zones.                                             |
| Domain                 | The subdomain of this workshop                                                                         |
| ClusterFile            | Path to the text file containing your cluster names (one name per line)                                |

Use `terraform apply`to create your ACME certificates and upload them the certificates Key Vault by using the Service Account. 

### Kubernetes (AKS)

Change the current directory to `../aks`.

Copy the example setting file `terraform.tfvars.template` to `terraform.tfvars` and
set the following parameters:

| Parameter              | Description                                                                                            |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Domain                 | The subdomain of this workshop                                                                         |
| UniquePrefix           | Should be empty                                                                                                        |
| SharedPrefix           | Will be included in the name of all clusters (e.g. customer or workshop name)                                          |
| ResourceGroupName      | Resource Group in Azure (needs to be created before)                                                                   |
| Location               | Location to deploy the clusters to (e.g. WestEurope)                                                                   |
| NodeCount              | Number of cluster nodes                                                                                                |
| NodeSize               | Azure VM Size                                                                                                          |
| NodeDiskSize           | Disk size in Gibibytes                                                                                                 |
| HttpApplicationRouting | Enables the [AKS HttpApplicationRouting feature](https://learn.microsoft.com/de-de/azure/aks/http-application-routing) |
| GitHubUsername         | Your GitHub username                                                                                                   |
| GitHubRepoToken        | A fine grained PAT to clone the workshop repository                                                                    |
| DockerhubUser          | Your Dockerhub username                                                                                                |
| DockerhubPAT           | Your Dockerhub PAT to extend the pull limit to 200 requests                                                            |
| AZ_Cert_Key_Vault_Name | Name of the key vault containing SSL certificates                                                      |
| AZ_SA_Key_Vault_Name   | Name of the key vault containing the ServiceAccount credentials                                        |
| AZ_Subscription_ID     | Thinkport's prod subscription ID                                                                       |
| AZ_RG_Name             | Resource group that contains all key vaults and DNS zones.                                             |

## Terraform Deployment

Use the helper scripts to use terraform for the deployment.

#### create workspaces

To create and configure several aks cluster at the same time, we need to a workspace for each cluster.

To create the terraform workspaces run

```
terraform_create_workspace.sh clusters.txt
```

#### create clusters

To generate the terraform plans (if desired, can be skipped) and to create the clusters run

```
terraform_plan.sh clusters.txt
terraform_apply.sh clusters.txt
```

#### do something on a single cluster

If you need to fix a single cluster you can use

```
terraform select workspace <clustername>
# and
terraform apply
```

for changes.

#### stop your clusters

If you need to stop your clusters (e.g. because there are several days between your workshop days), you can use ```
stop_clusters.sh cluster.txt

```

#### start your clusters

The clusters can be started again by runinng
```

start_clusters.sh clusters.txt

````

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
