# Pages Functions Preview — Hardening y Cierre de Gap

**Fecha:** 2025-10-20  
**Rama:** `feat/pages-functions-preview-hardening`  
**Objetivo:** Cerrar el gap hacia main con solución sólida para Pages Functions en preview

---

## 📋 Resumen Ejecutivo

### Estado Actual (2025-10-20)
- ✅ Pages Functions desplegadas en preview (desde 2025-10-15)
- ✅ Error "Disallowed operation in global scope" resuelto
- ✅ `/api/whoami` responde 200 con headers canary en preview
- ✅ Deploy production operativo (run 18545936306)
- ⚠️  Pendiente: KV namespaces warning en preview
- ⚠️  Pendiente: Tests unitarios para RNG determinista
- ⚠️  Pendiente: Regla ESLint anti-global-scope
- ⚠️  Pendiente: Contrato de headers canary en smokes

### Cambios Aplicados (2025-10-15)
**PR #45:** `fix(pages-functions): resolver global scope + deploy preview operativo`
- **Merged:** 2025-10-15T23:55:14Z
- **Commits principales:**
  - `68b00c3` — RNG determinista FNV-1a
  - `1cbbd12` — Date.now() diferido
  - `de6473f` — Response factories
  - `04f56e8` — Ajustes smokes preview

---

## 🔍 Evidencias del Estado Actual

### 1. Último Deploy Exitoso
**Run ID:** 18545936306  
**Fecha:** 2025-10-15T23:58:14Z  
**Branch:** main  
**Conclusión:** ✅ SUCCESS  
**Workflow:** CI — Briefing

### 2. Commit de Merge a Main
```
214c7e1 fix(pages-functions): resolver global scope + deploy preview operativo (#45)
```

**Archivos modificados (10 total):**
1. `apps/briefing/functions/_lib/log_policy.js` — RNG determinista (FNV-1a 32-bit)
2. `apps/briefing/functions/_lib/log.js` — hash6() para event keys
3. `apps/briefing/functions/_utils/roles.js` — logEvent con hash determinista
4. `apps/briefing/functions/_lib/accessStore.js` — withTimestamp parameter
5. `apps/briefing/functions/api/resolve_preview.js` — Response factory
6. `apps/briefing/functions/api/kv_roles_snapshot.js` — Response factory
7. `apps/briefing/functions/api/inbox.js` — 404 sin permiso (preview)
8. `apps/briefing/functions/api/decisiones.js` — 405 sin sesión (preview)
9. `apps/briefing/docs/internal/briefing_system/ci/082_reestructuracion_local.md` — Documentación
10. `CHANGELOG.md` — Registro de cambios

### 3. Headers Canary Confirmados (Preview)
**URL Preview:** `https://b3823c4a.runart-foundry.pages.dev/api/whoami`  
**Run ID:** 18545640218  

**Respuesta:**
```json
{
  "ok": true,
  "email": null,
  "role": "visitor",
  "rol": "visitante",
  "env": "preview",
  "ts": "2025-10-15T23:41:56.115Z"
}
```

**Headers:**
```
x-runart-canary: preview
x-runart-resolver: utils
```

### 4. Wrangler.toml Estado Actual
**Ubicación:** `apps/briefing/wrangler.toml`

**KV Namespaces (top-level):**
```toml
[[kv_namespaces]]
binding = "DECISIONES"
id = "6418ac6ace59487c97bda9c3a50ab10e"
preview_id = "e68d7a05dce645478e25c397d4c34c08"

[[kv_namespaces]]
binding = "LOG_EVENTS"
id = "9fbb7e6c2d6a4c1cb3ad2b3cce4040f5"
preview_id = "17937e5c45fa49ec83b4d275f1714d44"

[[kv_namespaces]]
binding = "RUNART_ROLES"
id = "26b8c3ca432946e2a093dcd33163f9e2"
preview_id = "7d80b07de98e4d9b9d5fd85516901ef6"
```

**⚠️ Problema identificado:** Comentario en wrangler.toml indica:
```toml
# Note: KV bindings are declared at the top-level for Pages Functions.
# Wrangler advierte que no se heredan automáticamente a entornos; sin embargo,
# para Pages el binding se respeta desde la configuración del proyecto.
# Si fuera necesario aislar namespaces por entorno, duplicar bloques [[kv_namespaces]]
# debajo de [env.preview] con preview_id correspondiente.
```

---

## 🎯 Gap Identificado y Soluciones

### Gap 1: KV Namespaces Warning en Preview
**Problema:** Wrangler puede emitir warning sobre herencia de KV bindings en env.preview

**Solución:** Duplicar `[[kv_namespaces]]` explícitamente en `[env.preview]`

**Riesgo:** Ninguno - solo clarifica configuración existente

**Estado:** PENDIENTE (este PR)

---

### Gap 2: Tests Unitarios Ausentes
**Problema:** No hay tests para:
- `sampleHit()` determinista en `log_policy.js`
- `hash6()` generador de claves en `log.js` y `roles.js`

**Solución:** Crear tests en `apps/briefing/tests/unit/`

**Cobertura esperada:**
- `sampleHit(action, role)` → misma entrada = mismo resultado
- `hash6(input)` → tabla de casos conocidos
- Validar FNV-1a 32-bit correctitud

**Estado:** PENDIENTE (este PR)

---

### Gap 3: Regla ESLint Anti-Global-Scope
**Problema:** Sin prevención automática de regresiones

**APIs prohibidas en top-level:**
- `Math.random()`
- `crypto.getRandomValues()`, `crypto.randomUUID()`
- `Date.now()`
- `new Response()` (sin factory)
- Cualquier I/O asíncrono

**Solución:** Regla ESLint custom o plugin

**Estado:** PENDIENTE (este PR)

---

### Gap 4: Contrato Headers Canary No Asertado
**Problema:** Smokes validan status 200 pero no headers explícitamente

**Headers esperados:**
- `X-RunArt-Canary: preview` (en preview)
- `X-RunArt-Resolver: utils` (siempre)

**Solución:** Actualizar smokes para verificar headers

**Estado:** PENDIENTE (este PR)

---

### Gap 5: Documentación Comportamientos Preview
**Problema:** 404/405 en `inbox.js`/`decisiones.js` son temporales

**Plan de reversión:**
- Cuando Access Service Token esté configurado:
  - `inbox.js` → 403 (en lugar de 404)
  - `decisiones.js` → 401 o 200 según autenticación

**Solución:** Documentar claramente en código y docs

**Estado:** PENDIENTE (este PR)

---

### Gap 6 (Opcional): Migración a wrangler pages deploy
**Estado actual:** Workflow usa custom action de Cloudflare

**Beneficio migración:**
- Comando estándar de wrangler CLI
- Menos dependencias de actions de terceros
- Más control sobre el proceso

**Estado:** EVALUAR (no bloqueante)

---

## 📂 Archivos a Modificar

### 1. Configuración
- [x] `apps/briefing/wrangler.toml` — Duplicar KV namespaces en env.preview
- [ ] `apps/briefing/.eslintrc.json` o `.eslintrc.js` — Regla anti-global-scope
- [ ] `apps/briefing/package.json` — Scripts de test si necesario

### 2. Tests Unitarios (NUEVO)
- [ ] `apps/briefing/tests/unit/log_policy.test.js` — Tests sampleHit
- [ ] `apps/briefing/tests/unit/event_keys.test.js` — Tests hash6

### 3. Smokes
- [ ] Archivo de smoke que valide headers canary
- [ ] (Investigar ubicación actual de smokes)

### 4. Documentación
- [ ] `apps/briefing/docs/internal/briefing_system/ci/082_reestructuracion_local.md` — Actualizar
- [ ] Comentarios inline en `inbox.js`, `decisiones.js` — Indicar temporal

### 5. Workflows (Opcional)
- [ ] `.github/workflows/ci.yml` — Evaluar migración a wrangler pages deploy

---

## 🔒 Riesgos y Mitigaciones

### Riesgo 1: Breaking Changes en Preview
**Mitigación:** Todos los cambios son additive o clarificaciones

### Riesgo 2: Tests Fallan en CI
**Mitigación:** Validar localmente antes de push

### Riesgo 3: ESLint Rompe Build Existente
**Mitigación:** Inicialmente como warning, luego error

### Riesgo 4: KV Duplicate Causa Conflictos
**Mitigación:** Preview usa preview_id ya existentes

---

## ✅ Checklist de Aceptación

### Configuración
- [ ] `wrangler.toml` preview sin warnings de KV
- [ ] ESLint regla anti-global activa

### Tests
- [ ] Tests `sampleHit` PASS
- [ ] Tests `hash6` PASS
- [ ] CI ejecuta tests unitarios

### Smokes
- [ ] Headers canary asertados explícitamente
- [ ] Documentado que 404/405 es temporal

### Documentación
- [ ] Bitácora 082 actualizada
- [ ] Comentarios inline en código temporal
- [ ] CHANGELOG.md actualizado

### Deploy
- [ ] Preview continúa funcionando
- [ ] No regresiones en producción
- [ ] CI checks pasan

---

## 📊 Métricas

### Antes de este PR
- Archivos modificados (PR #45): 10
- Tests unitarios: 0
- Reglas ESLint custom: 0
- Headers canary: Presentes pero no asertados

### Después de este PR (Esperado)
- Archivos modificados: +6
- Tests unitarios: +2 archivos (~20 test cases)
- Reglas ESLint custom: +1
- Headers canary: Asertados explícitamente

---

## 🔜 Próximos Pasos (Post-Merge)

1. **Access Service Token Integration**
   - Configurar secrets en GitHub
   - Revertir 404/405 a códigos definitivos
   - Activar auth smokes

2. **Optimización Continua**
   - Monitorear logs de producción
   - Ajustar thresholds de sampling
   - Refinar reglas de lint

3. **Expansión de Tests**
   - Tests de integración para endpoints
   - Tests de headers canary end-to-end
   - Coverage reports

---

## 📝 Historial de Implementación

### 2025-10-20T11:00 — Tests Unitarios ✅

**Archivos creados:**
1. `apps/briefing/tests/unit/log_policy.test.js` (76 líneas)
   - ✅ 10 test cases para `isAllowed`, `sampleHit`, FNV-1a hash
   - ✅ Validación de reproducibilidad determinista
   - ✅ Vectores de regresión con valores conocidos

2. `apps/briefing/tests/unit/event_keys.test.js` (72 líneas)
   - ✅ 7 test cases para `hash6()` determinista
   - ✅ Validación de colisiones (smoke test 1000 inputs)
   - ✅ Formato base36 de 6 caracteres

3. `apps/briefing/vitest.config.js`
   - ✅ Configuración Vitest para unit tests
   - ✅ Timeout 30s, environment node

**Resultado:** ✅ 17/17 tests pasando (646ms)

```bash
npm run test:vitest
# Test Files  2 passed (2)
# Tests  17 passed (17)
```

### 2025-10-20T11:10 — ESLint + Headers Canary + Docs ✅

**ESLint — Regla global scope:**
- ✅ `.eslintrc.json` creado con reglas `no-restricted-syntax`
- ✅ Prohibido: `Math.random()`, `Date.now()`, `new Response()`, `crypto.*` en global scope
- ✅ Scripts: `npm run lint` y `npm run lint:fix`
- ✅ Instalado `eslint@^8.57.0` en devDependencies
- ✅ Validado: 4 violaciones detectadas correctamente en archivo de prueba

**Smoke Tests — Headers canary:**
- ✅ `run-smokes.mjs` actualizado para validar headers en preview
- ✅ 4 escenarios whoami verifican `X-RunArt-Canary: preview`
- ✅ 3 escenarios verifican `X-RunArt-Resolver: utils`
- ✅ Validación solo activa cuando `IS_PREVIEW === true`

**Documentación inline:**
- ✅ `api/inbox.js` — Comentario TEMPORAL sobre 404 → 403
- ✅ `api/decisiones.js` — Comentario TEMPORAL sobre 405 → 401
- ✅ Referencia a TODO: revertir cuando Access Service Token esté configurado

**Archivos modificados (7 total):**
1. `apps/briefing/.eslintrc.json` — CREADO
2. `apps/briefing/.eslintignore` — CREADO
3. `apps/briefing/package.json` — +eslint, +scripts lint
4. `apps/briefing/tests/scripts/run-smokes.mjs` — +validaciones headers
5. `apps/briefing/functions/api/inbox.js` — +comentarios TEMPORAL
6. `apps/briefing/functions/api/decisiones.js` — +comentarios TEMPORAL
7. `apps/briefing/wrangler.toml` — +KV namespaces env.preview

---

**Estado:** 🚧 EN PROGRESO  
**Última actualización:** 2025-10-20T11:10Z
