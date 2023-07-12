#! /bin/bash
sed -i "s/\\\${NGINX_SERVERNAME}/$NGINX_SERVERNAME/" /etc/nginx/nginx.conf
sed -i "s/\\\${NGINX_CERTNAME}/$NGINX_CERTNAME/" /etc/nginx/nginx.conf
sed -i "s/\\\${NGINX_KEYNAME}/$NGINX_KEYNAME/" /etc/nginx/nginx.conf
sed -i "s/\\\${NGINX_LOGLEVEL}/$NGINX_LOGLEVEL/" /etc/nginx/nginx.conf

sleep 15
exec nginx -g "daemon off;"
