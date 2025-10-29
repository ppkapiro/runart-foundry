#!/usr/bin/env bash
set -e
REPO="RunArtFoundry/runart-foundry"
OUT="_reports/metrics_runs.tsv"
gh api repos/$REPO/actions/runs --paginate \
| jq -r '
  .workflow_runs[]
  | [.id, .name, .status, .conclusion,
     ((.updated_at | fromdateiso8601) - (.run_started_at | fromdateiso8601))]
  | @tsv' > "$OUT"
echo "[OK] Métricas exportadas a $OUT"
