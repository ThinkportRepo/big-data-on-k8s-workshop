#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD
j=0

for i in $(cat < "$1"); do
    if [[ $j == 0 ]]
    then
        az aks show --resource-group "bigdata-k8s-workshop" --name lab-${i}-aks --query "{NAME:name,NODES:agentPoolProfiles[0].count,STATUS:powerState.code}" --output table
    else 
        az aks show --resource-group "bigdata-k8s-workshop" --name lab-${i}-aks --query "{NAME:name,NODES:agentPoolProfiles[0].count,STATUS:powerState.code}" --output tsv
    fi
    let "j++"
  sleep 1
done