#!/bin/bash
# Script de despliegue Blue/Green

set -e

STATE_FILE="/opt/bluegreen-imanol/blue_green_state"
NGINX_UPSTREAM_CONFIG="/etc/nginx/conf.d/blue_green_upstream.conf"

PARAM_COLOR="$1"

# Determinar color actual 
if [ -f "$STATE_FILE" ]; then
  CURRENT_COLOR=$(cat "$STATE_FILE")
else
  CURRENT_COLOR="blue"
fi

# Determinar color objetivo + puerto 
if [ -n "$PARAM_COLOR" ]; then
  # modo forzado
  if [ "$PARAM_COLOR" = "blue" ]; then
    TARGET_COLOR="blue"
    TARGET_PORT=8081
  elif [ "$PARAM_COLOR" = "green" ]; then
    TARGET_COLOR="green"
    TARGET_PORT=8082
  else
    echo "Color inválido: $PARAM_COLOR (usa blue o green)"
    exit 1
  fi
else
  
  if [ "$CURRENT_COLOR" = "blue" ]; then
    TARGET_COLOR="green"
    TARGET_PORT=8082
  else
    TARGET_COLOR="blue"
    TARGET_PORT=8081
  fi
fi

echo "======================================="
echo "   Despliegue Blue/Green"
echo "   Color actual:  ${CURRENT_COLOR:-<desconocido>}"
echo "   Color nuevo:   $TARGET_COLOR"
echo "   Puerto nuevo:  $TARGET_PORT"
echo "======================================="

#  Levantar contenedor objetivo 
echo " Levantando contenedor ${TARGET_COLOR}-app ..."
docker compose up -d "${TARGET_COLOR}-app"

#  Smoke test con reintentos 
MAX_RETRIES=10
SLEEP_SECONDS=3
SUCCESS=0

echo " Ejecutando Smoke Test contra http://127.0.0.1:${TARGET_PORT}/ ..."
for i in $(seq 1 $MAX_RETRIES); do
  echo "  Intento $i/$MAX_RETRIES ..."
  if curl -fsS "http://127.0.0.1:${TARGET_PORT}/" > /dev/null 2>&1; then
    echo "  Smoke test OK en intento $i"
    SUCCESS=1
    break
  fi
  sleep "$SLEEP_SECONDS"
done

if [ "$SUCCESS" -ne 1 ]; then
  echo " ERROR: Smoke test falló para $TARGET_COLOR (puerto $TARGET_PORT)."
  echo "   Manteniendo activo el color anterior: $CURRENT_COLOR"
  exit 1
fi

echo " Smoke test exitoso para $TARGET_COLOR."

# Actualizar Nginx 
echo " Actualizando Nginx para apuntar a $TARGET_COLOR ..."
sudo tee "$NGINX_UPSTREAM_CONFIG" >/dev/null <<EOF
upstream current_upstream {
    server 127.0.0.1:${TARGET_PORT};
}
EOF

sudo nginx -t
sudo systemctl reload nginx

echo "$TARGET_COLOR" | sudo tee "$STATE_FILE" >/dev/null
echo " Despliegue completado. Tráfico apuntando a: $TARGET_COLOR (puerto $TARGET_PORT)."
