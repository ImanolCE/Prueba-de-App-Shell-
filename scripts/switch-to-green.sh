#!/bin/bash
set -e

sed -i 's|server green-app:80;|# server green-app:80;|g' nginx-proxy.conf
sed -i 's|# server green-app:80;|server green-app:80;|g' nginx-proxy.conf
sed -i 's|server blue-app:80;|# server blue-app:80;|g' nginx-proxy.conf

docker compose restart nginx-proxy

echo " Entorno GREEN activo"
