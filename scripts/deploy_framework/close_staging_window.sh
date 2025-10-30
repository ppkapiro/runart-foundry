#!/usr/bin/env bash
#
# CERRAR VENTANA DE MANTENIMIENTO STAGING
# RunArt Foundry — Protocolo de ventana de mantenimiento
#
# Propósito:
#   Volver staging a MODO PROTEGIDO (solo lectura, dry-run)
#
# IMPORTANTE:
#   - Solo usar cuando hayas terminado de trabajar en staging
#   - Documentar SIEMPRE el cierre en bitácora
#   - Verificar que no haya procesos pendientes antes de cerrar
#
# Uso:
#   source ./scripts/deploy_framework/close_staging_window.sh
#

set -euo pipefail

echo "================================================================================"
echo "🔴 CERRANDO VENTANA DE MANTENIMIENTO STAGING"
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

# CERRAR VENTANA: Modo protegido
export READ_ONLY=1
export DRY_RUN=1
export REAL_DEPLOY=0

echo "Estado nuevo (MODO PROTEGIDO):"
echo "  READ_ONLY: $READ_ONLY"
echo "  DRY_RUN: $DRY_RUN"
echo "  REAL_DEPLOY: $REAL_DEPLOY"
echo ""

# Timestamp para documentación
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "Timestamp cierre: $TIMESTAMP"
echo ""

echo "✅ [RUNART] Staging window CLOSED"
echo ""
echo "ℹ️  Staging está ahora en MODO PROTEGIDO:"
echo "   - Solo lectura (READ_ONLY=1)"
echo "   - Dry-run activado (DRY_RUN=1)"
echo "   - Deploys reales deshabilitados (REAL_DEPLOY=0)"
echo ""
echo "================================================================================"
