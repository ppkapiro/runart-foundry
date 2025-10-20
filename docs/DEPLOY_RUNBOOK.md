# Runbook de Despliegue y Operaciones

## Tabla de Contenidos
1. [Verificaciones Programadas](#verificaciones-programadas)
2. [Alertas e Incidentes](#alertas-e-incidentes)
3. [Run Repair (Reparación Rápida)](#run-repair-reparación-rápida)
4. [Rotación de Application Password](#rotación-de-application-password)
5. [Limpieza de Recursos de Prueba](#limpieza-de-recursos-de-prueba)
6. [Snapshots y Hashes de Manifiestos](#snapshots-y-hashes-de-manifiestos)

---

## Verificaciones Programadas

### Descripción General
Las verificaciones se ejecutan automáticamente según un cronograma y también se pueden disparar manualmente. Cada verificación:
- Valida autenticación contra la API de WordPress.
- Verifica que los recursos/configuraciones cumplan con los valores esperados.
- Genera un resumen compacto (sin HTML ni payloads grandes).
- Sube un artefacto con el resumen.
- Crea/actualiza/cierra un Issue si detecta problemas.

### Workflow: Verify Home (`verify-home.yml`)
**Trigger:**
- Automático: cada 6 horas (`0 */6 * * *`).
- Manual: `workflow_dispatch` sin inputs.

**Checks:**
- **Auth:** Valida credenciales contra `/wp-json/wp/v2/users/me` (200 → OK).
- **Settings:** Obtiene `show_on_front` (debe ser "page") y `page_on_front` (debe ser número >0).
- **Front Page Existence:** Verifica que la página indicada en `page_on_front` existe (GET `/wp-json/wp/v2/pages/{id}`).
- **Home Fronts:** Verifica que Home ES (`/`) y Home EN (`/en/`) responden con HTTP 200 (máx 3 redirects).

**Resumen esperado:**
```
Auth=OK/KO; show_on_front=page; page_on_front=123; front_exists=yes/no; FrontES=200/KO; FrontEN=200/KO
```

**Issue:**
- **Título:** `Alerta verificación home — YYYY-MM-DDTHH:MMZ`
- **Etiqueta:** `area:home`, `monitoring`, `incident`
- **Cuerpo:** Resumen + checklist de acciones (revisar settings, verificar Home en prod).
- **Cierre:** Automático cuando vuelve a OK.

---

### Workflow: Verify Menus (`verify-menus.yml`)
**Trigger:**
- Automático: cada 12 horas (`0 */12 * * *`).
- Manual: `workflow_dispatch` sin inputs.

**Checks:**
- **Auth:** Igual que Verify Home.
- **Manifest:** Lee `content/menus/menus.json`; calcula SHA256 del archivo.
- **Menus en WP:** Consulta menús publicados ES/EN (API `/wp-json/menus/v1/menus`).
- **Drift Detection:** Compara conteo de ítems del manifiesto con los en WP. Si no coinciden → `Drift=Sí`.

**Resumen esperado:**
```
IDs ES/EN: n/a; localizaciones: ES=... EN=...; items_es=3 items_en=3; manifest_items=3; hash=abc123...; Compliance=OK/Drift
```

**Issue:**
- **Título:** `Alerta verificación menus — YYYY-MM-DDTHH:MMZ`
- **Etiqueta:** `area:menus`, `monitoring`, `incident`
- **Cuerpo:** Resumen + checklist (revisar manifiesto, re-ejecutar `publish-prod-menu`).
- **Cierre:** Automático cuando Drift=No.

---

### Workflow: Verify Media (`verify-media.yml`)
**Trigger:**
- Automático: diario a las 03:00 UTC (`0 3 * * *`).
- Manual: `workflow_dispatch` sin inputs.

**Checks:**
- **Auth:** Igual que Verify Home.
- **Manifest:** Lee `content/media/media_manifest.json`; calcula SHA256.
- **Existence & Assignments:** Verifica medios del manifiesto en WP y conteo de asignaciones.
- **Test Media:** Cuenta medios marcados con `test=true` en el manifiesto (pueden ser borrados por cleanup).

**Resumen esperado:**
```
subidos=3, reusados=0, asignacionesOK=3, faltantes=0; hash=xyz789...
```

**Issue:**
- **Título:** `Alerta verificación media — YYYY-MM-DDTHH:MMZ`
- **Etiqueta:** `area:media`, `monitoring`, `incident`
- **Cuerpo:** Resumen + checklist (re-ejecutar `upload-media`, validar asignaciones).
- **Cierre:** Automático cuando faltantes=0.

---

### Workflow: Verify Settings (`verify-settings.yml`)
**Trigger:**
- Automático: cada 24 horas (`0 0 */1 * *`).
- Manual: `workflow_dispatch` sin inputs.

**Checks:**
- **Auth:** Igual que Verify Home.
- **Settings API:** GET `/wp-json/wp/v2/settings` y extrae:
  - `timezone_string` (esperado: `America/New_York`).
  - `permalink_structure` (esperado: `/%postname%/`).
  - `start_of_week` (esperado: `1`).
- **Compliance:** Si todos coinciden → OK; sino → Drift.

**Resumen esperado:**
```
timezone=America/New_York; permalink=/%postname%/; start_of_week=1; Compliance=OK/Drift
```

**Issue:**
- **Título:** `Alerta verificación settings — YYYY-MM-DDTHH:MMZ`
- **Etiqueta:** `area:settings`, `monitoring`, `incident`
- **Cuerpo:** Resumen + checklist (corregir settings en WP, re-ejecutar `site-settings`).
- **Cierre:** Automático cuando Compliance=OK.

---

## Alertas e Incidentes

### Cómo Verificar Alertas Activas
1. Ve a **Issues** en el repositorio.
2. Filtra por etiqueta `monitoring`.
3. Verifica que el estado es "Open".

### Cómo Responder a una Alerta
1. **Lee el Issue:** Revisa el resumen y el checklist propuesto.
2. **Toma acción manual:**
   - Para **Home:** Revisa settings en WP-Admin; asegúrate de que `show_on_front=page` y que la página existe.
   - Para **Menus:** Re-ejecuta `publish-prod-menu` para aplicar cambios del manifiesto.
   - Para **Media:** Re-ejecuta `upload-media` para sincronizar medios.
   - Para **Settings:** Corrige valores en WP-Admin o usa `site-settings`.
3. **Ejecuta Run Repair (opcional):** Usa el workflow `run-repair.yml` para automatizar la reparación (ver sección siguiente).
4. **Re-ejecuta la verificación:** Dispara la verificación correspondiente manualmente desde **Actions**.
5. **Confirma cierre:** Cuando la verificación vuelve a OK, el Issue se cierra automáticamente.

---

## Run Repair (Reparación Rápida)

### Workflow: `run-repair.yml`

**Trigger:** Manual (`workflow_dispatch`) con inputs:
- **area:** Área a reparar (enum: `home`, `menus`, `media`, `settings`).
- **mode:** Modo de ejecución (enum: `plan` o `apply`; default: `plan`).

**Comportamiento:**

| Area | Mode | Action |
|------|------|--------|
| home | plan | Mostraría qué haría set-home (noop actual) |
| home | apply | Ejecuta `set-home.yml` (workflow remoto) |
| menus | plan | Mostraría qué haría publish-prod-menu (noop actual) |
| menus | apply | Ejecuta `publish-prod-menu.yml` |
| media | plan | Mostraría qué haría upload-media (noop actual) |
| media | apply | Ejecuta `upload-media.yml` |
| settings | plan | Mostraría qué haría site-settings (noop actual) |
| settings | apply | Ejecuta `site-settings.yml` |

**Uso:**
1. Ve a **Actions** → **Run Repair**.
2. Haz clic en **Run workflow**.
3. Selecciona el `area` a reparar y el `mode` (típicamente comienza con `plan`).
4. Revisa el artefacto `run-repair_summary.txt`.
5. Si está bien, ejecuta de nuevo con `mode=apply`.

**Resumen generado:**
```
area=menus; mode=apply; action=publish-prod-menu.yml; resultado=OK; run=https://github.com/...#18657958933
```

---

## Rotación de Application Password

### Workflow: `rotate-app-password.yml`

**Trigger:** Manual (`workflow_dispatch`).

**Pasos manuales:**
1. Ve a **WP-Admin** → Usuarios → tu usuario → Application Passwords.
2. Crea una **nueva** Application Password (no reutilices una antigua).
3. Copia el nuevo token.

**Pasos automatizados:**
1. Ve a GitHub → Repo → **Settings** → **Secrets and variables** → **Repository secrets**.
2. Edita el secreto `WP_APP_PASSWORD` y pega el nuevo token.
3. Guarda.

**Validación:**
1. Ve a **Actions** → **Rotate Application Password**.
2. Haz clic en **Run workflow** (sin inputs).
3. Espera a que complete (debería validar contra `/wp-json/wp/v2/users/me` con el nuevo token).
4. Revisa el artefacto `rotate-app-password_summary.txt`.

**Salida esperada:**
```
Rotación exitosa; última validación=2025-10-20T16:45:30Z
```

---

## Limpieza de Recursos de Prueba

### Workflow: `cleanup-test-resources.yml`

**Trigger:**
- Automático: diario a las 02:30 UTC (`30 2 * * *`).
- Manual: `workflow_dispatch` sin inputs.

**Acciones:**
- Busca y borra posts/páginas cuyo título comienza con `Auto Test` y antigüedad > 7 días.
- (Opcional) Borra medios del `media_manifest.json` con `test=true`.

**Resumen generado:**
```
eliminados: posts=0, pages=0, media=0
```

**Nota:** Actualmente es un placeholder; implementación real dependerá de endpoints disponibles o WP-CLI remoto.

---

## Snapshots y Hashes de Manifiestos

### Qué se registra
Cada verificación calcula y registra:
- **SHA256 del manifiesto** (menus.json, media_manifest.json).
- **Timestamp** del run.
- **Estado de drift** (si el hash cambió sin despliegue aplicado).

### Dónde encontrar los hashes
- **Verify Menus:** Resumen incluye `hash=abc123...`
- **Verify Media:** Resumen incluye `hash=xyz789...`

### Cómo interpretar cambios de hash
1. Si el hash cambió en el último run y el workflow indicó Drift → el manifiesto fue actualizado pero no desplegado en producción.
2. Aplica el manifiesto via `publish-prod-menu` o `upload-media`.
3. Re-ejecuta la verificación; el Drift debería desaparecer.

---

## Flujo de Trabajo Típico (End-to-End)

### Escenario: Se detectó drift en menus
1. **Verificación:** `verify-menus` corre automáticamente cada 12h.
2. **Issue:** Se crea `Alerta verificación menus — 2025-10-20T12:00Z` con etiqueta `area:menus`.
3. **Acción manual o automatizada:**
   - **Opción A (Manual):** Ve a WP-Admin, actualiza menús, re-ejecuta `publish-prod-menu.yml`.
   - **Opción B (Automatizada):** Ejecuta `run-repair.yml` con `area=menus` y `mode=apply`.
4. **Re-verificación:** Dispara `verify-menus` manualmente desde **Actions**.
5. **Cierre:** Si vuelve a OK, el Issue se cierra automáticamente.

---

## Logs y Artefactos

### Dónde encontrar resultados
- **Artefactos:** Actions → Run correspondiente → **Artifacts** (ej. `verify-home-summary.txt`).
- **Issues:** Issues → Filtrar por `monitoring` → Revisar Issues abiertos.
- **Logs:** Actions → Run → Ver output de los pasos específicos.

### Información NO expuesta
- Secretos (`WP_USER`, `WP_APP_PASSWORD`) no aparecen en logs ni artefactos.
- Credenciales son utilizadas solo dentro del contenedor de GitHub Actions.

---

## Preguntas Frecuentes

**P: ¿Qué pasa si la verificación falla porque la API de WP no está disponible?**
A: El workflow marcará como "needs-attention" y creará un Issue. Verifica que el WP_BASE_URL es correcto y que la API es accesible.

**P: ¿Puedo cambiar la frecuencia de las verificaciones?**
A: Sí, edita el `cron` en cada workflow (ej. `verify-home.yml`). El formato es estándar cron: `"0 */6 * * *"` = cada 6 horas.

**P: ¿Qué hago si un Issue permanece abierto después de aplicar cambios?**
A: La verificación automática puede tardar hasta el siguiente ciclo. Para forzar cierre inmediato, dispara la verificación manualmente desde **Actions**.

---

## Mantenimiento Preventivo

### Semanal
- Revisa Issues etiquetados con `monitoring` abiertos.
- Verifica que todos los runs en **Actions** completaron exitosamente.

### Mensual
- Revisa y actualiza valores esperados en workflows (ej. timezone, permalink, menús base).
- Rota Application Password si no se ha hecho en los últimos 30 días.

### Trimestral
- Audita manifiestos (menus.json, media_manifest.json) para asegurar que reflejan la realidad.
- Revisa logs de limpieza para verificar que no se borran recursos no-teste.

---

**Última actualización:** 2025-10-20  
**Versión:** v0.5.1
