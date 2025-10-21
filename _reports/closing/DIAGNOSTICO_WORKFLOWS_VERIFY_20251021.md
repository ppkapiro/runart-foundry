# Diagnóstico: Workflows verify-* — STAGING sin WordPress

**Fecha**: 2025-10-21 12:52 UTC  
**Contexto**: Ejecución manual de workflows verify-* después de configurar credenciales  
**Estado**: ❌ **FALLAN POR FALTA DE WORDPRESS EN STAGING**

---

## 🔍 Análisis del Problema

### Síntomas

1. **Workflows verify-* fallan**
   - Run IDs: 18684394379 (verify-home), similares para settings/menus/media
   - Error: AUTH=KO, CODE=NA
   - Todos los workflows muestran el mismo patrón de fallo

2. **Credenciales correctamente configuradas en GitHub**
   ```bash
   gh variable list --repo RunArtFoundry/runart-foundry
   ```
   **Output**:
   - `WP_BASE_URL` = https://staging.runartfoundry.com ✅
   - `WP_ENV` = staging ✅
   
   ```bash
   gh secret list --repo RunArtFoundry/runart-foundry
   ```
   **Output**:
   - `WP_USER` = configurado hace 18 horas ✅
   - `WP_APP_PASSWORD` = configurado hace 18 horas ✅

3. **REST API responde 300 Multiple Choices**
   ```bash
   curl -I https://staging.runartfoundry.com/wp-json/
   ```
   **Output**: `HTTP/2 300`

### Causa Raíz

**STAGING no tiene WordPress instalado.** Solo contiene un archivo HTML simple:

```bash
$ curl https://staging.runartfoundry.com/
STAGING READY — Mon Oct 20 22:11:49 UTC 2025 — staging.runartfoundry.com — /homepages/7/d958591985/htdocs/staging
```

**Evidencia técnica**:

```bash
$ curl https://staging.runartfoundry.com/wp-json/wp/v2/
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>300 Multiple Choices</title>
</head><body>
<h1>Multiple Choices</h1>
The document name you requested (<code>/index.php</code>) could not be found on this server.
However, we found documents with names similar to the one you requested.<p>Available documents:
<ul>
<li><a href="/index.html">/index.html</a> (common basename)
</ul>
</body></html>
```

El servidor busca `/index.php` (WordPress) pero solo encuentra `/index.html` (HTML simple).

---

## 📊 Estado Actual

| Componente | Estado | Detalle |
|------------|--------|---------|
| Credenciales GitHub | ✅ | WP_BASE_URL, WP_USER, WP_APP_PASSWORD configurados |
| STAGING URL accesible | ✅ | https://staging.runartfoundry.com/ responde 200 |
| WordPress en STAGING | ❌ | **NO INSTALADO** - solo HTML simple |
| REST API | ❌ | `/wp-json/` devuelve 300 (no existe) |
| Workflows verify-* | ❌ | Fallan por falta de WordPress |

---

## 🎯 Opciones de Resolución

### Opción 1: Instalar WordPress en STAGING (RECOMENDADO para workflows)

**Pros**:
- Workflows verify-* funcionarían completamente
- Permite testing realista de integraciones WordPress
- Alineado con objetivo original de Fase 7

**Contras**:
- Requiere instalación y configuración de WordPress
- Necesita base de datos MySQL
- Mantenimiento adicional

**Pasos**:
1. Instalar WordPress en `/homepages/7/d958591985/htdocs/staging/`
2. Configurar base de datos MySQL para staging
3. Generar App Password para usuario técnico
4. Actualizar secrets `WP_USER` y `WP_APP_PASSWORD` con nuevas credenciales
5. Re-ejecutar workflows verify-*

**Referencias**:
- `docs/CHECKLIST_EJECUTIVA_FASE7.md` - Pasos de instalación
- `docs/RUNBOOK_FASE7_PREVIEW_PRIMERO.md` - Configuración completa

### Opción 2: Adaptar Workflows para Entorno Sin WordPress

**Pros**:
- No requiere instalación de WordPress
- Mantiene STAGING simple
- Validación básica de infraestructura sigue funcionando

**Contras**:
- Workflows verify-* no prueban integraciones reales
- Pierde valor de testing de WordPress REST API
- Requiere modificar workflows

**Pasos**:
1. Modificar workflows para detectar si WordPress está disponible
2. Si no hay WordPress, marcar checks como "skipped" en lugar de "failed"
3. Mantener validación básica (HTTP 200, DNS, SSL)

### Opción 3: Usar Producción para Workflows verify-* (NO RECOMENDADO)

**Pros**:
- WordPress ya instalado en producción
- REST API completamente funcional

**Contras**:
- ⚠️ **ALTO RIESGO**: workflows ejecutándose contra producción
- Puede afectar sitio en vivo
- No sigue estrategia "Preview Primero"

---

## 💡 Recomendación

**OPCIÓN 1: Instalar WordPress en STAGING**

**Justificación**:
1. Alineado con objetivo original de Fase 7 (conexión WP real)
2. Workflows verify-* fueron diseñados para WordPress
3. Permite testing seguro antes de prod
4. Documenta proceso de instalación para futuros entornos

**Próximos Pasos**:

1. **Instalar WordPress en STAGING** (estimado: 2-3 horas)
   - Seguir guía en `docs/CHECKLIST_EJECUTIVA_FASE7.md`
   - Configurar base de datos MySQL
   - Generar usuario técnico con App Password

2. **Actualizar Credenciales en GitHub**
   ```bash
   ./tools/load_staging_credentials.sh
   ```

3. **Re-ejecutar Workflows verify-***
   ```bash
   gh workflow run verify-home.yml
   gh workflow run verify-settings.yml
   gh workflow run verify-menus.yml
   gh workflow run verify-media.yml
   ```

4. **Validar Resultados**
   ```bash
   gh run list --workflow=verify-home.yml --limit 1
   ```

---

## 📝 Logs de Ejecución

### Credenciales Configuradas

```bash
$ gh variable list --repo RunArtFoundry/runart-foundry
NAME         VALUE                              UPDATED           
WP_BASE_URL  https://staging.runartfoundry.com  about 2 minutes ago
WP_ENV       staging                            about 2 minutes ago

$ gh secret list --repo RunArtFoundry/runart-foundry
NAME                               UPDATED           
WP_APP_PASSWORD                    about 18 hours ago
WP_USER                            about 18 hours ago
```

### Workflows Ejecutados

```bash
$ gh workflow run verify-home.yml
✓ Created workflow_dispatch event for verify-home.yml at main

$ gh workflow run verify-settings.yml
✓ Created workflow_dispatch event for verify-settings.yml at main

$ gh workflow run verify-menus.yml
✓ Created workflow_dispatch event for verify-menus.yml at main

$ gh workflow run verify-media.yml
✓ Created workflow_dispatch event for verify-media.yml at main
```

### Resultados

```bash
$ gh run list --workflow=verify-home.yml --limit 3
STATUS  TITLE        WORKFLOW     BRANCH  EVENT              ID           ELAPSED  AGE                   
X       Verify Home  Verify Home  main    workflow_dispatch  18684394379  16s      about 3 minutes ago
X       Verify Home  Verify Home  main    schedule           18675119935  15s      about 6 hours ago
X       Verify Home  Verify Home  main    schedule           18670308446  16s      about 10 hours ago
```

**Todos los runs fallan con AUTH=KO** debido a que `/wp-json/wp/v2/users/me` devuelve 300 (WordPress no disponible).

---

## 🔗 Referencias

- **Script de configuración**: `tools/load_staging_credentials.sh`
- **Documentación**: `docs/ops/load_staging_credentials.md`
- **Checklist Fase 7**: `docs/CHECKLIST_EJECUTIVA_FASE7.md`
- **Runbook Fase 7**: `docs/RUNBOOK_FASE7_PREVIEW_PRIMERO.md`
- **Bitácora Maestra**: `apps/briefing/docs/internal/briefing_system/ci/082_bitacora_fase7_conexion_wp_real.md`
- **Run fallido ejemplo**: https://github.com/RunArtFoundry/runart-foundry/actions/runs/18684394379

---

**Conclusión**: Las credenciales están correctamente configuradas. El problema es infraestructura: STAGING necesita WordPress instalado para que los workflows verify-* funcionen.

---

**Timestamp**: 2025-10-21T12:52:00Z  
**Analista**: GitHub Copilot  
**Estado**: ✅ Diagnóstico completo, ❌ WordPress pendiente de instalación
