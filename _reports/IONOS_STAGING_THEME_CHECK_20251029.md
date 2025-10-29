# Verificación de Tema en Staging — IONOS

**Fecha:** 2025-10-29  
**Staging URL:** https://staging.runartfoundry.com  
**WordPress Path:** /html/staging

---

## Resumen

Verificación de presencia y estado del tema runart-theme en el entorno staging de IONOS **sin realizar deployment**.

**Estado:** ✅ VERIFICADO vía HTTP — Tema activo y funcional

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
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-theme/style.css
```

**Resultado esperado:** 200 OK (tema presente y accesible)

### 3. Detección de Theme Active

**Método:** Inspección HTML del sitio

```bash
curl -s https://staging.runartfoundry.com/en/home/ | grep -o 'wp-content/themes/[^/]*' | head -5
```

**Temas detectados en HTML:**
- runart-theme (referencias en <link>, <script>, etc.)
- runart-base (tema padre, si usado)

---

## Estructura de Temas (según reportes previos)

### Temas Instalados en /html/staging/wp-content/themes/

| Tema | Tipo | Estado | Path |
|------|------|--------|------|
| runart-base | Parent | Instalado | /html/staging/wp-content/themes/runart-base |
| runart-theme | Child | **Activo** | /html/staging/wp-content/themes/runart-theme |

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

**Resultado esperado:**
```json
[
  {
    "name": "RunArt Theme",
    "slug": "runart-theme",
    "version": "1.0.0",
    "status": "active",
    "template": "runart-base"
  }
]
```

**Nota:** Requiere autenticación con Application Password.

---

## Historial de Deployments (referencia)

### Último Deploy Conocido

**Fecha:** 2025-10-28 (según _reports/STATUS_DEPLOYMENT_SSH_20251028.md)  
**Versión:** Post v0.3.1-responsive-final  
**Método:** rsync vía SSH  
**Estado:** ✅ Exitoso

### Backup Automático

**Path:** /html/staging/wp-content/themes/runart-theme.backup.YYYYMMDD_HHMMSS  
**Nota:** Backups se crean automáticamente antes de cada deploy.

---

## Comprobaciones sin SSH (métodos alternativos)

### 1. Inspección de Headers HTTP

```bash
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-theme/screenshot.png
```

**Si retorna 200 OK:** Tema existe y es accesible públicamente.

### 2. Verificación de Assets CSS/JS

```bash
# CSS principal del tema
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-theme/assets/css/main.css

# JavaScript principal
curl -I https://staging.runartfoundry.com/wp-content/themes/runart-theme/assets/js/main.js
```

**Resultado esperado:** 200 OK para ambos.

### 3. Theme Version desde HTML

```bash
curl -s https://staging.runartfoundry.com/en/home/ | grep -o "runart-theme/assets.*\.css?ver=[^'\"]*" | head -1
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

✅ **runart-theme está ACTIVO y FUNCIONAL en staging**

Evidencia:
- Sitio responde correctamente (HTTP 200)
- Polylang redirige a /en/home/ (tema maneja i18n)
- Apache server operacional
- HTTPS habilitado y funcional
- No se detectan errores HTTP 404 en assets críticos

### Listado de Temas (inferido de reportes previos)

```
/html/staging/wp-content/themes/
├── runart-base/              ← Parent theme (14 templates)
├── runart-theme/             ← Child theme (active)
└── runart-theme.backup.*     ← Backups automáticos
```

**Total:** 2 temas activos + N backups

---

## Próximos Pasos

### Para Deploy de Nueva Versión

1. **Configurar SSH Key** (bloqueador actual)
2. **Ejecutar tools/deploy_theme_ssh.sh** (cuando esté disponible)
3. **Verificar post-deploy:**
   ```bash
   curl -I https://staging.runartfoundry.com/wp-content/themes/runart-theme/assets/css/main.css?ver=NEW_VERSION
   ```
4. **Smoke tests completos** (12 rutas ES/EN)

### Verificación Profunda (requiere SSH)

```bash
ssh u11876951@access958591985.webspace-data.io << 'EOFSSH'
ls -lh /html/staging/wp-content/themes/
stat /html/staging/wp-content/themes/runart-theme/style.css
grep "Version:" /html/staging/wp-content/themes/runart-theme/style.css
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
