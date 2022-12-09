https://artifacthub.io/packages/helm/bitnami/cassandra

helm repo add my-repo https://charts.bitnami.com/bitnami
helm install cassandra my-repo/cassandra --set dbUser.user=trainadm,dbUser.password=train@thinkport -n nosql

cqlsh -u trainadm -p train@thinkport cassandra.nosql.svc.cluster.local 9042

Erste Beispiele
https://cassandra.apache.org/_/quickstart.html

Cassandra can be accessed through the following URLs from within the cluster:

- CQL: cassandra.nosql.svc.cluster.local:9042

To get your password run:

export CASSANDRA_PASSWORD=$(kubectl get secret --namespace "nosql" cassandra -o jsonpath="{.data.cassandra-password}" | base64 -d)

Check the cluster status by running:

kubectl exec -it --namespace nosql $(kubectl get pods --namespace nosql -l app.kubernetes.io/name=cassandra,app.kubernetes.io/instance=cassandra -o jsonpath='{.items[0].metadata.name}') nodetool status

To connect to your Cassandra cluster using CQL:

1. Run a Cassandra pod that you can use as a client:

   kubectl run --namespace nosql cassandra-client --rm --tty -i --restart='Never' \
   --env CASSANDRA_PASSWORD=$CASSANDRA_PASSWORD \
    \
   --image docker.io/bitnami/cassandra:4.0.7-debian-11-r9 -- bash

2. Connect using the cqlsh client:

   cqlsh -u cassandra -p $CASSANDRA_PASSWORD cassandra

To connect to your database from outside the cluster execute the following commands:

kubectl port-forward --namespace nosql svc/cassandra 9042:9042 &
cqlsh -u cassandra -p $CASSANDRA_PASSWORD 127.0.0.1 9042
