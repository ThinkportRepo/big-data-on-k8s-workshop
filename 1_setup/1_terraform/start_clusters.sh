#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD

for i in $(cat < "$1"); do
  echo "start cluster $i"
  az aks start --name "lab-${i}-aks" --resource-group "bigdata-k8s-workshop" --no-wait | tee "logs/${i}_azure_start.log"
  sleep 10
done