#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD

for i in $(cat < "$1"); do
  echo "stop cluster lab-$i-aks"
  az aks stop --name "lab-${i}-aks" --resource-group "bigdata-k8s-workshop" --no-wait  | tee "logs/${i}_azure_stop.log"
  sleep 10
done