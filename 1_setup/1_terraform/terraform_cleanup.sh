#!/bin/bash

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
pwd=$PWD

read -p '++ Please confirm to delete all terraform workspace (yes/no): ' rm_wp 

if [[ $rm_wp == "yes" ]]
then
    echo "++ Delete all existing terraform workspaces except default"

    for wp in $(terraform workspace select default && terraform workspace list)
    do
        wp_clean="$(echo -e "${wp}" | tr -d '[:space:]')"
        if [[ $wp != "* default" ]]
        then
            echo "deleting workspace "$wp_clean"..."
            #terraform workspace delete -force $wp_clean 
            terraform workspace delete $wp_clean 
        fi
    done
    terraform workspace list
    echo "deleting unused folders ..."
    rm -r terraform.tfstate.d

else
    echo "++ Skip deletion of terraform workspaces"
fi

rg=$(cat terraform.tfvars | grep ResourceGroupName | awk '{printf $3}' | tr -d '"')

read -p '++ Please confirm to delete Azure resource group '$rg' (yes/no): ' rm_rg

if [[ $rm_rg == "yes" ]]
then
    echo "++ Delete Azure resource group "$rg
    az group delete --name $rg

else
    echo "++ Skip deletion of Azure resource group "$rg
fi