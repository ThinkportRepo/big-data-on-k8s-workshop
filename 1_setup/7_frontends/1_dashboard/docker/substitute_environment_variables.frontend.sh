#!/bin/sh
ROOT_DIR=app
# Replace env vars in files served by NGINX
echo "######## Replace DNS Name #######"
echo $K8S_HOST
for file in $ROOT_DIR/js/*.js* $ROOT_DIR/index.html;
do
  echo $file
  sed -i "s|REPLACE_K8S_HOST|${K8S_HOST}|g" $file;
  #sed -i "s|replace_k8s_host|${K8S_HOST}|g" $file;
  echo "done substituteing"ec
done

echo $LAB_USER
for file in $ROOT_DIR/js/*.js* $ROOT_DIR/index.html;
do
  echo $file
  sed -i "s|REPLACE_LAB_USER|${LAB_USER}|g" $file;
  #sed -i "s|replace_k8s_host|${K8S_HOST}|g" $file;
  echo "done substituteing"ec
done
# replace value networkConnection = true;  socketio.js
echo $LAB_USER
for file in $ROOT_DIR/js/*.js* $ROOT_DIR/index.html;
do
  echo $file
  sed -i "s|networkConnection = false|networkConnection = true|g" $file;
  #sed -i "s|replace_k8s_host|${K8S_HOST}|g" $file;
  echo "done substituteing"ec
done

# Starting NGINX
nginx -g 'daemon off;'


