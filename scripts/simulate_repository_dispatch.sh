#!/usr/bin/env bash
set -euo pipefail
# Simula el workflow receive_repository_dispatch creando un log de evidencia.
# Uso: simulate_repository_dispatch.sh <event_type> [payload_json]

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$REPO_ROOT/docs/ops/logs"
mkdir -p "$LOG_DIR"

EVENT_TYPE="${1:-wp_content_published}"
PAYLOAD_JSON="${2:-{\"example\":true}}"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
LOG_FILE="$LOG_DIR/run_repository_dispatch_${TS}.log"

{
  echo "event=${EVENT_TYPE}"
  echo "payload=${PAYLOAD_JSON}"
  echo "ts=${TS}"
} > "$LOG_FILE"

echo "✅ Simulado repository_dispatch → $LOG_FILE"
