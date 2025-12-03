#!/bin/bash
# Cambia el tráfico a la app GREEN usando el script principal de despliegue

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

bash scripts/deploy_app.sh green
