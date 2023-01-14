#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD

for i in $(cat < "$1"); do
  echo "terraform workspace select $i"
  cd "$pwd" && terraform workspace select $i && terraform apply --auto-approve 2>&1 | tee "logs/${i}_plan.log"
  sleep 5
done