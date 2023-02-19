#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD/aks

echo "WARNING!! terraform can only destroy cluster setup when clusters are running"

for i in $(cat < "$1"); do
  echo "terraform workspace select $i"
  cd "$pwd" && terraform workspace select $i && terraform state rm module.kubernetes-config && terraform destroy --auto-approve 2>&1 && terraform workspace select default && terraform workspace delete $i | tee "logs/${i}_destroy.log"
  sleep 5
done