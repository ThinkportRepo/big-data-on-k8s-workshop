#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD
j=0

az aks list --query "[].{NAME:name,NODES:agentPoolProfiles[0].count,TARGET_STATE:powerState.code, PROVISIONING_STATE: provisioningState}" --output table