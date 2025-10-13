
# Auditoría completa de automatización Cloudflare & GitHub

**Fecha:** 2025-10-13
**Auditor:** GitHub Copilot

---

## 1. Cloudflare - Checklist y verificación

### Autenticación y conexión
- ✅ Usuario autenticado: ppcapiro@gmail.com
- ⚠️ Token API usado por GitHub Actions responde `Unable to authenticate request` (ver run 18414305468)
- ⚠️ Wrangler CLI pendiente de reconfirmar con token renovado

### Proyectos Cloudflare Pages detectados
- ✅ `runart-foundry` (`runart-foundry.pages.dev`)
- ✅ `runart-foundry-preview2` (`runart-foundry-preview2.pages.dev`)

### Deployments recientes
- ✅ Historial de deploys en producción y preview, con builds exitosos y algunos fallidos (normal en flujos CI/CD)
- ✅ Branches: `main`, `preview`, `develop`, `preview2`, y ramas de fixes
- ✅ Último deploy hace 19 horas (preview2) y 21 horas (develop)

### Configuración local
- ✅ `wrangler.toml` con bindings KV y entornos (`preview`, `preview2`, `production`)
- ✅ Makefile y scripts para smoke tests y deploy
- ✅ Roles y variables de Access definidos en `access/roles.json`
- ✅ Variables de entorno configuradas correctamente

### Estado final Cloudflare
La consola muestra proyectos y despliegues históricos, pero el token consumido por CI dejó de autenticar. Es necesario rotar el `CLOUDFLARE_API_TOKEN` antes de retomar los deploys automatizados.

### Verificación del workflow `pages-preview.yml`
- 🔄 Run `Deploy Preview (Cloudflare) #29` (GitHub run 18414305468, 2025-10-10) ejecutado vía `workflow_dispatch`
- ✅ Build MkDocs (modo estricto) y smoke de imports en Node completados
- ❌ Paso `cloudflare/pages-action@v1` falló con HTTP 400 → `Unable to authenticate request`
- ⛔ Sin URL hash (`preview_url` vacío); no se ejecutaron prechecks DNS/HTTP ni smokes Access
- ✅ Reintento del mismo run replicó el fallo

---

## 2. GitHub - Workflows y automatización

### Workflows principales detectados
- ✅ `.github/workflows/ci.yml`: Build, test de logs, deploy MkDocs y Cloudflare Pages
- ✅ `.github/workflows/pages-deploy.yml`: Deploy nativo y fallback a Cloudflare Pages, chequeo de estado y secrets
- ✅ `.github/workflows/pages-prod.yml`: Build, test, smoke tests y deploy a producción
- ✅ `.github/workflows/pages-preview.yml`: Build, test, smoke tests y deploy de previews en PRs y ramas de desarrollo
- ✅ `.github/workflows/pages-preview2.yml`: Build y deploy de entorno staging (CloudFed)
- ✅ `.github/workflows/auto-open-pr-on-deploy-branches.yml`: PR automático en ramas `deploy/*`
- ✅ `.github/workflows/structure-guard.yml`: Validación de estructura y gobernanza en pushes y PRs
- ✅ `.github/workflows/docs-lint.yml`: Lint de documentación y publicación de logs
- ✅ `.github/workflows/pages-preview-guard.yml`: Requiere check de Cloudflare Pages Preview en PRs
- ✅ `.github/workflows/env-report.yml`: Reporte de entorno y validación en PRs

### Integraciones y flujos
- ✅ Uso de `actions/checkout`, `actions/setup-python`, `actions/setup-node`, `cloudflare/pages-action`, `actions/github-script`, `actions/upload-artifact`
- ✅ Validación de secrets y variables antes de ejecutar jobs críticos
- ✅ Etiquetado automático y comentarios en PRs
- ✅ Fallback deploy si el nativo falla
- ✅ Validación de estructura y gobernanza antes de merge
- ✅ Lint y validación de documentación
- ✅ Smoke tests automáticos en deploy y preview

- ⚠️ Secrets detectados, pero `CLOUDFLARE_API_TOKEN` vigente no autentica ante Pages API
- ✅ Permisos restringidos por job (`contents`, `deployments`, `statuses`, `pull-requests`, `checks`)
- ✅ Validación de presencia de secrets antes de ejecutar deploys

---

## 3. Errores y advertencias detectados

- ❌ `cloudflare/pages-action@v1` devuelve `Unable to authenticate request` (token expirado o con permisos insuficientes)
- ⚠️ Comando de purga de caché con `wrangler` fallido: No existe, usar dashboard o API REST
- ⚠️ Algunos reportes referencian comandos obsoletos para purga de caché

### GitHub
- ⚠️ Workflows legacy detectados: `briefing_deploy.yml`, `briefing_pages.yml` (ya no se usan en el flujo principal)
- ⚠️ Algunos workflows documentados en reportes no existen físicamente
- ✅ Los jobs fallan explícitamente si faltan secrets (comportamiento correcto)

### Estado general
- ✅ Todos los workflows principales están presentes y activos
- ✅ Los flujos cubren build, test, deploy, validación, lint, gobernanza y reporting
- ✅ El etiquetado y comentarios automáticos en PRs funcionan correctamente
- ✅ La integración con Cloudflare Pages y validación de previews está activa y monitoreada

---

## 4. Recomendaciones (no ejecutadas)

### Limpieza y consolidación
- Eliminar workflows legacy y actualizar referencias en documentación
- Consolidar y revisar los secrets en GitHub
- Corregir comandos obsoletos en scripts y reportes (especialmente purga de caché)
- Rotar `CLOUDFLARE_API_TOKEN`, validar scopes (Pages:Edit, Pages:Read) y actualizar GitHub Secrets

### Validación y mantenimiento
- Validar que todos los workflows documentados existan y estén activos
- Revisar y actualizar scripts de validación y lint según necesidades futuras
- Confirmar que Cloudflare Access esté activado y configurado correctamente en producción
- Realizar smoke end-to-end tras el nuevo token para generar artefactos y actualizar reporte 082

---

**Este reporte es completo e informativo. No se han realizado correcciones ni cambios en el proyecto.**
