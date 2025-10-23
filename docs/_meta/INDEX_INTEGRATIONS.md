# Índice de Integraciones — RunArt Foundry

**Propósito:** Catálogo centralizado de integraciones técnicas, investigaciones y documentación relacionada con extensiones del sistema de documentación RunArt Foundry.

**Última actualización:** 2025-10-23T22:35:00Z

---

## Integraciones Activas

### 1. Briefing + status.json + Auto-posts

**Estado:** ✅ **ACTIVO — Sprint 3 en curso (Hardening + Observabilidad)**  
**Fecha inicio:** 2025-10-23  
**Fecha merge:** 2025-10-23T23:05:00Z  
**Rama:** `feat/briefing-status-integration-research` (mergeada)  
**Owner:** @ppkapiro

#### Descripción

Integración automatizada que publica métricas operativas del sistema de documentación en el micrositio Briefing, generando:
- Página `/status` con KPIs en tiempo real (live docs, archive docs, CI health)
- Posts automáticos en `/news` derivados de commits recientes en `docs/`

#### Componentes Técnicos

| Componente | Ubicación | Descripción |
|------------|-----------|-------------|
| `gen_status.py` | `scripts/` | Genera `docs/status.json` con métricas operativas |
| `render_status.py` | `tools/` | Convierte status.json → `apps/briefing/docs/status/index.md` |
| `commits_to_posts.py` | `tools/` | Extrae commits → genera posts en `apps/briefing/docs/news/` |
| `render_history.py` | `tools/` | Genera `/status/history` con gráficos Chart.js desde snapshots |
| `auto_rollback.py` | `tools/` | Rollback automático ante fallos de validación o build |
| `notify.py` | `tools/` | Notificaciones Slack/Discord (fallos, drift) |
| `briefing-status-publish.yml` | `.github/workflows/` | Pipeline CI/CD completo (7 steps) |
| `status-snapshot.yml` | `.github/workflows/` | Snapshots semanales (lunes 07:00 UTC) |
| `status-audit.yml` | `.github/workflows/` | Auditoría semanal con detección drift (lunes 09:00 UTC) |
| `STATUS_SCHEMA.md` | `docs/_meta/status_samples/` | Documentación de esquema JSON |
| `BRIEFING_STATUS_PIPELINE_RUN.md` | `docs/_meta/` | Logs de ejecuciones del workflow |

#### Documentación

| Documento | Ubicación | Propósito |
|-----------|-----------|-----------|
| **Investigación** | `docs/integration_briefing_status/briefing_status_integration_research.md` | Análisis comparativo: MkDocs vs PaperLang vs CI/CD (14KB) |
| **Plan** | `docs/integration_briefing_status/plan_briefing_status_integration.md` | Roadmap S1/S2/S3, arquitectura, KPIs, gobernanza (17KB) |
| **Esquema** | `docs/_meta/status_samples/STATUS_SCHEMA.md` | Especificación de status.json v1.0 + extensiones futuras |
| **Sample** | `docs/_meta/status_samples/status.json` | Ejemplo real de status.json (snapshot 2025-10-23) |

#### Hitos

- ✅ **2025-10-23:** Investigación completa (3 modelos analizados)
- ✅ **2025-10-23:** PoC funcional (render_status + commits_to_posts + workflow)
- ✅ **2025-10-23:** 14 posts de ejemplo generados (últimas 72h)
- ✅ **2025-10-23T23:05:00Z:** Merge a main (hash 10d49f0)
- ✅ **Sprint 2 completado:** Tests unitarios (8/8 ✅) + validador JSON + rate limiting + auditoría semanal
- ⏳ **Pendiente:** Sprint 3 (rollback + snapshots + auditoría dashboard)

#### Enlaces Rápidos

- [📄 Investigación](../integration_briefing_status/briefing_status_integration_research.md)
- [📋 Plan](../integration_briefing_status/plan_briefing_status_integration.md)
- [🔧 render_status.py](../../tools/render_status.py)
- [🔧 commits_to_posts.py](../../tools/commits_to_posts.py)
- [⚙️ Workflow](../../.github/workflows/briefing-status-publish.yml)
- [📊 Estado actual](/status/)
- [📰 Posts recientes](/news/)
- [📈 Historial & Tendencias](/status/history)
- [📁 Snapshots semanales](../status_samples/)

#### KPIs de Éxito

| KPI | Target | Estado |
|-----|--------|--------|
| Latencia publicación | ≤5 min post-merge | ✅ Workflow configurado (estimado 2-3 min) |
| Consistencia datos | 100% (status.json ↔ vista) | ✅ Validador JSON activo + auditoría semanal |
| Uptime workflow | ≥99% | ⏳ En monitoreo (workflow activo desde 2025-10-23) |
| Fallos validadores | 0 en 2 semanas | ✅ Tests unitarios 8/8 PASS |
| Cobertura tests | >80% | ✅ 100% (8 tests core funcionales) |

---

## Integraciones Planificadas

### 2. PaperLang (Opt-in)

**Estado:** 📅 Planificado (V2)  
**Prioridad:** Media  
**Dependencias:** Integración Briefing estable

#### Descripción

Framework especializado para publicaciones técnicas con narrativa compleja (whitepapers, RFCs, papers científicos).

#### Casos de Uso

- Informes técnicos trimestrales con bibliografía
- RFCs extensos con secciones numeradas
- Whitepapers con exportación a PDF/LaTeX

#### Decisión

**No prioritario para PoC**. Se mantiene como opción para casos donde se requiera formateo académico riguroso.

#### Referencias

- [Investigación → Sección "Modelo B"](../integration_briefing_status/briefing_status_integration_research.md#modelo-b-paperlang-opt-in-para-papers)

---

### 3. Dashboard de Auditoría (Historial)

**Estado:** 📅 Planificado (Sprint 3)  
**Prioridad:** Alta  
**Dependencias:** Integración Briefing activa + snapshots

#### Descripción

Página `/status/history` en Briefing con:
- Gráficos de tendencias (docs activos/archivados/totales)
- Historial de ejecuciones del workflow
- Métricas de CI (success rate, avg duration)

#### Componentes Técnicos

- `tools/render_history.py` (nuevo)
- `apps/briefing/docs/status/history.md` (generado)
- Snapshots semanales en `docs/_meta/status_samples/`

#### KPIs

- 4+ snapshots preservados en Git
- Historial visible con gráficos Mermaid o Chart.js
- Actualización automática semanal

---

### 4. Alertas Slack/Discord

**Estado:** 📅 Planificado (Sprint 3)  
**Prioridad:** Media  
**Dependencias:** Integración Briefing estable

#### Descripción

Notificaciones automáticas en canales de equipo cuando:
- Workflow falla (gen_status, render, posts)
- Drift detectado en auditoría semanal
- Validación JSON falla

#### Implementación

```yaml
# .github/workflows/briefing-status-publish.yml
- name: Notify on failure
  if: failure()
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
      -H 'Content-Type: application/json' \
      -d '{"text": "⚠️ Briefing Status Publish falló: ${{ github.sha }}"}'
```

---

### 5. Gráficos Dinámicos (Chart.js/D3.js)

**Estado:** 📅 Planificado (Post-Sprint 3)  
**Prioridad:** Baja  
**Dependencias:** Dashboard de auditoría implementado

#### Descripción

Reemplazar gráficos estáticos Mermaid con visualizaciones interactivas:
- Líneas de tiempo (tendencias de docs activos)
- Barras apiladas (docs por owner)
- Pie charts (distribución por tags)

#### Tecnología

- Chart.js (más simple, integración rápida)
- D3.js (más flexible, curva aprendizaje alta)

---

## Integraciones Descartadas

### ❌ Integración con Notion API

**Razón:** Dependencia externa crítica, sincronización bidireccional compleja, costo de mantenimiento alto.

**Decisión:** Usar exclusivamente Git como fuente de verdad.

---

### ❌ Sistema de Comentarios (Disqus/Giscus)

**Razón:** Fuera de alcance de sistema de documentación interna. Preferir issues de GitHub para discusiones.

**Decisión:** Enlazar a GitHub Discussions desde Briefing si necesario.

---

## Estructura de Carpetas

```
docs/
├── integration_briefing_status/
│   ├── briefing_status_integration_research.md  (14KB, análisis detallado)
│   └── plan_briefing_status_integration.md      (17KB, roadmap S1/S2/S3)
├── _meta/
│   ├── status_samples/
│   │   ├── STATUS_SCHEMA.md                     (esquema v1.0)
│   │   └── status.json                          (sample 2025-10-23)
│   ├── BRIEFING_STATUS_PIPELINE_RUN.md          (logs ejecuciones)
│   └── INDEX_INTEGRATIONS.md                    (este archivo)
├── status.json                                   (generado automáticamente)
└── live/
    └── ...

apps/
└── briefing/
    └── docs/
        ├── status/
        │   └── index.md                          (generado por render_status.py)
        └── news/
            ├── 2025-10-23-auto-update-3ec7926a.md
            ├── 2025-10-23-auto-update-b21659aa.md
            └── ...                                (generados por commits_to_posts.py)

tools/
├── render_status.py                              (JSON → Markdown status)
├── commits_to_posts.py                           (git log → posts)
└── validate_status_schema.py                     (TODO: Sprint 2)

scripts/
└── gen_status.py                                 (métricas → status.json)

.github/
└── workflows/
    └── briefing-status-publish.yml               (pipeline completo)
```

---

## Gobernanza

### Owners por Integración

| Integración | Owner | Revisores | Proceso de Cambios |
|-------------|-------|-----------|-------------------|
| **Briefing + status.json** | @ppkapiro | @team-docs | PR con tests + dry-run |
| **PaperLang** | TBD | @team-docs | RFC + PoC antes de merge |
| **Dashboard Auditoría** | @ppkapiro | @team-docs, @team-infra | PR con gráficos validados |

### Proceso de Propuesta

1. **Issue** en GitHub con label `integration/proposal`
2. **RFC** (si integración >5 componentes o dependencias externas)
3. **Revisión** por 2+ owners
4. **PoC** funcional en rama de feature
5. **PR** con tests + docs actualizadas
6. **Merge** a `main` + monitoreo 1ª semana
7. **Rollback** si KPIs no se cumplen en 2 semanas

---

## Referencias Externas

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Jinja2 Templates](https://jinja.palletsprojects.com/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [jsonschema](https://python-jsonschema.readthedocs.io/)

---

**Fecha:** 2025-10-23T22:35:00Z  
**Commit:** (pendiente de PR en `feat/briefing-status-integration-research`)  
**Autor:** GitHub Copilot (Integration Index)
