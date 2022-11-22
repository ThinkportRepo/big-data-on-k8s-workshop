# Azure Lab Setup via Teraform

## Login zu Azure

You should login to azure by using `az` command first.
Check the correct subscription by using `az account show`.

### Required settings

To get your K8s clusters just set the number of desired clusters `NumberOfClusters` and a resource group name `ResourceGroupName` (the resource group needs to be created beforehand). Each cluster will get a random pet name to have a unique identifier.

### Optional settings

The following optional settings can be used:

- you can set a shared prefix for your cluster that included in all cluster names: `SharedPrefix`, default: `tp`
- a location can be set (e.g. europewest): `Location`, default: `germanywestcentral`
- the node size can be specified: `NodeSize`, default: `Standard_B2s`
- the number of worker nodes can be defined, `NodeCount`, default: `1`
- HTTP application routing can be enabled for demonstration/training purposes: `httpApplicationRouting`, default: `true`

### terraform deployment

````
terraform init

terraform validate

terraform plan




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
