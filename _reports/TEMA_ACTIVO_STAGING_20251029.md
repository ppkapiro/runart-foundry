# Tema Activo en Staging — Verificación y Canon

**Fecha:** 2025-10-29  
**Staging URL:** https://staging.runartfoundry.com  
**Método:** Verificación HTTP + Documentación

---

## ✅ Tema Activo Confirmado

### Canon Documental

- **Nombre:** RunArt Base
- **Slug:** `runart-base`
- **Ruta oficial:** `/homepages/7/d958591985/htdocs/staging/wp-content/themes/runart-base/`
- **Estado en repo:** Todo el repositorio y scripts apuntan a `runart-base` como referencia canónica

### Evidencia Actual (Solo Lectura)

**Observación HTTP:**
- El HTML de staging referencia el child theme `runart-theme` en assets (`<link>`, `<script>`)
- Redirección Polylang activa: `302` → `/en/home/` (i18n funcional)
- HTTPS habilitado y operacional
- Apache server detectado

**Interpretación:**
- Canon documental = `runart-base` (parent theme)
- Tema activo actual = `runart-theme` (child theme, referenciado en HTML)
- Esta documentación NO modifica el servidor; establece el canon para futuros deploys

---

## 📋 Estructura de Temas

### Staging Theme Directory

```
/homepages/7/d958591985/htdocs/staging/wp-content/themes/
├── runart-base/              ← Canon oficial (parent)
├── runart-theme/             ← Child (actualmente referenciado)
└── runart-theme.backup.*     ← Backups históricos
```

### Archivos Clave (Canon)

```
runart-base/
├── style.css                 ← Theme header con metadata
├── functions.php             ← Theme setup y enqueues
├── index.php                 ← Template fallback obligatorio
├── header.php, footer.php
├── page.php, front-page.php
├── templates/                ← Page templates
├── inc/                      ← Includes (CPTs, ACF, custom features)
├── assets/
│   ├── css/
│   │   ├── main.css
│   │   └── responsive.overrides.css
│   └── js/
│       └── main.js
└── languages/                ← Traducciones (Polylang)
```

---

## 🔒 Operación Congelada

### Estado Actual

- **READ_ONLY:** Activado (`READ_ONLY=1`)
- **DRY_RUN:** Activado (`DRY_RUN=1`)
- **SSH:** Deshabilitado por política
- **Modificaciones:** Ninguna; este reporte es documental

### Políticas Activas

1. **Congelación de Deploys:** Scripts en modo seguro por defecto
2. **CI Guardrails:** Verificación automática de flags en PRs
3. **Media Review:** Cambios en media requieren etiqueta `media-review`
4. **Alineación Futura:** Requiere issue aprobado + ventana de mantenimiento

---

## 🧪 Verificación HTTP

### Respuesta del Servidor

```bash
curl -I -L https://staging.runartfoundry.com
```

**Resultado:**

```
HTTP/2 302 (redirect)
Location: https://staging.runartfoundry.com/en/home/
X-Redirect-By: Polylang

HTTP/2 200 OK
Content-Type: text/html; charset=UTF-8
Server: Apache
```

**Análisis:**
- ✅ Sitio responde correctamente
- ✅ Polylang activo (i18n funcional)
- ✅ Redirección a `/en/home/` (inglés por defecto)
- ✅ Apache server (típico IONOS)
- ✅ HTTPS habilitado

### Assets del Tema (Canon)

```bash
# Verificar parent theme (canon)
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-base/style.css

# Verificar child theme (evidencia actual)
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-theme/style.css
```

**Esperado:** 200 OK para ambos (parent + child instalados)

---

## 📊 Configuración WordPress

### Polylang (i18n)

- ✅ Plugin activo
- ✅ Idiomas: ES + EN
- ✅ Redirección automática funcional
- ✅ Cookie `pll_language` detectada

### Permalinks

- ✅ Estructura bilingüe: `/{lang}/{slug}/`
- ✅ Home ES: `/es/inicio/`
- ✅ Home EN: `/en/home/`

### HTTPS

- ✅ Certificado válido
- ✅ Redirección HTTP → HTTPS activa

---

## 🔄 Próxima Alineación (Pendiente)

### Objetivo

Alinear tema activo en staging con el canon documental (`runart-base`).

### Requisitos

1. ✅ Issue aprobado con ventana de mantenimiento
2. ✅ SSH key configurado (bloqueador actual)
3. ✅ Backup previo del child theme
4. ✅ Smoke tests post-cambio (12 rutas ES/EN)
5. ✅ Documentación del cambio en `_reports/`

### Procedimiento (No Ejecutado)

```bash
# 1. Conectar al servidor
ssh u111876951@access958591985.webspace-data.io

# 2. Cambiar tema activo
cd /homepages/7/d958591985/htdocs/staging
wp theme activate runart-base --allow-root

# 3. Flush cache y permalinks
wp cache flush --allow-root
wp rewrite flush --allow-root

# 4. Verificar
wp theme list --allow-root
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-base/style.css
```

---

## 📚 Referencias

- **Deployment Master:** `docs/Deployment_Master.md`
- **Theme Check:** `_reports/IONOS_STAGING_THEME_CHECK_20251029.md`
- **Staging Exploration:** `_reports/IONOS_STAGING_EXPLORATION_20251029.md`
- **SSH Status:** `_reports/STATUS_DEPLOYMENT_SSH_20251029.md`
- **Normalización:** `_reports/REFERENCIAS_TEMA_CORREGIDAS_20251029.md`

---

## ✅ Conclusión

- **Canon fijado:** RunArt Base (`runart-base`)
- **Estado actual:** Child theme `runart-theme` referenciado (no modificado)
- **Operación:** Congelada (READ_ONLY + DRY_RUN activos)
- **Próxima acción:** Alineación bajo ventana aprobada con SSH key configurado

---

**Timestamp:** 2025-10-29T19:30:00Z  
**Método:** Verificación HTTP + Documentación canonical  
**No se realizó deployment** — Reporte documental estableciendo canon oficial
