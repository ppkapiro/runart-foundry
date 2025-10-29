# 📊 Script de Inventario: Access + KV Roles

**Fecha:** 2025-10-20  
**Commit:** `eb6e45c`  
**Estado:** ✅ Completado y documentado

---

## ✅ Archivos Creados

### 1. Script Principal
**📄 `scripts/inventory_access_roles.sh`** (185 líneas)

Funcionalidad:
- ✅ Carga automática de credenciales desde `~/.runart/env`
- ✅ Validación robusta con mensajes de ayuda
- ✅ Descubrimiento automático de app Access por dominio
- ✅ Extracción de policies con precedencia
- ✅ Listado de grupos de Access
- ✅ Inventario de service tokens
- ✅ Volcado completo de KV roles (email → rol)
- ✅ Generación de reporte Markdown estructurado

**Salida:** `docs/internal/security/evidencia/ROLES_ACCESS_REPORT_YYYYMMDD_HHMM.md`

### 2. Documentación HOWTO
**📄 `docs/internal/security/HOWTO_inventory_access_roles.md`** (280 líneas)

Incluye:
- ✅ Descripción completa del script
- ✅ Requisitos detallados (variables, tokens, permisos)
- ✅ Instrucciones paso a paso para crear API token
- ✅ Guía de uso con ejemplos
- ✅ Sección de troubleshooting extensiva
- ✅ Recomendaciones de seguridad
- ✅ Guía de automatización (CI/cron)
- ✅ Referencias a APIs de Cloudflare

### 3. README de Scripts
**📄 `scripts/README.md`** (193 líneas)

Contenido:
- ✅ Índice de todos los scripts del proyecto
- ✅ Documentación de cada script principal
- ✅ Guía de configuración de secrets
- ✅ Tabla de workflows de CI
- ✅ Troubleshooting general
- ✅ Checklist para nuevos scripts
- ✅ Mejores prácticas de seguridad

---

## 🔧 Características Técnicas

### Validaciones Implementadas

```bash
✓ Carga de credenciales desde ~/.runart/env
✓ Verificación de CLOUDFLARE_API_TOKEN
✓ Verificación de CLOUDFLARE_ACCOUNT_ID
✓ Detección automática de namespace KV
✓ Manejo de errores con mensajes descriptivos
✓ Fallback a valores default del wrangler.toml
```

### APIs de Cloudflare Consultadas

1. **Access Apps API**
   ```
   GET /accounts/{account}/access/apps
   ```
   - Descubre app por dominio `runart-foundry.pages.dev`

2. **Access Policies API**
   ```
   GET /accounts/{account}/access/apps/{app_id}/policies
   ```
   - Extrae Include/Require/Exclude con precedencia

3. **Access Groups API**
   ```
   GET /accounts/{account}/access/groups
   ```
   - Lista definiciones de grupos (emails/dominios)

4. **Service Tokens API**
   ```
   GET /accounts/{account}/access/service_tokens
   ```
   - Inventario de tokens con expiraciones

5. **KV Storage API**
   ```
   GET /accounts/{account}/storage/kv/namespaces/{ns}/keys
   GET /accounts/{account}/storage/kv/namespaces/{ns}/values/{key}
   ```
   - Lista claves y valores del namespace RUNART_ROLES

### Formato de Salida

Reporte Markdown con secciones:
```markdown
1. Aplicación protegida (nombre, dominio, ID)
2. Policies ordenadas por precedencia
3. Grupos de Access expandidos
4. Service Tokens con metadatos
5. Tabla KV: email → rol
6. Resumen operativo y próximos pasos
```

---

## 🎯 Casos de Uso

### 1. Auditoría de Seguridad
```bash
./scripts/inventory_access_roles.sh
# → Genera snapshot completo del estado actual
```

**Utilidad:**
- Revisar quién tiene acceso
- Validar configuración de policies
- Detectar tokens expirados
- Auditar roles asignados

### 2. Documentación de Cambios
```bash
# Antes de cambios
./scripts/inventory_access_roles.sh
# → ROLES_ACCESS_REPORT_20251020_1400.md

# Después de cambios
./scripts/inventory_access_roles.sh
# → ROLES_ACCESS_REPORT_20251020_1500.md

# Comparar
diff -u docs/internal/security/evidencia/ROLES_ACCESS_REPORT_*.md
```

### 3. Onboarding de Equipo
```markdown
El reporte generado sirve como documentación para:
- Nuevos devs: entender modelo de acceso
- QA: validar permisos esperados
- Security: auditar configuración
```

### 4. Troubleshooting
```bash
# Usuario reporta "no puede acceder"
./scripts/inventory_access_roles.sh

# Verificar en reporte:
1. ¿Está su email en alguna policy Include?
2. ¿Está en grupo correcto?
3. ¿Tiene rol asignado en KV?
4. ¿Hay Exclude bloqueándolo?
```

---

## 📋 Requisitos Pendientes

### Para Ejecutar el Script

⚠️ **Acción requerida:** Crear Cloudflare API Token

1. **Dashboard Cloudflare**
   - URL: https://dash.cloudflare.com/profile/api-tokens
   - Template: "Read all resources" o custom

2. **Permisos necesarios:**
   - ✅ Account.Cloudflare Access: **Read**
   - ✅ Account.Workers KV Storage: **Read**
   - ✅ Account.Access: Apps and Policies: **Read**

3. **Configurar en local:**
   ```bash
   echo "CLOUDFLARE_API_TOKEN=tu_token_aqui" >> ~/.runart/env
   chmod 600 ~/.runart/env
   ```

4. **Validar:**
   ```bash
   ./scripts/inventory_access_roles.sh
   # Debe mostrar: ✓ CLOUDFLARE_API_TOKEN configurado
   ```

### Variables Verificadas

| Variable | Estado | Valor Actual |
|----------|--------|--------------|
| `CLOUDFLARE_ACCOUNT_ID` | ✅ OK | `a2c7fc66f0...` |
| `CLOUDFLARE_API_TOKEN` | ❌ VACÍO | (necesita configuración) |
| `NAMESPACE_ID_RUNART_ROLES_PREVIEW` | ✅ OK | `7d80b07de...` |
| `ACCESS_CLIENT_ID` | ✅ OK | `b6d63d68e8...` |
| `ACCESS_CLIENT_SECRET` | ✅ OK | `f44692247...` |

---

## 🔒 Seguridad

### Protección de Credenciales

✅ **Implementado:**
- Script lee de `~/.runart/env` (no versionado)
- Variables no se logean en output
- Tokens truncados en mensajes de debug

⚠️ **Recomendaciones:**
```bash
# Permisos restrictivos
chmod 600 ~/.runart/env

# Verificar no está en git
grep -r "CLOUDFLARE_API_TOKEN" .git/ || echo "OK"

# NO compartir reportes públicamente
# (contienen IDs de apps, policies, emails)
```

### Rotación de Tokens

📅 **Plan sugerido:**
- Crear token con expiración 90 días
- Configurar recordatorio para renovar
- Al rotar: actualizar `~/.runart/env`
- Revocar token anterior en dashboard

---

## 📊 Métricas

### Archivos Creados
- **3 archivos nuevos**
- **658 líneas de código/documentación**
- **1 script ejecutable**
- **2 documentos Markdown**

### Cobertura Funcional
- ✅ 5 APIs de Cloudflare integradas
- ✅ 100% de secciones requeridas en reporte
- ✅ Validación completa de pre-requisitos
- ✅ Documentación exhaustiva (HOWTO + README)

### Testing
- ✅ Validación de variables sin token
- ✅ Mensajes de error descriptivos
- ⏳ Pendiente: ejecución con token válido
- ⏳ Pendiente: validar formato de reporte

---

## 🔜 Próximos Pasos

### Inmediatos
1. **Crear API Token** (requiere acceso al dashboard Cloudflare)
2. **Configurar en `~/.runart/env`**
3. **Ejecutar script y validar reporte**
4. **Revisar output y ajustar formato si necesario**

### Corto Plazo
- Agregar flag `--json` para output programático
- Implementar comparación automática entre reportes
- Integrar en workflow de CI para auditorías periódicas
- Crear alertas si detecta cambios no autorizados

### Medio Plazo
- Dashboard web para visualizar reportes
- Histórico de cambios en Access/KV
- Notificaciones automáticas de expiración de tokens
- Integración con sistema de tickets

---

## 📚 Referencias

### Documentación Creada
- [HOWTO: Inventory Access Roles](docs/internal/security/HOWTO_inventory_access_roles.md)
- [Scripts README](scripts/README.md)

### Documentación Relacionada
- [Secret Governance](docs/internal/security/secret_governance.md)
- [Secret Changelog](docs/internal/security/secret_changelog.md)
- [Estructura y Gobernanza](docs/proyecto_estructura_y_gobernanza.md)

### APIs de Cloudflare
- [Access Apps](https://developers.cloudflare.com/api/operations/access-applications-list-access-applications)
- [Access Policies](https://developers.cloudflare.com/api/operations/access-policies-list-access-policies)
- [KV Storage](https://developers.cloudflare.com/api/operations/workers-kv-namespace-list-a-namespace'-s-keys)

---

## ✅ Checklist Final

### Script
- [x] Código implementado y testeado (sin token)
- [x] Validaciones de pre-requisitos
- [x] Mensajes de error descriptivos
- [x] Permisos de ejecución (`chmod +x`)
- [x] Comentarios en código
- [ ] Ejecución exitosa con token válido

### Documentación
- [x] HOWTO completo con ejemplos
- [x] README de scripts actualizado
- [x] Troubleshooting documentado
- [x] Referencias a APIs incluidas
- [x] Guías de seguridad

### Repositorio
- [x] Archivos committed
- [x] Push a main exitoso
- [x] Structure validation PASS
- [x] Pre-commit hook ejecutado
- [x] Commit message descriptivo

### Próximos Pasos Documentados
- [x] Instrucciones para crear token
- [x] Guía de configuración
- [x] Casos de uso explicados
- [x] Plan de automatización

---

**✅ COMPLETADO:** Script de inventario creado, documentado y versionado

**⏳ PENDIENTE:** Configurar CLOUDFLARE_API_TOKEN para primera ejecución
