# Notizen für den Trainer

## Git pull ausführen auf PVC ausführen

Falls der Code für alle geupdated werden soll diesen Befehl ausführen

```
k exec -it $(kubectl get pods -n frontend -l "app=vscode" -o jsonpath="{.items[0].metadata.name}") -n frontend --  git -C /home/coder/git/ pull
```

export KUBECONFIG=/Users/alor/All/git/big-data-on-k8s-workshop/1_setup/1_terraform/trainer_kubeconfig
