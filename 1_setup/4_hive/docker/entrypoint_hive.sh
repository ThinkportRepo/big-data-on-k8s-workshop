#!/bin/bash
# get database host from environment variables that are set from the Kubernetes deployment
export METASTORE_DB_HOSTNAME=${METASTORE_DB_HOSTNAME:-localhost}
echo "Waiting for database on ${METASTORE_DB_HOSTNAME} to launch on 5432 ..."
while ! nc -z ${METASTORE_DB_HOSTNAME} 5432; do
sleep 1
done
# TODO: Limit while loop
echo "Database on ${METASTORE_DB_HOSTNAME}:5432 started"

if [ $METASTORE_SCHEMA_INIT = true ]
then
    echo "Init apache hive metastore on ${METASTORE_DB_HOSTNAME}:5432"
    bash /opt/metastore/bin/schematool -initSchema -dbType postgres
else
    echo "Metastore Database already initialized"
fi

bash /opt/metastore/bin/start-metastore