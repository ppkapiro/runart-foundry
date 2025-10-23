---
status: archived
owner: reinaldo.capiro
updated: 2025-10-15
audience: internal
tags: [briefing, runart, ops]
---

# Pipeline Canario — Diagnóstico (20251015T200044Z UTC)

Host: https://runart-foundry.pages.dev

## KV detectado
- RUNART_ROLES: presente ✅
- CANARY_ROLE_RESOLVER_EMAILS: presente ✅

## Comparativa
| Caso | Esperado | X-RunArt-Canary | X-RunArt-Resolver | Archivo |
|------|----------|------------------|-------------------|---------|
| owner | owner | ? | ? | whoami_headers_owner.txt |
| client_admin | client_admin | ? | ? | whoami_headers_client_admin.txt |
| team | team | ? | ? | whoami_headers_team.txt |
| client | client | ? | ? | whoami_headers_client.txt |
| control_legacy | (legacy) | ? | ? | whoami_headers_control_legacy.txt |

## Veredicto (marcar)
- [ ] **GO** → Activar canario global en preview (ROLE_RESOLVER_SOURCE="utils").
- [ ] **NO-GO** → Mantener legacy; abrir fix con evidencias.

## Observaciones de headers (si faltan, puede que Access/curl fallback esté en uso)

