# Arquitectura del Briefing — RUN Art Foundry (v0)

> **Propósito**: Definir cómo funciona el **panel briefing** como sistema web interno (no público), qué componentes lo conforman hoy, qué decisiones técnicas guían su evolución y qué queda por hacer para escalar.

## 1. Naturaleza del sistema
- El briefing es un **panel interno permanente** para documentación, control y automatización.  
- No es la web pública; **alimenta** entregables externos (PDFs, press-kits, dossiers, exportaciones).  
- Crece por módulos (formularios, inbox, promoción a YAML, validaciones, reportes).

## 2. Estado actual (qué hay hoy)
- **Frontend**: MkDocs en Cloudflare Pages (micrositio interno).  
- **Contenido**: Master Plan, fichas (ES/EN), press-kit v0/v1, reportes (corte de control), decisiones (formulario), inbox, logs.  
- **Automatización (CI/CD)**:  
  - presskit_pdf.yml → genera PDFs (v0/v1 ES/EN) y publica en `/presskit/`.  
  - promote_inbox.yml / preview → convierte respuestas del inbox → YAML + assets + nav.  
  - validate_projects (pre-commit/CI) → valida esquema YAML.  
  - corte_control_fase2 → métricas y verificación.  
- **Datos de entrada**: Formularios (docs/decisiones/) → `/api/decisiones` → storage KV (inbox).  
- **Datos de salida**: PDFs, YAMLs normalizados, sitio navegable.

## 3. Mapa de módulos
- **Documentación**: Master Plan, reportes, fichas.  
- **Captura**: Formularios (cliente) → Inbox (KV).  
- **Normalización**: Promoción Inbox → YAML (script + workflow).  
- **Medios**: `assets/{year}/{slug}/` (dummy → optimizadas).  
- **Publicación**: PDFs (press-kit) + sitio MkDocs.  
- **Control**: Tablero de fase, logs, corte de control.  

```mermaid
flowchart LR
  C[Cliente/Formulario] -->|POST /api/decisiones| I[Inbox (KV)]
  I -->|workflow promote| Y[docs/projects/*.yaml]
  Y -->|mkdocs build| S[Sitio briefing]
  Y -->|presskit_pdf.yml| P[PDFs /presskit]
  S --> R[Reportes/Corte de control]
```

## 4. Roles y accesos (baseline)

* **Equipo interno**: acceso completo a navegación, reportes, logs.
* **Cliente (opcional)**: acceso a secciones de consulta y formularios; **sin** acceso a logs internos.
* **Accesos futuros**: segmentar navegación por perfiles (pendiente).

## 5. Decisiones de diseño (lineamientos)

* **D-001**: El briefing permanece en **MkDocs** como UI base (simple, auditable, portable).
* **D-002**: Formularios livianos + API de recepción (Cloudflare Functions o equivalente) con **moderación** antes de promoción a YAML.
* **D-003**: Los **YAMLs son la fuente de verdad** para proyectos; la promoción desde inbox es explícita (no automática).
* **D-004**: Quality gates obligatorios (schema + lint) en pre-commit/CI.
* **D-005**: PDFs se generan en CI y se publican en `/presskit/`; artefactos quedan en Actions como respaldo.
* **D-006**: El panel briefing consolida y exporta; la web pública (si aplica) **consume** desde aquí.

## 6. Backlog técnico (prioridades)

* **ARQ-01**: Segmentación de menús por rol (equipo/cliente).
* **ARQ-02**: Editor guiado para fichas (front) que escriba YAML conforme al schema.
* **ARQ-03**: Validación avanzada de enlaces (cola asíncrona + retries).
* **ARQ-04**: Dashboard de métricas (embebido o externo) — fichas por estado, imágenes reales vs dummy, errores.
* **ARQ-05**: Plantillas de exportación (ZIP de fichas/medios por lote).
* **ARQ-06**: Seguridad de endpoints (tokens/captcha para formularios).
* **ARQ-07**: Trazabilidad de cambios (changelogs por ficha).

## 7. Riesgos y mitigaciones

* **Datos incompletos** → Moderación de inbox + campos obligatorios mínimos.
* **Links rotos** → Corte de control periódico + validaciones en CI.
* **Imágenes pesadas** → Política de optimización (<300 KB) y verificación en corte.
* **Desalineación ES/EN** → Traducciones solo cuando ES esté cerrado.

## 8. KPIs del sistema (no de marketing)

* % fichas con imágenes reales (vs dummy).
* % enlaces válidos por corte.
* Tiempo medio de promoción inbox → YAML.
* Nº PDFs generados por semana.
* Nº de incidencias por corte resueltas en el siguiente corte.

## 9. Roadmap de arquitectura (3 hitos)

* **Hito A (4–6 semanas)**: ARQ-01/02/06 (roles, editor guiado, seguridad formularios).
* **Hito B (6–8 semanas)**: ARQ-03/04 (validación avanzada + dashboard).
* **Hito C (8–10 semanas)**: ARQ-05/07 (exportaciones + trazabilidad).

## 10. Anexos

* Esquema YAML de proyectos (`docs/projects/schema.yaml`).
* Workflows CI/CD activos (lista y enlaces internos).
* Decisiones D-001…D-006 (este documento).

---
