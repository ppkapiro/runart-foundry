---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ops]
---

# Registro de Riesgos — Reorganización Monorepo (Fase B)

## Enfoque

- **Alcance**: Riesgos de la transición hacia la estructura modular propuesta en `020_target_structure.md` y ejecución del plan en `060_migration_plan.md`.
- **Horizonte**: Próximos 3–6 meses, incluyendo PRs piloto y adopción de workflows reusables.
- **Metodología**: Evaluación cualitativa (probabilidad/impacto) con propietarias/os claros y señales de alerta temprana.

## Matriz resumida

| ID | Riesgo | Probabilidad | Impacto | Mitigación primaria | Responsable |
| --- | --- | --- | --- | --- | --- |
| R1 | Ruptura de CI/CD tras mover workflows a plantillas | Media | Alta | Migrar por canary (F4) + fallback inmediato | DevOps |
| R2 | Desalineación entre Make targets y scripts reales | Alta | Media | Validaciones automáticas `make audit` + doc viva | Plataforma |
| R3 | Módulos sin owner durante reorganización | Media | Alta | Asignar steward por módulo en `STATUS.md` | Dirección Técnica |
| R4 | Deuda de config al separar Workers/API | Baja | Alta | Checklist de entorno + tests de contrato | Backend |
| R5 | Shock cultural por cambios en flujo de trabajo | Media | Media | Comunicación semanal + pairing | Líderes de equipo |
| R6 | Duplicidad de assets compartidos | Media | Media | Crear `packages/*` con CI de integridad | Frontend |
| R7 | Regresiones SEO en sitio briefing | Baja | Alta | Smoke tests + Lighthouse cron | Marketing |
| R8 | Timebox insuficiente para mantenimiento | Media | Media | Buffer 20% y priorización en roadmap | PM |

## Detalle de riesgos clave

### R1 — Ruptura de CI/CD
- **Causa raíz**: Reemplazar `ci.yml` por plantillas puede omitir permisos, secretos o artefactos.
- **Señales tempranas**: Jobs en amarillo, ausencia de artefactos en PR piloto, errores de `workflow_call`.
- **Plan B**: Mantener copia exacta de `ci.yml` previo; revertir y volver a lanzar pipeline.

### R2 — Desalineación de Make targets
- **Causa raíz**: Makefile raíz delega pero módulos siguen usando scripts locales.
- **Señales**: Fallos en `make build MODULE=x`, targets obsoletos en CI, comandos manuales documentados en PR.
- **Plan B**: Escalar a sesión técnica para reconciliar targets y actualizar doc; fallback a Makefile previo.

### R3 — Módulos sin owner
- **Causa raíz**: Reorganización crea `apps/*`, `services/*`, etc., sin responsables definidos.
- **Señales**: PRs sin reviewer claro, rotación de on-call, backlog detenido.
- **Plan B**: Temporada de stewardship (rotación) y adopción de matriz RACI por módulo.

### R4 — Deuda de configuración Workers/API
- **Causa raíz**: Separación de `functions/` a `services/briefing-api` puede perder binding/env vars.
- **Señales**: Errores en deploy Cloudflare, endpoints 5xx, secretos faltantes.
- **Plan B**: Script de verificación `wrangler deploy --dry-run`; revertir `git mv` hasta alinear config.

### R5 — Shock cultural
- **Causa raíz**: Equipos acostumbrados a `briefing/` monolítico y CI centralizado.
- **Señales**: Feedback negativo en retro, adopción baja de nuevos targets, incidentes por desconocimiento.
- **Plan B**: Formación y documentación adicional; programar pairing cross-team.

### R6 — Duplicidad de assets
- **Causa raíz**: Paquetes compartidos sin gobernanza permiten forks locales.
- **Señales**: Assets divergentes (`extra.css`), builds con tamaños distintos, PRs duplicando código.
- **Plan B**: Automatizar verificación hash/size; designar maintainers de `packages/*`.

### R7 — Regresiones SEO
- **Causa raíz**: Cambios en estructura de MkDocs o assets afectan metadatos.
- **Señales**: Lighthouse < 90, warnings en Search Console.
- **Plan B**: Revertir cambios en tema/navegación; ejecutar scripts de auditoría en `scripts/test_lighthouse.sh`.

### R8 — Timebox insuficiente
- **Causa raíz**: Cambios no estimados (deuda oculta) y soporte operativo.
- **Señales**: Sprint rollover > 30%, burn-down plano.
- **Plan B**: Re-planificar fases prioritarias (F4, F5) y negociar entregables.

## Dependencias externas

- Cloudflare Pages/Workers: Cambios de estructura requieren coordinación con credenciales y entornos.
- PProveedores de analytics/SEO: Validar que integraciones (p.ej., Matomo, GA) sigan registrándose.
- QA manual: Disponibilidad para pruebas de regresión en fases críticas.

## Gobernanza y seguimiento

- Revisión quincenal del registro (sync con `STATUS.md`).
- Riesgos en rojo se escalan en el standup diario.
- Documentar incidentes asociados en `docs/architecture/INCIDENTS.md` (por crear) para retroalimentar mitigaciones.
