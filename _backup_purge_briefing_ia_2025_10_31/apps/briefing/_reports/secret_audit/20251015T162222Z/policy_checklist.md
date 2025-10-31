# Access Policy Checklist

## Estado Actual
⚠️ **Access devuelve HTTP 302 (redirect a login)** cuando se usa el service token actual.

## Diagnóstico
El JWT en la respuesta incluye: `"service_token_status":false`  
Esto indica que el service token NO está autorizado en la policy de Access para `/api/whoami`.

## Acciones Requeridas

### 1. Verificar Service Token Actual
- **Token ID:** `b6d63d68e8a79f538af8713239243d22.access`
- **Origen:** Configurado en secretos locales y CI
- **Estado:** Probablemente no incluido en ninguna policy de la aplicación

### 2. Crear/Actualizar Service Token para CI
En Cloudflare Dashboard:
1. Ir a **Zero Trust** → **Access** → **Service Authentication**
2. Crear nuevo Service Token:
   - **Nombre:** `runart-ci-diagnostics`
   - **Duración:** 1 año (o permanente)
   - Copiar Client ID y Client Secret

### 3. Actualizar Policy de la Aplicación
En Cloudflare Dashboard:
1. Ir a **Zero Trust** → **Access** → **Applications**
2. Buscar aplicación: `RUN Briefing` (o `runart-foundry.pages.dev`)
3. Editar Policy existente o crear nueva:
   - **Policy Name:** `CI Diagnostics`
   - **Action:** Allow
   - **Include:** Service Token → seleccionar `runart-ci-diagnostics`
   - **NO marcar** "Require One-time PIN"
4. Aplicar y verificar

### 4. Actualizar Secretos
Después de crear el service token:

```bash
# Local
echo -n "NUEVO_CLIENT_ID" | sed 's/^/ACCESS_CLIENT_ID=/' >> ~/.runart/env
echo -n "NUEVO_CLIENT_SECRET" | sed 's/^/ACCESS_CLIENT_SECRET=/' >> ~/.runart/env

# CI
echo -n "NUEVO_CLIENT_ID" | gh secret set ACCESS_CLIENT_ID_PREVIEW
echo -n "NUEVO_CLIENT_SECRET" | gh secret set ACCESS_CLIENT_SECRET_PREVIEW
```

### 5. Validación
Probar nuevamente:
```bash
curl -I https://runart-foundry.pages.dev/api/whoami \
  -H "CF-Access-Client-Id: NUEVO_CLIENT_ID" \
  -H "CF-Access-Client-Secret: NUEVO_CLIENT_SECRET"
```

**Esperado:** HTTP 200 (no 302)

## Referencias
- Application ID: `208c1b2a60b592e4f5468bd56804e905bff41b8745928f4eaf136ea2e4d5ee5b` (del JWT)
- Hostname: `runart-foundry.pages.dev`
- Endpoint protegido: `/api/whoami`

## Próximos Pasos
Una vez el service token esté autorizado:
1. Reejecutar FASE 3 para validar headers
2. Continuar con FASE 4 (CI diagnóstico)
3. Confirmar que RESUMEN muestra headers correctos

---
**Nota:** Sin un service token autorizado, el CI siempre devolverá headers "?" porque Access bloquea el acceso.
