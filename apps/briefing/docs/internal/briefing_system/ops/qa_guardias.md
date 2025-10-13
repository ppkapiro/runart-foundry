# Guardia QA y Automatizaciones

**Versión:** v0.1 — 2025-10-08  
**Stream:** QA + Reporting automatizado  
**Responsable primario:** Runart DevOps  
**Soporte:** Plataforma + Operaciones

---

## 1. Alcance
- Ejecutar y monitorear los workflows de QA:
  - `Docs Lint` (`.github/workflows/docs-lint.yml`)
  - `Environment Report` (`.github/workflows/env-report.yml`)
  - `Status & Changelog Update` (`.github/workflows/status-update.yml`)
- Publicar y archivar la evidencia de cada corrida en `_reports/qa_runs/<timestamp>/`.
- Escalar incidencias que bloqueen deploys, sesiones “Ver como” o reporting semanal.

## 2. Matriz de guardia
| Ventana | Responsable | Contacto | Notas |
| --- | --- | --- | --- |
| Lunes a viernes (14:00–20:00 UTC) | Copilot / DevOps | #runart-ops | Ventana principal para merges y releases. |
| Fines de semana | Plataforma | #runart-plataforma | Sólo respuesta a incidentes críticos. |
| Escalamiento | PM Runart | #runart-core | Cualquier falla >4h o caída de Access. |

## 3. Checklists por workflow

### 3.1 Docs Lint
- Trigger: PRs a `main` o `deploy/**` que toquen `apps/**`, `docs/**`, `*.md`.
- Qué valida: `mkdocs build --strict`, snippets `--8<--`, encabezados H1 y espacios finales (script `tools/lint_docs.py`).
- Acción esperada: ✅ successful job + artifact `docs-lint-log`.
- Falla común: páginas fuera de `nav`. Resolver ajustando `mkdocs.yml` o marcando como _draft_.

### 3.2 Environment Report
- Trigger: cualquier PR (workflow `env-report.yml`).
- Pasos:
  1. Resolver URL de preview (Cloudflare Pages).
  2. Ejecutar `tools/check_env.py --mode=config`.
  3. Ejecutar `tools/check_env.py --mode=http --base-url PREVIEW --expect-env preview` (si hay URL).
- Acción esperada: Comentario en el PR con estado ✅/⚠️/❌ y artifact `env-check-log`.
- Falla común: preview aún no desplegada → se registra ⚠️ con fallback.

### 3.3 Status & Changelog Update
- Trigger: Push a `main` o `workflow_dispatch` manual.
- Pasos automatizados:
  1. Publica secciones de `CHANGELOG.md` marcadas como _Unreleased_.
  2. Inserta el evento en `STATUS.md` bajo “Últimos hitos”.
  3. Crea commit `chore(docs): update status & changelog [skip ci]` si hubo cambios.
- Revisión: confirmar que el commit aparece en GitHub y que `STATUS.md` refleja la fecha correcta.

## 4. Evidencia y reportes
- Guardar cada corrida manual/local en `_reports/qa_runs/<timestamp>/` incluyendo:
  - `docs-lint.log`
  - `env-check-config.log` y, si aplica, `env-check-http.log`
  - Extractos del summary de GitHub Actions (`run_summary.md`)
- Actualizar `docs/internal/briefing_system/reports/2025-10-11_fase5_ui_contextual_y_experiencias_por_rol.md` con referencias a la carpeta.
- Notificar en Bitácora 082 con el timestamp y resultado global.

## 5. Protocolo de incidentes
1. Registrar incidente en `docs/internal/briefing_system/ops/incidents.md`.
2. Compartir enlace al run fallido y a la carpeta de `_reports/qa_runs/<timestamp>/`.
3. Abrir issue en GitHub si requiere fix estructural (tag `qa` + `automation`).
4. Cerrar incidente sólo cuando:
   - Workflow vuelve a verde.
   - Evidencia actualizada.
   - Stakeholders informados.

## 6. Próximos pasos
- Integrar `env_report` con los dashboards `/dash/{role}` una vez estén disponibles APIs reales.
- Preparar smoke tests HTTP adicionales (`/api/inbox`, `/api/logs/summary`).
- Automatizar la publicación de evidencia en Notion/Runart Core.
