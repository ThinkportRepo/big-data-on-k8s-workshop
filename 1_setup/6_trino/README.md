# Trino Setup on Kubernetes

For Trino we can use the official Chart (https://github.com/trinodb/charts) without building a own Docker image.
But unfortunately this Chart does not contain a ingress so we had to add it firs

## Helm Chart

### Set values

first edit the `values.yaml` file and set the values accordingly for

- s3 (endpoint and secrets)
- connectors
- memory sizing

### Install Chart

first create a new namespace

```consol
kubectl create namespace trino

```

then install chart with helm

```consol
helm upgrade --install -f values.yaml  trino -n trino .

```

### Uninstall Chart

in case of issues uninstall the chart and the create pvc for the database

```
helm list -n trino
helm delete trino -n trino
```

### Possible Configurations

The following table lists the configurable parameters of the Trino chart and their default values.

| Parameter                                           | Description | Default                                           |
| --------------------------------------------------- | ----------- | ------------------------------------------------- |
| `image.repository`                                  |             | `"trinodb/trino"`                                 |
| `image.pullPolicy`                                  |             | `"IfNotPresent"`                                  |
| `image.tag`                                         |             | `"latest"`                                        |
| `imagePullSecrets`                                  |             | `[{"name": "registry-credentials"}]`              |
| `server.workers`                                    |             | `2`                                               |
| `server.node.environment`                           |             | `"production"`                                    |
| `server.node.dataDir`                               |             | `"/data/trino"`                                   |
| `server.node.pluginDir`                             |             | `"/usr/lib/trino/plugin"`                         |
| `server.log.trino.level`                            |             | `"INFO"`                                          |
| `server.config.path`                                |             | `"/etc/trino"`                                    |
| `server.config.http.port`                           |             | `8080`                                            |
| `server.config.https.enabled`                       |             | `false`                                           |
| `server.config.https.port`                          |             | `8443`                                            |
| `server.config.https.keystore.path`                 |             | `""`                                              |
| `server.config.authenticationType`                  |             | `""`                                              |
| `server.config.query.maxMemory`                     |             | `"4GB"`                                           |
| `server.config.query.maxMemoryPerNode`              |             | `"1GB"`                                           |
| `server.config.memory.heapHeadroomPerNode`          |             | `"1GB"`                                           |
| `server.exchangeManager.name`                       |             | `"filesystem"`                                    |
| `server.exchangeManager.baseDir`                    |             | `"/tmp/trino-local-file-system-exchange-manager"` |
| `server.workerExtraConfig`                          |             | `""`                                              |
| `server.coordinatorExtraConfig`                     |             | `""`                                              |
| `server.autoscaling.enabled`                        |             | `false`                                           |
| `server.autoscaling.maxReplicas`                    |             | `5`                                               |
| `server.autoscaling.targetCPUUtilizationPercentage` |             | `50`                                              |
| `accessControl`                                     |             | `{}`                                              |
| `additionalNodeProperties`                          |             | `{}`                                              |
| `additionalConfigProperties`                        |             | `{}`                                              |
| `additionalLogProperties`                           |             | `{}`                                              |
| `additionalExchangeManagerProperties`               |             | `{}`                                              |
| `eventListenerProperties`                           |             | `{}`                                              |
| `additionalCatalogs`                                |             | `{}`                                              |
| `env`                                               |             | `[]`                                              |
| `initContainers`                                    |             | `{}`                                              |
| `securityContext.runAsUser`                         |             | `1000`                                            |
| `securityContext.runAsGroup`                        |             | `1000`                                            |
| `service.type`                                      |             | `"ClusterIP"`                                     |
| `service.port`                                      |             | `8080`                                            |
| `nodeSelector`                                      |             | `{}`                                              |
| `tolerations`                                       |             | `[]`                                              |
| `affinity`                                          |             | `{}`                                              |
| `auth`                                              |             | `{}`                                              |
| `serviceAccount.create`                             |             | `false`                                           |
| `serviceAccount.name`                               |             | `""`                                              |
| `serviceAccount.annotations`                        |             | `{}`                                              |
| `secretMounts`                                      |             | `[]`                                              |
| `coordinator.jvm.maxHeapSize`                       |             | `"8G"`                                            |
| `coordinator.jvm.gcMethod.type`                     |             | `"UseG1GC"`                                       |
| `coordinator.jvm.gcMethod.g1.heapRegionSize`        |             | `"32M"`                                           |
| `coordinator.additionalJVMConfig`                   |             | `{}`                                              |
| `coordinator.resources`                             |             | `{}`                                              |
| `coordinator.livenessProbe`                         |             | `{}`                                              |
| `coordinator.readinessProbe`                        |             | `{}`                                              |
| `worker.jvm.maxHeapSize`                            |             | `"8G"`                                            |
| `worker.jvm.gcMethod.type`                          |             | `"UseG1GC"`                                       |
| `worker.jvm.gcMethod.g1.heapRegionSize`             |             | `"32M"`                                           |
| `worker.additionalJVMConfig`                        |             | `{}`                                              |
| `worker.resources`                                  |             | `{}`                                              |
| `worker.livenessProbe`                              |             | `{}`                                              |
| `worker.readinessProbe`                             |             | `{}`                                              |
| `kafka.mountPath`                                   |             | `"/etc/trino/schemas"`                            |
| `kafka.tableDescriptions`                           |             | `{}`                                              |

#### Remark

when Reading from a Ceph storage with s3 endpoint one have to build the Docker image with a modified `trino-delta-lake-400.jar`

## Trino Testing

a quick test can be done by opening the trino console via

```
kubectl exec -it <trino-coordinator-pod> -- trino
```

Ein paar einfache Abfragen sind

```
show catalogs;

show schemas from <catalog>;

# don't miss the slash at the end
create schema delta.test WITH (location='s3a://test/');


CREATE TABLE delta.test.city (
  dummy bigint
)
WITH (
  location = 's3a://test/s3data'
);


```
