#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD

$rg="big-data-k8s-workshop"

read -p '++ Should a new Azure resource group be created (yes/no): ' c_rg

if [[ $c_rg == "yes" ]]
then
    read -e -p '++ Please enter name for resource group: ' -i 'test' rg
    #az group delete --name $rg
    echo $rg

else
    echo "++ Skip "
fi






for i in $(cat < "$1"); do
  echo "terraform workspace new $i"
  #cd "$pwd" && terraform workspace new $i
done