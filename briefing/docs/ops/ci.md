# CI & Gates — Etapa 6

La CI ejecuta dos checks obligatorios en cada PR:
- **Build MkDocs** (`make build`)
- **Logs tests** (`make test-logs` / `scripts/test_logs_strict.mjs`)

## Requisitos
- Secrets válidos de Cloudflare KV: `CF_LOG_EVENTS_ID`, `CF_LOG_EVENTS_PREVIEW_ID`.
- Para desplegar desde GitHub Actions: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`.

## Flujo
1. `make venv` prepara dependencias de MkDocs.
2. `make build` compila el sitio y detecta warnings críticos.
3. `make test-logs` ejecuta el script de logs. Si `scripts/test_logs.mjs` no existe,
   se usa `scripts/test_logs_strict.mjs`, que llama a `POST /api/log_event` y
   `GET /api/logs_list`.
4. Opcional: `deploy` crea `wrangler.toml` y publica en Cloudflare Pages cuando la rama es `main`.

## Criterios de aceptación
- Ambos checks deben estar en verde para poder fusionar a `main`.
- En producción (`Pages`), `GET /api/logs_list` debe responder sin `fallback: true` y
  `POST /api/log_event` respeta allowlist y sampling.
- Si aparece "noop" en los logs del job, indica que falta el test estricto: este repo
  incluye `scripts/test_logs_strict.mjs` para asegurar la cobertura.

## Troubleshooting
- **Faltan secrets**: configura los cuatro secretos en `Settings → Secrets and variables → Actions`.
- **Fallo en logs tests**: revisa `briefing/functions/api/log_event.js` y `logs_list.js`,
  confirma que las rutas están sincronizadas y que el worker tiene binding `LOG_EVENTS`.
- **MkDocs build falla**: ejecuta `make venv && make build` en local para replicar y verifica
  advertencias nuevas en la salida.
