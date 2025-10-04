
### v0.2 — Etapa 2 (Roles + CSS base)
- Roles admin/equipo/cliente activados vía `/api/whoami` (Cloudflare Access).
- UI con `data-role` + ocultamiento `.interno`.
- Tokens/estados CSS base + documentación de accesos y estilos.
- Sin nuevos warnings de MkDocs (baseline conservado).

### v0.6 — Cierre Etapa 6
- CI validada con gates obligatorios (`make build`, `make test-logs`).
- Secrets reales de Cloudflare KV configurados.
- `GET /api/logs_list` y `POST /api/log_event` operativos en Pages (sin fallback).
- Allowlist y sampling activos en logger.
- Build MkDocs y tests de logs: ✅ PASS.
