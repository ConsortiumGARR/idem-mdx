#! /bin/bash

if [ -f "/etc/nginx/nginx.conf.template" ]; then
  gomplate -f /etc/nginx/nginx.conf.template -o /etc/nginx/nginx.conf
  rm /etc/nginx/nginx.conf.template
fi

chown -R nginx:nginx /etc/letsencrypt

exec nginx -g "daemon off;"
