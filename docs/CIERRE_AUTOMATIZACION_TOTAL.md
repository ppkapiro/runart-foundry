# Cierre de Automatización Total — Fase 6

**Fecha de Activación:** 2025-10-20  
**Versión:** v0.5.1  
**Estado:** Verificación integral, alertas, mantenimiento y documentación operativa

---

## Resumen Ejecutivo

Se ha implementado un sistema completo de verificaciones programadas (cron + manual), alertas automáticas por Issues, reparación rápida, rotación de credenciales y limpieza de recursos. Todos los workflows están configurados en main y listos para ejecutarse.

### Componentes Implementados

| Componente | Workflow | Trigger | Status |
|------------|----------|---------|--------|
| Verificación Home | `verify-home.yml` | Cron 6h + manual | ✅ Active |
| Verificación Menús | `verify-menus.yml` | Cron 12h + manual | ✅ Active |
| Verificación Medios | `verify-media.yml` | Cron 24h + manual | ✅ Active |
| Verificación Settings | `verify-settings.yml` | Cron 24h + manual | ✅ Active |
| Reparación Rápida | `run-repair.yml` | Manual (area/mode) | ✅ Active |
| Rotación Password | `rotate-app-password.yml` | Manual | ✅ Active |
| Limpieza Recursos | `cleanup-test-resources.yml` | Cron 24h + manual | ✅ Active |

---

## Verificaciones Programadas

### 1. Verify Home (`verify-home.yml`)
- **Cron:** `0 */6 * * *` (cada 6 horas)
- **Checks:** Auth, show_on_front, page_on_front, Home ES/EN (200)
- **Artefacto:** `verify-home_summary.txt`
- **Issue label:** `area:home`
- **Resumen:** `Auth=OK/KO; show_on_front=page; page_on_front=<id>; front_exists=yes/no; FrontES=200/KO; FrontEN=200/KO`

### 2. Verify Menus (`verify-menus.yml`)
- **Cron:** `0 */12 * * *` (cada 12 horas)
- **Checks:** Auth, manifiesto menus.json (SHA256), menús WP ES/EN, drift detection
- **Artefacto:** `verify-menus_summary.txt`
- **Issue label:** `area:menus`
- **Resumen:** `IDs ES/EN: n/a; localizaciones: ES=... EN=...; items_es=# items_en=#; manifest_items=#; hash=abc123...; Compliance=OK/Drift`
- **Manifest hash:** Registrado en cada run para auditoría

### 3. Verify Media (`verify-media.yml`)
- **Cron:** `0 3 * * *` (diario a 03:00 UTC)
- **Checks:** Auth, manifiesto media_manifest.json (SHA256), existencia en WP, asignaciones, medios de test
- **Artefacto:** `verify-media_summary.txt`
- **Issue label:** `area:media`
- **Resumen:** `subidos=#, reusados=#, asignacionesOK=#, faltantes=#; hash=xyz789...`
- **Manifest hash:** Registrado en cada run para auditoría

### 4. Verify Settings (`verify-settings.yml`)
- **Cron:** `0 0 */1 * *` (cada 24 horas)
- **Checks:** Auth, timezone, permalink_structure, start_of_week
- **Artefacto:** `verify-settings_summary.txt`
- **Issue label:** `area:settings`
- **Resumen:** `timezone=<val>; permalink=<val>; start_of_week=<val>; Compliance=OK/Drift`
- **Valores esperados:**
  - `timezone_string`: `America/New_York`
  - `permalink_structure`: `/%postname%/`
  - `start_of_week`: `1`

---

## Alertas Automáticas

### Gestión de Issues
- **Cada verificación crea/actualiza/cierra Issues automáticamente** según el estado.
- **Patrón de Issue:**
  - **Título:** `Alerta verificación <área> — YYYY-MM-DDTHH:MMZ`
  - **Etiquetas:** `monitoring`, `incident`, `area:<área>`
  - **Cuerpo:** Resumen del workflow + checklist de acciones recomendadas
- **Cierre automático:** Cuando la verificación vuelve a OK

### Respuesta a Alertas
1. Revisa el Issue en **GitHub Issues**.
2. Sigue el checklist propuesto o ejecuta `run-repair.yml`.
3. Re-ejecuta la verificación desde **Actions**.
4. El Issue se cierra automáticamente cuando vuelve a OK.

---

## Run Repair (Reparación Rápida)

**Workflow:** `run-repair.yml`  
**Trigger:** Manual (`workflow_dispatch`)

**Inputs:**
- `area`: `home | menus | media | settings`
- `mode`: `plan | apply` (default: `plan`)

**Comportamiento:**
- `plan`: Describe qué haría (verificación en seco)
- `apply`: Ejecuta el workflow de reparación correspondiente

**Mapping:**
| Area | Workflow invocado |
|------|-------------------|
| home | `set-home.yml` |
| menus | `publish-prod-menu.yml` |
| media | `upload-media.yml` |
| settings | `site-settings.yml` |

**Artefacto:** `run-repair_summary.txt`  
**Resumen:** `area=<x>; mode=plan/apply; action=<workflow>; resultado=OK/KO; run=<url>`

---

## Mantenimiento y Guardarraíles

### 1. Rotación de Application Password
**Workflow:** `rotate-app-password.yml`  
**Trigger:** Manual  
**Pasos:**
1. Crear nuevo Application Password en WP-Admin.
2. Actualizar secreto `WP_APP_PASSWORD` en GitHub.
3. Ejecutar workflow para validar (debe pasar auth).

**Artefacto:** `rotate-app-password_summary.txt`  
**Resumen:** `Rotación exitosa; última validación=YYYY-MM-DDTHH:MMZ`

### 2. Limpieza de Recursos de Prueba
**Workflow:** `cleanup-test-resources.yml`  
**Trigger:** Cron `30 2 * * *` (diario 02:30 UTC) + manual  
**Acciones:**
- Borra posts/páginas con título que empieza por "Auto Test" con antigüedad > 7 días.
- (Opcional) Borra medios del manifiesto marcados con `test=true`.

**Artefacto:** `cleanup_summary.txt`  
**Resumen:** `eliminados: posts=#, pages=#, media=#`

### 3. Control de Drift y Hashes
- **Cada verificación calcula SHA256 del manifiesto** (menus.json, media_manifest.json).
- **Registra el hash en el resumen** para auditoría.
- **Marca `Drift` si el hash cambió sin que se haya aplicado en producción.**

**Interpretación:**
- Si hash cambió → manifiesto fue actualizado.
- Si Drift=Sí → cambios no desplegados; ejecutar publish/upload correspondiente.
- Si Drift=No → manifiesto y producción están sincronizados.

---

## Documentación

### Archivos Principales
- **`.github/workflows/verify-home.yml`** — Verificación de Home
- **`.github/workflows/verify-menus.yml`** — Verificación de Menús
- **`.github/workflows/verify-media.yml`** — Verificación de Medios
- **`.github/workflows/verify-settings.yml`** — Verificación de Settings
- **`.github/workflows/run-repair.yml`** — Reparación Rápida
- **`.github/workflows/rotate-app-password.yml`** — Rotación de Password
- **`.github/workflows/cleanup-test-resources.yml`** — Limpieza de Recursos
- **`docs/DEPLOY_RUNBOOK.md`** — Guía operativa detallada
- **`docs/CIERRE_AUTOMATIZACION_TOTAL.md`** — Este documento

### Manifiestos
- **`content/menus/menus.json`** — Manifest de menús (estructura: id, name, lang, items)
- **`content/media/media_manifest.json`** — Manifest de medios (estructura: id, filename, type, hash, featured_in, test)

---

## Flujo de Operación

### Operación Normal
1. Verificaciones se ejecutan automáticamente según cron.
2. Cada una genera un resumen (artefacto) y valida contra WP.
3. Si todo OK → sin Issues creados.
4. Si hay problemas → se crea/actualiza Issue con etiqueta `area:*`.

### Respuesta a Alerta
1. GitHub crea Issue automático.
2. Operador revisa el Issue y el checklist.
3. Operador ejecuta reparación manual o usa `run-repair.yml`.
4. Re-ejecuta verificación desde **Actions**.
5. Si OK → Issue se cierra automáticamente.

### Mantenimiento Programado
- **Semanal:** Revisar Issues abiertos de monitoring.
- **Mensual:** Rotar Application Password; revisar errores en logs.
- **Trimestral:** Auditar manifiestos y actualizar valores esperados si cambian.

---

## Seguridad y Privacidad

### Secretos (NO expuestos)
- `WP_USER` — Usuario de WP
- `WP_APP_PASSWORD` — Token de aplicación de WP

Estos se utilizan solo dentro de los contenedores de GitHub Actions y no aparecen en logs ni artefactos.

### Variables (Públicas)
- `WP_BASE_URL` — URL base del sitio de WP (ej. `https://misite.com`)

### Logs Mínimos
- No se imprimen HTML ni payloads grandes.
- Solo status, campos clave y conteos.
- Artefactos contienen resúmenes compactos.

---

## Estándares de Codificación

### Resúmenes (Output Esperado)
Formato: `campo1=valor1; campo2=valor2; ...` (una línea, separado por `;`)

Ejemplo Verify Home:
```
Auth=OK; show_on_front=page; page_on_front=42; front_exists=yes; FrontES=200; FrontEN=200
```

Ejemplo Verify Menus:
```
IDs ES/EN: n/a; localizaciones: ES={...} EN={...}; items_es=3 items_en=3; manifest_items=3; hash=abc123def456; Compliance=OK
```

### Manifiestos (Estructura JSON)
**menus.json:**
```json
[
  { "id": "main-es", "name": "Main Menu ES", "lang": "es", "items": [...] },
  { "id": "footer-en", "name": "Footer Menu EN", "lang": "en", "items": [...] }
]
```

**media_manifest.json:**
```json
[
  { "id": "logo", "filename": "logo.svg", "type": "image/svg+xml", "hash": "abc...", "featured_in": [...], "test": false }
]
```

---

## Releases y Versionado

### v0.5.1 — Verificación Integral + Alertas
- **Fecha:** 2025-10-20
- **Features:**
  - Verify Home/Menus/Media/Settings (cron + manual)
  - Issues automáticos por área (crear/actualizar/cerrar)
  - Run Repair (plan/apply)
  - Rotación de Application Password
  - Limpieza extendida de recursos de test
  - Control de drift y hash de manifiestos
  - Documentación operativa completa

---

## Lecciones Aprendidas

1. **Manifiestos centralizados:** Mantener menus.json y media_manifest.json actualizados es crítico para drift detection.
2. **Issues por etiqueta:** Usar etiquetas `area:*` permite buscar y filtrar fácilmente.
3. **Resúmenes compactos:** Formato de una línea (semicolon-separated) es fácil de parsear y leer.
4. **Cron timing:** Escalonar verificaciones (6h home, 12h menus, 24h media/settings) para no saturar.
5. **Logs sin secretos:** Usar variables env en scripts para mantener credenciales fuera de output.

---

## Próximos Pasos Recomendados

1. **Monitoreo de métricas:** Agregar métrica de "Issues abiertos por área" para dashboard.
2. **Webhook de notificación:** Integrar notificaciones a Slack/Email para alertas inmediatas.
3. **Auditoría de cambios:** Registrar quién/cuándo modificó manifiestos en una tabla de auditoría.
4. **Escalado:** Si hay múltiples sitios WP, replicar workflows con prefijo de sitio (ej. `verify-site1-home.yml`).

---

**Responsable:** GitHub Automation System  
**Última revisión:** 2025-10-20  
**Próxima revisión recomendada:** 2026-01-20
