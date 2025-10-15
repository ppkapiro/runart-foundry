# Gobernanza de Secretos y Credenciales — RUNART

**Versión:** 1.0  
**Fecha:** 2025-10-15  
**Responsable:** DevOps / Security Team  
**Revisión:** Trimestral

---

## 1. Fuente de Verdad

### Tabla Única de Secretos/IDs

| Secreto/ID | Alcance | Dónde Vive | Dueño | Rotación | Notas |
|------------|---------|------------|-------|----------|-------|
| **CLOUDFLARE_API_TOKEN** | CI + Local | GitHub Secrets + ~/.runart/env | DevOps | 90 días | Token con permisos KV Edit |
| **CLOUDFLARE_ACCOUNT_ID** | CI + Local | GitHub Secrets + ~/.runart/env | DevOps | Estático | ID de cuenta Cloudflare |
| **NAMESPACE_ID_RUNART_ROLES_PREVIEW** | CI + Local | GitHub Secrets + ~/.runart/env | DevOps | Estático | KV namespace preview |
| **ACCESS_CLIENT_ID_PREVIEW** | CI + Local | GitHub Secrets + ~/.runart/env | Security | 180 días | Service Token para CI |
| **ACCESS_CLIENT_SECRET_PREVIEW** | CI + Local | GitHub Secrets + ~/.runart/env | Security | 180 días | Service Token para CI |

### Valores de Referencia (No Sensibles)
- **Account ID:** `a2c7fc66f00eab69373e448193ae7201`
- **Namespace Preview:** `7d80b07de98e4d9b9d5fd85516901ef6`
- **Application ID (Access):** `208c1b2a60b592e4f5468bd56804e905bff41b8745928f4eaf136ea2e4d5ee5b`

---

## 2. Convención de Nombres

### Estándar RUNART (5 secretos únicos)
1. `CLOUDFLARE_API_TOKEN` - Token API de Cloudflare
2. `CLOUDFLARE_ACCOUNT_ID` - ID de cuenta
3. `NAMESPACE_ID_RUNART_ROLES_PREVIEW` - ID de namespace KV preview
4. `ACCESS_CLIENT_ID_PREVIEW` - Service Token Client ID
5. `ACCESS_CLIENT_SECRET_PREVIEW` - Service Token Client Secret

### Nomenclatura
- **Prefijo:** `CLOUDFLARE_` para recursos de Cloudflare, `ACCESS_` para Access
- **Sufijo:** `_PREVIEW` para recursos de entorno preview
- **Separador:** Guión bajo (`_`)
- **Case:** MAYÚSCULAS (UPPER_SNAKE_CASE)

### ❌ Nombres Deprecados (No Usar)
- `CF_ACCOUNT_ID`, `CF_API_TOKEN` → usar `CLOUDFLARE_*`
- `RUNART_ROLES_KV_PREVIEW` → usar `NAMESPACE_ID_RUNART_ROLES_PREVIEW`
- `ACCESS_CLIENT_ID` (sin sufijo) → usar `ACCESS_CLIENT_ID_PREVIEW`

---

## 3. Caducidad y Rotación

### Calendario de Rotación

| Secreto | Frecuencia | Próxima Rotación | Procedimiento |
|---------|------------|------------------|---------------|
| CLOUDFLARE_API_TOKEN | 90 días | 2026-01-13 | Ver § 3.1 |
| ACCESS_CLIENT_ID_PREVIEW | 180 días | 2026-04-13 | Ver § 3.2 |
| ACCESS_CLIENT_SECRET_PREVIEW | 180 días | 2026-04-13 | Ver § 3.2 |
| CLOUDFLARE_ACCOUNT_ID | Permanente | N/A | Solo si cambia cuenta |
| NAMESPACE_ID_RUNART_ROLES_PREVIEW | Permanente | N/A | Solo si cambia namespace |

### 3.1 Procedimiento: Rotar API Token
```bash
# 1. Crear nuevo token en Cloudflare con permisos Workers KV Storage:Edit
# 2. Verificar token
curl -H "Authorization: Bearer NUEVO_TOKEN" \
  https://api.cloudflare.com/client/v4/user/tokens/verify

# 3. Actualizar local
echo -n "NUEVO_TOKEN" | sed 's/^/CLOUDFLARE_API_TOKEN=/' >> ~/.runart/env

# 4. Actualizar CI
echo -n "NUEVO_TOKEN" | gh secret set CLOUDFLARE_API_TOKEN

# 5. Validar con smoke test
./scripts/smoke_secret_health.sh

# 6. Revocar token anterior en dashboard Cloudflare
# 7. Registrar en bitácora (ver § 5)
```

### 3.2 Procedimiento: Rotar Service Token (Access)
```bash
# 1. Crear nuevo Service Token en Cloudflare Zero Trust → Service Authentication
#    Nombre: runart-ci-diagnostics-YYYYMMDD
# 2. Añadir a policy de aplicación RUN Briefing
# 3. Actualizar local
echo -n "NUEVO_CLIENT_ID" | sed 's/^/ACCESS_CLIENT_ID_PREVIEW=/' >> ~/.runart/env
echo -n "NUEVO_SECRET" | sed 's/^/ACCESS_CLIENT_SECRET_PREVIEW=/' >> ~/.runart/env

# 4. Actualizar CI
echo -n "NUEVO_CLIENT_ID" | gh secret set ACCESS_CLIENT_ID_PREVIEW
echo -n "NUEVO_SECRET" | gh secret set ACCESS_CLIENT_SECRET_PREVIEW

# 5. Validar acceso a /api/whoami
curl -I https://runart-foundry.pages.dev/api/whoami \
  -H "CF-Access-Client-Id: NUEVO_CLIENT_ID" \
  -H "CF-Access-Client-Secret: NUEVO_SECRET"

# 6. Eliminar token anterior de policy Access
# 7. Registrar en bitácora
```

---

## 4. Pre-Flight CI: Validación de Secretos

### 4.1 Script de Validación (`smoke_secret_health.sh`)
Ver: `scripts/smoke_secret_health.sh`

### 4.2 Integración en Workflow
Añadir paso al inicio de `.github/workflows/run_canary_diagnostics.yml`:

```yaml
- name: 🔒 Pre-flight: Secret Health Check
  run: |
    chmod +x scripts/smoke_secret_health.sh
    ./scripts/smoke_secret_health.sh
  env:
    CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
    NAMESPACE_ID_RUNART_ROLES_PREVIEW: ${{ secrets.NAMESPACE_ID_RUNART_ROLES_PREVIEW }}
    ACCESS_CLIENT_ID_PREVIEW: ${{ secrets.ACCESS_CLIENT_ID_PREVIEW }}
    ACCESS_CLIENT_SECRET_PREVIEW: ${{ secrets.ACCESS_CLIENT_SECRET_PREVIEW }}
```

### 4.3 Criterios de Validación
El workflow debe fallar si:
- ❌ Falta algún secreto requerido
- ❌ API token no es válido/activo
- ❌ Cuenta no es accesible
- ❌ Namespace preview no existe
- ❌ PUT/GET de sonda en KV falla
- ❌ Service token no autorizado (HTTP 302 en /api/whoami)

---

## 5. Bitácora de Cambios

### Formato de Registro
Cada cambio de secreto debe registrarse en `docs/internal/security/secret_changelog.md`:

```markdown
## 2025-10-15 | CLOUDFLARE_API_TOKEN
- **Acción:** Rotación programada
- **Quién:** DevOps (GitHub Copilot)
- **Por qué:** Rotación trimestral (día 90)
- **Validación:** smoke_secret_health.sh ✅
- **Incidentes:** Ninguno
```

---

## 6. Checklist de Release

### Pre-Producción (Preview)
- [ ] `smoke_secret_health.sh` pasa en preview ✅
- [ ] KV presente y legible en CI ✅
- [ ] Headers `/api/whoami` con X-RunArt-Canary y Resolver ✅
- [ ] RESUMEN de diagnóstico marca GO ✅
- [ ] Secretos alineados entre CI y local ✅

### Producción
- [ ] Aprobar promoción de código a `main`
- [ ] Verificar secrets de producción (no preview)
- [ ] Ejecutar diagnóstico en producción
- [ ] Monitorear logs primeros 30 minutos

---

## 7. Contactos y Escalamiento

| Rol | Responsable | Contacto |
|-----|-------------|----------|
| **Secretos CI/CD** | DevOps Team | devops@runart.com |
| **Access Policies** | Security Team | security@runart.com |
| **Cloudflare API** | Platform Team | platform@runart.com |
| **Escalamiento 24/7** | On-Call Engineer | oncall@runart.com |

---

## 8. Auditorías

### Frecuencia
- **Mensual:** Verificar caducidad de tokens
- **Trimestral:** Rotar API tokens programados
- **Semestral:** Rotar Service Tokens
- **Anual:** Auditoría completa de secretos y permisos

### Herramientas
- `scripts/smoke_secret_health.sh` - Validación automática
- `apps/briefing/_reports/secret_audit/` - Historial de auditorías
- GitHub Actions logs - Trazabilidad de ejecuciones

---

## 9. Incidentes y Recovery

### Escenarios Comunes

#### Secreto Comprometido
1. Revocar inmediatamente en Cloudflare
2. Rotar secreto siguiendo procedimientos § 3
3. Revisar logs de acceso para detectar uso no autorizado
4. Notificar a Security Team
5. Actualizar bitácora con incident ID

#### CI Falla por Secreto Expirado
1. Verificar fecha de caducidad en dashboard
2. Rotar secreto siguiendo procedimientos § 3
3. Reejecutar workflow fallido
4. Actualizar calendario de rotación

#### Namespace KV Eliminado
1. Crear nuevo namespace en Cloudflare
2. Actualizar `wrangler.toml` con nuevo ID
3. Actualizar secretos `NAMESPACE_ID_RUNART_ROLES_PREVIEW`
4. Sembrar KV con `scripts/runart_phase2.sh`
5. Validar con diagnóstico CI

---

## 10. Referencias

### Documentación Interna
- [Secret Audit 2025-10-15](../../../apps/briefing/_reports/secret_audit/20251015T162222Z/)
- [Policy Checklist](../../../apps/briefing/_reports/secret_audit/20251015T162222Z/policy_checklist.md)
- [Mapping Before/After](../../../apps/briefing/_reports/secret_audit/20251015T162222Z/mapping_before_after.md)

### Documentación Externa
- [Cloudflare API Tokens](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)
- [Cloudflare Access Service Tokens](https://developers.cloudflare.com/cloudflare-one/identity/service-tokens/)
- [Workers KV API](https://developers.cloudflare.com/kv/api/)

---

**Última actualización:** 2025-10-15  
**Próxima revisión:** 2026-01-15
