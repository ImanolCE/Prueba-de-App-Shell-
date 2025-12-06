#!/bin/bash
# Script principal de despliegue Blue/Green

set -e

PARAM_COLOR="$1"  

STATE_FILE="/opt/bluegreen-imanol/blue_green_state"
NGINX_UPSTREAM_CONFIG="/etc/nginx/conf.d/blue_green_upstream.conf"


if [ -f "$STATE_FILE" ]; then
  CURRENT_COLOR=$(cat "$STATE_FILE")
else
  CURRENT_COLOR="blue"
fi


if [ -n "$PARAM_COLOR" ]; then
  TARGET_COLOR="$PARAM_COLOR"
else
 
  if [ "$CURRENT_COLOR" = "blue" ]; then
    TARGET_COLOR="green"
  else
    TARGET_COLOR="blue"
  fi
fi

if [ "$TARGET_COLOR" != "blue" ] && [ "$TARGET_COLOR" != "green" ]; then
  echo "Color inválido: $TARGET_COLOR (usa blue o green)"
  exit 1
fi

if [ "$TARGET_COLOR" = "blue" ]; then
  TARGET_PORT=8081
else
  TARGET_PORT=8082
fi

echo "======================================="
echo "   Despliegue Blue/Green"
echo "   Color actual:   $CURRENT_COLOR"
echo "   Color objetivo: $TARGET_COLOR"
echo "   Puerto interno: $TARGET_PORT"
echo "======================================="


echo " Levantando contenedor app-$TARGET_COLOR ..."
docker compose up -d "${TARGET_COLOR}-app"


MAX_RETRIES=10
SLEEP_SECONDS=3
OK="no"

echo "---------------------------------------"
echo " Ejecutando Smoke Test contra http://127.0.0.1:${TARGET_PORT}/ ..."
for i in $(seq 1 "$MAX_RETRIES"); do
  if curl -fsS "http://127.0.0.1:${TARGET_PORT}/" > /dev/null 2>&1; then
    echo " Smoke test OK en intento $i de $MAX_RETRIES"
    OK="yes"
    break
  fi
  echo " Intento $i/$MAX_RETRIES falló. Esperando ${SLEEP_SECONDS}s..."
  sleep "$SLEEP_SECONDS"
done

if [ "$OK" != "yes" ]; then
  echo " ERROR: Smoke test SIGUE fallando para $TARGET_COLOR (puerto $TARGET_PORT)."
  echo "   Manteniendo activo el color anterior: $CURRENT_COLOR"
 `
  exit 1
fi

echo " Smoke test exitoso para $TARGET_COLOR."


echo " Actualizando Nginx para apuntar a app-$TARGET_COLOR ..."
sudo tee "$NGINX_UPSTREAM_CONFIG" >/dev/null <<EOF
upstream current_upstream {
    server 127.0.0.1:${TARGET_PORT};
}
EOF

sudo nginx -t
sudo systemctl reload nginx

echo "$TARGET_COLOR" | sudo tee "$STATE_FILE" >/dev/null
echo " Despliegue completado. Tráfico apuntando a: $TARGET_COLOR (puerto $TARGET_PORT)."
