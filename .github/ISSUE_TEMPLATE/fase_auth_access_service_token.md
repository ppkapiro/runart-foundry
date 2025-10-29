---
name: Fase AUTH - Access Service Token Integration
about: Integración de Access Service Token para habilitar smokes autenticados y revertir códigos temporales
title: 'Fase AUTH: Access Service Token + smokes autenticados + reversión códigos temporales'
labels: enhancement, auth, ci, smokes
assignees: ''
---

## 🎯 Objetivo

Habilitar autenticación en smokes de producción mediante Access Service Token y revertir comportamientos temporales en Functions para códigos HTTP definitivos.

## 📋 Subtareas

### 1. Configuración de Access Service Token

- [ ] **Generar Access Service Token en Cloudflare Zero Trust**
  - Dashboard → Access → Service Tokens
  - Crear token dedicado para "RunArt Briefing CI/CD"
  - Generar credenciales (Client ID + Client Secret)
  - Documentar fecha de creación y alcance de permisos

- [ ] **Configurar secretos en GitHub**
  - Agregar `ACCESS_SERVICE_TOKEN_CLIENT_ID` en repository secrets
  - Agregar `ACCESS_SERVICE_TOKEN_CLIENT_SECRET` en repository secrets
  - Verificar que no se exponen en logs de CI

- [ ] **Configurar en entornos Cloudflare Pages (opcional)**
  - Preview: variables `ACCESS_CLIENT_ID` y `ACCESS_CLIENT_SECRET`
  - Production: variables `ACCESS_CLIENT_ID` y `ACCESS_CLIENT_SECRET`

### 2. Habilitar smokes AUTH en CI

- [ ] **Actualizar workflow `pages-prod.yml`**
  - Añadir job separado "Run Prod Smokes (Auth)" o condicional en el existente
  - Configurar `env`:
    ```yaml
    PROD_BASE_URL: https://runart-foundry.pages.dev/
    ACCESS_SERVICE_TOKEN: ${{ secrets.ACCESS_SERVICE_TOKEN_CLIENT_ID }}:${{ secrets.ACCESS_SERVICE_TOKEN_CLIENT_SECRET }}
    RUN_AUTH_SMOKES: "1"
    ```
  - Ejecutar `npm --prefix apps/briefing run smokes:prod:auth`
  - Subir artifacts de smokes AUTH

- [ ] **Validar que headers/cookies se enmascaran en logs**
  - `Authorization: Bearer ***` (mascarar token)
  - Cookies de sesión Access enmascaradas
  - Verificar en artifacts de CI que no hay datos sensibles

### 3. Extender `run-smokes-prod.mjs` con checks AUTH

- [ ] **Implementar función `runAuthSuite()` activada**
  - Leer `ACCESS_SERVICE_TOKEN` de env (formato `client_id:client_secret`)
  - Añadir headers de autenticación:
    ```javascript
    headers: {
      'CF-Access-Client-Id': clientId,
      'CF-Access-Client-Secret': clientSecret
    }
    ```

- [ ] **Check D: GET `/api/whoami` (autenticado)**
  - Esperado: **200** con body `{ env: "production", role: "admin"|"owner", ... }`
  - Validar header `X-RunArt-Resolver: utils`
  - Anotar rol devuelto en SUMMARY.md

- [ ] **Check E: GET `/api/inbox` (autenticado)**
  - Esperado según rol:
    - Owner/Team: **200** con array de mensajes
    - Client/Visitor: **403** con `{"ok":false,"error":"Acceso restringido"}`
  - Parametrizable via `EXPECTED_INBOX_STATUS` (default: 200)

- [ ] **Check F: POST `/api/decisiones` (autenticado)**
  - Body mínimo: `{ "draft": true }`
  - Esperado según rol:
    - Owner/Team: **200** con `{"ok":true,...}`
    - Sin permisos: **403**
    - Sin sesión: **401**

- [ ] **Generar SUMMARY_AUTH.md separado**
  - Tabla con checks D/E/F
  - Resumen PASS/FAIL
  - Timestamp y rol detectado

### 4. Revertir códigos temporales en Functions

- [ ] **`apps/briefing/functions/api/inbox.js`**
  - Eliminar comentario `// TEMPORAL: devuelve 404 en preview...`
  - Cambiar comportamiento:
    - De: `return new Response(JSON.stringify({ok:false}), {status: 404})`
    - A: `return new Response(JSON.stringify({ok:false,error:"Acceso restringido",role}), {status: 403})`
  - Mantener 200 para owner/team autenticados

- [ ] **`apps/briefing/functions/api/decisiones.js`**
  - Eliminar comentario `// TEMPORAL: devuelve 405 en preview...`
  - Cambiar comportamiento:
    - POST sin sesión Access: **401** (en lugar de 405)
    - POST autenticado sin permisos: **403**
    - POST owner/team: **200** con payload de decisión
  - Validar que guarda en KV `DECISIONES` correctamente

### 5. Documentación y evidencias

- [ ] **Actualizar `082_reestructuracion_local.md`**
  - Sección "Smokes de producción (auth)" con:
    - Fecha/hora de ejecución
    - Run ID de CI
    - Resultados D/E/F con status y roles
    - Artefactos: ruta a `smokes_prod_<timestamp>/SUMMARY_AUTH.md`

- [ ] **Actualizar `PROBLEMA_pages_functions_preview.md`**
  - Marcar como "✅ COMPLETADO EN PRODUCCIÓN (AUTH HABILITADO)"
  - Añadir bloque "Smokes AUTH — Evidencias" con:
    - Run ID de CI con smokes AUTH
    - Tabla de resultados D/E/F
    - Confirmación de reversión de códigos temporales

- [ ] **Actualizar `CHANGELOG.md`**
  - Entrada nueva con fecha de integración AUTH
  - Detalles: Access Service Token configurado, smokes AUTH habilitados, códigos 404/405 → 403/401

- [ ] **Actualizar `reports/2025-10-20_access_service_token_followup.md`**
  - Marcar checklist como completado
  - Anotar fecha de cierre y evidencias finales

### 6. Validación end-to-end

- [ ] **Ejecutar smokes AUTH localmente**
  - Exportar `ACCESS_SERVICE_TOKEN="client_id:client_secret"`
  - Ejecutar `RUN_AUTH_SMOKES=1 npm run smokes:prod:auth`
  - Verificar 3/3 PASS en checks D/E/F
  - Confirmar que logs no exponen tokens

- [ ] **Verificar en CI (main)**
  - Workflow "Run Prod Smokes (Auth)" PASS
  - Artifacts subidos con SUMMARY_AUTH.md
  - No hay secretos expuestos en logs de GitHub Actions

- [ ] **Smoke manual en navegador (opcional)**
  - Autenticarse en `https://briefing.runartfoundry.com` (si existe alias)
  - Verificar `/api/whoami` devuelve rol correcto
  - Verificar `/api/inbox` devuelve 200 o 403 según rol
  - Verificar POST `/api/decisiones` con payload válido

## ✅ Criterios de aceptación

- [ ] Access Service Token configurado en GitHub Secrets y funcionando
- [ ] Smokes AUTH habilitados en workflow `pages-prod.yml` con step dedicado
- [ ] Checks D/E/F implementados y pasando (3/3 PASS)
- [ ] Códigos temporales 404/405 revertidos a 403/401 en `inbox.js` y `decisiones.js`
- [ ] Documentación actualizada (082, PROBLEMA, CHANGELOG, follow-up)
- [ ] Artifacts de CI con SUMMARY_AUTH.md y sin datos sensibles
- [ ] Logs de CI enmascaran tokens y cookies de Access

## 📚 Referencias

- `reports/2025-10-20_access_service_token_followup.md` — Documento de follow-up inicial
- `apps/briefing/tests/scripts/run-smokes-prod.mjs` — Runner de smokes (AUTH preparado)
- `apps/briefing/functions/api/inbox.js` — Endpoint a revertir (404 → 403)
- `apps/briefing/functions/api/decisiones.js` — Endpoint a revertir (405 → 401)
- `.github/workflows/pages-prod.yml` — Workflow de deploy a producción

## 🔒 Seguridad

⚠️ **IMPORTANTE:** 
- NO exponer `ACCESS_SERVICE_TOKEN` en texto plano en issues, commits o logs
- Enmascar tokens en artifacts con `***` o `[REDACTED]`
- Rotar tokens si hay sospecha de exposición
- Limitar permisos del token al mínimo necesario (solo Pages Functions de briefing)

---

**Estado:** 🟡 Pendiente  
**Prioridad:** Alta  
**Fase:** Access Service Token Integration
