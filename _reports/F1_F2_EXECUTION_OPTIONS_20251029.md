# F1/F2 Execution Options — Content Audit Phase 1

**Fecha:** 2025-10-29  
**Contexto:** Auditoría de contenido e imágenes v2  
**PRs relacionados:** #77 (F1+F2), #81 (F1 bitácora), #82 (F2 bitácora)

---

## Estado Actual

### Inventarios Locales (TOTAL=0)

- **F1 (Páginas):** `research/content_audit_v2/01_pages_inventory.md` — commit `1b37475`
- **F2 (Imágenes):** `research/content_audit_v2/02_images_inventory.md` — commit `3221b19`

Ambos ejecutados localmente con WP-CLI sin path a WordPress staging → 0 resultados.

**Próximo paso:** Ejecutar en staging con datos reales.

---

## Opciones de Ejecución

### Opción 1: Bridge REST API con Endpoints Personalizados ⭐ RECOMENDADO

**Descripción:** Extender el plugin `runart-wpcli-bridge` para agregar endpoints REST específicos para auditoría de contenido.

**Endpoints a implementar:**

1. `/wp-json/runart/v1/audit/pages`
   - GET: Lista todas las páginas/posts con metadatos (ID, URL, lang, type, status, title, slug)
   - Query params: `post_type`, `post_status`, `posts_per_page`

2. `/wp-json/runart/v1/audit/images`
   - GET: Lista todos los attachments (imágenes) con metadatos (ID, URL, MIME, dimensions, size, alt, title, lang)
   - Query params: `mime_type`, `posts_per_page`

**Ventajas:**
- ✅ Seguro: autenticación vía WP Application Password
- ✅ Integrado: reutiliza infraestructura existente (workflow `wpcli-bridge.yml`)
- ✅ Sin SSH: no requiere keys ni acceso shell
- ✅ Gobernanza: modo READ_ONLY garantizado por diseño del endpoint
- ✅ CI-friendly: workflow ejecuta y commitea resultados automáticamente

**Desventajas:**
- ⚠ Requiere deploy de plugin actualizado a staging
- ⚠ Dev time: ~1-2h para implementar endpoints + tests

**Workflow integration:**
```yaml
# Actualizar .github/workflows/wpcli-bridge.yml
on:
  workflow_dispatch:
    inputs:
      command:
        options:
          - audit_pages    # NEW
          - audit_images   # NEW
```

**Implementación:**
```bash
# 1. Editar plugin
vim tools/wpcli-bridge-plugin/includes/class-audit-endpoints.php

# 2. Build y deploy
gh workflow run build-wpcli-bridge.yml
gh workflow run install-wpcli-bridge.yml

# 3. Ejecutar auditoría
gh workflow run wpcli-bridge.yml -f command=audit_pages
gh workflow run wpcli-bridge.yml -f command=audit_images
```

---

### Opción 2: SSH + WP-CLI Manual con Key Setup

**Descripción:** Configurar SSH key en IONOS, ejecutar WP-CLI directamente vía terminal manual.

**Pasos:**

1. **Setup SSH Key:**
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/ionos_runart -C "runart-staging-deploy"
   # Copiar key al servidor vía panel IONOS o ssh-copy-id
   ```

2. **Actualizar config:**
   ```bash
   echo 'export IONOS_SSH_KEY="$HOME/.ssh/ionos_runart"' >> ~/.runart_staging_env
   source tools/staging_env_loader.sh
   ```

3. **Ejecutar F1:**
   ```bash
   ssh -i ~/.ssh/ionos_runart u11876951@access958591985.webspace-data.io \
     "cd /html/staging && wp post list --post_type=page,post --format=csv --fields=ID,post_title,post_name,post_status,post_type" \
     > /tmp/f1_pages.csv
   ```

4. **Procesar y commit:**
   ```bash
   # Convertir CSV → Markdown con idioma detection
   python tools/audit/process_f1_csv.py /tmp/f1_pages.csv > research/content_audit_v2/01_pages_inventory.md
   git add research/content_audit_v2/01_pages_inventory.md
   git commit -m "F1: inventario staging real (SSH/WP-CLI)"
   ```

**Ventajas:**
- ✅ Control total sobre comandos WP-CLI
- ✅ Flexibilidad para queries complejas
- ✅ No requiere cambios en plugin

**Desventajas:**
- ❌ Requiere SSH key setup (manual, una sola vez)
- ❌ No integrado con CI/workflows
- ❌ Menos seguro: requiere exponer SSH key como secret
- ❌ Manual: requiere intervención humana para cada ejecución
- ❌ Gobernanza débil: READ_ONLY no enforced por diseño

---

### Opción 3: GitHub Actions + SSH Key Secret

**Descripción:** Crear workflow que use SSH key almacenada como GitHub Secret para ejecutar WP-CLI remotamente.

**Implementación:**

1. **Setup Secret:**
   ```bash
   # Generar key localmente
   ssh-keygen -t ed25519 -f ~/.ssh/ionos_runart_ci -N ""
   
   # Copiar key al servidor (manual o ssh-copy-id)
   
   # Añadir private key como GitHub Secret:
   gh secret set IONOS_SSH_KEY < ~/.ssh/ionos_runart_ci
   ```

2. **Crear workflow:** `.github/workflows/audit-content-wpcli.yml`
   ```yaml
   name: audit-content-wpcli
   
   on:
     workflow_dispatch:
       inputs:
         phase:
           description: "Fase (f1_pages | f2_images)"
           required: true
           type: choice
           options:
             - f1_pages
             - f2_images
   
   jobs:
     execute:
       runs-on: ubuntu-latest
       steps:
         - name: Setup SSH
           run: |
             mkdir -p ~/.ssh
             echo "${{ secrets.IONOS_SSH_KEY }}" > ~/.ssh/ionos
             chmod 600 ~/.ssh/ionos
             ssh-keyscan -H ${{ vars.IONOS_SSH_HOST }} >> ~/.ssh/known_hosts
         
         - name: Execute F1 (pages)
           if: inputs.phase == 'f1_pages'
           run: |
             ssh -i ~/.ssh/ionos ${{ vars.IONOS_SSH_USER }}@${{ vars.IONOS_SSH_HOST }} \
               'cd ${{ vars.STAGING_WP_PATH }} && wp post list --post_type=page,post --format=csv' \
               > /tmp/f1.csv
         
         - name: Process and commit
           run: |
             # Convertir CSV → MD, commit, push
   ```

3. **Ejecutar:**
   ```bash
   gh workflow run audit-content-wpcli.yml -f phase=f1_pages
   ```

**Ventajas:**
- ✅ Integrado con CI
- ✅ Automatizable
- ✅ Trazabilidad (logs en GitHub Actions)

**Desventajas:**
- ⚠ Expone SSH key como secret (riesgo medio)
- ⚠ Requiere setup manual inicial
- ⚠ Gobernanza: READ_ONLY no enforced (depende de comandos)

---

### Opción 4: Local Execution con DB Snapshot (NO RECOMENDADO)

**Descripción:** Descargar snapshot de DB staging, cargar localmente, ejecutar WP-CLI local.

**Desventajas:**
- ❌ Viola principio READ_ONLY (staging data sale de servidor)
- ❌ GDPR/Privacy concerns (datos de usuarios en local)
- ❌ Overhead: requiere MySQL local, snapshot grande (>100MB)
- ❌ No refleja estado real-time de staging

---

## Decisión Recomendada

### Ruta Crítica: Opción 1 (Bridge REST API)

**Justificación:**
1. **Seguridad:** Autenticación WP nativa, sin SSH keys
2. **Gobernanza:** READ_ONLY by design
3. **Escalabilidad:** Reutilizable para futuras auditorías
4. **CI-Native:** Se integra con workflows existentes
5. **Mantenibilidad:** Código centralizado en plugin

**Timeline:**
- **Hoy (2025-10-29):** Implementar endpoints en plugin (1-2h)
- **Mañana:** Deploy plugin actualizado, ejecutar F1/F2, actualizar PR #77

**Fallback:** Si Opción 1 no es viable (ej: no acceso a deploy plugin), usar Opción 2 (SSH manual) para desbloquear progreso.

---

## Tareas Pendientes (si se elige Opción 1)

### Development
- [ ] Crear `tools/wpcli-bridge-plugin/includes/class-audit-endpoints.php`
- [ ] Registrar endpoints en `includes/class-rest-api.php`
- [ ] Añadir unit tests básicos
- [ ] Build plugin: `gh workflow run build-wpcli-bridge.yml`

### Deploy
- [ ] Deploy a staging: `gh workflow run install-wpcli-bridge.yml`
- [ ] Verificar endpoints: `curl -u user:pass https://staging.../wp-json/runart/v1/audit/pages`

### Execution
- [ ] Actualizar workflow `wpcli-bridge.yml` con opciones `audit_pages`, `audit_images`
- [ ] Ejecutar: `gh workflow run wpcli-bridge.yml -f command=audit_pages`
- [ ] Verificar output en `_reports/bridge/bridge_*_audit_pages.md`
- [ ] Parsear JSON → actualizar `research/content_audit_v2/01_pages_inventory.md`
- [ ] Commit y push a PR #77

### Documentation
- [ ] Documentar nuevos endpoints en `docs/Bridge_API.md`
- [ ] Actualizar bitácora con métricas reales (F1: Total/ES/EN, F2: Total/MIME breakdown)

---

## Referencias

- Bridge plugin: `tools/wpcli-bridge-plugin/`
- Workflow actual: `.github/workflows/wpcli-bridge.yml`
- Staging config: `_reports/STATUS_DEPLOYMENT_SSH_20251029.md`
- PR #77: https://github.com/RunArtFoundry/runart-foundry/pull/77
- Bitácora: `_reports/BITACORA_AUDITORIA_V2.md`

---

**Conclusión:** Opción 1 (Bridge REST API) es la ruta recomendada por seguridad, gobernanza y mantenibilidad. Requiere ~2h de dev time pero desbloquea F1/F2 y establece patrón reutilizable para auditorías futuras.

