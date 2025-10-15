#!/usr/bin/env bash
set -euo pipefail

BRANCH="${1:-unknown}"
HOST_BRANCH="${2:-}" 
HOST_JSON="${3:-}" 

ISSUE_TITLE="Habilitar Access para preview por rama: ${BRANCH}"
ISSUE_BODY=$(cat <<EOF
Checklist:

- [ ] Access -> Applications -> RUN Briefing -> + Add public hostname: ${HOST_BRANCH}/*
- [ ] Agregar policy de CI (Service Auth/Bypass con Service Token)
- [ ] En policy humana, OTP + Exclude service tokens
- [ ] Guardar y validar con curl y verificador local

Adjunto diagnostico de host (JSON crudo):

${HOST_JSON}
EOF
)

if ISSUE_DATA=$(gh issue create --repo RunArtFoundry/runart-foundry --title "${ISSUE_TITLE}" --body "${ISSUE_BODY}" --json number,url 2>/dev/null); then
	ISSUE_NUMBER=$(echo "${ISSUE_DATA}" | jq -r '.number')
	ISSUE_URL=$(echo "${ISSUE_DATA}" | jq -r '.url')
	echo "Issue creado: #${ISSUE_NUMBER} (${ISSUE_URL})"
else
	echo "WARN: no se pudo crear issue automático para ${HOST_BRANCH}. Ejecutar manualmente." >&2
fi