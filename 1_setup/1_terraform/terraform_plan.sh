#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD

for i in $(cat < "$1"); do
  echo "terraform workspace select $i"
  cd "$pwd/aks" && terraform workspace select $i && terraform plan -out ${i}.plan 2>&1 | tee "logs/${i}_plan.log"
  sleep 10
done