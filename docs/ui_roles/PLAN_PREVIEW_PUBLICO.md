# Plan de Public Preview — RunArt Briefing v2.0.0-rc1
**Fecha:** 2025-10-21 19:15:00  
**Responsable:** PM + UX + QA  
**Duración:** 2 semanas (período de feedback controlado)

---

## 1. Alcance de Contenido

### Vistas Expuestas

Vista | Rol objetivo | Contenido incluido | Datos sensibles
--- | --- | --- | ---
`cliente_portada.md` | Cliente externo | CCEs (hito_card, entrega_card, evidencia_clip, faq_item) con dataset de ejemplo | ❌ Ninguno (datos ficticios en `cliente_vista.json`)
`owner_portada.md` | Owner interno | CCEs (kpi_chip, decision_chip, hito_card, ficha_tecnica_mini) con dataset de ejemplo | ❌ Ninguno (datos ficticios en `owner_vista.json`)
`equipo_portada.md` | Equipo interno | CCEs (hito_card, entrega_card, evidencia_clip, ficha_tecnica_mini) con dataset de ejemplo | ❌ Ninguno (datos ficticios en `equipo_vista.json`)
`admin_portada.md` | Admin (solo lectura en Preview) | CCEs (decision_chip, kpi_chip, evidencia_clip, hito_card) con dataset de ejemplo | ❌ Ninguno (datos ficticios en `admin_vista.json`)
`tecnico_portada.md` | Técnico (solo lectura en Preview) | CCEs (hito_card, evidencia_clip, ficha_tecnica_mini, decision_chip) con dataset de ejemplo | ❌ Ninguno (datos ficticios en `tecnico_vista.json`)

### Documentos de Soporte Expuestos

Documento | Propósito | Audiencia
--- | --- | ---
`glosario_cliente_2_0.md` | Glosario con lenguaje cliente (4 términos + ejemplos) | Cliente + Owner + Equipo
`TOKENS_UI.md` | Token definitions (para referencia de diseño) | Equipo + Técnico
`view_as_spec.md` | Especificación View-as (solo documentación) | Admin + Equipo + Técnico

**Nota:** View-as NO se activa para usuarios no-Admin en Preview. Solo se expone la documentación para transparencia.

---

## 2. Audiencia y Perfiles

Perfil | N° usuarios invitados | Rol asignado | Acceso
--- | --- | --- | ---
**Cliente piloto** | 2 | Cliente | Solo `cliente_portada.md` + glosario
**Owner interno piloto** | 1 | Owner | `owner_portada.md` + glosario + acceso a vistas generales
**Equipo Core** | 3 | Equipo | `equipo_portada.md` + todas las vistas (lectura)
**Admin/QA** | 2 | Admin | Todas las vistas + View-as habilitado (solo para testing)
**Técnico** | 1 | Técnico | `tecnico_portada.md` + logs/datasets técnicos

**Total audiencia:** 9 usuarios (Preview controlada)

---

## 3. Límites y Restricciones

### Funcionalidad NO Incluida en Preview

- Edición de datos en vivo (todos los datasets son read-only de ejemplo)
- Integración con backend de producción (Preview usa datos ficticios)
- View-as para roles no-Admin (solo Admin puede activar override para testing)
- Notificaciones push o emails automatizados
- Exportación de reportes (pendiente para v2.1.0)

### Restricciones Técnicas

- Preview desplegado en subdomain staging: `preview.runartfoundry.internal`
- No indexable por buscadores (robots.txt bloqueado)
- Requiere autenticación SSO (solo usuarios invitados)
- TTL de sesión: 30 minutos (consistente con View-as)

---

## 4. Lista de Verificación Previa (Pre-flight Checklist)

Criterio | Estado | Responsable | Evidencia
--- | --- | --- | ---
i18n coverage ≥99% en vistas expuestas | [ ] | UX + i18n Team | QA checklist F6-F8 + validación ES/EN manual
AA crítico (headers/buttons/chips) validado | [ ] | QA + Accessibility | REPORTE_AUDITORIA_TOKENS_F8.md
Enlaces rotos = 0 en portadas y glosario | [ ] | QA | Automated link checker (npm run check-links)
Navegación por rol (≥5 evidencias por vista principal) | [ ] | PM + UX | Validación datasets `*_vista.json` (3–6 items)
View-as NO expuesto a no-Admin | [ ] | Tech Lead + QA | Test manual roles Cliente/Owner/Equipo (debe rechazar ?viewAs)
Datasets sin datos sensibles | [ ] | PM + Legal | Review `*_vista.json` (datos ficticios confirmados)
Tokens CSS bundle incluido | [ ] | Frontend Dev | Verificar build incluye TOKENS_UI.md definitions
Banner Preview visible en todas las páginas | [ ] | Frontend Dev | Banner "⚠️ Preview v2.0.0-rc1 — Feedback bienvenido"

**Deadline pre-flight:** 24 horas antes del lanzamiento de Preview (2025-10-22 19:00)

---

## 5. Instrucciones para Feedback

### Canales de Reporte

Canal | Uso | Formato | SLA respuesta
--- | --- | --- | ---
**GitHub Issues** (repo privado) | Bugs, errores UI, i18n faltante | Template estándar (ver abajo) | 48 horas
**Formulario Google Forms** | Feedback UX, micro-copy, sugerencias | Forma libre + escala satisfacción 1–5 | 72 horas (compilación semanal)
**Slack #preview-v2-feedback** | Consultas rápidas, aclaraciones | Mensaje + screenshot opcional | 24 horas

### Template de Reporte (GitHub Issues)

```markdown
**Rol:** [Cliente / Owner / Equipo / Admin / Técnico]
**Vista:** [cliente_portada / owner_portada / ...]
**Navegador:** [Chrome 119 / Firefox 120 / Safari 17 / ...]
**Descripción:** [Breve descripción del issue]
**Pasos para reproducir:** 
1. ...
2. ...
**Comportamiento esperado:** [Qué debería pasar]
**Comportamiento actual:** [Qué pasa]
**Screenshot/evidencia:** [Adjuntar si aplica]
**Prioridad sugerida:** [Crítico / Alto / Medio / Bajo]
```

### Métricas de Aceptación en Preview

Métrica | Objetivo | Medición
--- | --- | ---
Tiempo de comprensión <10s por bloque clave | ≥80% usuarios | Encuesta post-sesión: "¿Cuánto tardaste en entender el bloque X?"
0 textos hard-coded fuera de i18n reportados | 100% | Count de issues con tag "i18n-missing"
Satisfacción general (escala 1–5) | ≥4.0 promedio | Formulario Google Forms
Issues críticos bloqueantes | ≤2 | GitHub Issues con label "critical"

---

## 6. Feedback Loop y Proceso de Incorporación

### Ciclo de Revisión

1. **Recolección diaria** (lunes–viernes):
   - PM revisa issues nuevos en GitHub y Slack.
   - Clasifica por prioridad: Crítico / Alto / Medio / Bajo.
   - Asigna a responsable (UX, Frontend, i18n Team, etc.).

2. **Triage semanal** (cada viernes 16:00):
   - Compilación de feedback en documento `FEEDBACK_PREVIEW_SEMANAL_<fecha>.md`.
   - Decisión GO/NO-GO para ajustes antes de Gate Prod.
   - Comunicación de cambios a usuarios Preview (changelog incremental).

3. **Incorporación de cambios**:
   - **Críticos:** fix inmediato (hotfix en Preview staging, <24h).
   - **Altos:** sprint siguiente (v2.0.0 final).
   - **Medios/Bajos:** backlog v2.1.0.

### Criterios de Cierre de Preview

Criterio | Umbral | Acción
--- | --- | ---
Issues críticos resueltos | 100% | Validar con QA regression
Issues altos resueltos o en progreso | ≥80% | Documentar pendientes en CHANGELOG v2.0.0
Satisfacción promedio | ≥4.0 | Encuesta final día 14 de Preview
i18n coverage validada | ≥99% | Re-run automated check + manual spot-check

**Fecha de cierre estimada:** 2025-11-04 (2 semanas desde inicio Preview)

---

## 7. Comunicación y Onboarding

### Mensaje de Invitación (Plantilla)

```markdown
Hola [Nombre],

Has sido invitado al **Public Preview de RunArt Briefing v2.0.0-rc1**. Esta versión incluye:
- Vistas específicas por rol (Cliente, Owner, Equipo, Admin, Técnico)
- Glosario cliente 2.0 con lenguaje claro
- CCEs (chips, cards, clips) con tokens de diseño
- i18n ES/EN completa

**Tu rol asignado:** [Cliente / Owner / Equipo / Admin / Técnico]

**Acceso:**
- URL: https://preview.runartfoundry.internal
- Autenticación: SSO (tu cuenta @runartfoundry.com)
- Duración: 2 semanas (hasta 2025-11-04)

**Cómo dar feedback:**
- Reporta bugs en GitHub Issues: [enlace template]
- Sugerencias UX en Google Forms: [enlace]
- Consultas rápidas en Slack #preview-v2-feedback

**Métricas que nos interesan:**
- ¿Cuánto tiempo tardas en entender cada bloque clave? (objetivo: <10s)
- ¿Encuentras textos en inglés que deberían estar en español (o viceversa)?
- ¿Los colores y contrastes son cómodos de leer?

Gracias por tu participación. Tu feedback es clave para el éxito de v2.0.0.

Saludos,  
Equipo RunArt Briefing
```

### Sesión de Onboarding (Opcional)

- **Fecha:** 1 día antes del inicio de Preview (2025-10-20 o similar)
- **Duración:** 30 minutos
- **Formato:** Video call + demo en vivo
- **Agenda:**
  1. Bienvenida y objetivos de Preview (5 min)
  2. Tour por las vistas según rol asignado (15 min)
  3. Instrucciones de feedback y canales (5 min)
  4. Q&A (5 min)

---

## 8. Rollback y Contingencia

### Criterios para Abortar Preview

Situación | Acción | Responsable
--- | --- | ---
≥5 issues críticos bloqueantes en primeras 48h | Abortar Preview; revertir a docs actuales; comunicar delay | PM + Tech Lead
Falla de autenticación SSO | Suspender acceso temporalmente; fix urgente | DevOps + Security
Datos sensibles expuestos accidentalmente | Suspender Preview inmediatamente; auditoría forense; comunicación a Legal | PM + Legal + Security

### Plan de Comunicación de Aborto

```markdown
Estimado usuario Preview,

Por precaución, hemos suspendido temporalmente el Public Preview de RunArt Briefing v2.0.0-rc1 debido a [razón breve]. Estamos trabajando en una solución y te mantendremos informado.

Fecha estimada de reanudación: [TBD]

Gracias por tu paciencia.

Equipo RunArt Briefing
```

---

## 9. Métricas de Éxito (KPIs Preview)

KPI | Objetivo | Fuente de datos | Responsable medición
--- | --- | --- | ---
Tasa de participación (usuarios activos / invitados) | ≥80% | Analytics staging | PM
Issues críticos | ≤2 | GitHub Issues | QA
Satisfacción promedio (1–5) | ≥4.0 | Google Forms | UX
Tiempo de comprensión promedio (bloques clave) | <10s | Encuesta post-sesión | UX
i18n issues reportados | ≤5 | GitHub Issues (tag "i18n-missing") | i18n Team
AA issues reportados | 0 | GitHub Issues (tag "accessibility") | Accessibility QA

---

## 10. Estado del Plan

Ítem | Estado | Observación
--- | --- | ---
Alcance definido | ✅ | 5 vistas + 3 docs soporte
Audiencia invitada | ⏳ | Pendiente envío invitaciones (deadline: 2025-10-22)
Pre-flight checklist | ⏳ | Completar 24h antes del lanzamiento
Feedback loop documentado | ✅ | Canales + template + proceso de triage
Comunicación preparada | ✅ | Plantilla invitación + onboarding opcional
Rollback plan | ✅ | Criterios aborto + comunicación

**Estado General:** ✅ **LISTO — Plan documentado; pendiente ejecución pre-flight y envío invitaciones.**

---

## Próximos Pasos
1. Ejecutar pre-flight checklist (24h antes de lanzamiento)
2. Enviar invitaciones a 9 usuarios piloto
3. Monitorear feedback diario (PM)
4. Triage semanal (viernes 16:00)
5. Compilar métricas finales día 14 y cerrar Preview con informe ejecutivo
