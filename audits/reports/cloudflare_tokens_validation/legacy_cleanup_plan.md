# PLAN DE LIMPIEZA - SECRETS LEGACY CLOUDFLARE

**Fecha de creación:** 2025-10-14  
**Auditoría de referencia:** ci/credenciales-cloudflare-audit  
**Eliminación planificada:** 2025-10-28 (14 días tras validación)

## 📋 Secrets Legacy Identificados

| Secret Legacy | Secret Canónico | Estado | Fecha Eliminación | Workflows Afectados |
|---------------|-----------------|--------|-------------------|-------------------|
| `CF_API_TOKEN` | `CLOUDFLARE_API_TOKEN` | DEPRECATED | 2025-10-28 | pages-deploy.yml, briefing_deploy.yml |
| `CF_ACCOUNT_ID` | `CLOUDFLARE_ACCOUNT_ID` | DEPRECATED | 2025-10-28 | pages-deploy.yml, briefing_deploy.yml |

## ⚠️ Workflows Requieren Migración ANTES de Eliminación

### 1. pages-deploy.yml (CRÍTICO)
**Archivo:** `.github/workflows/pages-deploy.yml`  
**Líneas a cambiar:**
```diff
- if [ -z "${{ secrets.CF_API_TOKEN }}" ]; then missing+=("CF_API_TOKEN"); fi
+ if [ -z "${{ secrets.CLOUDFLARE_API_TOKEN }}" ]; then missing+=("CLOUDFLARE_API_TOKEN"); fi
- if [ -z "${{ secrets.CF_ACCOUNT_ID }}" ]; then missing+=("CF_ACCOUNT_ID"); fi  
+ if [ -z "${{ secrets.CLOUDFLARE_ACCOUNT_ID }}" ]; then missing+=("CLOUDFLARE_ACCOUNT_ID"); fi

- apiToken: ${{ secrets.CF_API_TOKEN }}
+ apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
- accountId: ${{ secrets.CF_ACCOUNT_ID }}
+ accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
```

### 2. briefing_deploy.yml (CRÍTICO)
**Archivo:** `.github/workflows/briefing_deploy.yml`  
**Líneas a cambiar:**
```diff
- apiToken: ${{ secrets.CF_API_TOKEN }}
+ apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

### 3. apps/briefing/.github/workflows/briefing_pages.yml
**Archivo:** `apps/briefing/.github/workflows/briefing_pages.yml`  
**Líneas a cambiar:**
```diff
- apiToken: ${{ secrets.CF_API_TOKEN }}
+ apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

## ✅ Workflows Ya Migrados (No Requieren Acción)

- ✅ `pages-preview.yml` - Usa CLOUDFLARE_API_TOKEN
- ✅ `pages-preview2.yml` - Usa CLOUDFLARE_API_TOKEN  
- ✅ `overlay-deploy.yml` - Usa CLOUDFLARE_API_TOKEN

## 📅 Cronograma de Eliminación

### Fase 1: Migración (2025-10-15 a 2025-10-21)
- [ ] Migrar pages-deploy.yml a tokens canónicos
- [ ] Migrar briefing_deploy.yml a tokens canónicos
- [ ] Migrar apps/briefing/.github/workflows/briefing_pages.yml
- [ ] Ejecutar 2-3 deploys exitosos con tokens canónicos
- [ ] Validar que no hay regresiones

### Fase 2: Marcado Deprecated (2025-10-22)
- [ ] Añadir comentarios DEPRECATED en workflows
- [ ] Actualizar documentación con advertencias
- [ ] Crear recordatorio para eliminación

### Fase 3: Eliminación (2025-10-28)
- [ ] Verificar última vez que workflows funcionan con canónicos
- [ ] Eliminar CF_API_TOKEN de GitHub Secrets
- [ ] Eliminar CF_ACCOUNT_ID de GitHub Secrets  
- [ ] Actualizar inventario de secrets
- [ ] Cerrar issue de limpieza

## 🚨 Validaciones Pre-Eliminación

### Checklist Obligatorio ANTES de Eliminar
- [ ] ✅ pages-deploy.yml migrado y funcionando
- [ ] ✅ briefing_deploy.yml migrado y funcionando
- [ ] ✅ Mínimo 3 deploys exitosos con tokens canónicos
- [ ] ✅ No hay referencias a CF_API_TOKEN en código
- [ ] ✅ No hay referencias a CF_ACCOUNT_ID en código
- [ ] ✅ ci_cloudflare_tokens_verify.yml ejecutado exitosamente

### Comando de Verificación
```bash
# Buscar referencias legacy
grep -r "CF_API_TOKEN" .github/workflows/
grep -r "CF_ACCOUNT_ID" .github/workflows/
grep -r "CF_API_TOKEN" apps/briefing/.github/workflows/

# Debe retornar: No matches found
```

## 🔄 Rollback Plan (Si Algo Falla)

En caso de problemas durante la migración:

1. **Revertir workflows:** Cambiar de vuelta a CF_API_TOKEN temporalmente
2. **Validar funcionamiento:** Ejecutar deploy de emergencia  
3. **Investigar problema:** Verificar scopes de CLOUDFLARE_API_TOKEN
4. **Documentar issue:** Crear ticket con detalles del fallo
5. **Reprogramar limpieza:** Extender fecha de eliminación si necesario

## 📞 Contactos y Escalación

- **Responsable técnico:** CI/CD Automation (GitHub Issues)
- **Escalación:** @ppkapiro (GitHub)
- **Documentación:** docs/internal/runbooks/runbook_cf_tokens.md
- **Soporte:** Issues con label `security` + `tokens` + `cleanup`

---

**⚠️ IMPORTANTE:** No eliminar secrets legacy hasta completar TODAS las validaciones arriba.  
**📅 Fecha límite:** 2025-10-28 (puede extenderse si hay problemas en migración)