#!/usr/bin/env bash
set -e
BRANCH="$1"
HOST_BRANCH="$2"
HOST_JSON="$3"
ISSUE_TITLE="Habilitar Access para preview por rama: $BRANCH"
ISSUE_BODY="Checklist:\n\n- [ ] Access → Applications → RUN Briefing → + Add public hostname: $HOST_BRANCH/*\n- [ ] Agregar policy de CI (Service Auth/Bypass con Service Token)\n- [ ] En policy humana, OTP + Exclude service tokens\n- [ ] Guardar y validar con curl y verificador local\n\nAdjunto diagnóstico de host:\n\n$HOST_JSON\n"

gh issue create --title "$ISSUE_TITLE" --body "$ISSUE_BODY"