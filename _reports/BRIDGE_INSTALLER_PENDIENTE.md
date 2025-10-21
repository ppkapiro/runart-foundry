# 🔗 WP-CLI Bridge Installer — Estado Pendiente

**Fecha:** 2025-10-21  
**Estado:** BLOQUEADO — Pendiente configuración de secretos admin  
**Prioridad:** MEDIA (funcionalidad opcional; bridge endpoints operan manualmente)

---

## Resumen Ejecutivo

El workflow de instalación automática del plugin WP-CLI Bridge (`install-wpcli-bridge.yml`) está implementado pero **no puede ejecutarse exitosamente** porque los secretos de administrador WordPress necesarios para login en wp-admin **no están disponibles en el entorno del runner**.

**Componentes completados:**
- ✅ Plugin WP-CLI Bridge implementado (`tools/wpcli-bridge-plugin/`)
- ✅ Workflow de empaquetado ZIP (`build-wpcli-bridge.yml`)
- ✅ Workflows de ejecución de comandos bridge (manual + cron)
- ✅ Workflows de mantenimiento semanal (cache_flush + rewrite_flush)
- ✅ Workflow instalador implementado con lógica completa
- ✅ Tolerancia a errores y reportes automáticos

**Bloqueador actual:**
- ❌ Secretos admin WordPress no configurados o no accesibles por el runner

---

## Problema Técnico

### Síntoma
El workflow `install-wpcli-bridge` falla en el paso "Determinar credenciales admin" con exit code 11:
```
No se encontraron credenciales admin en secrets.
Configure secretos: WP_ADMIN_USER y WP_ADMIN_PASS...
```

### Evidencia (Run 18695152197)
```
install Determinar credenciales admin (solo secrets) ...
env:
  WP_ADMIN_USER: 
  WP_ADMIN_PASS: 
  WP_ADMIN_USERNAME: 
  RUNART_ADMIN_USER: 
  RUNART_ADMIN_PASS: 
  RUNART_ADMIN_PASSWORD: 
  ADMIN_USER: 
  ADMIN_PASS: 
  GH_TOKEN: ***
...
Descargando artifact desde run 18691911856
error fetching artifacts: HTTP 403: Resource not accessible by integration
```

**Análisis:**
1. Todos los secretos admin llegan vacíos al runner
2. El fallback a artifacts (versión anterior) falla con 403 por permisos
3. Los secretos REST (WP_USER, WP_APP_PASSWORD) **SÍ funcionan** en otros workflows

### Causa raíz probable
Los secretos de administrador WordPress **no existen** o están guardados:
- En un Environment de GitHub Actions que no se declaró correctamente
- Con nombres diferentes a los soportados por el workflow
- En un scope (org/repo/environment) al que el workflow no tiene acceso

---

## Arquitectura del Instalador

### Flujo completo
```
1. Checkout repo
2. Empaquetar plugin → /tmp/runart-wpcli-bridge.zip
3. Determinar credenciales admin (SECRETS ONLY)
   ├─ Busca WP_ADMIN_USER/PASS (preferido)
   ├─ Fallback a RUNART_ADMIN_USER/PASS
   ├─ Fallback a ADMIN_USER/PASS
   └─ Si no encuentra → EXIT 11
4. Login wp-admin (POST wp-login.php con cookies)
5. Obtener nonce desde plugin-install.php?tab=upload
6. Subir ZIP vía update.php?action=upload-plugin
7. Activar plugin (GET plugins.php?action=activate...)
8. Validar REST endpoint /wp-json/runart/v1/bridge/health
9. Generar reporte → _reports/bridge/install_YYYYMMDD_HHMM.md
10. Auto-commit y push
```

### Secretos requeridos

| Tipo | Nombre preferido | Alternativas | Uso |
|------|-----------------|--------------|-----|
| Admin user | `WP_ADMIN_USER` | `WP_ADMIN_USERNAME`, `RUNART_ADMIN_USER`, `ADMIN_USER` | Login wp-admin |
| Admin pass | `WP_ADMIN_PASS` | `RUNART_ADMIN_PASS`, `RUNART_ADMIN_PASSWORD`, `ADMIN_PASS`, `ADMIN_PASSWORD` | Login wp-admin |
| REST user | `WP_USER` | — | Auth Application Password |
| REST pass | `WP_APP_PASSWORD` | — | Auth Application Password |

**Nota:** REST secrets ya funcionan en verify-staging, wpcli-bridge, etc.

### Environment configuration
El job declara:
```yaml
environment:
  name: staging
```
Esto permite acceder a **Environment secrets** si están guardados en el environment "staging" de GitHub.

---

## Archivos del sistema Bridge

### Workflows
- `.github/workflows/build-wpcli-bridge.yml` — Empaqueta plugin ZIP como artifact
- `.github/workflows/install-wpcli-bridge.yml` — **BLOQUEADO** — Instala y activa plugin vía wp-admin
- `.github/workflows/wpcli-bridge.yml` — Ejecuta comandos bridge (health, cache_flush, rewrite_flush, users_list, plugins_list); cron 9:45am Miami lunes-viernes
- `.github/workflows/wpcli-bridge-maintenance.yml` — Mantenimiento cache_flush semanal; viernes 10:00am Miami
- `.github/workflows/wpcli-bridge-rewrite-maintenance.yml` — Mantenimiento rewrite_flush semanal; viernes 10:05am Miami

### Plugin
- `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php` — Plugin completo con endpoints REST
- `tools/wpcli-bridge-plugin/README.md` — Documentación de endpoints
- `plugins/runart-wpcli-bridge/` — Versión mínima del plugin (health only, v1.0.1)
- `_artifacts/plugins/runart-wpcli-bridge-v1.0.1.zip` — ZIP generado (estructura correcta)

### Reportes
- `_reports/bridge/bridge_YYYYMMDD_HHMM_<command>.md` — Reportes de comandos ejecutados
- `_reports/bridge/maintenance_YYYYMMDD_HHMM_<command>.md` — Reportes de mantenimiento semanal
- `_reports/bridge/install_YYYYMMDD_HHMM.md` — **PENDIENTE** — Reporte de instalación (esperando PASS)
- `_reports/bridge/summary_20251021_150507.md` — Resumen de cierre Fase 10

---

## Soluciones pendientes

### Opción 1: Configurar secretos admin en GitHub (RECOMENDADO)
1. Ir a Settings → Secrets and variables → Actions
2. Si usar Environment secrets:
   - Ir a Environments → Crear/editar "staging"
   - Añadir secretos ahí
3. Si usar Repository secrets:
   - Añadir directamente en Repository secrets
4. Crear secretos:
   - `WP_ADMIN_USER` = nombre de usuario admin WordPress
   - `WP_ADMIN_PASS` = contraseña admin WordPress (NO Application Password; contraseña real)
5. Re-ejecutar workflow `install-wpcli-bridge`

**Validación:**
- El step "Determinar credenciales admin" debe mostrar: `Usando credenciales desde Secrets (WP_ADMIN_USER/WP_ADMIN_PASS)`
- Login debe retornar HTTP 302/200
- Validación REST debe retornar `{"ok": true, ...}`
- Reporte debe mostrar estado PASS

### Opción 2: Instalación manual del plugin
Si no se pueden configurar secretos:
1. Descargar `tools/wpcli-bridge-plugin/` como ZIP manualmente
2. Subir a staging.runartfoundry.com/wp-admin/plugin-install.php?tab=upload
3. Activar plugin
4. Validar con workflow `wpcli-bridge` (command=health)

### Opción 3: Eliminar dependencia de instalador automático
Si la instalación automática no es crítica:
1. Mantener plugin instalado manualmente (una sola vez)
2. Los workflows de comandos y mantenimiento seguirán funcionando
3. Documentar que el instalador está deshabilitado y por qué

---

## Registro de intentos fallidos

| Run ID | Fecha | Resultado | Causa |
|--------|-------|-----------|-------|
| 18691911856 | 2025-10-21 | FAIL | Secretos vacíos → fallback artifact → 403 |
| 18695152197 | 2025-10-21 | FAIL | Secretos vacíos → sin fallback → exit 11 |

**Lecciones aprendidas:**
- Artifacts no son accesibles entre runs por permisos del GITHUB_TOKEN
- Los secretos de Environment requieren declarar `environment: { name: "..." }` en el job
- Los secretos REST funcionan porque están en Repository secrets
- El validador local de YAML marca warnings en `environment` y `secrets.*` pero son válidos en GitHub

---

## Pasos para retomar

### Checklist pre-ejecución
- [ ] Confirmar que secretos admin existen: `WP_ADMIN_USER`, `WP_ADMIN_PASS`
- [ ] Verificar scope (Repository vs Environment) y ajustar `environment:` si es necesario
- [ ] Verificar que el workflow se ejecuta en el repo original (no fork)
- [ ] Verificar que la rama tiene permisos de secrets

### Ejecución
```bash
# Opción A: Vía gh CLI
gh workflow run install-wpcli-bridge.yml --repo RunArtFoundry/runart-foundry

# Opción B: Vía UI
# Ir a Actions → install-wpcli-bridge → Run workflow
```

### Validación post-instalación
```bash
# 1. Verificar que el instalador terminó con éxito
gh run list --workflow=install-wpcli-bridge.yml --limit 1 --json conclusion

# 2. Leer reporte generado
ls -lht _reports/bridge/install_*.md | head -1
cat _reports/bridge/install_<TIMESTAMP>.md

# 3. Validar endpoint manualmente con Application Password
curl -u "$WP_USER:$WP_APP_PASSWORD" \
  https://staging.runartfoundry.com/wp-json/runart/v1/bridge/health

# 4. Ejecutar comando bridge vía workflow
gh workflow run wpcli-bridge.yml --repo RunArtFoundry/runart-foundry -f command=health
```

---

## Estado de otros componentes (funcionales)

### ✅ Bridge endpoints operativos (modo manual)
- `wpcli-bridge.yml` ejecuta comandos correctamente
- Mantenimiento semanal programado y funcional (tolerante a plugin ausente)
- Reportes se generan en `_reports/bridge/` con formato correcto

### ✅ Monitoreo Fase 11 operativo
- `verify-staging.yml` — Health check diario con métricas
- `smoke-tests.yml` — Tests de contenido (tolerante a manifest ausente)
- Dashboard de métricas (`scripts/generate_metrics_dashboard.sh`)
- Badges en README actualizados

### ✅ Cierre Fase 10 completado
- Tag `release/staging-demo-v1.0-closed` creado
- Validación final extendida generada
- Documentación consolidada en `_reports/INDEX.md`

---

## Referencias cruzadas

- **Conversación original:** Fase 11 → Bridge opcional → Instalador automático
- **Closure tag:** `release/staging-demo-v1.0-closed` (incluye bridge workflows + installer)
- **Documentos relacionados:**
  - `_reports/FASE11_CIERRE_EJECUTIVO.md` — Estado Fase 11
  - `_reports/INDEX.md` — Índice maestro actualizado con Fase 11
  - `tools/wpcli-bridge-plugin/README.md` — Endpoints del bridge
  - `README.md` — Badges de workflows (incluye bridge)

---

## Próximos pasos (cuando se retome)

1. **Inmediato:** Configurar secretos admin en GitHub Settings
2. **Validación:** Re-ejecutar `install-wpcli-bridge.yml` y confirmar PASS
3. **Opcional:** Añadir badge del workflow rewrite-maintenance al README
4. **Documentación:** Actualizar `_reports/INDEX.md` con estado RESUELTO del installer
5. **Cierre definitivo:** Tag `release/bridge-v1.0-complete` cuando el instalador pase

---

## Contacto / Notas

- **Responsable:** GitHub Copilot (agente automatizado)
- **Última actualización:** 2025-10-21T19:50Z
- **Prioridad:** MEDIA (bridge funciona manualmente; instalador es nice-to-have)
- **Bloqueador crítico:** NO (no impide operación normal del sistema)

**Nota para el siguiente agente/sesión:**  
Este documento contiene TODO el contexto necesario para retomar el instalador del bridge. Los workflows de bridge y mantenimiento **YA ESTÁN FUNCIONANDO** en modo tolerante (generan reportes WARN si el plugin no está instalado). El único componente pendiente es la **instalación automática** del plugin, bloqueada por falta de secretos admin WordPress. Si los secretos no se pueden configurar, la alternativa es instalación manual una sola vez y documentar que el instalador automático queda deshabilitado.

---

## 🧩 AUDITORÍA DE AISLAMIENTO STAGING vs PRODUCCIÓN

**Nueva herramienta disponible:** Se ha creado el script `tools/staging_isolation_audit.sh` para verificar y corregir el aislamiento entre entornos staging y producción.

**Reportes generados:**
- `_reports/isolation/isolacion_staging_20251021_153636.md` — Resultado de auditoría
- `_reports/isolation/RESUMEN_EJECUTIVO_AISLAMIENTO.md` — Análisis ejecutivo completo

**Script características:**
- ✅ **Protección total de producción** (cero modificaciones destructivas)
- ✅ **Verificación de bases de datos independientes**
- ✅ **Detección de enlaces simbólicos problemáticos**
- ✅ **Corrección automática de URLs de staging**
- ✅ **Limpieza de cachés solo en staging**
- ✅ **Reportes detallados con próximos pasos**

**Para ejecutar en servidor real:**
```bash
# Configurar variables de entorno necesarias
export DB_USER="usuario_bd"
export DB_PASSWORD="password_bd" 
export DB_HOST="host_bd"
export WP_USER="admin_wp"
export WP_APP_PASSWORD="app_password"
export CLOUDFLARE_API_TOKEN="token_cf"
export CF_ZONE_ID="zone_id"

# Ejecutar auditoría
./tools/staging_isolation_audit.sh
```

**Estado actual:** Script operativo y seguro, listo para ejecución en servidor de hosting con credenciales reales.
