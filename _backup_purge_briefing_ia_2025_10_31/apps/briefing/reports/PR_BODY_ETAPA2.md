# Etapa 2 — Roles reales + CSS base + docs mínimas

## Qué
- GET `/api/whoami` con roles: **admin** (ACCESS_ADMINS), **equipo** (ACCESS_EQUIPO_DOMAINS), **cliente** (resto).
- UI: `<html data-role="…">` + clase `role-cliente`; toggle “Ver como” (solo admin, visual).
- CSS base: tokens `--space-*`, `--radius`; estados `.is-busy`, `.msg-*`.
- Control de visibilidad `.interno` (nav + contenido).
- Doc mínima: “Accesos y estilos (ETAPA 2)” en `docs/index.md`.

## Cómo probar
1. `make venv && make build` → PASS, **sin nuevos warnings** vs baseline.
2. `/api/whoami` → `{ email, role, ts }` según Access.
3. UI:
   - `data-role` correcto.
   - `.interno` oculto para cliente (o “ver como=cliente”).
   - Toggle solo visible para admin; persistencia en localStorage.

## No-regresión
- Warnings MkDocs = baseline.
- Sin cambios de rutas ni 404 de assets.

## Evidencias
- Ver `briefing/reports/quality/QUALITY_P9.md` y `BUILD_TAIL_P9.txt`.

## Checklist
- [x] whoami.js (admin/equipo/cliente)
- [x] main.html `data-role` + `role-cliente`
- [x] extra.css tokens/estados + ocultamiento `.interno`
- [x] nav con `class: interno` en secciones internas
- [x] docs/index.md sección “Accesos y estilos”
- [x] build PASS sin warnings nuevos
