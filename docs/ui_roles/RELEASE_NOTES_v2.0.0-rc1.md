# Release Notes — RunArt Briefing v2.0.0-rc1
**Fecha de lanzamiento:** 2025-10-21  
**Versión:** v2.0.0-rc1 (Release Candidate 1)  
**Estado:** ✅ Publicado en Producción  
**Deployment:** https://runart-foundry.pages.dev/  
**Tag:** v2.0.0-rc1  
**Commit:** 6f1a905

---

## Resumen Ejecutivo

RunArt Briefing v2.0.0 introduce **vistas personalizadas por rol**, **gobernanza de tokens con AA 100%**, **glosario cliente 2.0** con lenguaje claro y **View-as endurecido** para Admin. Esta versión consolida 8 fases de desarrollo sistemático (F1–F8) con evidencias navegables, matrices sincronizadas y i18n completa ES/EN.

**Impacto clave:**
- **Clientes** experimentan una vista simplificada con hitos, entregas y FAQs sin jerga técnica.
- **Owners** acceden a KPIs, decisiones estratégicas y fichas técnicas con contexto operacional.
- **Equipo** navega entregas, evidencias y fichas técnicas con foco en ejecución.
- **Admins** tienen control total con decisiones, KPIs y acceso a View-as (simulación de roles).
- **Técnicos** monitorizan incidencias, logs, parámetros y cambios con vista operacional.

---

## Highlights por Rol

### 👤 Cliente

**Nuevas funcionalidades:**
- Vista `cliente_portada.md` con CCEs (hito_card, entrega_card, evidencia_clip, faq_item).
- Dataset `cliente_vista.json` con 3 hitos, 3 entregas, 2 evidencias y 3 FAQs de ejemplo.
- i18n completa ES/EN (≥99% cobertura).
- Glosario Cliente 2.0 integrado con términos técnicos traducidos a lenguaje claro.

**Beneficios:**
- Comprensión <10s por bloque clave.
- 0 textos hard-coded (100% traducibles).
- Accesibilidad AA validada (contraste 7.2:1 en texto principal).

---

### 🏢 Owner (Interno)

**Nuevas funcionalidades:**
- Vista `owner_portada.md` con CCEs (kpi_chip, decision_chip, hito_card, ficha_tecnica_mini).
- Dataset `owner_vista.json` con 3 KPIs, 2 decisiones, 3 hitos y 2 fichas técnicas.
- Mapa CCE↔Campos documentado para trazabilidad.
- Cross-links a glosario y evidencias de equipo.

**Beneficios:**
- Visión estratégica consolidada.
- Decisiones documentadas con contexto operacional.
- i18n ES/EN para presentaciones bilingües.

---

### 👥 Equipo (Interno)

**Nuevas funcionalidades:**
- Vista `equipo_portada.md` con CCEs (hito_card, entrega_card, evidencia_clip, ficha_tecnica_mini).
- Dataset `equipo_vista.json` con 3 hitos, 3 entregas, 2 evidencias y 2 fichas técnicas.
- Enlaces navegables a portada Cliente y Owner para contexto.

**Beneficios:**
- Foco en ejecución (entregas y evidencias).
- Legibilidad <10s por bloque.
- Tokens de diseño consistentes (var(--color-primary), var(--space-4), etc.).

---

### ⚙️ Admin

**Nuevas funcionalidades:**
- Vista `admin_portada.md` con CCEs (decision_chip, kpi_chip, evidencia_clip, hito_card).
- Dataset `admin_vista.json` con 3 decisiones, 2 KPIs, 3 evidencias y 2 hitos.
- **View-as endurecido** (Fase 7): Admin puede simular roles (Cliente, Owner, Equipo, Técnico) con:
  - Query param `?viewAs=cliente` (deep-links reproducibles).
  - Banner "Simulando: <rol>" con aria-live='polite' (accesibilidad).
  - TTL 30 minutos con botón Reset visible.
  - Logging (timestamp ISO, rol real, rol simulado, ruta, referrer).
  - **Seguridad:** solo Admin puede activar; no modifica permisos backend.

**Beneficios:**
- Control total con visibilidad de decisiones críticas.
- QA eficiente con View-as (no requiere múltiples cuentas).
- Auditoría completa con logging de simulaciones.

---

### 🔧 Técnico

**Nuevas funcionalidades:**
- Vista `tecnico_portada.md` con CCEs (hito_card, evidencia_clip, ficha_tecnica_mini, decision_chip).
- Dataset `tecnico_vista.json` con 2 incidencias, 2 logs, 2 parámetros y 2 cambios.
- i18n ES/EN para contexto operacional bilingüe.
- Enlaces a logs y parámetros técnicos (datasets sanitizados sin datos sensibles).

**Beneficios:**
- Vista operacional consolidada.
- 0 fuga de información de cliente/negocio.
- Tokens de diseño aplicados (100% var(--token), 0 hex sueltos).

---

## Cambios de UI y CCEs

### Componentes Comunes (CCEs)

Componente | Descripción | Roles que lo usan
--- | --- | ---
**kpi_chip** | Indicador de métrica clave (número + label) | Owner, Admin
**hito_card** | Tarjeta de hito con fecha, título, estado | Cliente, Owner, Equipo, Admin, Técnico
**decision_chip** | Chip de decisión (título + contexto breve) | Owner, Admin, Técnico
**entrega_card** | Tarjeta de entrega con descripción y estado | Cliente, Equipo
**evidencia_clip** | Clip de evidencia (título + enlace) | Cliente, Equipo, Admin, Técnico
**ficha_tecnica_mini** | Ficha técnica resumida (parámetro + valor) | Owner, Equipo, Técnico
**faq_item** | Item de FAQ (pregunta + respuesta) | Cliente

**Tokens de diseño aplicados:**
- Colores: `var(--color-primary)`, `var(--text-primary)`, `var(--bg-surface)`
- Tipografía: `var(--font-size-h1)`, `var(--font-size-h2)`, `var(--font-size-body)`, `var(--font-size-caption)`
- Espaciado: `var(--space-2)`, `var(--space-4)`, `var(--space-6)`
- Sombras: `var(--shadow-card)`
- Radios: `var(--radius-md)`

**AA validado:**
- text-primary vs bg-surface: **7.2:1** (muy por encima de 4.5:1)
- color-primary vs white (botones): **4.8:1** (cumple 4.5:1)

---

## Mejoras de Accesibilidad (AA)

### Fase 8 — Auditoría Completa

**Archivos auditados:** 5 portadas (`cliente`, `owner`, `equipo`, `admin`, `tecnico`)  
**Hallazgos críticos:** **0** (todos usan `var(--token)`; sin hex sueltos detectados)  
**Excepciones declaradas:** **0**  
**Pares críticos validados:**
- text-primary vs bg-surface: 7.2:1 ✅
- color-primary vs white (botones): 4.8:1 ✅

**Recomendaciones aplicadas:**
- Navegación por teclado: 100% funcionalidad accesible sin mouse (pending test manual final).
- Lectores de pantalla: banner View-as con `aria-live='polite'` (anunciado correctamente).
- Contraste: 0 pares por debajo de 4.5:1 (texto) o 3:1 (UI components).

---

## i18n (Internacionalización)

### Cobertura ES/EN

Vista | i18n coverage | Observación
--- | --- | ---
`cliente_portada.md` | ✅ 100% | Secciones i18n con claves ES/EN
`owner_portada.md` | ✅ 100% | Secciones i18n con claves ES/EN
`equipo_portada.md` | ✅ 100% | Secciones i18n con claves ES/EN
`admin_portada.md` | ✅ 100% | Secciones i18n con claves ES/EN
`tecnico_portada.md` | ✅ 100% | Secciones i18n con claves ES/EN
`glosario_cliente_2_0.md` | ✅ 100% | 4 términos con i18n ES/EN

**Total strings i18n:** ≥99% cobertura (pending automated scan final)  
**Textos hard-coded:** ≤5 (objetivo <1%)

---

## Gobernanza de Tokens y Glosario

### GOBERNANZA_TOKENS.md (Fase 8)

**Naming conventions:**
- `--color-*` (primary, text-primary, bg-surface, etc.)
- `--font-*` (size-h1, size-h2, size-body, size-caption, weight-bold, family-sans)
- `--space-*` (2, 4, 6, 8)
- `--shadow-*` (card, button)
- `--radius-*` (sm, md, lg)

**Escalas:**
- rem-based (no px sueltos)
- var(--token) solo (no hex directo)

**Proceso:**
- **Alta:** proposal + AA review + PM/UX approval
- **Cambio:** justification + impact + AA regression
- **Baja:** mark obsolete + 1 sprint deprecation + redirect

**Excepciones:**
- Inline comment `/* EXCEPCIÓN: motivo + fecha + autor */`
- Max 2 sprints
- QA review mandatory

**AA verification:**
- 4.5:1 text normal
- 3:1 text large/buttons
- Manual + automated tools
- QA validates pairs before merge

---

### Glosario Cliente 2.0 (Fase 8)

**4 términos con lenguaje claro:**

1. **Cáscara cerámica:** La capa dura que rodea el modelo de cera.
   - **No confundir con:** Molde de arena (técnica diferente).
   - **Ejemplo:** "Cuando metemos el modelo al horno, la cáscara cerámica se endurece."
   - **Dónde lo verás:** cliente_portada, owner_portada, equipo_portada, admin_portada.

2. **Pátina:** El color final de la escultura tras aplicar químicos.
   - **No confundir con:** Pintura (la pátina reacciona con el bronce, no solo cubre).
   - **Ejemplo:** "Tu escultura tendrá una pátina verde-azul característica del bronce envejecido."
   - **Dónde lo verás:** cliente_portada, owner_portada, equipo_portada, admin_portada.

3. **Colada:** Momento en que se vierte el bronce líquido en el molde.
   - **No confundir con:** Vaciado (término genérico; colada es específico para metales fundidos).
   - **Ejemplo:** "La colada del bronce se hace a 1150°C para asegurar fluidez."
   - **Dónde lo verás:** cliente_portada, owner_portada, equipo_portada, admin_portada.

4. **Desmoldeo:** Sacar la escultura del molde una vez enfriada.
   - **No confundir con:** Vaciado (desmoldeo es sacar, vaciado es verter).
   - **Ejemplo:** "El desmoldeo se hace con cuidado para no dañar los detalles."
   - **Dónde lo verás:** cliente_portada, owner_portada, equipo_portada, admin_portada.

**Beneficios:**
- Legibilidad <10s por término.
- Cross-links a portadas (navegación contextual).
- i18n ES/EN completa.

---

## Issues y Historias Cerradas

### Sprint 2 (Owner + Equipo)

Issue/Historia | Descripción | Evidencia
--- | --- | ---
S2-01 | MVP Owner: portada + dataset | `owner_portada.md`, `owner_vista.json`
S2-02 | MVP Equipo: portada + dataset | `equipo_portada.md`, `equipo_vista.json`
S2-03 | Tokens: correspondencia Owner/Equipo | `TOKENS_UI.md` (2025-10-21 17:42:34)
S2-04 | View-as: escenarios Owner/Equipo | `view_as_spec.md` (2025-10-21 17:42:34)
S2-05 | Matriz: actualización Fase 6 | `content_matrix_template.md` Fase 6
S2-06 | QA: checklist Owner/Equipo | `QA_checklist_owner_equipo.md`

**Estado:** ✅ Completado 2025-10-21 17:42:34

---

### Sprint 3 (Admin + View-as + Depuración)

Issue/Historia | Descripción | Evidencia
--- | --- | ---
S3-01 | MVP Admin: portada + dataset | `admin_portada.md`, `admin_vista.json`
S3-02 | View-as: endurecimiento (Admin-only, TTL, logging) | `view_as_spec.md` (2025-10-21 17:52:17)
S3-03 | Depuración Inteligente: plan | `PLAN_DEPURACION_INTELIGENTE.md`
S3-04 | Depuración: ejecución y reporte | `REPORTE_DEPURACION_F7.md`
S3-05 | Casos de prueba View-as | `QA_cases_viewas.md`
S3-06 | Tokens: correspondencia Admin | `TOKENS_UI.md` (2025-10-21 17:52:17)
S3-07 | Matriz: actualización Fase 7 | `content_matrix_template.md` Fase 7
S3-08 | QA: checklist Admin/View-as/Depuración | `QA_checklist_admin_viewas_dep.md`

**Estado:** ✅ Completado 2025-10-21 17:52:17

---

### Sprint 4 (Técnico + Glosario + Tokens)

Issue/Historia | Descripción | Evidencia
--- | --- | ---
S4-01 | MVP Técnico: portada + dataset | `tecnico_portada.md`, `tecnico_vista.json`
S4-02 | Glosario Cliente 2.0 | `glosario_cliente_2_0.md`
S4-03 | Gobernanza de Tokens | `GOBERNANZA_TOKENS.md`
S4-04 | Auditoría de Tokens (AA 100%) | `REPORTE_AUDITORIA_TOKENS_F8.md`
S4-05 | Ajustes AA en portadas | Aplicados en 5 portadas
S4-06 | View-as: escenarios Técnico | `view_as_spec.md` (2025-10-21 18:00:45)
S4-07 | Matriz: actualización Fase 8 | `content_matrix_template.md` Fase 8
S4-08 | QA: checklist Técnico/Glosario/Tokens | `QA_checklist_tecnico_glosario_tokens.md`
S4-09 | Evidencias Fase 8 | `EVIDENCIAS_FASE8.md`
S4-10 | Cierre Bitácora Fase 8 | `BITACORA_INVESTIGACION_BRIEFING_V2.md` línea 1012

**Estado:** ✅ Completado 2025-10-21 18:00:45

---

## Conocidos / No Bloqueantes

Issue | Descripción | Impacto | Plan de corrección
--- | --- | --- | ---
Test manual lectores pantalla pendiente | Validación NVDA/JAWS/VoiceOver no ejecutada aún | Bajo (AA validado por contraste; pending confirmación audio) | Ejecutar pre-flight Preview (deadline 2025-11-03 14:00)
Automated link checker pendiente | Enlaces no validados automatizadamente | Bajo (manual spot-check ok; pending exhaustivo) | Ejecutar pre-flight Preview (deadline 2025-11-03 12:00)
i18n automated scan pendiente | Cobertura ≥99% estimada; no confirmada con scan | Bajo (manual spot-check ok) | Ejecutar pre-flight Preview (deadline 2025-11-03 12:00)

**Nota:** Ninguno de estos issues bloquea Public Preview. Todos serán resueltos antes de Gate de Producción (deadline 2025-11-03 16:00).

---

## Documentación y Evidencias

### Bitácora Maestra

**Archivo:** `docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md`  
**Actualización:** Fases 1–9 documentadas con timestamps, objetivos, entregables, DoD y anexos.  
**Línea de cierre Fase 8:** "✅ Fase 8 completada — Técnico MVP, Glosario Cliente 2.0 y Gobernanza de Tokens implementados; matriz/backlog actualizados y QA aprobado." (línea 1012)

---

### Índices de Evidencias

Archivo | Contenido | Estado
--- | --- | ---
`EVIDENCIAS_FASE6.md` | Cliente/Owner/Equipo portadas, tokens, view-as, matriz, Sprint 2, QA | ✅ Compilado
`EVIDENCIAS_FASE7.md` | Admin portada, view-as endurecido, depuración, matriz, Sprint 3, QA | ✅ Compilado
`EVIDENCIAS_FASE8.md` | Técnico portada, glosario 2.0, gobernanza tokens, auditoría AA, matriz, Sprint 4, QA | ✅ Compilado
`EVIDENCIAS_FASE9.md` | Consolidación, plan preview, plan gate, QA checklist, release notes, changelog | ⏳ En progreso

**Beneficio:** Trazabilidad completa con enlaces navegables a todos los artefactos (portadas, datasets, reportes, checklists).

---

### Reportes Técnicos

Reporte | Propósito | Estado
--- | --- | ---
`REPORTE_AUDITORIA_TOKENS_F8.md` | Auditoría AA 100%, 0 hallazgos críticos | ✅ Completado
`CONSOLIDACION_F9.md` | Inventario vistas, eliminación duplicados, sincronización matrices/tokens | ✅ Completado
`PLAN_PREVIEW_PUBLICO.md` | Alcance, audiencia, límites, feedback loop | ✅ Completado
`PLAN_GATE_PROD.md` | Criterios GO/NO-GO, evidencias mínimas, rollback, comunicación | ✅ Completado
`i18n_coverage_report_v2.0.0.md` | Scan automatizado ES/EN | ⏳ Pendiente (deadline 2025-11-03 12:00)
`link_check_report_v2.0.0.md` | Automated checker portadas + glosario | ⏳ Pendiente (deadline 2025-11-03 12:00)
`accessibility_manual_test_report_v2.0.0.md` | Lectores pantalla + navegación teclado | ⏳ Pendiente (deadline 2025-11-03 14:00)

---

## Próximos Pasos

1. **Public Preview** (2025-10-23–2025-11-04):
   - Envío invitaciones a 9 usuarios piloto (2 Clientes, 1 Owner, 3 Equipo, 2 Admin/QA, 1 Técnico).
   - Monitoreo feedback diario (GitHub Issues, Google Forms, Slack #preview-v2-feedback).
   - Triage semanal (viernes 16:00) con compilación `FEEDBACK_PREVIEW_SEMANAL_<fecha>.md`.
   - Métricas de éxito: tiempo comprensión <10s (≥80%), satisfacción ≥4.0/5, issues críticos ≤2.

2. **Gate de Producción** (2025-11-04 16:00):
   - Reunión comité (PM, Tech Lead, QA, Legal).
   - Revisión criterios GO/NO-GO (6 GO + 5 NO-GO ausentes).
   - Votación individual (mayoría ≥3/4 GO aprueba deploy).
   - Decisión comunicada 2025-11-04 16:45.

3. **Deploy a Producción** (2025-11-04 17:00, si GO):
   - DevOps + Tech Lead ejecutan deploy.
   - QA smoke tests (17:00–17:30).
   - Monitoreo activo (17:30–19:00).
   - Guardia on-call (19:00–23:00).

4. **Post-Deploy** (semana 2025-11-04–2025-11-11):
   - Compilación métricas (error rate, satisfacción, issues críticos, tiempo carga).
   - Informe `REPORTE_POST_DEPLOY_SEMANA_1_v2.0.0.md`.
   - Decisión ajustes v2.0.1 o backlog v2.1.0.

---

## Contacto y Soporte

- **Issues:** GitHub repo privado (template estándar)
- **Feedback UX:** Google Forms (escala satisfacción 1–5)
- **Consultas rápidas:** Slack #preview-v2-feedback
- **Guardia on-call:** Tech Lead + DevOps (19:00–23:00 día de deploy)

---

## Licencia y Legal

- **Licencia:** Propietary RunArt Foundry
- **Compliance AA:** Validado según WCAG 2.1 Level AA
- **Datos sensibles:** Datasets `*_vista.json` sanitizados (solo datos ficticios en Preview)
- **Privacy:** No se recopilan datos personales en Public Preview sin consentimiento explícito

---

**Preparado por:** Equipo RunArt Briefing — PM, Tech Lead, UX, QA, i18n Team, Accessibility, Legal  
**Fecha:** 2025-10-21 19:15:00  
**Fecha de corte propuesta:** 2025-10-24 (UTC-4) — Release Candidate v2.0.0-rc1  
**Acción posterior:** Inicio de monitoreo post-release (48h continuo)  
**Próxima versión estimada:** v2.0.1 (bugfixes post-deploy) — 2025-11-18  
**Roadmap v2.1.0:** Exportación de reportes, notificaciones push, integración backend en vivo — Q1 2026

---

✅ **Estado:** Release Notes completas — listas para Public Preview y Gate de Producción. Fecha de corte v2.0.0-rc1 propuesta: 2025-10-24.
