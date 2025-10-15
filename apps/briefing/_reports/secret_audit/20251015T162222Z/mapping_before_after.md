# Normalización de Secretos — Antes → Después

## GitHub Actions Secrets

### Eliminar (duplicados)
| Secret Actual | Razón | Acción |
|---------------|-------|--------|
| `CF_ACCOUNT_ID` | Duplicado de CLOUDFLARE_ACCOUNT_ID | `gh secret remove CF_ACCOUNT_ID` |
| `CF_API_TOKEN` | Duplicado de CLOUDFLARE_API_TOKEN | `gh secret remove CF_API_TOKEN` |
| `RUNART_ROLES_KV_PREVIEW` | Nombre legacy no estándar | `gh secret remove RUNART_ROLES_KV_PREVIEW` |
| `RUNART_ROLES_KV_PROD` | Nombre legacy no estándar | `gh secret remove RUNART_ROLES_KV_PROD` |
| `CF_LOG_EVENTS_ID` | Nombre no estándar | `gh secret remove CF_LOG_EVENTS_ID` |
| `CF_LOG_EVENTS_PREVIEW_ID` | Nombre no estándar | `gh secret remove CF_LOG_EVENTS_PREVIEW_ID` |
| `CLOUDFLARE_PROJECT_NAME` | No necesario (hardcoded en workflow) | `gh secret remove CLOUDFLARE_PROJECT_NAME` |

### Renombrar (añadir sufijo _PREVIEW)
| Secret Actual | Nuevo Nombre | Valor |
|---------------|--------------|-------|
| `ACCESS_CLIENT_ID` | `ACCESS_CLIENT_ID_PREVIEW` | (copiar valor existente) |
| `ACCESS_CLIENT_SECRET` | `ACCESS_CLIENT_SECRET_PREVIEW` | (copiar valor existente) |

### Crear (nuevos)
| Secret Nuevo | Valor | Fuente |
|--------------|-------|--------|
| `NAMESPACE_ID_RUNART_ROLES_PREVIEW` | `7d80b07de98e4d9b9d5fd85516901ef6` | wrangler.toml preview_id |

### Mantener sin cambios
| Secret | Estado |
|--------|--------|
| `CLOUDFLARE_API_TOKEN` | ✅ Mantener |
| `CLOUDFLARE_ACCOUNT_ID` | ✅ Mantener |

---

## Local ~/.runart/env

### Actualizar
| Variable | Valor Anterior | Valor Nuevo | Razón |
|----------|---------------|-------------|-------|
| `NAMESPACE_ID_RUNART_ROLES_PREVIEW` | `26b8c3ca432946e2a093dcd33163f9e2` (prod) | `7d80b07de98e4d9b9d5fd85516901ef6` (preview) | Alineación con wrangler.toml |

### Añadir (para consistencia)
| Variable | Valor | Razón |
|----------|-------|-------|
| `ACCESS_CLIENT_ID_PREVIEW` | (mismo que ACCESS_CLIENT_ID) | Explícito para preview |
| `ACCESS_CLIENT_SECRET_PREVIEW` | (mismo que ACCESS_CLIENT_SECRET) | Explícito para preview |

---

## Resultado Final

### Secretos GitHub Actions (estándar)
1. `CLOUDFLARE_API_TOKEN`
2. `CLOUDFLARE_ACCOUNT_ID`
3. `NAMESPACE_ID_RUNART_ROLES_PREVIEW`
4. `ACCESS_CLIENT_ID_PREVIEW`
5. `ACCESS_CLIENT_SECRET_PREVIEW`

### Variables Local ~/.runart/env (estándar)
1. `CLOUDFLARE_API_TOKEN`
2. `CLOUDFLARE_ACCOUNT_ID`
3. `NAMESPACE_ID_RUNART_ROLES_PREVIEW` = `7d80b07de98e4d9b9d5fd85516901ef6`
4. `ACCESS_CLIENT_ID` (mantener para compatibilidad)
5. `ACCESS_CLIENT_SECRET` (mantener para compatibilidad)
6. `ACCESS_CLIENT_ID_PREVIEW` (alias explícito)
7. `ACCESS_CLIENT_SECRET_PREVIEW` (alias explícito)

---

## Validación Post-Normalización

✅ Todos los secretos tienen nombres sin duplicados  
✅ CI y local apuntan al mismo namespace preview  
✅ Access tokens tienen sufijo _PREVIEW explícito  
✅ Sin secrets legacy o no estándar
