#!/usr/bin/env bash
#
# ABRIR VENTANA DE MANTENIMIENTO STAGING
# RunArt Foundry — Protocolo de ventana de mantenimiento
#
# Propósito:
#   Abrir staging para trabajar (escritura real, pruebas, aprobaciones)
#
# IMPORTANTE:
#   - Solo usar cuando se necesite trabajar activamente en staging
#   - Documentar SIEMPRE la apertura en bitácora
#   - Cerrar con close_staging_window.sh cuando termines
#
# Uso:
#   source ./scripts/deploy_framework/open_staging_window.sh
#

set -euo pipefail

echo "================================================================================"
echo "🟢 ABRIENDO VENTANA DE MANTENIMIENTO STAGING"
echo "================================================================================"

# Guardar estado previo para referencia
PREV_READ_ONLY="${READ_ONLY:-undefined}"
PREV_DRY_RUN="${DRY_RUN:-undefined}"
PREV_REAL_DEPLOY="${REAL_DEPLOY:-undefined}"

echo "Estado previo:"
echo "  READ_ONLY: $PREV_READ_ONLY"
echo "  DRY_RUN: $PREV_DRY_RUN"
echo "  REAL_DEPLOY: $PREV_REAL_DEPLOY"
echo ""

# ABRIR VENTANA: Modo trabajo
export READ_ONLY=0
export DRY_RUN=0
export REAL_DEPLOY=1

echo "Estado nuevo (VENTANA ABIERTA):"
echo "  READ_ONLY: $READ_ONLY"
echo "  DRY_RUN: $DRY_RUN"
echo "  REAL_DEPLOY: $REAL_DEPLOY"
echo ""

# Timestamp para documentación
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "Timestamp apertura: $TIMESTAMP"
echo ""

echo "✅ [RUNART] Staging window OPENED"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   - Staging está ahora en MODO TRABAJO (escritura habilitada)"
echo "   - Puedes aprobar contenidos, escribir JSON, probar endpoints"
echo "   - RECUERDA cerrar la ventana cuando termines con:"
echo "     source ./scripts/deploy_framework/close_staging_window.sh"
echo ""
echo "================================================================================"
