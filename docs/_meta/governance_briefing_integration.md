# Gobernanza — Integración Briefing + status.json
**Sprint 3 — Hardening + Observabilidad**

**Última actualización:** 2025-10-23  
**Owner:** @ppkapiro  
**Revisores:** @team-docs, @team-infra

---

## 📋 Objetivo

Este documento establece la gobernanza técnica de la integración **Briefing + status.json + Auto-posts**, incluyendo:
- Roles y responsabilidades
- Proceso de cambios (RFC, PR, tests)
- Políticas de rollback y comunicación
- SLA y métricas de calidad

---

## 👥 Roles y Responsabilidades

### Owner Principal

**@ppkapiro** (Integration Lead)

- Aprobación final de cambios críticos (esquema JSON, workflows)
- Revisión de RFCs y propuestas de extensión
- Monitoreo de KPIs semanales
- Coordinación con equipo docs e infra

### Revisores

**@team-docs** (Documentation Team)

- Revisión de templates y contenido generado
- Validación de frontmatter y metadatos
- Testeo de páginas Briefing (/status, /news, /history)

**@team-infra** (Infrastructure Team)

- Revisión de workflows GitHub Actions
- Validación de seguridad (secrets, tokens)
- Monitoreo de logs de ejecución

### Contributors

Cualquier miembro del proyecto puede:
- Proponer mejoras vía issue `integration/enhancement`
- Reportar bugs vía issue `integration/bug`
- Crear PRs para hotfixes (con revisión owner)

---

## 🔄 Flujo de Cambios

### Cambios Menores (Hotfix, Typos)

**Ejemplos:** Correcciones de typos en templates, ajuste de mensajes de log.

**Proceso:**
1. Crear issue `integration/hotfix`
2. PR directo a `main`
3. Revisión por 1 owner
4. Merge tras CI verde

**SLA:** <24h

---

### Cambios Mayores (Features, Refactors)

**Ejemplos:** Nuevos campos en status.json, cambios en estructura de posts, nuevos workflows.

**Proceso:**
1. Crear issue `integration/proposal` con descripción detallada
2. **RFC** si el cambio afecta:
   - Esquema JSON (breaking changes)
   - Workflows críticos (publish, audit)
   - Dependencias externas (APIs, webhooks)
3. PoC funcional en rama `feat/` o `refactor/`
4. PR a `main` con:
   - Tests unitarios (cobertura >80%)
   - Dry-run manual validado
   - Documentación actualizada (`INDEX_INTEGRATIONS.md`, `governance_briefing_integration.md`)
5. Revisión por 2+ owners
6. Merge tras CI verde + approval
7. **Monitoreo 1ª semana** (logs, KPIs, alertas)

**SLA:** 5-10 días

---

### Cambios Críticos (Breaking Changes)

**Ejemplos:** Migración de esquema JSON v1 → v2, cambio de MkDocs a otro SSG, refactor completo de workflows.

**Proceso:**
1. RFC obligatorio con:
   - Justificación técnica
   - Plan de migración (backward compatibility)
   - Estimación de esfuerzo (horas)
   - Impacto en dependencias downstream
2. Discusión pública (issue + reunión síncrona)
3. Aprobación por **100% owners**
4. PoC validado en staging/preview
5. PR a `main` con migration guide
6. Rollout gradual (feature flags si aplica)
7. **Monitoreo 2 semanas** con rollback plan activo

**SLA:** 2-4 semanas

---

## 🛑 Política de Rollback

### Trigger de Rollback Automático

El script `auto_rollback.py` se ejecuta automáticamente si:
- Validación de `status.json` falla (schema inválido)
- Build de MkDocs falla en canary step
- Frontmatter de status/news inválido

**Acciones:**
1. Restaurar `docs/status.json` desde backup (`.bak`)
2. Revertir archivos generados (`status/index.md`, `news/*.md`)
3. Commit con `[skip ci]` y mensaje `revert: auto-rollback briefing publish`
4. Enviar alerta Slack/Discord (nivel ERROR)

### Rollback Manual (Decisión Humana)

**Cuándo:**
- KPIs degradados >48h (uptime workflow <95%, latencia >10min)
- Bugs críticos detectados por usuarios
- Datos incorrectos publicados en Briefing

**Proceso:**
1. Owner declara rollback en issue dedicado
2. Identificar último commit estable (tag `sprint-N-stable`)
3. Revertir cambios con `git revert` o reset a commit estable
4. Comunicar a equipo (Slack/Discord + GitHub Discussions)
5. Post-mortem en 72h (documento `POSTMORTEM_YYYY-MM-DD.md`)

**Autorización:** Owner principal + 1 revisor

---

## 📢 Comunicación

### Canales

| Evento | Canal | Nivel | Destinatario |
|--------|-------|-------|--------------|
| **PR abierto** | GitHub PR | INFO | @team-docs |
| **CI fallo** | Slack `#integrations-alerts` | ERROR | @ppkapiro, @team-infra |
| **Drift detectado** | Slack `#integrations-alerts` | WARN | @team-docs |
| **Rollback ejecutado** | Slack + Discord | ERROR | @all-team |
| **Sprint completado** | GitHub Discussions | INFO | @all-team |

### Templates de Mensajes

**Slack (Fallo CI):**
```
⚠️ **Briefing Status Publish Failed**
Commit: `abc1234`
Job: https://github.com/ppkapiro/runartfoundry/actions/runs/123456
Auto-rollback: ✅ OK
Acción requerida: Revisar logs + hotfix en <24h
```

**Discord (Drift Detectado):**
```
🔍 **Drift Detectado en status.json**
Auditoría semanal (lunes 09:00 UTC)
- Live docs: +3 (42 → 45)
- Archive: sin cambios
Issue: #123
```

---

## 📊 SLA y Métricas

### Service Level Agreements

| Métrica | Target | Medición | Frecuencia |
|---------|--------|----------|------------|
| **Uptime workflow** | ≥99% | Ejecuciones exitosas / total | Mensual |
| **Latencia publicación** | ≤5 min | Tiempo desde merge → deploy | Por run |
| **Rollback exitoso** | 100% | Restauración completa | Por incidente |
| **Resolución bugs críticos** | <24h | Tiempo desde reporte → merge | Por bug |
| **Cobertura tests** | >80% | pytest-cov | Por commit |

### KPIs de Calidad

| KPI | Target | Sprint 2 | Sprint 3 (Objetivo) |
|-----|--------|----------|----------------------|
| **Tests unitarios PASS** | 100% | 8/8 ✅ | 15/15 ✅ |
| **Fallos validación JSON** | 0 en 2 semanas | ✅ (0 fallos) | ✅ (0 fallos) |
| **Alerts disparadas** | ≤2 por mes | — (recién activado) | 0-1 |
| **Snapshots históricos** | ≥12 semanas | 0 (pendiente) | ≥3 |

---

## 🔐 Seguridad

### Secrets Management

| Secret | Uso | Rotación | Owner |
|--------|-----|----------|-------|
| `GITHUB_TOKEN` | Push commits automáticos | No aplica (auto-generado) | GitHub Actions |
| `SLACK_WEBHOOK` | Alertas Slack | Cada 6 meses | @team-infra |
| `DISCORD_WEBHOOK` | Alertas Discord | Cada 6 meses | @team-infra |

**Política:** No hardcodear URLs de webhooks en workflows. Usar `${{ secrets.* }}` siempre.

### Auditoría de Cambios

Todos los commits en `tools/`, `scripts/`, `.github/workflows/` relacionados con Briefing deben:
- Tener PR revisado por ≥1 owner
- Pasar pre-commit hooks (black, flake8, mypy)
- Incluir tests si modifican lógica de negocio

**Logs:** Accesibles en `docs/_meta/BRIEFING_STATUS_PIPELINE_RUN.md` y GitHub Actions.

---

## 📚 Referencias Técnicas

- [INDEX_INTEGRATIONS.md](INDEX_INTEGRATIONS.md) → Catálogo completo
- [BRIEFING_STATUS_PIPELINE_RUN.md](BRIEFING_STATUS_PIPELINE_RUN.md) → Logs de ejecución
- [status_samples/STATUS_SCHEMA.md](status_samples/STATUS_SCHEMA.md) → Esquema JSON v1.0
- [plan_briefing_status_integration.md](../integration_briefing_status/plan_briefing_status_integration.md) → Roadmap S1/S2/S3

---

## 🔄 Historial de Cambios Gobernanza

| Fecha | Versión | Cambios | Autor |
|-------|---------|---------|-------|
| 2025-10-23 | v1.0 | Documento inicial (Sprint 3) | @ppkapiro |

---

**Aprobado por:** @ppkapiro  
**Fecha aprobación:** 2025-10-23  
**Próxima revisión:** 2025-11-23 (mensual)
