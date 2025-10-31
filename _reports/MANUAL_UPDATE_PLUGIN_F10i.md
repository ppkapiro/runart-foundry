# Manual de Actualización — Plugin WP-CLI Bridge v1.2.0 (F10-i + F11)

**Fecha:** 2025-10-31  
**Versión:** 1.2.0  
**Branch:** `feat/ai-visual-implementation`  
**Commit:** `c2f2f8ee`

---

## ⚠️ IMPORTANTE: WordPress NO se actualiza desde Git

El plugin de WordPress en staging **NO** se sincroniza automáticamente desde el repositorio Git. Cada cambio en `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php` requiere **actualización manual** siguiendo este flujo.

---

## 📦 Paquete de Distribución

**Archivo ZIP:**
- Ubicación: `_dist/plugins/runart-wpcli-bridge/runart-wpcli-bridge-v1.2.0_f10i-f11_20251031T105200Z.zip`
- Symlink: `_dist/runart-wpcli-bridge-latest.zip` → (apunta al ZIP versionado)
- SHA256: `0d61410a0a0e867b01983fc03b0ccb3d0b6ec7291aed78114701c0553f9bafd7`

**Contenido del ZIP:**
- `runart-wpcli-bridge.php` (109KB, versión 1.2.0)
- `data/assistants/rewrite/` (contenidos enriquecidos F9)
- `data/embeddings/` (embeddings visuales y correlaciones F7/F8)
- `README.md`
- `init_monitor_page.php`

---

## 🚀 Flujo de Actualización (Paso a Paso)

### 1. Clonar/actualizar repositorio localmente

```bash
cd ~/work/runartfoundry
git checkout feat/ai-visual-implementation
git pull origin feat/ai-visual-implementation
```

### 2. Verificar que tienes el ZIP actualizado

```bash
ls -lh _dist/runart-wpcli-bridge-latest.zip
# Debe mostrar: runart-wpcli-bridge-latest.zip -> plugins/runart-wpcli-bridge/runart-wpcli-bridge-v1.2.0_f10i-f11_20251031T105200Z.zip

sha256sum _dist/runart-wpcli-bridge-latest.zip
# Debe mostrar: 0d61410a0a0e867b01983fc03b0ccb3d0b6ec7291aed78114701c0553f9bafd7
```

### 3. Descargar ZIP a tu máquina local

**Opción A — SCP (desde tu máquina local):**
```bash
scp pepe@ppcapiro:~/work/runartfoundry/_dist/runart-wpcli-bridge-latest.zip ~/Downloads/
```

**Opción B — Desde el servidor:**
```bash
# Copiar a carpeta accesible por SFTP
cp _dist/runart-wpcli-bridge-latest.zip ~/public_html/tmp/
```

### 4. Subir plugin a WordPress staging

1. Abrir navegador → https://staging.runartfoundry.com/wp-admin/
2. Login con credenciales de admin
3. Menú lateral: **Plugins** → **Añadir nuevo plugin**
4. Click en botón: **Subir plugin**
5. Click en **Seleccionar archivo** → elegir `runart-wpcli-bridge-latest.zip`
6. Click en **Instalar ahora**

### 5. Reemplazar plugin existente

Si WordPress muestra mensaje:
> "El plugin RunArt WP-CLI Bridge ya está instalado"

**Elegir:** "Reemplazar el plugin actual"

**Alternativa (si da problemas):**
1. Plugins → Buscar "RunArt WP-CLI Bridge"
2. Click en **Desactivar**
3. Click en **Eliminar**
4. Repetir paso 4 (subir nuevo ZIP)
5. Click en **Activar plugin**

### 6. Verificar activación

Después de instalar/reemplazar:
1. Ir a: **Plugins** → **Plugins instalados**
2. Buscar: "RunArt WP-CLI Bridge (REST)"
3. Verificar:
   - **Estado:** Activo (texto azul)
   - **Versión:** 1.2.0
   - **Descripción:** "Endpoints REST seguros para WP-CLI, contenidos enriquecidos con carga rápida (F10-i) y job queue generación IA (F11)."

### 7. Verificar endpoints REST

Abrir navegador o usar `curl` para verificar que los nuevos endpoints responden:

**Endpoint 1 — Listado IA rápido:**
```bash
curl -X GET "https://staging.runartfoundry.com/wp-json/runart/content/enriched-list" \
  -H "Cookie: wordpress_logged_in_xxx=..." \
  | jq '.ok, .items | length, .source, .duration_ms'
```

**Respuesta esperada:**
```json
{
  "ok": true,
  "items": [ ... ],
  "total": 3,
  "source": "wp-content/runart-data (production)",
  "duration_ms": 15
}
```

**Endpoint 2 — Páginas WP paginadas:**
```bash
curl -X GET "https://staging.runartfoundry.com/wp-json/runart/content/wp-pages?per_page=10&page=1" \
  -H "Cookie: wordpress_logged_in_xxx=..." \
  | jq '.ok, .pages | length'
```

**Respuesta esperada:**
```json
{
  "ok": true,
  "pages": [
    { "id": "page_42", "title": "Exposición de Arte", "slug": "exposicion-arte", "lang": "es" },
    ...
  ],
  "total": 10,
  "page": 1,
  "per_page": 10
}
```

**Endpoint 3 — Solicitud generación IA (POST):**
```bash
curl -X POST "https://staging.runartfoundry.com/wp-json/runart/content/enriched-request" \
  -H "Cookie: wordpress_logged_in_xxx=..." \
  -H "Content-Type: application/json" \
  -H "X-WP-Nonce: <nonce>" \
  -d '{"wp_id": 123, "slug": "test-page", "lang": "es", "assistant": "ia-visual"}'
```

**Respuesta esperada (staging readonly):**
```json
{
  "ok": false,
  "status": "readonly",
  "message": "Staging en modo solo lectura. Solicitud registrada para procesamiento en CI.",
  "job_id": "req_1730345678_123"
}
```

### 8. Probar panel editorial

1. Ir a: https://staging.runartfoundry.com/en/panel-editorial-ia-visual/
2. **Verificar carga rápida:**
   - Panel debe mostrar contenidos IA en **<1 segundo**
   - Banner debe decir: "✓ IA (3) Cargando páginas WP…"
   - Después de 2-5s: "✓ IA (3) ✓ WP (10)" o "✓ IA (3) ⚠ WP lento o sin respuesta."
3. **Verificar botón "Generar IA":**
   - Items con `status=pending` deben mostrar botón azul "Generar IA"
   - Click en botón → alert: "⚠ Solicitud registrada (staging readonly). Se procesará en CI."
4. **Abrir consola de desarrollador (F12):**
   - Verificar logs: `[runart-ai-visual] IA fetch OK`, `[runart-ai-visual] WP fetch OK`
   - No debe haber errores 404 ni "page_id parameter is required"

---

## 🔍 Troubleshooting

### Problema 1: "El plugin no aparece en la lista de plugins instalados"

**Causa:** WordPress no detectó el archivo principal del plugin.

**Solución:**
1. Verificar que el ZIP contiene `runart-wpcli-bridge.php` en la raíz (no dentro de subcarpeta)
2. Re-generar ZIP:
   ```bash
   cd tools/wpcli-bridge-plugin
   zip -r runart-wpcli-bridge-latest.zip runart-wpcli-bridge.php data/ README.md init_monitor_page.php
   ```
3. Subir ZIP regenerado

### Problema 2: "Los endpoints devuelven 404 Not Found"

**Causa:** Plugin no está activado o permalinks no están actualizados.

**Solución:**
1. WP Admin → Plugins → verificar que "RunArt WP-CLI Bridge" está **Activo**
2. WP Admin → Ajustes → Enlaces permanentes → Click en **Guardar cambios** (flush rewrite rules)
3. Reintentar endpoint:
   ```bash
   curl -I https://staging.runartfoundry.com/wp-json/runart/content/enriched-list
   ```

### Problema 3: "Panel muestra 'Cargando…' indefinidamente"

**Causa:** JavaScript no cargó correctamente o endpoints no responden.

**Solución:**
1. Abrir consola de desarrollador (F12)
2. Buscar errores en red (pestaña Network):
   - Filtrar por `runart/content/`
   - Verificar status code (debe ser 200)
3. Si hay error 401/403:
   - Verificar que estás logueado en WordPress
   - Probar endpoint con credenciales:
     ```bash
     curl -u admin:password https://staging.runartfoundry.com/wp-json/runart/content/enriched-list
     ```

### Problema 4: "Botón 'Generar IA' no aparece"

**Causa:** Items no tienen `status=pending` o faltan IDs de WP.

**Solución:**
1. Verificar respuesta de `enriched-list`:
   ```bash
   curl https://staging.runartfoundry.com/wp-json/runart/content/enriched-list | jq '.items[] | {id, status, wp_id}'
   ```
2. Confirmar que existe al menos un item con:
   ```json
   { "id": "page_123", "status": "pending", "wp_id": 123 }
   ```
3. Si no hay items pending, crear uno manualmente:
   - Editar `data/assistants/rewrite/index.json`
   - Agregar: `{ "page_id": "page_999", "status": "pending" }`
   - Re-empaquetar plugin y subir

### Problema 5: "WP muestra timeout en todos los requests"

**Causa:** Staging es muy lento o endpoint `wp-pages` tiene bug.

**Solución:**
1. Verificar logs de staging:
   ```bash
   tail -f wp-content/uploads/runart-jobs/wp_pages_fetch.log
   ```
2. Si timeout es legítimo (>5s), panel debe funcionar en "modo IA solamente"
3. Aumentar timeout en panel JS (editar `panel-editor.js`, línea `fetchWithTimeout(..., 5000)` → cambiar a `10000`)

---

## 📊 Cambios en esta Versión (1.2.0)

### Backend (PHP)

**Nuevos endpoints:**
- `GET /runart/content/enriched-list` — Listado IA con cascading reads (wp-content → uploads → plugin)
- `GET /runart/content/wp-pages` — Páginas WP paginadas (simplificado, sin fusión)
- `GET /runart/content/enriched-merge` — Helper de fusión server-side (opcional)
- `POST /runart/content/enriched-request` — Job queue de solicitudes generación IA

**Helper de permisos:**
- `runart_wpcli_bridge_permission_editor()` — Validación `edit_pages || manage_options`

**Optimizaciones:**
- Cascading file reads con 3 paths ordenados (target: <200ms)
- Respuesta mínima en `wp-pages` (solo id/title/slug/lang)
- Logging opcional de duración (`duration_ms`)
- Graceful readonly handling en staging

### Frontend (JavaScript)

**Panel reescrito (ES5):**
- `fetchWithTimeout()` con `AbortController` + fallback `Promise.race`
- Carga dos pasos: IA inmediata → WP async con timeout 5s
- Status badges informativos: ✓ IA, ✓ WP, ⚠ Timeout, ⚠ Error
- Merge in-memory sin re-fetch
- Botón "Generar IA" para items `status=pending && wp_id`
- Handler global `window.runartRequestGeneration()`

**UX:**
- Render inicial <1s con contenidos IA
- No bloqueo de UI mientras carga WP
- Feedback claro en alerts después de solicitar generación
- Logging detallado en consola para debugging

---

## 📝 Checklist Post-Instalación

- [ ] Plugin activo en WP Admin → Plugins
- [ ] Versión 1.2.0 visible en descripción
- [ ] Endpoint `enriched-list` responde con `ok:true` + items array
- [ ] Endpoint `wp-pages` responde con `ok:true` + pages array
- [ ] Endpoint `enriched-request` responde con `ok:false, status:readonly` (staging)
- [ ] Panel editorial carga en <1s mostrando items IA
- [ ] Banner muestra "✓ IA (N)" inmediatamente
- [ ] Después de 2-5s: banner actualiza con "✓ WP (M)" o "⚠ WP lento"
- [ ] Botón "Generar IA" visible en items pending
- [ ] Click en botón → alert con mensaje de confirmación
- [ ] Consola sin errores 404 ni "page_id parameter is required"
- [ ] Jobs registrados en `wp-content/uploads/runart-jobs/enriched-requests.json` (verificar via SFTP)

---

## 🔗 Referencias

- **PR:** https://github.com/RunArtFoundry/runart-foundry/pull/1
- **Commit:** c2f2f8ee
- **Bitácora:** `_reports/BITACORA_AUDITORIA_V2.md` (entradas F10-i + F11)
- **Arquitectura:** `docs/ai/architecture_overview.md` (sección F11)

---

**Última actualización:** 2025-10-31T11:05:00Z
