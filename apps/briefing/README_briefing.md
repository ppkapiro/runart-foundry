# Estado del Proyecto — Octubre 2025

## Fuente canónica de documentación
- **Documentación activa**: [`docs/live/`](../../docs/live/)
  - Hubs temáticos: [Arquitectura](../../docs/live/architecture/index.md), [Operaciones](../../docs/live/operations/index.md), [UI/Roles](../../docs/live/ui_roles/index.md)
  - Estado operativo: [`docs/status.json`](../../docs/status.json) (regenerar con `make status_update`)
- **Archivo histórico**: [`docs/archive/`](../../docs/archive/)

## Estado del proyecto
- [x] **Fase 0 – Diagnóstico** (cerrada)
- [x] **Fase 1 – Pilotos y estructura base** (cerrada)
- [x] **Fase 2 – Automatización y control** (cerrada) — ver [Corte de Control — Fase 2](./docs/client_projects/runart_foundry/reports/corte_control_fase2.md)
- [x] **Fase ARQ – Sistema briefing interno** (cerrada)
- [x] **ARQ+ v1 – Navegación y exportaciones** (cerrada)

📎 Referencia: [Arquitectura del Briefing](docs/briefing_arquitectura.md)

### Visibilidad por rol

**Prioridad de resolución actual:** `owner > client_admin > client > team > visitor`.

| Email / dominio | Rol asignado | Fuente |
| --- | --- | --- |
| `ppcapiro@gmail.com` | owner | `access/roles.json` · `ACCESS_ADMINS` |
| `runartfoundry@gmail.com` | client_admin | `access/roles.json` |
| `musicmanagercuba@gmail.com` | client | `access/roles.json` |
| `infonetwokmedia@gmail.com` | team | `access/roles.json` |
| dominios listados en `team_domains` (`runartfoundry.com`) | team | `access/roles.json` / KV |

- `/api/whoami` expone `{ role, rol }` (inglés + alias en español) y refleja `RUNART_ENV`.
- Middleware inyecta cabeceras `X-RunArt-Email`, `X-RunArt-Role` y `X-RunArt-Role-Alias` para el resto de Functions.
- `/api/inbox` permite `owner`, `client_admin`, `team`; el resto obtiene 403.
- `/api/admin/roles` (fase 3) controlará altas/bajas persistiendo en `RUNART_ROLES` y registrando en `LOG_EVENTS`.

| Sección / módulo | Equipo | Cliente | Visitante |
| --- | :---: | :---: | :---: |
| Reportes (cliente) | ✅ | ✅ | 🔒 |
| Reportes (interno) | ✅ | 🔒 | 🔒 |
| Decisiones e Inbox | ✅ | 🔒 | 🔒 |
| Documentación técnica | ✅ | ✅ | 🔒 |
| Press-kit | ✅ | ✅ | 🔒 |
| Plan & Roadmap / Proceso | ✅ | ✅ | 🔒 |

> Nota: La segmentación actual se controla con `overrides/roles.js` y las clases `interno` en la navegación de `mkdocs.yml`.

### Acciones pendientes (tras corte Fase 2)
- Sustituir imágenes dummy por optimizadas en las fichas piloto e intermedias.  
- Corregir/validar enlaces externos con alerta.  
- Confirmar PDFs v0/v1 publicados (ES/EN).  
- Reejecutar corte de control tras las correcciones.  

### Roadmap inmediato
- **Fase 3 – Escalamiento de fichas y contenidos**  
   Ampliar de 10 a 20–30 proyectos documentados, con bio extendida, narrativa corporativa definitiva y testimonios reales.  

- **Fase 4 – Traducción bilingüe**  
   Traducir fichas y press-kit al inglés con consistencia en PDFs y navegación.  

*(Ver [Master Plan](./docs/client_projects/runart_foundry/reports/2025-10-02_master_plan.md) para roadmap completo hasta Fase 8.)*

---

# RUN Art Foundry — Micrositio Briefing (submódulo)

## Qué es
Micrositio privado (MkDocs Material) para documentar plan, fases, auditoría, proceso y captura de **Decisiones** (formulario → Cloudflare Worker + KV) con acceso restringido (Cloudflare Access).

## Estructura
- Ubicación canónica: `apps/briefing/` (la capa `briefing/` fue archivada en `_archive/legacy_removed_20251007/`).
- Estado del switch: ✅ Lista para ejecutar — ver `docs/internal/briefing_system/architecture/065_switch_pages.md` para checklist y evidencias requeridas.
- `mkdocs.yml` configuración del micrositio.
- `docs/` contenido en Markdown (cliente en `client_projects/runart_foundry/` e interno en `internal/briefing_system/`).
- `overrides/` meta `noindex` y ajustes del tema.
- `functions/api/` Pages Functions (decisiones.js, inbox.js) con binding `DECISIONES`.
- `wrangler.toml` configuración de Pages con bindings KV.

## Requisitos
- Python 3.11+ y `pip install mkdocs mkdocs-material`.
- Cloudflare Pages (build de MkDocs), Cloudflare Access y KV (namespace `DECISIONES`).
- Pages Functions para los endpoints de API (sin necesidad de workers.dev).

## Gates de CI (Etapa 6)
- **Build MkDocs**: `make build`
- **Logs tests**: `make test-logs` (usa `scripts/test_logs_strict.mjs` si no existe la versión básica)

Consulta `docs/internal/briefing_system/ops/ci.md` para los requisitos, flujo completo y troubleshooting.

## Resumen de la etapa actual (cerrada)
- **ARQ-0 — Baseline**: Estructura MkDocs, despliegue en Cloudflare Pages y acceso privado con Access.
- **ARQ-1 — Roles y navegación**: Segmentación por rol en `mkdocs.yml` y overrides.
- **ARQ-2 — Editor guiado**: Captura de fichas con validación previa y POST seguro al inbox.
- **ARQ-3 — Seguridad y moderación**: Token, honeypot y flujo pending/accept/reject respaldado por smoke tests.
- **ARQ-4 — Dashboards cliente**: KPIs resumidos (accepted/pending/rejected, ventana 7d y latencia).
- **ARQ-5 — Exportaciones MF**: Descarga JSONL/CSV filtrada por fechas con sesión Access.
- **ARQ-6 — QA continuo**: Scripts de smoke (`qa_arq6.sh`) y validaciones de estructura.
- **ARQ+ v1 — Navegación limpia + ZIP**: Enlaces internos neutralizados y export ZIP (JSONL+CSV) empaquetado.

## Cómo navegar
- [Arquitectura](docs/briefing_arquitectura.md)
- [Corte Fase ARQ](docs/client_projects/runart_foundry/reports/corte_arq.md)
- [Mapa de interfaces (ARQ)](docs/arq/mapa_interfaces.md)
- [Dashboards KPIs (cliente)](docs/dashboards/cliente.md)
- [Herramientas → Editor](docs/editor/index.md)
- [Herramientas → Inbox](docs/inbox/index.md)
- [Herramientas → Exportaciones](docs/exports/index.md)

> Las rutas de herramientas y APIs requieren sesión válida en Cloudflare Access.

## Estado del deployment

### ✅ Completado
- **Sitio local**: http://127.0.0.1:8000 (ejecutar `cd apps/briefing && make serve`)
- **Cloudflare Pages**: https://runart-foundry.pages.dev/
- **Preview (hash)**: consultar el output `preview_url` del step `deploy-preview` en GitHub Actions (no existe `preview.<project>.pages.dev` por defecto)

> **Nota**: Las URLs de preview se toman del output (hash) de cloudflare/pages-action; NO usar preview.<project>.pages.dev.
- **KV Namespaces**:
  - Production: `6418ac6ace59487c97bda9c3a50ab10e`
  - Preview: `e68d7a05dce645478e25c397d4c34c08`

### ✅ Arquitectura final (Pages Functions)

**Backend**: Los endpoints de API ahora corren como **Cloudflare Pages Functions** integradas en el mismo dominio de Pages, sin necesidad de workers.dev:
- `POST https://runart-foundry.pages.dev/api/decisiones`
- `GET https://runart-foundry.pages.dev/api/inbox`

**Bindings KV**:
- Production: `6418ac6ace59487c97bda9c3a50ab10e`
- Preview: `e68d7a05dce645478e25c397d4c34c08`

### 🚀 Pipeline real (2025-10-09)
- **Orquestador**: `docs/internal/briefing_system/plans/04_orquestador_pipeline_real.md` (AUTO_CONTINUE, D1–D6).
- **Workflows**: `pages-preview.yml`, `pages-preview2.yml`, `pages-prod.yml` generan despliegues para Preview, CloudFed y Producción.
- **QA Local**: `npm run build` + `npm run test:unit:smoke` (2025-10-09T14:25Z) documentados en D4.
- **Smokes Producción**: `_reports/tests/T4_prod/20251009T124000Z_production_smokes.json` (5/5 PASS).
- **Logs adicionales**: `docs/internal/briefing_system/reports/2025-10-10_local_build_and_dev.log`, `_reports/tests/T3_e2e/20251009T153900Z_preview_smokes.json`, `_reports/tests/T4_prod/20251009T154500Z_production_smokes.json`.
- **Entornos activos**:
   - Local: `wrangler pages dev site --port 8787` (bindings `.dev.vars`).
   - Preview: URL hash entregada por Cloudflare Pages (`deploy-preview.preview_url` en GitHub Actions).
   - CloudFed Preview2: `https://preview2.runart-foundry.pages.dev` (302 → `/dash/visitor` con Access).
   - Producción: `https://runart-foundry.pages.dev` (protegido con Cloudflare Access, 302 esperado sin sesión).
- **Completado 2025-10-09**: IDs `kv_*_preview2` aplicados en `wrangler.toml`, deploy manual mediante `wrangler pages deploy --branch preview2` y smoke `_reports/tests/T3_e2e/20251009T192112Z_preview2_smokes.json` documentado.
- Configurados en `wrangler.toml`

### ⚠️ Acción requerida (usuario)

1. **Activar Cloudflare Access** (privacidad - OBLIGATORIO):
   - Ir a: https://dash.cloudflare.com/a2c7fc66f00eab69373e448193ae7201/pages
   - Seleccionar proyecto `runart-foundry`
   - En Settings → Access → Enable Access
   - Crear regla "Allow" solo para correo de Uldis
   - Una vez activo, el header `Cf-Access-Authenticated-User-Email` poblará el usuario real

2. **Opcional - CI/CD con GitHub Actions**:
   - Crear secretos en GitHub:
     - `CF_API_TOKEN`: Token de API de Cloudflare
     - `CF_ACCOUNT_ID`: `a2c7fc66f00eab69373e448193ae7201`
   - Mover `.github/workflows/briefing_pages.yml` a la raíz del repo (si el repo Git incluye todo el proyecto)

## Pasos sugeridos (usuario)
1) Servir en local:
   ```bash
   cd apps/briefing
   make serve
   # Configura el entorno si es la primera vez
   make venv
   make serve
   ```

2) Build y redeploy:
   ```bash
   cd apps/briefing
   make build
   npx wrangler pages deploy site --project-name runart-foundry
   ```

## Operativa

### Promover fichas del inbox → YAML
1. Abrir **Actions → Promote Inbox → YAML** y lanzar `Run workflow`.
2. Verificar o ajustar el parámetro `source_url` (por defecto: `/api/inbox`).
3. Tras la ejecución se generan automáticamente:
   - `docs/projects/<slug>.yaml` (ficha preliminar en español).
   - `docs/projects/en/<slug>.yaml` (stub en inglés).
   - `assets/<year>/<slug>/.gitkeep` (carpeta para medios futuros).
4. El menú del briefing añade la sección **“Nuevas fichas (ES)”** con los slugs generados.
5. Consultar `./docs/client_projects/runart_foundry/reports/fase1_fichas.md` y `./_logs/briefing_run.log` para el registro de la promoción.

### Capturar fichas con el editor guiado
1. Ir a **Herramientas → Editor** en la navegación interna (rol equipo).
2. Completar los campos requeridos (slug, título, artista, año) y cargar listas con el formato `https://url | detalle`.
3. Revisar la vista previa YAML y, si es correcto, copiarla o enviarla directo al inbox (`/api/decisiones`).
4. Cada envío añade `token_origen: editor_v1` y un comentario interno para trazabilidad.
5. Antes de promover, ejecutar `python scripts/validate_projects.py` desde `briefing/` para confirmar que la ficha cumple el esquema.

### ARQ-3 · Seguridad y Moderación — Operativa
- **Flujo**: `Editor (token + honeypot + origin-hint) → KV (estado pending) → Moderar (accept/reject) → Visibilidad cliente (solo accepted)`.
- **Variables en Cloudflare Pages**:
   - `EDITOR_TOKEN` (Secret): Token compartido entre editor, inbox y CLI (`RUN_TOKEN`).
   - `MOD_REQUIRED` (Variable): `1` para exigir revisión manual (default), `0` para aceptar automáticamente.
   - `ORIGIN_ALLOWED` (Variable): Prefijo permitido para `Origin/Referer` (ej. `https://runart-foundry.pages.dev`).
- **Smoke tests**: Ejecutar `apps/briefing/scripts/smoke_arq3.sh` tras escudos de Access (o `briefing/scripts/...` mientras dure la compatibilidad).
   ```bash
   PAGES_URL=https://runart-foundry.pages.dev \
   RUN_TOKEN=dev-token \
   ACCESS_JWT="$(cat /path/to/cf_access.jwt)" \
   bash apps/briefing/scripts/smoke_arq3.sh
   ```
- **Resultados**: Muestra códigos HTTP esperados ✅ / tolerados ⚠️ / errores ❌.
- **Notas**: Si el entorno usa Cloudflare Access, pasa el JWT vía `ACCESS_JWT` o reutiliza cookies (`ACCESS_COOKIE_FILE`).

### ARQ-4 · Dashboard (MF)
- **Qué muestra**: Totales por estado (Accepted, Pending, Rejected), nuevos envíos en los últimos 7 días y latencia media de moderación (horas, 1 decimal).
- **Dónde verlo**: Navegación → `Dashboards → KPIs (cliente)`.
- **Requisitos**: Sesión válida mediante Cloudflare Access; sin ella, el panel indica que requiere autenticación y no carga datos.
- **Limitaciones MF**: Indicadores básicos y sparkline SVG simple de 14 días; sin filtros ni visualizaciones avanzadas.

### ARQ-5 · Exportaciones (MF)
- **Qué exporta**: Fichas accepted filtradas por rango de fechas, en formatos JSONL (una ficha por línea) y CSV resumido.
- **Dónde acceder**: Navegación → `Herramientas → Exportaciones (MF)` (visible solo para equipo).
- **Requisitos**: Sesión activa mediante Cloudflare Access; el módulo consulta `/api/inbox` directamente desde el navegador.
- **Limitaciones MF**: Sin ZIP ni PDF, sin empaquetado de medios; queda preparado para extenderse en la v1.1 si se requiere.

### ARQ+ v1 — limpieza de warnings (preparado para ZIP)
- MkDocs deja de emitir warnings por rutas fuera de `docs/` — los enlaces internos hacia `audits/`, `scripts/` y `assets/` se neutralizaron temporalmente con la marca *“recurso interno no publicado”*.
- Cuando los recursos externos se publiquen oficialmente (o cuando se integre el ZIP v1.1), bastará revertir la neutralización para restaurar los hipervínculos.

#### QA Export (smoke)
Para validar rápidamente que el endpoint `/api/export_zip` responde (requiere sesión Access en navegador para la verificación visual):

```bash
PAGES_URL=https://runart-foundry.pages.dev \
RUN_TOKEN=dev-token \
bash apps/briefing/scripts/smoke_exports.sh
```

### Corte ARQ (MF)
- **Cobertura**: ARQ-0 → ARQ-5 completados (baseline, roles, editor, seguridad/moderación, dashboard cliente y exportaciones).
- **Reporte**: Ver [`reports/corte_arq.md`](./docs/client_projects/runart_foundry/reports/corte_arq.md) para resumen, QA y pendientes.
- **Mapa de interfaces (ARQ)**: ver `Reportes → Mapa de interfaces (ARQ)`.
- **Warnings conocidos**: Navegación incluye rutas fuera de `docs/`; MkDocs emite avisos tolerados hasta reubicar reportes/PDFs en fases siguientes.
- **Próxima fase sugerida**: Endurecimiento adicional y limpieza de navegación (rate limiting, filtros KPIs, export ZIP/PDF, reorden de reportes).

## Build & QA
```bash
cd apps/briefing
make venv           # prepara entorno virtual y dependencias
make build          # compila MkDocs (warnings tolerados inventariados)
make serve          # opcional: vista previa local

# QA funcional - PRODUCCIÓN (reconoce Access redirects como PASS)
PROD_URL=https://runart-foundry.pages.dev \
RUN_TOKEN=dev-token \
make test-smoke-prod                    # smoke test optimizado para producción

# QA funcional - AVANZADO (Node.js con reporting)
PROD_URL=https://runart-foundry.pages.dev \
make test-smoke-wrapper                 # smoke test con configuración automática

# QA funcional - LEGACY (corregido para Access)
PAGES_URL=... RUN_TOKEN=... \
   bash scripts/smoke_arq3.sh           # smoke ARQ-3 con manejo de redirects
PAGES_URL=... RUN_TOKEN=... \
   bash scripts/smoke_exports.sh        # verifica /api/export_zip (requiere Access)

# Validación de fichas (opcional)
python scripts/validate_projects.py docs/projects/<slug>.yaml
```

### Inventario de páginas (preview 2025-10-07)
- Generar snapshot del build con `python tools/list_site_pages.py --root apps/briefing/site --output apps/briefing/_reports/snapshots/site_preview_2025-10-07.tsv`.
- Baseline bootstrap (sin snapshot histórico del tag) en `_reports/snapshots/site_baseline_briefing-cleanup-20251007.tsv`.
- Reporte de diff (`tools/diff_site_snapshots.py`) disponible en [`_reports/diff_briefing-cleanup-20251007.md`](_reports/diff_briefing-cleanup-20251007.md) → Added 0 · Removed 0 · Changed 0 · Unchanged 57.

### 🚀 Despliegue APU 2025-10-07
- Merge final: `deploy/apu-briefing-20251007` → `main` (`deploy: briefing-cleanup-20251007 (release final)` en 2025-10-06T21:36:39Z).
- Producción Cloudflare Pages: <https://briefing.runartfoundry.com> (verificar banner `env: production` y navegación Cliente/Interno).
- Validaciones post-despliegue esperadas: `/api/whoami` → 200 (`env:"production"`), `/api/inbox` → 403 sin token, `/api/decisiones` → 401 sin token.
- Documentación asociada: bitácora [`082_reestructuracion_local`](docs/internal/briefing_system/ci/082_reestructuracion_local.md) y [`CHANGELOG.md`](CHANGELOG.md).
- Tag release: `briefing-cleanup-20251007` y PR `deploy: briefing-cleanup-20251007 (Cloudflare Pages)` (revisión ARQ).

## Enlaces internos no publicados
- `python scripts/neutralize_external_links.py`: neutraliza enlaces a `audits/`, `scripts/` y otros recursos fuera de `docs/`, generando un snapshot en `_tmp/link_toggle_snapshot.json`.
- `python scripts/neutralize_external_links.py --dry-run`: vista previa sin escribir cambios.
- `ENABLE_PUBLISH=1 python scripts/neutralize_external_links.py` (o `--mode publish`): restaura los hipervínculos originales usando el snapshot cuando los recursos se publiquen.
- Conserva el snapshot en Git hasta completar la publicación; al volver a neutralizar, se reemplaza automáticamente.

## Archivos creados
```
apps/briefing/
├─ mkdocs.yml
├─ README_briefing.md
├─ docs/
│  ├─ index.md
│  ├─ client_projects/
│  │  └─ runart_foundry/
│  │     ├─ plan/index.md
│  │     ├─ auditoria/index.md
│  │     └─ reports/
│  ├─ internal/
│  │  └─ briefing_system/
│  │     ├─ architecture/
│  │     ├─ ops/
│  │     └─ ci/
│  ├─ decisiones/
│  ├─ editor/
│  ├─ exports/
│  ├─ inbox/
│  └─ ...
├─ overrides/
│  ├─ extra.css
│  └─ main.html
├─ functions/
│  └─ api/
└─ workers/
   └─ decisiones.js
```

## Próxima etapa
Consulta [`NEXT_PHASE.md`](../../NEXT_PHASE.md) para el alcance inmediato: roles diferenciados, mejoras de CSS/UI y endurecimiento opcional.

## Cierre de etapa (ARQ+ v1)
- Auditoría y build final ejecutados.
- Enlaces internos: toggle publish/neutralize documentado.
- Siguiente etapa: ver `NEXT_PHASE.md` (roles y CSS/UI).
