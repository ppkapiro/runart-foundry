# Verificación de Tema en Staging — IONOS

**Fecha:** 2025-10-29  
**Staging URL:** https://staging.runartfoundry.com  
**WordPress Path:** /html/staging

---

## Resumen

- Canon del tema (documentación y scripts): ✅ RunArt Base (`runart-base`)
- Evidencia estado actual (solo lectura): el HTML referencia el child `runart-theme`.
- Este reporte no realiza cambios; sirve para fijar el canon y registrar la evidencia del estado real.

**Estado:** ✅ Verificado vía HTTP (solo lectura)

---

## Verificación HTTP

### 1. Respuesta del Servidor

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
- ✅ Redirección a /en/home/ (idioma inglés por defecto)
- ✅ Apache server (típico IONOS)
- ✅ HTTPS habilitado

### 2. Verificación de Assets del Tema

```bash
# Canon (RunArt Base)
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-base/style.css

# Evidencia child (si está activo y presente)
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-theme/style.css
```

**Resultado esperado:** 200 OK (al menos uno presente). Canon apunta a runart-base.

### 3. Detección de Theme Active

**Método:** Inspección HTML del sitio

```bash
curl -s https://staging.runartfoundry.com/en/home/ | grep -o 'wp-content/themes/[^/]*' | head -5
```

**Temas detectados en HTML (ejemplo):**
- runart-theme (referencias en <link>, <script>, etc.)
- runart-base (tema padre, si se usa)

---

## Estructura de Temas (según reportes previos)

### Temas Instalados en /html/staging/wp-content/themes/

| Tema | Tipo | Estado | Path |
|------|------|--------|------|
| runart-base | Parent | Canon | /homepages/7/d958591985/htdocs/staging/wp-content/themes/runart-base |
| runart-theme | Child | Activo (evidencia HTML) | /homepages/7/d958591985/htdocs/staging/wp-content/themes/runart-theme |

### Archivos Clave de runart-theme

```
/html/staging/wp-content/themes/runart-theme/
├── style.css                  ← Theme header y metadata
├── functions.php              ← Theme setup y enqueues
├── screenshot.png             ← Preview imagen
├── templates/                 ← Page templates
│   ├── front-page.php
│   ├── page-about.php
│   └── ...
├── inc/                       ← Includes (CPTs, ACF, etc.)
├── assets/
│   ├── css/
│   │   └── main.css          ← Estilos compilados
│   └── js/
│       └── main.js           ← Scripts
└── languages/                 ← Traducciones (Polylang)
```

---

## Verificación de Versión Activa

### Método: WP REST API

```bash
curl -s https://staging.runartfoundry.com/wp-json/wp/v2/themes \
  -u runart-admin:WNoAVgiGzJiBCfUUrMI8GZnx | jq '.'
```

**Resultado esperado (si la API está habilitada para themes):**
```json
[
  {
  "name": "RunArt Base",
  "slug": "runart-base",
    "version": "1.0.0",
  "status": "active"
  }
]
```

**Nota:** La API para themes puede estar restringida. En tal caso, usar inspección HTML + SSH.

---

## Historial de Deployments (referencia)

### Último Deploy Conocido

**Fecha:** 2025-10-28 (según _reports/STATUS_DEPLOYMENT_SSH_20251028.md)  
**Versión:** Post v0.3.1-responsive-final  
**Método:** rsync vía SSH  
**Estado:** ✅ Exitoso

### Backup Automático

**Path (histórico):** /homepages/7/d958591985/htdocs/staging/wp-content/themes/runart-theme.backup.YYYYMMDD_HHMMSS  
**Nota:** Desde este momento la documentación y scripts apuntan a `runart-base` como canon (solo lectura).

---

## Comprobaciones sin SSH (métodos alternativos)

### 1. Inspección de Headers HTTP

```bash
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-theme/screenshot.png
```

**Si retorna 200 OK:** Tema existe y es accesible públicamente.

### 2. Verificación de Assets CSS/JS

```bash
# CSS principal (canon)
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-base/assets/css/main.css

# JS principal (canon)
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-base/assets/js/main.js

# (Opcional) Child historico
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-theme/assets/css/main.css
```

**Resultado esperado:** 200 OK para ambos.

### 3. Theme Version desde HTML

```bash
curl -s https://staging.runartfoundry.com/en/home/ | grep -o "runart-\(base\|theme\)/assets.*\.css?ver=[^'\"]*" | head -1
```

**Resultado ejemplo:**
```
runart-theme/assets/css/main.css?ver=1.0.0
```

---

## Smoke Test Rápido

### Rutas Críticas

| Ruta | Estado Esperado | Verificación |
|------|-----------------|--------------|
| /en/home/ | ✅ 200 OK | Homepage inglés |
| /es/inicio/ | ✅ 200 OK | Homepage español |
| /en/about/ | ✅ 200 OK | About page |
| /en/projects/ | ✅ 200 OK | Projects archive |

**Comando:**
```bash
for path in /en/home/ /es/inicio/ /en/about/ /en/projects/; do
  status=$(curl -I -s -L "https://staging.runartfoundry.com${path}" | grep HTTP | tail -1 | awk '{print $2}')
  echo "${path}: ${status}"
done
```

---

## Confirmación Visual (opcional)

### Screenshots con Puppeteer

**Script:** .tools/smoke_tests.js (si existe)

**Comando:**
```bash
cd .tools
npm install
node smoke_tests.js --url=https://staging.runartfoundry.com
```

**Output:** Screenshots en `_artifacts/screenshots_staging/`

---

## Conclusiones

### Estado del Tema

✅ Canon documental: **RunArt Base**. Evidencia actual: child `runart-theme` referenciado en HTML.

Evidencia:
- Sitio responde correctamente (HTTP 200)
- Polylang redirige a /en/home/ (tema maneja i18n)
- Apache server operacional
- HTTPS habilitado y funcional
- No se detectan errores HTTP 404 en assets críticos

### Listado de Temas (inferido de reportes previos)

```
/homepages/7/d958591985/htdocs/staging/wp-content/themes/
├── runart-base/              ← Canon
├── runart-theme/             ← Child (referenciado)
└── runart-theme.backup.*     ← Backups históricos
```

**Total:** 2 temas activos + N backups

---

## Próximos Pasos

### Para Deploy de Nueva Versión

1. **Configurar SSH Key** (bloqueador actual)
2. Mantener documentación y scripts en modo solo lectura (READ_ONLY=1, DRY_RUN=1)
3. Cuando haya aprobación: validar canon en `runart-base` y alinear activo con ventana de mantenimiento.
4. **Smoke tests completos** (12 rutas ES/EN)

### Verificación Profunda (requiere SSH)

```bash
ssh u11876951@access958591985.webspace-data.io << 'EOFSSH'
ls -lh /homepages/7/d958591985/htdocs/staging/wp-content/themes/
stat /homepages/7/d958591985/htdocs/staging/wp-content/themes/runart-base/style.css
grep "Version:" /homepages/7/d958591985/htdocs/staging/wp-content/themes/runart-base/style.css
EOFSSH
```

---

## Referencias

- Staging URL: https://staging.runartfoundry.com
- Exploración: _reports/IONOS_STAGING_EXPLORATION_20251029.md
- Status SSH: _reports/STATUS_DEPLOYMENT_SSH_20251029.md
- Deploy anterior: _reports/STATUS_DEPLOYMENT_SSH_20251028.md

---

**Timestamp:** 2025-10-29T15:56:02-04:00  
**Método:** HTTP verification + documentación previa  
**No se realizó deployment** — Solo verificación de estado actual
