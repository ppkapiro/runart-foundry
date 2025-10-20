# 📋 Fase 7 — Ejecución Conexión WordPress Real
**Fecha de inicio:** 2025-10-20 14:16 UTC  
**Responsable:** GitHub Copilot (preparación) → Owner (credenciales)  
**Estado:** 🟡 En ejecución (Preparación completada, Esperando credenciales)

---

## 📌 Entregables de Preparación (✅ Completados)

### 1. ✅ Rama de trabajo creada
- **Rama:** `feat/fase7-wp-connection`
- **Base:** `main` (commit `1ad3728`)
- **Commit inicial:** `06b8138` — Preparación Fase 7

### 2. ✅ Workflows enriquecidos con detección de modo
Se actualizaron los 4 workflows `verify-*` para incluir:
- Campo `mode` en el resumen de ejecución
- Lógica: `mode=real` si `WP_BASE_URL ≠ placeholder.local`, else `mode=placeholder`
- Sin cambios funcionales; solo enriquecimiento de output

**Workflows actualizados:**
- `.github/workflows/verify-home.yml` (Cada 6h)
- `.github/workflows/verify-settings.yml` (Cada 24h)
- `.github/workflows/verify-menus.yml` (Cada 12h)
- `.github/workflows/verify-media.yml` (Diario)

### 3. ✅ Issue #50 actualizado
- Creado: `issues/Issue_50_Fase7_Conexion_WordPress_Real.md`
- Sección "Ejecución" añadida con status de progreso
- Mini-checklist "Carga de credenciales por el owner" con instrucciones claras

### 4. ✅ Documentación en README.md
- Sección "🔐 Integración WP Real (Fase 7 — En progreso)" añadida
- Instrucciones para owner:
  - Dónde crear `WP_BASE_URL` (Variables → Actions)
  - Dónde crear `WP_USER` y `WP_APP_PASSWORD` (Secrets → Actions)
  - Nota de seguridad sobre credenciales
- Explicación de detección de modo y flujo de conmutación

### 5. ✅ Commit de preparación
```
chore(fase7): preparar conmutación a WP real y documentación de credenciales
```

---

## 🔐 Punto de Espera: Carga de Credenciales (PENDIENTE OWNER)

El siguiente paso requiere que el **owner del repositorio** cargue las credenciales reales en GitHub Actions.

### Instrucciones para el owner

#### 1. Crear `WP_BASE_URL` (Variable)
1. Ir a `Settings → Secrets and variables → Actions → Variables`
2. Click en `New repository variable`
3. Name: `WP_BASE_URL`
4. Value: URL real del sitio WP (ej: `https://tu-wp.com`)
5. Guardar

#### 2. Crear `WP_USER` (Secret)
1. Ir a `Settings → Secrets and variables → Actions → Secrets`
2. Click en `New repository secret`
3. Name: `WP_USER`
4. Value: Usuario con rol Editor (ej: `github-actions`)
5. Guardar

#### 3. Crear `WP_APP_PASSWORD` (Secret)
1. Ir a `Settings → Secrets and variables → Actions → Secrets`
2. Click en `New repository secret`
3. Name: `WP_APP_PASSWORD`
4. Value: Application Password generada en WordPress (`Users → Tu usuario → Application Passwords`)
5. ⚠️ **CRÍTICO:** Copiar y pegar una sola vez; GitHub enmascara automáticamente
6. Guardar

**Estado actual:** [ ] `WP_BASE_URL` cargada | [ ] `WP_USER` cargada | [ ] `WP_APP_PASSWORD` cargada

---

## 🔄 Próximos Pasos (Tras carga de credenciales)

### Fase: Ejecución de Verificaciones

1. **Ejecutar `verify-home` manualmente**
   - Ir a `Actions → Verify Home → Run workflow → Run workflow`
   - Esperar a que termine (~30 segundos)
   - Verificar artifact `verify-home-summary`: `mode=real; Auth=OK; ...`

2. **Si Auth=OK → Ejecutar `verify-settings`**
   - Ir a `Actions → Verify Settings → Run workflow → Run workflow`
   - Verificar artifact: `mode=real; ... Compliance=OK`

3. **Si Auth=OK → Ejecutar `verify-menus`**
   - Ir a `Actions → Verify Menus → Run workflow → Run workflow`
   - Verificar artifact: `mode=real; Compliance=...`

4. **Si Auth=OK → Ejecutar `verify-media`**
   - Ir a `Actions → Verify Media → Run workflow → Run workflow`
   - Verificar artifact: `mode=real; ...`

### Fase: Validación y Cierre

1. **Si todos devuelven Auth=OK:**
   - Marcar en Issue #50 el checklist "Validación de Conectividad" como completado
   - Adjuntar screenshots o enlaces a los artifacts
   - Actualizar `CHANGELOG.md` con entrada de Fase 7

2. **Si alguno devuelve Auth=KO:**
   - Registrar en Issue #50 la línea de diagnóstico (Auth Code, URL, usuario)
   - Verificar:
     - URL accesible desde internet
     - Usuario existe en WordPress
     - Application Password no expirada
     - REST API habilitada en WordPress
   - Reintentarlo tras corregir

---

## 📊 Tablas de Control

### Checklist de Carga de Credenciales (Owner)
| Elemento | Ubicación | Tipo | Estado |
|----------|-----------|------|--------|
| `WP_BASE_URL` | Settings → Secrets/Variables → Variables | Variable | [ ] Pendiente |
| `WP_USER` | Settings → Secrets/Variables → Secrets | Secret | [ ] Pendiente |
| `WP_APP_PASSWORD` | Settings → Secrets/Variables → Secrets | Secret | [ ] Pendiente |

### Checklist de Verificaciones (Tras credenciales)
| Workflow | Trigger | Target | Estado | Artifact |
|----------|---------|--------|--------|----------|
| verify-home | Manual | `Auth=OK` | [ ] Pendiente | verify-home-summary.txt |
| verify-settings | Manual | `Compliance=OK` | [ ] Pendiente | verify-settings-summary.txt |
| verify-menus | Manual | `Compliance=No` | [ ] Pendiente | verify-menus-summary.txt |
| verify-media | Manual | `MISSING=0` | [ ] Pendiente | verify-media-summary.txt |

---

## 📝 Notas Operativas

- **Seguridad:** Los secrets nunca se loguean. GitHub los enmascara automáticamente con `***`.
- **Variable vs Secret:** `WP_BASE_URL` es una Variable (puede ser visible tras un commit); `WP_USER` y `WP_APP_PASSWORD` son Secrets (siempre enmascarados).
- **Reintentos:** Si un workflow falla, el siguiente NO se ejecuta automáticamente. Reintentarlo manualmente.
- **Rollback:** Si hay problemas, se pueden revertir los secretos a `placeholder.local` y valores dummy temporales sin afectar el CI.
- **Logs:** Copilot NO accede a los valores de los secretos; solo verifica que existan y están enmascarados en los artifacts.

---

## 🔗 Referencias

- [Issue #50 — Checklist Fase 7](../issues/Issue_50_Fase7_Conexion_WordPress_Real.md)
- [README.md — Sección Integración WP Real](../README.md#-integración-wp-real-fase-7--en-progreso)
- [CIERRE_AUTOMATIZACION_TOTAL.md](../docs/CIERRE_AUTOMATIZACION_TOTAL.md)
- [DEPLOY_RUNBOOK.md](../docs/DEPLOY_RUNBOOK.md)

---

**Documento de progreso generado automáticamente.**  
Última actualización: 2025-10-20 14:16 UTC
