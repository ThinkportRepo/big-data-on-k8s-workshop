#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD

az account set --subscription 64ec55c6-c384-4ab1-9c23-97ace4b4dbc6


for i in $(cat < "$1"); do
  echo "get cluster credentials $i"
  az aks get-credentials --resource-group "bigdata-k8s-workshop" --name "lab-${i}-aks"
  sleep 2
done




