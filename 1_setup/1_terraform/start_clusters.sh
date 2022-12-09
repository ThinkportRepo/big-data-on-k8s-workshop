#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD

for i in $(cat < "$1"); do
  echo "terraform workspace select $i"
  az aks start --name "atruvia-${i}-aks" --resource-group "bigdata-k8s-workshop" | tee "${i}_azure_start.log"
  sleep 10
done