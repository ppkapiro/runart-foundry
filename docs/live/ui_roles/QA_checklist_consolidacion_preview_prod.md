---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ui]
---

# QA Checklist — Consolidación, Public Preview y Gate de Producción — v2.0.0

**Fecha inicio:** 2025-10-21 19:15:00  
**Responsable:** QA Lead + Accessibility QA + i18n Team  
**Estado:** ⏳ En progreso

---

## Sección 1: Consolidación (Pre-Preview)

### 1.1. Inventario de Vistas

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] 5 portadas creadas (Cliente, Owner, Equipo, Admin, Técnico) | | | QA | CONSOLIDACION_F9.md sección 1
[ ] 5 datasets `*_vista.json` con 3–6 items por CCE | | | QA | Manual count en cada JSON
[ ] i18n ES/EN presente en todas las portadas | | | i18n Team | Spot-check secciones i18n
[ ] 0 duplicados funcionales activos | | | PM + Tech Lead | CONSOLIDACION_F9.md sección 2 (tabla depuración)
[ ] Tombstones creados para legados (motivo, fecha, reemplazo) | | | Tech Lead | REPORTE_DEPURACION_F7.md

**Deadline:** 2025-10-22 12:00

---

### 1.2. Sincronización de Matrices

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] content_matrix_template.md con Fase 5–8 sections | | | PM | Grep search "Fase 5\|Fase 6\|Fase 7\|Fase 8"
[ ] Todas las vistas activas con filas en matriz | | | PM + UX | Manual review filas tecnico_portada, admin_portada, etc.
[ ] Estado por rol (G/A/R) asignado consistentemente | | | PM | Columna "Rol" con valores G/A/R sin vacíos
[ ] Columna "Evidencia" con enlaces a datasets | | | QA | Verificar enlaces `*_vista.json` presentes

**Deadline:** 2025-10-22 14:00

---

### 1.3. Gobernanza de Tokens

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] TOKENS_UI.md sin pendientes críticos | | | Tech Lead | REPORTE_AUDITORIA_TOKENS_F8 (0 hallazgos críticos)
[ ] GOBERNANZA_TOKENS.md aplicada (naming, escalas, proceso) | | | Tech Lead | Spot-check 5 portadas (100% var(--token), 0 hex sueltos)
[ ] AA validado (text-primary/bg-surface 7.2:1, color-primary/white 4.8:1) | | | Accessibility QA | REPORTE_AUDITORIA_TOKENS_F8 pares críticos

**Deadline:** 2025-10-22 16:00

---

### 1.4. View-as Endurecimiento

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] view_as_spec.md con políticas (Admin-only, TTL 30min, lista blanca) | | | Tech Lead | Read view_as_spec.md secciones "Política de activación", "Persistencia y TTL"
[ ] Logging documentado (timestamp, rol real, rol simulado, ruta) | | | Tech Lead | view_as_spec.md sección "Seguridad"
[ ] Banner accesible (aria-live='polite') documentado | | | Accessibility QA | view_as_spec.md sección "Accesibilidad"
[ ] Casos de prueba creados (TC-VA-01..TC-VA-08) | | | QA | QA_cases_viewas.md

**Deadline:** 2025-10-22 17:00

---

## Sección 2: Public Preview

### 2.1. i18n Coverage

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] Automated scan i18n ES/EN ejecutado | | | i18n Team | i18n_coverage_report_v2.0.0.md
[ ] Cobertura ≥99% (≤5 strings hard-coded) | | | i18n Team | Report con count total strings vs i18n keys
[ ] Manual spot-check en vistas principales (Cliente, Owner, Admin) | | | QA + i18n Team | Screenshots ES vs EN lado a lado
[ ] Consistencia terminológica vs glosario_cliente_2_0.md | | | UX + i18n Team | Checklist términos (Cáscara, Pátina, Colada, Desmoldeo)

**Deadline:** 2025-11-03 12:00

---

### 2.2. AA Crítico

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] Contraste headers/buttons/chips validado (≥4.5:1 text, ≥3:1 UI) | | | Accessibility QA | accessibility_manual_test_report_v2.0.0.md
[ ] Test manual lectores de pantalla (NVDA, JAWS, VoiceOver) | | | Accessibility QA | Report con screenshots/transcripts
[ ] Test navegación por teclado (Tab, Enter, Esc) | | | QA | Checklist navegación teclado (100% funcionalidad accesible sin mouse)
[ ] 0 bloqueantes críticos AA reportados | | | Accessibility QA | GitHub Issues (tag "accessibility", filter "critical")

**Deadline:** 2025-11-03 14:00

---

### 2.3. Enlaces y Navegación

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] Automated link checker ejecutado | | | QA | link_check_report_v2.0.0.md
[ ] 0 enlaces rotos en portadas y glosario | | | QA | Report con lista de rotos (debe estar vacía)
[ ] Cross-links glosario ↔ portadas funcionando | | | QA | Manual spot-check "Dónde lo verás" enlaces
[ ] Deep-links View-as documentados y reproducibles | | | QA | Test manual `/briefing?viewAs=cliente`, `/briefing?viewAs=owner`, etc.

**Deadline:** 2025-11-03 12:00

---

### 2.4. Navegación por Rol (Evidencias)

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] ≥5 evidencias navegables en vista Cliente | | | PM + QA | cliente_vista.json count items (hitos: 3, entregas: 3, evidencias: 2, faqs: 3)
[ ] ≥5 evidencias navegables en vista Owner | | | PM + QA | owner_vista.json count items (kpis: 3, decisiones: 2, hitos: 3, fichas: 2)
[ ] ≥5 evidencias navegables en vista Equipo | | | PM + QA | equipo_vista.json count items (hitos: 3, entregas: 3, evidencias: 2, fichas: 2)
[ ] ≥5 evidencias navegables en vista Admin | | | PM + QA | admin_vista.json count items (decisiones: 3, kpis: 2, evidencias: 3, hitos: 2)
[ ] ≥3 evidencias navegables en vista Técnico | | | PM + QA | tecnico_vista.json count items (incidencias: 2, logs: 2, parametros: 2, cambios: 2)

**Deadline:** 2025-10-22 18:00

---

### 2.5. View-as NO Expuesto a No-Admin

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] Test rol Cliente con ?viewAs=admin → rechazado | | | QA + Security | Test manual (debe mostrar error o ignorar)
[ ] Test rol Owner con ?viewAs=tecnico → rechazado | | | QA + Security | Test manual (debe mostrar error o ignorar)
[ ] Test rol Equipo con ?viewAs=cliente → rechazado | | | QA + Security | Test manual (debe mostrar error o ignorar)
[ ] Test rol Técnico con ?viewAs=owner → rechazado | | | QA + Security | Test manual (debe mostrar error o ignorar)
[ ] Solo Admin puede activar ?viewAs=* | | | QA + Security | QA_cases_viewas.md TC-VA-05

**Deadline:** 2025-11-03 16:00 (pre-flight Preview)

---

### 2.6. Datasets sin Datos Sensibles

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] Review manual cliente_vista.json (datos ficticios) | | | PM + Legal | Confirmar nombres/proyectos genéricos
[ ] Review manual owner_vista.json (datos ficticios) | | | PM + Legal | Confirmar KPIs redondeados, no reales
[ ] Review manual equipo_vista.json (datos ficticios) | | | PM + Legal | Confirmar tareas generalizadas
[ ] Review manual admin_vista.json (datos ficticios) | | | PM + Legal | Confirmar decisiones sin nombres reales
[ ] Review manual tecnico_vista.json (datos ficticios) | | | PM + Legal | Confirmar logs sanitizados (sin IPs/tokens)

**Deadline:** 2025-10-23 12:00 (antes de envío invitaciones Preview)

---

### 2.7. Banner Preview Visible

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] Banner "⚠️ Preview v2.0.0-rc1 — Feedback bienvenido" implementado | | | Frontend Dev | Screenshot de portada con banner
[ ] Banner visible en todas las vistas (Cliente, Owner, Equipo, Admin, Técnico) | | | QA | Navegación manual por las 5 vistas
[ ] Banner con enlace a formulario feedback | | | Frontend Dev | Test click enlace → Google Forms abierto

**Deadline:** 2025-10-23 16:00 (pre-flight Preview)

---

## Sección 3: Gate de Producción

### 3.1. Criterios GO — AA

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] Contraste AA 100% pares validados ≥4.5:1 (text) / ≥3:1 (UI) | | | Accessibility QA | accessibility_manual_test_report_v2.0.0.md
[ ] Lectores pantalla: 0 bloqueantes críticos | | | Accessibility QA | Report NVDA/JAWS/VoiceOver
[ ] Navegación teclado: 100% funcionalidad accesible sin mouse | | | QA | Checklist navegación teclado

**Deadline:** 2025-11-03 14:00

---

### 3.2. Criterios GO — i18n

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] Cobertura i18n ≥99% (≤5 strings hard-coded) | | | i18n Team | i18n_coverage_report_v2.0.0.md
[ ] Consistencia terminológica: 0 conflictos críticos | | | UX + i18n Team | Checklist términos vs glosario
[ ] Formato fechas/números localizado 100% correcto | | | QA | Screenshots comparativos ES vs EN

**Deadline:** 2025-11-03 12:00

---

### 3.3. Criterios GO — Sincronización Matrices y Tokens

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] content_matrix_template.md 100% sincronizada con vistas activas | | | PM + UX | CONSOLIDACION_F9.md sección 3
[ ] TOKENS_UI.md sin pendientes críticos (0 hallazgos abiertos) | | | Tech Lead + QA | REPORTE_AUDITORIA_TOKENS_F8.md estado final
[ ] GOBERNANZA_TOKENS.md aplicada: 100% var(--token), 0 hex sueltos | | | Tech Lead | CONSOLIDACION_F9.md sección 4

**Deadline:** 2025-11-03 16:00

---

### 3.4. Criterios GO — View-as Endurecido

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] Admin-only activation: 100% rechazado si rol ≠ Admin | | | QA + Security | TC-VA-05 (test roles Cliente/Owner/Equipo/Técnico con ?viewAs)
[ ] TTL 30 minutos: reset automático o manual funcionando | | | QA | TC-VA-03 (test sesión prolongada)
[ ] Logging funcional: 100% eventos loggeados | | | Tech Lead + DevOps | Sample logs staging (timestamp/rol real/rol simulado/ruta)
[ ] Banner aria-live='polite' anunciado correctamente | | | Accessibility QA | Test lector pantalla (NVDA/VoiceOver)

**Deadline:** 2025-11-03 16:00

---

### 3.5. Criterios GO — Evidencias Navegables

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] ≥5 evidencias navegables por rol principal (Cliente, Owner, Equipo, Admin) | | | PM + UX | CONSOLIDACION_F9.md sección 1 (datasets 3–6 items)
[ ] Enlaces internos funcionando: 0 rotos | | | QA | link_check_report_v2.0.0.md
[ ] Cross-links glosario ↔ portadas: 100% términos con "Dónde lo verás" enlazado | | | UX + QA | glosario_cliente_2_0.md validado

**Deadline:** 2025-11-03 12:00

---

### 3.6. Criterios GO — Depuración

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] 0 duplicados funcionales activos | | | PM + Tech Lead | CONSOLIDACION_F9.md sección 2
[ ] 100% legados con tombstones (motivo, fecha, reemplazo) | | | Tech Lead | REPORTE_DEPURACION_F7.md
[ ] Redirecciones documentadas: 100% rutas legacy apuntan a nuevas vistas | | | Tech Lead + DevOps | REPORTE_DEPURACION_F7.md tabla redirecciones

**Deadline:** 2025-11-03 16:00

---

### 3.7. Criterios NO-GO (Verificación de Ausencia)

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] 0 hallazgos críticos AA (contraste <4.5:1 text, <3:1 UI) | | | Accessibility QA | accessibility_manual_test_report_v2.0.0.md
[ ] <10 strings hard-coded sin i18n (<1% cobertura) | | | i18n Team | i18n_coverage_report_v2.0.0.md
[ ] <3 enlaces rotos en portadas principales | | | QA | link_check_report_v2.0.0.md
[ ] View-as NO activable por roles no-Admin | | | QA + Security | TC-VA-05 (debe rechazar)
[ ] 0 datos sensibles en datasets `*_vista.json` | | | PM + Legal | Manual review datasets

**Deadline:** 2025-11-03 16:00

---

## Sección 4: Evidencias Compiladas

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] EVIDENCIAS_FASE6.md compilada | | | PM | Índice con tabla de enlaces y extractos
[ ] EVIDENCIAS_FASE7.md compilada | | | PM | Índice con tabla de enlaces y extractos
[ ] EVIDENCIAS_FASE8.md compilada | | | PM | Índice con tabla de enlaces y extractos
[ ] EVIDENCIAS_FASE9.md compilada | | | PM + Tech Lead | Índice con ≥9 enlaces y extractos (en progreso)

**Deadline:** 2025-11-03 17:00

---

## Sección 5: Reportes Técnicos

Criterio | Estado | Observación | Responsable | Evidencia
--- | --- | --- | --- | ---
[ ] REPORTE_AUDITORIA_TOKENS_F8.md completado | | | QA + Accessibility | ✅ Completado 2025-10-21 18:00:45
[ ] CONSOLIDACION_F9.md completada | | | PM + Tech Lead | ✅ Completado 2025-10-21 19:15:00
[ ] i18n_coverage_report_v2.0.0.md completado | | | i18n Team | Pendiente deadline 2025-11-03 12:00
[ ] link_check_report_v2.0.0.md completado | | | QA | Pendiente deadline 2025-11-03 12:00
[ ] accessibility_manual_test_report_v2.0.0.md completado | | | Accessibility QA | Pendiente deadline 2025-11-03 14:00

**Deadline:** 2025-11-03 14:00

---

## Sección 6: Estado General

Sección | Estado | Pendientes críticos | Observación
--- | --- | --- | ---
**1. Consolidación** | ⏳ | [ ] Inventario vistas<br>[ ] Sincronización matrices<br>[ ] Gobernanza tokens<br>[ ] View-as | Deadline 2025-10-22 17:00
**2. Public Preview** | ⏳ | [ ] i18n coverage<br>[ ] AA crítico<br>[ ] Enlaces<br>[ ] Evidencias por rol<br>[ ] View-as no-Admin<br>[ ] Datasets sin sensibles<br>[ ] Banner Preview | Deadline 2025-11-03 16:00
**3. Gate de Producción** | ⏳ | [ ] 6 criterios GO<br>[ ] 5 criterios NO-GO | Deadline 2025-11-03 16:00
**4. Evidencias** | ⏳ | [ ] EVIDENCIAS_FASE9 | Deadline 2025-11-03 17:00
**5. Reportes Técnicos** | ⏳ | [ ] i18n report<br>[ ] Link check report<br>[ ] AA manual test report | Deadline 2025-11-03 14:00

---

## Resumen de Validación

- **Total ítems checklist:** 76
- **Completados:** 0 (inicio 2025-10-21 19:15:00)
- **Pendientes:** 76
- **Bloqueantes críticos:** Ninguno identificado aún (pending validación)

**Estado General:** ⏳ **En progreso — Checklist lista para ejecución; validación programada 2025-10-22–2025-11-03.**

---

## Aprobación Final

Rol | Nombre | Firma | Fecha
--- | --- | --- | ---
**QA Lead** | | | 
**Accessibility QA** | | | 
**i18n Team Lead** | | | 
**PM** | | | 

**Decisión:** [ ] GO / [ ] NO-GO

**Observaciones finales:**
```
[Espacio para notas del comité Gate de Producción]
```

---

**Próximos pasos:**
1. Ejecutar ítems de checklist según deadlines (2025-10-22–2025-11-03)
2. Compilar reportes técnicos (i18n, links, AA manual)
3. Validar criterios GO/NO-GO en reunión comité (2025-11-04 16:00)
4. Firmar aprobación final y comunicar decisión
