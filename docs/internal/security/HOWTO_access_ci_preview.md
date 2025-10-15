# HOWTO: Verificación de Service Token de Access (Preview) — CI

Este documento describe los pasos manuales para configurar, verificar y documentar el Service Token de Cloudflare Access en el entorno preview desde un terminal bash en WSL Ubuntu.

---

## 📋 Requisitos Previos

- **Terminal:** bash (WSL Ubuntu o Linux)
- **Herramientas instaladas:**
  - GitHub CLI (`gh`) autenticado: `gh auth status`
  - Node.js 18+ para ejecutar scripts de verificación
  - `jq` para procesamiento JSON: `sudo apt install jq`
- **Acceso al dashboard de Cloudflare Access** para autorizar el Service Token
- **Service Token creado** en Cloudflare Access:
  - Nombre: `runart-ci-diagnostics`
  - Client ID y Client Secret listos para usar

---

## 🔐 Paso 1: Actualizar Secrets del Repositorio GitHub

Reemplaza `LOS_VALORES_CLIENT_ID` y `LOS_VALORES_CLIENT_SECRET` con los valores reales del Service Token:

```bash
# Navega al directorio del repositorio
cd /home/pepe/work/runartfoundry

# Actualiza los secrets en GitHub (requiere permisos de escritura en el repo)
gh secret set ACCESS_CLIENT_ID_PREVIEW --body "LOS_VALORES_CLIENT_ID"
gh secret set ACCESS_CLIENT_SECRET_PREVIEW --body "LOS_VALORES_CLIENT_SECRET"

# Verifica que los secrets se hayan guardado
gh secret list | grep ACCESS_CLIENT
```

**Resultado esperado:**
```
ACCESS_CLIENT_ID_PREVIEW       Updated 2025-10-15
ACCESS_CLIENT_SECRET_PREVIEW   Updated 2025-10-15
```

---

## ✅ Paso 2: Verificación Local del Token

Antes de ejecutar el workflow en CI, verifica localmente que el Service Token funciona:

```bash
# Exporta las variables de entorno con los valores del Service Token
export ACCESS_CLIENT_ID_PREVIEW="tu_client_id_real"
export ACCESS_CLIENT_SECRET_PREVIEW="tu_client_secret_real"

# Opcional: Define el host de preview si es diferente al default
# export PREVIEW_HOST="https://runart-foundry.pages.dev"

# Ejecuta el verificador local (desde el directorio raíz del repo)
cd apps/briefing
npm run verify:access:preview
```

**Resultado esperado (éxito):**
```
═══════════════════════════════════════════════════════════════════
  RUNART | Verificación de Service Token de Access (Preview)
═══════════════════════════════════════════════════════════════════

✅ Credenciales presentes
   Client ID: abc12345...xyz9
   Secret: def67890...(oculto)

🌐 Target: https://runart-foundry.pages.dev/api/whoami
📡 Enviando request con headers de Service Token...

📊 Status: 200 OK

🔍 Headers de Canary:
   X-RunArt-Canary: preview
   X-RunArt-Resolver: utils

📄 Body (primeros 512 chars):
{"email":"service-token@cloudflare.access","resolver":"utils","role":"service"}

═══════════════════════════════════════════════════════════════════
✅ VERIFICACIÓN EXITOSA
   • HTTP 200 OK
   • X-RunArt-Canary: preview
   • X-RunArt-Resolver: utils
   • Service Token funciona correctamente en preview
═══════════════════════════════════════════════════════════════════
```

### Troubleshooting

Si el verificador falla:

- **HTTP 302 (Redirect)**: El Service Token NO está autorizado en la policy de Access.
  - **Solución:** Ve al dashboard de Cloudflare Access → Aplicación "RUN Briefing" → Policy → Agrega el Service Token `runart-ci-diagnostics` en una regla de Allow (debe estar ANTES de las reglas de OTP/Login).

- **Headers X-RunArt-* ausentes**: La aplicación no está devolviendo los headers personalizados.
  - **Solución:** Verifica que el Worker de preview esté desplegado correctamente y que incluya los headers en la respuesta de `/api/whoami`.

- **Error de red/timeout**: Problemas de conectividad o el host de preview no está disponible.
  - **Solución:** Verifica el host con `curl -I https://<host>/health` y confirma que resuelve DNS.

---

## 🚀 Paso 3: Disparar el Workflow de Diagnóstico en CI

Una vez que la verificación local sea exitosa:

```bash
# Dispara el workflow de diagnóstico canary
gh workflow run run_canary_diagnostics.yml

# Monitorea la ejecución en tiempo real
gh run watch --exit-status
```

**Nota:** El workflow tarda ~5-10 minutos. Espera a que termine con status `success`.

---

## 📦 Paso 4: Descargar Artifacts y Mover el RESUMEN

Una vez que el workflow termina exitosamente:

```bash
# Opción A: Usar el script automatizado (recomendado)
npm run canary:post

# Opción B: Descarga manual
RUN_ID=$(gh run list --workflow=run_canary_diagnostics.yml --status=success --limit=1 --json databaseId --jq '.[0].databaseId')
echo "Run ID: $RUN_ID"

# Descarga los artifacts
mkdir -p /tmp/canary_artifacts
gh run download "$RUN_ID" --dir /tmp/canary_artifacts

# Busca el RESUMEN
find /tmp/canary_artifacts -name "RESUMEN_*.md"

# Copia a la carpeta de evidencia
TIMESTAMP=$(date -u +%Y%m%d_%H%M)
mkdir -p docs/internal/security/evidencia
cp /tmp/canary_artifacts/*/RESUMEN_*.md \
   docs/internal/security/evidencia/RESUMEN_PREVIEW_${TIMESTAMP}.md

echo "✅ RESUMEN guardado en: docs/internal/security/evidencia/RESUMEN_PREVIEW_${TIMESTAMP}.md"
```

---

## 📝 Paso 5: Actualizar Changelog con Run ID y Ruta del RESUMEN

Edita el archivo `docs/internal/security/secret_changelog.md`:

```bash
# Abre el changelog con tu editor favorito
nano docs/internal/security/secret_changelog.md
# O usa vim, vscode, etc.
```

Actualiza la sección de **"2025-10-15 | Verificación de Service Token en Preview"**:

1. Reemplaza `[PENDIENTE - completar después de ejecución]` con el `$RUN_ID` real.
2. Reemplaza `RESUMEN_PREVIEW_YYYYMMDD_HHMM.md` con el nombre del archivo guardado.
3. Ajusta la fecha si es necesario.

**Ejemplo:**
```markdown
- **Run ID:** `18540123456` (reemplaza con el ID real)
- **Evidencia:** `docs/internal/security/evidencia/RESUMEN_PREVIEW_20251015_1630.md`
```

Guarda el archivo y haz commit:

```bash
git add docs/internal/security/secret_changelog.md
git add docs/internal/security/evidencia/RESUMEN_PREVIEW_*.md
git commit -m "docs(security): actualizar changelog tras verificación de token CI preview"
```

---

## 🔄 Paso 6: Empujar Cambios al PR

```bash
# Verifica que estás en la rama correcta
git branch --show-current
# Debe mostrar: feat/ci-access-service-token-verification

# Push de los cambios
git push origin feat/ci-access-service-token-verification
```

---

## ✅ Criterios de Aceptación

Verifica que todos estos puntos se cumplan antes de marcar como completado:

- [ ] `/api/whoami` (preview) devuelve **HTTP 200**
- [ ] Headers presentes en la respuesta:
  - [ ] `X-RunArt-Canary: preview` (o el valor esperado)
  - [ ] `X-RunArt-Resolver: utils` (o el valor esperado)
- [ ] Archivo `RESUMEN_PREVIEW_*.md` descargado y guardado en `docs/internal/security/evidencia/`
- [ ] Changelog `secret_changelog.md` actualizado con:
  - [ ] Run ID del workflow exitoso
  - [ ] Ruta del archivo RESUMEN
  - [ ] Fecha y hora (UTC)
  - [ ] TTL del token y fecha de próxima rotación
- [ ] PR actualizado con los commits de documentación
- [ ] Verificador local (`npm run verify:access:preview`) sale con código 0

---

## 🔧 Comandos de Referencia Rápida

```bash
# Verificación local
cd apps/briefing
export ACCESS_CLIENT_ID_PREVIEW="..."
export ACCESS_CLIENT_SECRET_PREVIEW="..."
npm run verify:access:preview

# Disparar workflow
gh workflow run run_canary_diagnostics.yml
gh run watch

# Postprocesar artifacts
npm run canary:post

# Ver último RESUMEN descargado
ls -lht docs/internal/security/evidencia/RESUMEN_PREVIEW_*.md | head -n 1
cat $(ls -t docs/internal/security/evidencia/RESUMEN_PREVIEW_*.md | head -n 1)

# Commit y push
git add docs/internal/security/
git commit -m "docs(security): evidencia y changelog de verificación Access preview"
git push origin feat/ci-access-service-token-verification
```

---

## 📚 Referencias

- **Workflow:** `.github/workflows/run_canary_diagnostics.yml`
- **Verificador local:** `tools/diagnostics/verify_access_service_token.mjs`
- **Postprocesador:** `tools/diagnostics/postprocess_canary_summary.sh`
- **Changelog:** `docs/internal/security/secret_changelog.md`
- **Cloudflare Access Dashboard:** [https://one.dash.cloudflare.com/](https://one.dash.cloudflare.com/)

---

## 💡 Tips

- **Reutiliza el verificador local** siempre que regeneres el Service Token o cambies la policy de Access.
- **Documenta siempre el Run ID** en el changelog para trazabilidad completa.
- **Rotación del token:** Programa una alerta de calendario para 30 días antes del vencimiento (TTL: 180 días).
- **Fallback:** Si `npm run canary:post` falla, siempre puedes descargar manualmente con `gh run download <RUN_ID>`.

---

**Última actualización:** 2025-10-15  
**Autor:** DevOps / GitHub Copilot  
**Versión:** 1.0
