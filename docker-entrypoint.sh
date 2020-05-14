#!/usr/bin/env sh
set -e

# change permission

chown -R nginx /var/log/nginx
chown -R nginx /etc/nginx/html
chown -R nginx /etc/nginx/key

exec "$@"