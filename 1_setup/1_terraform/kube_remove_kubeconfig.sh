read -p '++ Please confirm to delete all entries from KubeConfig '$rg' (yes/no): ' rm_rk

if [[ $rm_rk == "yes" ]]
then
    echo "++ Delete KubeConfig entries"
    for i in $(cat < "$1"); do
        echo "Delete entry for ${i}"
        kubectl config unset "clusters.lab-${i}-aks"
        kubectl config unset "contexts.lab-${i}-aks"
        kubectl config unset "users.clusterUser_bigdata-k8s-workshop_lab-${i}-aks"
        echo "###################################################################"
        sleep 1
    done

    kubectl config view -o jsonpath='{.clusters[*].name}'
    kubectl config view -o jsonpath='{.contexts[*].name}'
    kubectl config view -o jsonpath='{.users[*].name}'
    

else
    echo "++ Skip deletion of Azure resource group "$rg
fi