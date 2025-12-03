#!/usr/bin/env bash
# Script de despliegue Blue/Green con:
#  - Modo automático (sin parámetros): alterna entre blue/green
#  - Modo forzado (con parámetro blue|green): usa ese color directamente
#
#   ./scripts/deploy_app.sh         # auto toggle
#   ./scripts/deploy_app.sh blue    # forzar blue
#   ./scripts/deploy_app.sh green   # forzar green

set -euo pipefail

STATE_FILE="/opt/bluegreen-imanol/blue_green_state"
NGINX_UPSTREAM_CONFIG="/etc/nginx/conf.d/blue_green_upstream.conf"

# Leer parámetro opcional
FORCED_COLOR="${1:-}"   # puede ser "", "blue" o "green"

echo "======================================="
echo "   Despliegue Blue/Green"
echo "   Parámetro recibido: '${FORCED_COLOR:-<none>}'"
echo "======================================="

#  Leer color actual (por defecto 'blue' si no hay archivo)
CURRENT_COLOR="blue"
if [[ -f "$STATE_FILE" ]]; then
  CURRENT_COLOR="$(tr -d '\n\r' < "$STATE_FILE")"
fi

if [[ "$CURRENT_COLOR" != "blue" && "$CURRENT_COLOR" != "green" ]]; then
  echo "Valor de estado inválido en $STATE_FILE: '$CURRENT_COLOR', usando 'blue' por defecto."
  CURRENT_COLOR="blue"
fi

#  Determinar TARGET_COLOR
if [[ -n "$FORCED_COLOR" ]]; then
  # Modo forzado
  if [[ "$FORCED_COLOR" != "blue" && "$FORCED_COLOR" != "green" ]]; then
    echo "Color inválido: $FORCED_COLOR (usa blue o green)"
    exit 1
  fi
  TARGET_COLOR="$FORCED_COLOR"
  echo "Modo FORZADO → TARGET_COLOR = $TARGET_COLOR"
else
  if [[ "$CURRENT_COLOR" == "blue" ]]; then
    TARGET_COLOR="green"
  else
    TARGET_COLOR="blue"
  fi
  echo "Modo AUTO → CURRENT_COLOR = $CURRENT_COLOR, TARGET_COLOR = $TARGET_COLOR"
fi

# Puerto según el color
if [[ "$TARGET_COLOR" == "blue" ]]; then
  TARGET_PORT=8081
else
  TARGET_PORT=8082
fi

echo " Usando puerto interno: $TARGET_PORT"
echo "---------------------------------------"

# Smoke test contra el target
echo " Ejecutando Smoke Test contra http://127.0.0.1:${TARGET_PORT}/ ..."
if ! curl -fsS "http://127.0.0.1:${TARGET_PORT}/" > /dev/null; then
  echo " ERROR: Smoke test falló para $TARGET_COLOR (puerto $TARGET_PORT)."
  echo "   Se mantiene activo el color anterior: $CURRENT_COLOR"
  exit 1
fi
echo " Smoke test exitoso en $TARGET_COLOR"
echo "---------------------------------------"

# Actualizar upstream de Nginx
echo " Actualizando Nginx para apuntar a app-$TARGET_COLOR en el puerto $TARGET_PORT ..."
sudo tee "$NGINX_UPSTREAM_CONFIG" >/dev/null <<EOF
upstream current_upstream {
    server 127.0.0.1:${TARGET_PORT};
}
EOF

sudo nginx -t
sudo systemctl reload nginx

#  Guardar nuevo estado
echo "$TARGET_COLOR" | sudo tee "$STATE_FILE" >/dev/null

echo " Despliegue $TARGET_COLOR completado."
echo "   Nginx ya apunta a puerto $TARGET_PORT."
echo "   Estado actualizado en $STATE_FILE."
echo "======================================="
