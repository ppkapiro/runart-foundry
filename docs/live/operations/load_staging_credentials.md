---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ops]
---

# Configuración de Credenciales de STAGING

## 📋 Propósito

Este documento explica cómo cargar las credenciales de WordPress STAGING en GitHub para que los workflows `verify-*` puedan ejecutarse en la rama `main`.

## 🎯 Objetivo

Configurar tres valores en el repositorio de GitHub:

1. **WP_BASE_URL** (variable): URL pública de STAGING
2. **WP_USER** (secret): Usuario técnico de WordPress
3. **WP_APP_PASSWORD** (secret): App Password generada en WordPress

## ✅ Pre-requisitos

Antes de ejecutar el script, asegúrate de tener:

- [ ] **gh CLI instalado y autenticado**
  ```bash
  gh auth status
  ```
  Si no estás autenticado, ejecuta:
  ```bash
  gh auth login
  ```

- [ ] **Permisos en el repositorio**
  - Necesitas permisos de administrador o mantenedor
  - Capacidad para gestionar variables y secrets

- [ ] **Credenciales de WordPress STAGING a mano**
  - Usuario técnico (ej: `wp_automation`)
  - App Password generada en WordPress

- [ ] **URL de STAGING confirmada**
  - `https://staging.runartfoundry.com`

## 🔧 Uso del Script

### Opción 1: Desde el directorio del repositorio

```bash
cd /home/pepe/work/runartfoundry
./tools/load_staging_credentials.sh
```

El script detectará automáticamente el repositorio.

### Opción 2: Especificando el repositorio

```bash
./tools/load_staging_credentials.sh RunArtFoundry/runart-foundry
```

### Opción 3: Desde cualquier ubicación

```bash
./tools/load_staging_credentials.sh owner/repo-name
```

## 📝 Proceso Interactivo

El script te solicitará la siguiente información:

### 1. Confirmación de repositorio

```
ℹ Repositorio objetivo: RunArtFoundry/runart-foundry
ℹ Verificando acceso al repositorio...
✅ Acceso al repositorio confirmado
```

### 2. Configuración de WP_BASE_URL

Esta variable es pública y se configura automáticamente:

```
ℹ Configurando variable WP_BASE_URL=https://staging.runartfoundry.com
✅ Variable WP_BASE_URL configurada
```

### 3. Introducir WP_USER

```
ℹ Introduce WP_USER (usuario técnico de WordPress para STAGING):
wp_automation  ← tu input aquí
✅ Secret WP_USER configurado
```

### 4. Introducir WP_APP_PASSWORD

La entrada es **oculta** (no se muestra mientras escribes):

```
ℹ Introduce WP_APP_PASSWORD (App Password de STAGING - entrada oculta):
****  ← entrada oculta
✅ Secret WP_APP_PASSWORD configurado
```

### 5. Verificación

```
ℹ Verificando variables y secrets en el repositorio...

Variables:
WP_BASE_URL  staging  Updated 2025-10-21T...
WP_ENV       staging  Updated 2025-10-21T...
✅ Variables verificadas

Secrets:
WP_APP_PASSWORD  Updated 2025-10-21T...
WP_USER          Updated 2025-10-21T...
✅ Secrets verificados
```

### 6. Confirmación final

```
╔═══════════════════════════════════════════════════════════════╗
║                  ✅ CREDENCIALES CARGADAS                     ║
╚═══════════════════════════════════════════════════════════════╝

✅ Configuración completada en RunArtFoundry/runart-foundry

ℹ Variables configuradas:
  • WP_BASE_URL = https://staging.runartfoundry.com
  • WP_ENV = staging

ℹ Secrets configurados:
  • WP_USER = **** (oculto)
  • WP_APP_PASSWORD = **** (oculto)
```

## 🚀 Ejecutar Workflows

Una vez configuradas las credenciales, puedes ejecutar los workflows manualmente:

### Desde GitHub UI

1. Ve a **Actions** en tu repositorio
2. Selecciona el workflow deseado (ej: `verify-home.yml`)
3. Haz clic en **Run workflow**
4. Selecciona la rama `main`
5. Haz clic en **Run workflow**

### Desde gh CLI

```bash
# Ejecutar un workflow específico
gh workflow run verify-home.yml

# Ejecutar todos los workflows verify-*
gh workflow run verify-home.yml
gh workflow run verify-settings.yml
gh workflow run verify-menus.yml
gh workflow run verify-media.yml

# Ver estado de ejecuciones recientes
gh run list --workflow=verify-home.yml --limit 5
```

## 🔍 Verificación Manual

### Listar variables

```bash
gh variable list --repo RunArtFoundry/runart-foundry
```

Deberías ver:
```
WP_BASE_URL  staging  Updated ...
WP_ENV       staging  Updated ...
```

### Listar secrets

```bash
gh secret list --repo RunArtFoundry/runart-foundry
```

Deberías ver:
```
WP_APP_PASSWORD  Updated ...
WP_USER          Updated ...
```

**Nota**: Los valores de los secrets no son visibles por seguridad.

## 📊 Logs

Cada ejecución del script genera un log en:

```
logs/gh_credentials_setup_staging_YYYYMMDD_HHMMSS.log
```

Ejemplo:
```
logs/gh_credentials_setup_staging_20251021_100530.log
```

El log contiene:
- Timestamp de configuración
- Repositorio objetivo
- Variables configuradas (valores visibles)
- Secrets configurados (valores ocultos)
- Status de la operación

## ⚠️ Troubleshooting

### Error: "No estás autenticado en gh CLI"

**Solución**:
```bash
gh auth login
```

Sigue las instrucciones para autenticarte con tu cuenta de GitHub.

### Error: "No se puede acceder al repositorio"

**Causas posibles**:
- Nombre del repositorio incorrecto
- No tienes permisos en el repositorio
- El repositorio no existe

**Solución**:
```bash
# Verificar acceso al repositorio
gh repo view RunArtFoundry/runart-foundry

# Verificar tus permisos
gh api repos/RunArtFoundry/runart-foundry --jq '.permissions'
```

### Error: "No se pudo configurar variable/secret"

**Causas posibles**:
- Permisos insuficientes
- Límites de API alcanzados

**Solución**:
- Verifica que tienes permisos de administrador/mantenedor
- Espera unos minutos y vuelve a intentar

### Workflows fallan después de configurar credenciales

**Verifica**:

1. **Usuario tiene permisos en WordPress**:
   - Ve a WordPress Admin → Users → [tu usuario]
   - Verifica que tiene rol de Editor o superior

2. **App Password es válida**:
   - Ve a WordPress Admin → Users → Profile
   - Sección "Application Passwords"
   - Verifica que la password no ha sido revocada
   - Si es necesario, genera una nueva

3. **URL es correcta**:
   ```bash
   curl -I https://staging.runartfoundry.com/wp-json/
   ```
   Debería devolver `200 OK` y headers de WordPress REST API.

4. **Credenciales funcionan**:
   ```bash
   # Prueba básica (reemplaza USERNAME y APP_PASSWORD)
   curl -u "USERNAME:APP_PASSWORD" \
     https://staging.runartfoundry.com/wp-json/wp/v2/pages?per_page=1
   ```

## 🔒 Seguridad

### Buenas prácticas implementadas

✅ **Entrada oculta**: `WP_APP_PASSWORD` usa `stty -echo` para evitar mostrar la password  
✅ **No se loggean secrets**: Los logs solo muestran `**** (oculto)`  
✅ **Secrets de GitHub**: Los valores están cifrados en GitHub  
✅ **Variables vs Secrets**: URL es pública (variable), credenciales son privadas (secrets)  

### Recomendaciones

1. **Usa un usuario técnico dedicado** en WordPress (no tu usuario personal)
2. **Genera App Passwords específicas** para CI/CD (no uses tu password principal)
3. **Rota las App Passwords regularmente** (cada 90 días con el workflow `rotate-app-password.yml`)
4. **Revoca App Passwords** que no uses
5. **No compartas** el output del script que contiene la URL y usuario

## 📚 Referencias

- **Script**: `tools/load_staging_credentials.sh`
- **Workflows que usan estas credenciales**:
  - `.github/workflows/verify-home.yml`
  - `.github/workflows/verify-settings.yml`
  - `.github/workflows/verify-menus.yml`
  - `.github/workflows/verify-media.yml`
- **Workflow de rotación**: `.github/workflows/rotate-app-password.yml`
- **Documentación de gh CLI**: https://cli.github.com/manual/

## 🔄 Actualizar Credenciales

Si necesitas actualizar alguna credencial (ej: después de rotar la App Password), simplemente vuelve a ejecutar el script:

```bash
./tools/load_staging_credentials.sh
```

Los valores anteriores serán sobrescritos con los nuevos.

---

**Última actualización**: 2025-10-21  
**Versión**: 1.0  
**Estado**: ✅ Operativo
