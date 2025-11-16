#!/bin/bash
# Script principal de despliegue Blue/Green
# Uso de :
#   ./scripts/deploy_app.sh blue
#   ./scripts/deploy_app.sh green

set -e

TARGET_COLOR="$1"   # blue o green

if [ -z "$TARGET_COLOR" ]; then
  echo "Uso: $0 {blue|green}"
  exit 1
fi

if [ "$TARGET_COLOR" != "blue" ] && [ "$TARGET_COLOR" != "green" ]; then
  echo "Color inválido: $TARGET_COLOR (usa blue o green)"
  exit 1
fi

# ==== Configuración ====
STATE_FILE="/opt/bluegreen-imanol/blue_green_state"
NGINX_UPSTREAM_CONFIG="/etc/nginx/conf.d/blue_green_upstream.conf"

if [ "$TARGET_COLOR" = "blue" ]; then
  TARGET_PORT=8081
else
  TARGET_PORT=8082
fi

echo "======================================="
echo " Iniciando despliegue $TARGET_COLOR"
echo " Puerto objetivo: $TARGET_PORT"
echo "======================================="

# 1. Estado actual (si existe)
if [ -f "$STATE_FILE" ]; then
  CURRENT_COLOR=$(cat "$STATE_FILE")
else
  CURRENT_COLOR="blue"
fi

echo "Color actual asumido: $CURRENT_COLOR"

# 2. Build + levantar contenedor objetivo (interno)
echo " Construyendo y levantando app-$TARGET_COLOR ..."
docker compose build "${TARGET_COLOR}-app"
docker compose up -d "${TARGET_COLOR}-app"

# 3. Smoke del test sobre el puerto interno (no público)
echo " Ejecutando Smoke Test contra http://127.0.0.1:$TARGET_PORT ..."
if ! curl -fsS "http://127.0.0.1:$TARGET_PORT" > /dev/null; then
  echo " ERROR: Smoke test falló para app-$TARGET_COLOR"
  echo "   Haciendo rollback (apagando app-$TARGET_COLOR)..."
  docker stop "app-$TARGET_COLOR" || true
  exit 1
fi
echo " Smoke test exitoso"

# 4. Actualizar el Nginx para apuntar al nuevo upstream
echo " Actualizando Nginx para apuntar a app-$TARGET_COLOR ..."
sudo sed -i "s|http://127.0.0.1:[0-9]\+|http://127.0.0.1:${TARGET_PORT}|g" "$NGINX_UPSTREAM_CONFIG"
sudo nginx -t
sudo systemctl reload nginx

# 5. Guardar estado
echo "$TARGET_COLOR" | sudo tee "$STATE_FILE" >/dev/null

echo "🚀 Despliegue $TARGET_COLOR completado. Nginx ya apunta a puerto $TARGET_PORT."


