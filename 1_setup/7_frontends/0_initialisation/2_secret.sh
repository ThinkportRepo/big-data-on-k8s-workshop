#bin/sh
kubectl create secret generic github --from-file=git_token -n frontend --from-file=git_user -n frontend
