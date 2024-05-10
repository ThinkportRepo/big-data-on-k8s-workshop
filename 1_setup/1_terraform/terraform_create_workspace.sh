#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD/aks

rg="bigdata-k8s-workshop"

read -p '++ Should a new Azure resource group be created (yes/no): ' c_rg

if [[ $c_rg == "yes" ]]
then
    read -p '++ Please enter name for resource group ('$rg'): ' new_rg
    
    if [[ $new_rg == "" ]]
    then 
      create_rg=$rg
    else
      create_rg=$new_rg
    fi

    az group create --location westeurope --resource-group $create_rg --tags 'created-by=Alex Ortner' 'owner-email=aorter@thinkport.digital' delete-after='20.12.2024' 'project=Big Data Workshop'
else
    echo "++ Skip "
fi


for i in $(cat < "$1"); do
  echo "terraform workspace new $i"
  cd "$pwd" && terraform workspace new $i
done

cd ..