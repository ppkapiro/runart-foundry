---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ui]
---

# Plan de Gate de Producción — RunArt Briefing v2.0.0
**Fecha:** 2025-10-21 19:15:00  
**Responsable:** PM + Tech Lead + QA + Legal  
**Deadline decisión GO/NO-GO:** 2025-11-04 17:00 (post-cierre Preview)

---

## 1. Resumen Ejecutivo

El Gate de Producción es el punto de control final antes del despliegue de RunArt Briefing v2.0.0 a entorno productivo. Este plan define:
- **Criterios objetivos GO/NO-GO**
- **Evidencias mínimas exigidas**
- **Plan de rollback documentado**
- **Comunicación a stakeholders**

**Decisión final:** Comité formado por PM, Tech Lead, QA y Legal vota GO/NO-GO basándose en criterios objetivos. Mayoría simple (≥3/4 GO) aprueba el despliegue.

---

## 2. Criterios GO (Obligatorios)

### 2.1. Accesibilidad (AA)

Criterio | Medición | Umbral GO | Evidencia mínima | Responsable
--- | --- | --- | --- | ---
Contraste AA en headers/buttons/chips | Auditoría automatizada + manual | 100% pares validados ≥4.5:1 (text) / ≥3:1 (UI components) | `REPORTE_AUDITORIA_TOKENS_F8.md` con pares críticos validados | QA + Accessibility
Lectores de pantalla compatibles | Test manual (NVDA, JAWS, VoiceOver) | 0 bloqueantes críticos | Report QA con screenshots/transcripts | QA
Navegación por teclado | Test manual (Tab, Enter, Esc) | 100% funcionalidad accesible sin mouse | Checklist navegación teclado | QA

**Estado actual:** ✅ REPORTE_AUDITORIA_TOKENS_F8 validó text-primary/bg-surface 7.2:1, color-primary/white 4.8:1. Pendiente test manual lectores pantalla y teclado (pre-flight Preview).

---

### 2.2. Internacionalización (i18n)

Criterio | Medición | Umbral GO | Evidencia mínima | Responsable
--- | --- | --- | --- | ---
Cobertura i18n ES/EN en vistas expuestas | Automated scan + manual spot-check | ≥99% (≤5 strings hard-coded) | `i18n_coverage_report_v2.0.0.md` | i18n Team
Consistencia terminológica | Review cruzado vs glosario_cliente_2_0.md | 0 conflictos críticos | Checklist terminología | UX + i18n Team
Formato de fechas/números localizado | Test manual ES vs EN | 100% correcto | Screenshots comparativos | QA

**Estado actual:** ✅ QA checklists F6-F8 validaron i18n ES/EN en todas las portadas. Pendiente automated scan final (pre-flight Preview).

---

### 2.3. Sincronización de Matrices y Tokens

Criterio | Medición | Umbral GO | Evidencia mínima | Responsable
--- | --- | --- | --- | ---
content_matrix_template.md sincronizada con vistas activas | Diff automático + review manual | 100% filas con estado G/A/R asignado | `CONSOLIDACION_F9.md` sección 3 | PM + UX
TOKENS_UI.md sin pendientes críticos | Review de hallazgos REPORTE_AUDITORIA_TOKENS_F8 | 0 hallazgos críticos abiertos | `REPORTE_AUDITORIA_TOKENS_F8.md` estado final | Tech Lead + QA
GOBERNANZA_TOKENS.md aplicada consistentemente | Spot-check en 5 portadas | 100% var(--token), 0 hex sueltos | `CONSOLIDACION_F9.md` sección 4 | Tech Lead

**Estado actual:** ✅ CONSOLIDACION_F9 confirma matriz 100% sincronizada, tokens bajo gobernanza AA 100%, 0 hex sueltos.

---

### 2.4. View-as Endurecido

Criterio | Medición | Umbral GO | Evidencia mínima | Responsable
--- | --- | --- | --- | ---
Admin-only activation | Test roles Cliente/Owner/Equipo/Técnico con ?viewAs | 100% rechazado si rol real ≠ Admin | Test cases `QA_cases_viewas.md` TC-VA-05 | QA + Security
TTL 30 minutos | Test sesión prolongada | Reset automático o manual funcionando | Test case TC-VA-03 | QA
Logging funcional | Verificar logs con timestamp/rol real/rol simulado/ruta | 100% eventos loggeados | Sample logs en staging | Tech Lead + DevOps
Banner accesible | Test lector de pantalla | aria-live='polite' anunciado correctamente | Test manual NVDA/VoiceOver | QA + Accessibility

**Estado actual:** ✅ view_as_spec.md documenta todos los requisitos. Pendiente test E2E en Preview staging (pre-flight).

---

### 2.5. Evidencias Navegables por Rol

Criterio | Medición | Umbral GO | Evidencia mínima | Responsable
--- | --- | --- | --- | ---
≥5 evidencias navegables por rol principal (Cliente, Owner, Equipo, Admin) | Count manual en datasets `*_vista.json` | Cada dataset con 3–6 items | `CONSOLIDACION_F9.md` sección 1 | PM + UX
Enlaces internos funcionando | Automated link checker | 0 enlaces rotos en portadas y glosario | Link check report | QA
Cross-links glosario ↔ portadas | Manual spot-check | 100% términos glosario con "Dónde lo verás" enlazado | `glosario_cliente_2_0.md` validado | UX + QA

**Estado actual:** ✅ CONSOLIDACION_F9 confirma datasets con 3–6 items por CCE. Pendiente link checker automatizado (pre-flight).

---

### 2.6. Depuración y Eliminación de Duplicados

Criterio | Medición | Umbral GO | Evidencia mínima | Responsable
--- | --- | --- | --- | ---
0 duplicados funcionales activos | Review tabla depuración | 100% legados con tombstones (motivo, fecha, reemplazo) | `CONSOLIDACION_F9.md` sección 2 + `REPORTE_DEPURACION_F7.md` | PM + Tech Lead
Redirecciones documentadas | Checklist redirecciones | 100% rutas legacy apuntan a nuevas vistas | `REPORTE_DEPURACION_F7.md` tabla redirecciones | Tech Lead + DevOps

**Estado actual:** ✅ CONSOLIDACION_F9 confirma 0 duplicados funcionales; tombstones creados para legados.

---

## 3. Criterios NO-GO (Bloqueantes)

Si **cualquiera** de los siguientes ocurre, el despliegue es **NO-GO automático**:

Criterio | Impacto | Acción
--- | --- | ---
≥1 hallazgo crítico AA (contraste <4.5:1 en texto, <3:1 en UI) | Legal + Accessibility compliance | Corrección urgente + re-audit antes de nuevo Gate
≥10 strings hard-coded sin i18n (>1% cobertura) | UX degradada para usuarios ES/EN | Sprint de corrección i18n + re-scan
≥3 enlaces rotos en portadas principales | Navegación bloqueada para usuarios | Fix urgente + re-check
View-as activable por roles no-Admin | Security breach | Hotfix seguridad + audit forense
Datos sensibles en datasets `*_vista.json` | Legal + Privacy compliance | Purge datasets + legal review + comunicación

**Escalación NO-GO:** PM notifica a CTO y Legal dentro de 2 horas. Se programa reunión emergencia para definir plan de corrección y nueva fecha Gate.

---

## 4. Evidencias Mínimas Exigidas

### 4.1. Índices de Evidencias (EVIDENCIAS_FASE*.md)

Archivo | Contenido mínimo | Estado
--- | --- | ---
`EVIDENCIAS_FASE6.md` | Tabla de enlaces a Cliente/Owner/Equipo portadas, datasets, tokens, view-as, matriz, Sprint 2, QA checklist | ✅ Compilado
`EVIDENCIAS_FASE7.md` | Tabla de enlaces a Admin portada, view-as endurecido, depuración (plan + reporte), matriz, Sprint 3, QA checklist | ✅ Compilado
`EVIDENCIAS_FASE8.md` | Tabla de enlaces a Técnico portada, glosario 2.0, gobernanza tokens, auditoría tokens, matriz, Sprint 4, QA checklist | ✅ Compilado
`EVIDENCIAS_FASE9.md` | Tabla de enlaces a consolidación, plan preview, plan gate, QA checklist, release notes, changelog, tokens vigentes, matriz final, view-as conforme | ⏳ En progreso

**Deadline:** 24 horas antes de decisión Gate (2025-11-03 17:00).

---

### 4.2. Reportes Técnicos

Reporte | Propósito | Responsable | Deadline
--- | --- | --- | ---
`REPORTE_AUDITORIA_TOKENS_F8.md` | Validación AA 100%, 0 hallazgos críticos | QA + Accessibility | ✅ Completado
`CONSOLIDACION_F9.md` | Inventario vistas finales, eliminación duplicados, sincronización matrices/tokens | PM + Tech Lead | ✅ Completado
`i18n_coverage_report_v2.0.0.md` | Scan automatizado + manual ES/EN, lista de pendientes | i18n Team | 2025-11-03 12:00
`link_check_report_v2.0.0.md` | Automated checker portadas + glosario, lista de rotos | QA | 2025-11-03 12:00
`accessibility_manual_test_report_v2.0.0.md` | Lectores pantalla + navegación teclado, issues bloqueantes | QA + Accessibility | 2025-11-03 14:00

---

### 4.3. QA Checklists Validadas

Checklist | Validación | Responsable | Estado
--- | --- | --- | ---
`QA_checklist_cliente.md` | [x] todos los ítems | QA | ✅ Completado F5
`QA_checklist_owner_equipo.md` | [x] todos los ítems | QA | ✅ Completado F6
`QA_checklist_admin_viewas_dep.md` | [x] todos los ítems | QA | ✅ Completado F7
`QA_checklist_tecnico_glosario_tokens.md` | [x] todos los ítems | QA | ✅ Completado F8
`QA_checklist_consolidacion_preview_prod.md` | [x] todos los ítems (secciones Preview + Gate Prod) | QA | ⏳ En progreso

---

## 5. Plan de Rollback

### 5.1. Estrategia de Reversión

Componente | Acción de rollback | Tiempo estimado | Responsable
--- | --- | --- | ---
**Frontend (vistas UI)** | Revertir deploy a tag `v1.9.0` (última versión estable) | 15 minutos | DevOps + Frontend Lead
**CSS Tokens** | Revertir archivo tokens CSS a versión pre-v2.0.0 | 5 minutos | DevOps
**Datasets JSON** | Restaurar `*_vista.json` desde backup pre-deploy | 10 minutos | DevOps + Backend
**i18n locales** | Revertir archivos ES/EN a versión pre-v2.0.0 | 5 minutos | DevOps + i18n Team
**Backend (si aplica)** | No hay cambios backend en v2.0.0 (solo frontend/UI) | N/A | —
**Base de datos** | No hay migraciones de DB en v2.0.0 | N/A | —

**Tiempo total rollback:** ≤35 minutos (asumiendo acceso inmediato a sistemas).

---

### 5.2. Proceso de Rollback (Paso a Paso)

1. **Detección de falla crítica** (≤5 minutos desde reporte):
   - Usuario/monitor reporta issue bloqueante.
   - PM + Tech Lead confirman criterio NO-GO cumplido.
   - Decisión rollback comunicada a DevOps + CTO.

2. **Inicio de rollback** (≤10 minutos desde decisión):
   - DevOps ejecuta script `rollback_v2.0.0.sh` (automatizado):
     ```bash
     # Revertir frontend a v1.9.0
     git checkout tags/v1.9.0
     npm run build
     npm run deploy:prod
     
     # Revertir tokens CSS
     cp backups/tokens_v1.9.0.css public/css/tokens.css
     
     # Revertir datasets
     cp backups/*_vista_v1.9.0.json data/
     
     # Revertir i18n
     cp backups/locales_v1.9.0/* locales/
     
     # Restart services
     pm2 restart briefing-app
     ```
   - Monitoreo en staging: validar que v1.9.0 funciona correctamente.
   - Deploy a producción con rollback completo.

3. **Validación post-rollback** (≤20 minutos):
   - QA smoke tests en producción (navegación básica, login, vistas principales).
   - Confirmar métricas de error vuelven a baseline v1.9.0.
   - PM confirma OK a CTO.

4. **Comunicación post-rollback** (≤30 minutos desde inicio):
   - Mensaje a stakeholders (ver sección 6.3).
   - Postmortem scheduling (dentro de 48h).

---

### 5.3. Criterios para Activar Rollback

Situación | Acción | Responsable decisión
--- | --- | ---
≥5 usuarios reportan UI rota (white screens, estilos no cargados) en primeras 2 horas | Rollback inmediato | PM + Tech Lead
≥3 issues críticos AA (contraste ilegible) reportados en primeras 4 horas | Rollback inmediato | PM + Legal + Accessibility
Falla de autenticación SSO (usuarios no pueden acceder) | Rollback inmediato + escalación DevOps/Security | CTO + DevOps Lead
Datos sensibles expuestos en producción | Rollback inmediato + audit forense + legal notification | CTO + Legal + Security

---

## 6. Comunicación

### 6.1. Mensaje Pre-Deploy (Stakeholders Internos)

**Destinatarios:** CTO, PM, UX Lead, QA Lead, Tech Lead, i18n Team, Legal  
**Fecha:** 2025-11-04 09:00 (8 horas antes de deploy)

```markdown
**Subject:** RunArt Briefing v2.0.0 — Deploy a Producción — 2025-11-04 17:00

Hola equipo,

Confirmamos el deploy de RunArt Briefing v2.0.0 a producción hoy **2025-11-04 a las 17:00**.

**Resumen de cambios:**
- 5 vistas específicas por rol (Cliente, Owner, Equipo, Admin, Técnico)
- Glosario Cliente 2.0 con lenguaje claro
- Gobernanza de tokens con AA 100% validado
- View-as endurecido (Admin-only, TTL 30min, logging)
- i18n ES/EN ≥99% cobertura

**Gate de Producción:**
- Decisión GO: [GO/NO-GO] (anunciada 2025-11-04 16:00)
- Criterios cumplidos: [lista resumida]
- Evidencias: docs/ui_roles/EVIDENCIAS_FASE9.md

**Rollback plan:**
- Tiempo estimado: 35 minutos
- Tag de reversión: v1.9.0
- Script automatizado: rollback_v2.0.0.sh

**Monitoreo post-deploy:**
- QA smoke tests: 17:00–17:30
- Monitoreo activo: 17:30–19:00 (2 horas)
- Guardia: Tech Lead + DevOps (on-call 19:00–23:00)

Para dudas: Slack #briefing-v2-deploy

Saludos,  
PM RunArt Briefing
```

---

### 6.2. Mensaje Post-Deploy (Stakeholders + Usuarios)

**Destinatarios:** Todos los usuarios con acceso a RunArt Briefing  
**Fecha:** 2025-11-04 18:00 (1 hora post-deploy, si GO)

```markdown
**Subject:** ✅ RunArt Briefing v2.0.0 — Disponible en Producción

Hola,

Nos complace anunciar el lanzamiento de **RunArt Briefing v2.0.0**, disponible ahora en producción.

**Novedades principales:**
- **Vistas personalizadas por rol:** Experimenta una interfaz diseñada específicamente para tu perfil (Cliente, Owner, Equipo, Admin o Técnico).
- **Glosario cliente 2.0:** Lenguaje claro con ejemplos prácticos para términos técnicos.
- **Diseño accesible:** Contraste AA validado, navegación por teclado, soporte para lectores de pantalla.
- **i18n completa:** Interfaz en español e inglés sin textos hard-coded.

**Qué esperar:**
- Si tu rol es Cliente, verás una vista simplificada con hitos, entregas y FAQs.
- Si eres Owner/Equipo, tendrás acceso a KPIs, decisiones y fichas técnicas.
- Si eres Admin/Técnico, podrás acceder a logs, parámetros y vista operacional.

**Feedback:**
- Reporta issues en GitHub: [enlace]
- Sugerencias en Slack #briefing-feedback

Para más detalles, consulta las Release Notes: [enlace a RELEASE_NOTES_v2.0.0-rc1.md]

Gracias por tu paciencia durante el desarrollo. ¡Esperamos que disfrutes la nueva experiencia!

Saludos,  
Equipo RunArt Briefing
```

---

### 6.3. Mensaje de Rollback (Si aplica)

**Destinatarios:** Stakeholders internos + usuarios afectados  
**Fecha:** Inmediatamente post-rollback

```markdown
**Subject:** ⚠️ RunArt Briefing v2.0.0 — Rollback a v1.9.0

Hola,

Por precaución, hemos revertido RunArt Briefing de v2.0.0 a la versión anterior v1.9.0 debido a [razón breve: ej. "problemas de accesibilidad críticos reportados por múltiples usuarios"].

**Estado actual:**
- Versión en producción: v1.9.0 (estable)
- v2.0.0: suspendida temporalmente
- Tus datos y proyectos no se ven afectados.

**Próximos pasos:**
- Estamos investigando la causa raíz.
- Programaremos un nuevo deploy de v2.0.0 una vez corregidos los issues.
- Fecha estimada: [TBD — comunicaremos en ≤48h]

**Postmortem:**
- Reunión interna: [fecha] [hora]
- Informe público: disponible en [enlace] una vez completado.

Lamentamos las molestias. Gracias por tu comprensión.

Saludos,  
Equipo RunArt Briefing
```

---

## 7. Comité de Decisión Gate

### 7.1. Miembros del Comité

Rol | Nombre | Voto | Área de responsabilidad
--- | --- | --- | ---
**PM** | [Nombre] | 1 voto | Criterios generales, timeline, comunicación
**Tech Lead** | [Nombre] | 1 voto | Tokens, view-as, arquitectura técnica
**QA Lead** | [Nombre] | 1 voto | AA, i18n, enlaces, tests E2E
**Legal** | [Nombre] | 1 voto | Compliance, datos sensibles, accessibility legal

**Quórum:** 4/4 presentes  
**Decisión:** Mayoría simple (≥3/4 GO) aprueba despliegue

---

### 7.2. Proceso de Votación

1. **Presentación de evidencias** (30 minutos):
   - PM presenta `CONSOLIDACION_F9.md` + `EVIDENCIAS_FASE9.md`.
   - QA presenta reportes técnicos (i18n, links, AA manual).
   - Tech Lead presenta estado tokens, view-as, matrices.
   - Legal confirma compliance (datos sensibles, AA legal).

2. **Revisión de criterios GO/NO-GO** (15 minutos):
   - Cada miembro del comité valida los 6 criterios GO (sección 2).
   - Identificación de bloqueantes (criterios NO-GO, sección 3).

3. **Votación individual** (5 minutos):
   - Cada miembro vota GO o NO-GO con justificación breve.
   - Votos registrados en acta `ACTA_GATE_PROD_v2.0.0.md`.

4. **Decisión final** (5 minutos):
   - Si ≥3/4 GO: PM anuncia deploy aprobado; comunicación interna/externa.
   - Si ≥2/4 NO-GO: PM anuncia delay; se programa corrección urgente y nuevo Gate.

**Fecha/hora reunión:** 2025-11-04 16:00 (1 hora antes del deploy programado)

---

## 8. Métricas Post-Deploy (Monitoreo)

### 8.1. Ventanas de Monitoreo

Ventana | Duración | Responsable | Acción si falla
--- | --- | --- | ---
**Smoke tests** | 17:00–17:30 (30 min) | QA | Rollback inmediato si ≥1 test crítico falla
**Monitoreo activo** | 17:30–19:00 (90 min) | Tech Lead + DevOps | Rollback si ≥5 issues críticos reportados
**Guardia on-call** | 19:00–23:00 (4 horas) | Tech Lead + DevOps | Evaluar rollback caso por caso

---

### 8.2. KPIs de Éxito Post-Deploy (Primera Semana)

KPI | Objetivo | Fuente de datos | Responsable medición
--- | --- | --- | ---
Tasa de error 5xx (backend) | ≤0.1% | Logs servidor | DevOps
Tasa de error JS (frontend) | ≤1% | Sentry / Browser console logs | Frontend Lead
Issues críticos reportados | ≤2 | GitHub Issues (label "critical") | PM + QA
Satisfacción usuario (encuesta post-uso) | ≥4.0 (escala 1–5) | Google Forms | UX
Tiempo de carga promedio (portadas) | ≤2s (p95) | Analytics / Lighthouse | Frontend Lead
Cobertura i18n validada en producción | ≥99% | Manual spot-check | i18n Team

**Compilación semanal:** PM genera `REPORTE_POST_DEPLOY_SEMANA_1_v2.0.0.md` (disponible 2025-11-11).

---

## 9. Estado del Plan de Gate

Ítem | Estado | Observación
--- | --- | ---
Criterios GO documentados | ✅ | 6 criterios objetivos con umbrales y evidencias
Criterios NO-GO documentados | ✅ | 5 bloqueantes automáticos
Evidencias mínimas exigidas | ⏳ | EVIDENCIAS_FASE9 en progreso; reportes técnicos pendientes deadline 2025-11-03
Plan de rollback completo | ✅ | Script automatizado + proceso paso a paso + criterios de activación
Comunicación preparada | ✅ | 3 plantillas (pre-deploy, post-deploy, rollback)
Comité de decisión formado | ✅ | 4 miembros (PM, Tech Lead, QA, Legal) con votación mayoría simple
Métricas post-deploy definidas | ✅ | KPIs + ventanas de monitoreo

**Estado General:** ✅ **PREPARADO — Gate documentado; pendiente ejecución evidencias técnicas y reunión comité 2025-11-04 16:00.**

---

## 10. Próximos Pasos

Paso | Responsable | Deadline
--- | --- | ---
Completar `EVIDENCIAS_FASE9.md` | PM + Tech Lead | 2025-11-03 17:00
Ejecutar i18n automated scan final | i18n Team | 2025-11-03 12:00
Ejecutar automated link checker | QA | 2025-11-03 12:00
Test manual AA (lectores pantalla + teclado) | QA + Accessibility | 2025-11-03 14:00
Compilar `accessibility_manual_test_report_v2.0.0.md` | QA | 2025-11-03 14:00
Compilar `QA_checklist_consolidacion_preview_prod.md` final | QA | 2025-11-03 16:00
Reunión comité Gate | PM, Tech Lead, QA, Legal | 2025-11-04 16:00
Decisión GO/NO-GO | Comité | 2025-11-04 16:45
Comunicación interna pre-deploy (si GO) | PM | 2025-11-04 09:00
Deploy a producción (si GO) | DevOps + Tech Lead | 2025-11-04 17:00
Comunicación post-deploy (si GO) | PM | 2025-11-04 18:00
