#!/bin/bash
# Cambia el tráfico a la app BLUE usando el script principal de despliegue

set -e

# Ruta absoluta al directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Ir a la raíz del proyecto (donde está docker-compose.yml)
cd "$PROJECT_ROOT"

# Ejecutar despliegue hacia BLUE
bash scripts/deploy_app.sh blue
