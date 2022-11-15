#!/bin/sh
ROOT_DIR=app
# Replace env vars in files served by NGINX
for file in $ROOT_DIR/js/*.js* $ROOT_DIR/index.html;
do
  #echo $file
  sed -i "s|REPLACE_K8S_HOST|${K8S_HOST}|" $file;
done

# Starting NGINX
nginx -g 'daemon off;'