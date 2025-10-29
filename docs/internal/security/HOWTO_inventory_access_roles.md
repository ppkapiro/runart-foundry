# Script de Inventario de Accesos y Roles

**Ubicación:** `scripts/inventory_access_roles.sh`

## Descripción

Este script genera un reporte completo del inventario de accesos y roles en RunArt Foundry, incluyendo:

- **Aplicaciones de Cloudflare Access** configuradas
- **Policies de Access** (Include/Require/Exclude) con orden de precedencia
- **Grupos de Access** con sus definiciones
- **Service Tokens** activos y sus expiraciones
- **Roles en KV** (mapeo email → rol) desde el namespace de preview

## Requisitos

### 1. Variables de Entorno

El script necesita las siguientes variables configuradas en `~/.runart/env`:

```bash
CLOUDFLARE_API_TOKEN=<tu_token>
CLOUDFLARE_ACCOUNT_ID=<account_id>
NAMESPACE_ID_RUNART_ROLES_PREVIEW=<namespace_id>  # Opcional, usa default del wrangler.toml
```

### 2. Crear Cloudflare API Token

1. Ve a https://dash.cloudflare.com/profile/api-tokens
2. Click en "Create Token"
3. Usa el template "Read all resources" o crea uno personalizado con:
   - **Account.Cloudflare Access**: Read
   - **Account.Workers KV Storage**: Read
   - **Account.Access: Apps and Policies**: Read
4. Copia el token generado
5. Agrégalo a `~/.runart/env`:
   ```bash
   echo "CLOUDFLARE_API_TOKEN=tu_token_aqui" >> ~/.runart/env
   ```

### 3. Dependencias

- `curl` - Para hacer requests a la API de Cloudflare
- `jq` - Para parsear JSON

Instalar en Ubuntu/Debian:
```bash
sudo apt-get install curl jq
```

## Uso

### Ejecución Básica

```bash
./scripts/inventory_access_roles.sh
```

### Salida

El script genera un reporte en:
```
docs/internal/security/evidencia/ROLES_ACCESS_REPORT_YYYYMMDD_HHMM.md
```

El reporte incluye:

1. **Aplicación protegida** - Nombre, dominio y ID de la app
2. **Policies** - Reglas de acceso ordenadas por precedencia
3. **Grupos** - Definiciones de grupos con emails/dominios incluidos/excluidos
4. **Service Tokens** - Tokens activos con fechas de expiración
5. **KV Roles** - Tabla completa de email → rol desde el namespace
6. **Resumen operativo** - Guía de interpretación y próximos pasos

### Ejemplo de Salida

```markdown
# RunArt Foundry — Inventario de Acceso y Roles
_Generado: 20251020_1530 UTC_

## Aplicación protegida
- **App:** RUN Briefing
- **Dominio:** runart-foundry.pages.dev
- **App ID:** `abc123...`

## Policies (orden de evaluación)

### 0. Allow Admin Emails
- **Action:** allow
- **Precedence:** 0
- **Include:** email=admin@example.com
- **Require:** 
- **Exclude:** 

### 1. Block Service Tokens
- **Action:** deny
- **Precedence:** 1
- **Include:** service_token=xyz789
- **Require:** 
- **Exclude:** 

...
```

## Troubleshooting

### Error: "Variable CLOUDFLARE_API_TOKEN no configurada"

**Solución:**
1. Verifica que el archivo `~/.runart/env` existe
2. Verifica que contiene `CLOUDFLARE_API_TOKEN=...` con un valor no vacío
3. Si está vacío, sigue las instrucciones en **Requisitos** arriba

### Error: "No encontré la app de Access para dominio..."

**Causas posibles:**
1. El dominio `runart-foundry.pages.dev` no tiene una aplicación de Access configurada
2. El token no tiene permisos para leer Access apps
3. El account ID es incorrecto

**Solución:**
1. Ve al dashboard de Cloudflare > Zero Trust > Access > Applications
2. Verifica que existe una app para el dominio
3. Verifica que el token tiene permisos "Account.Cloudflare Access: Read"

### Error: curl timeouts o "403 Forbidden"

**Causas:**
- Token expirado o inválido
- Token sin los permisos necesarios

**Solución:**
1. Genera un nuevo token siguiendo las instrucciones arriba
2. Actualiza `~/.runart/env` con el nuevo token

## Seguridad

⚠️ **IMPORTANTE:**

- El archivo `~/.runart/env` contiene credenciales sensibles
- Permisos recomendados: `chmod 600 ~/.runart/env`
- NO commitear este archivo al repositorio
- NO compartir el CLOUDFLARE_API_TOKEN públicamente
- Rotar el token cada 90 días

## Automatización

Para ejecutar este script en CI/CD o de forma programada:

```bash
# En GitHub Actions
- name: Generate Access Inventory
  env:
    CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
  run: ./scripts/inventory_access_roles.sh

# En cron (Linux)
0 0 * * 0 /path/to/scripts/inventory_access_roles.sh  # Cada domingo a medianoche
```

## Mantenimiento

### Actualizar el script

Si cambia el dominio de la aplicación:
1. Editar la variable `APP_DOMAIN` en el script
2. O pasar como parámetro: `APP_DOMAIN=nuevo-dominio.com ./scripts/inventory_access_roles.sh`

### Analizar múltiples apps

Para generar reportes de múltiples aplicaciones, duplicar y ejecutar el script con diferentes valores de `APP_DOMAIN`.

## Referencias

- [Cloudflare Access API](https://developers.cloudflare.com/api/operations/access-applications-list-access-applications)
- [Cloudflare API Tokens](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)
- [KV API](https://developers.cloudflare.com/api/operations/workers-kv-namespace-list-a-namespace'-s-keys)

## Changelog

### 2025-10-20
- Creación inicial del script
- Soporte para apps, policies, grupos, service tokens y KV roles
- Validación de credenciales con mensajes de ayuda
- Generación de reportes en Markdown

---

**Autor:** RunArt DevOps  
**Última actualización:** 2025-10-20
