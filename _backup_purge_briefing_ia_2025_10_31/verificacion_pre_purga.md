# 🔍 Verificación Pre-Purga: Briefing e IA Visual

**Fecha:** $(date '+%Y-%m-%d %H:%M:%S')
**Proyecto:** RunArt Foundry
**Rama:** feat/ai-visual-implementation

---

## 📊 Resumen del Escaneo


### Elementos Identificados para Eliminación

#### Directorios Principales
```
✓ apps/briefing/ (442M)
✓ _dist/build_runart_aivp/ (60K)
✓ tools/runart-ia-visual-unified/ (332K)
✓ data/assistants/ (32K)
✓ wp-content/runart-data/ (36K)
✓ _reports/FASE4/ (196K)
✓ _reports/consolidacion_prod/ (128K)
```

#### Workflows Briefing
```
✓ .github/workflows/briefing-status-publish.yml (265 líneas)
✓ .github/workflows/briefing_deploy.yml (100 líneas)
```

#### Documentos Específicos
```
✓ docs/ui_roles/BITACORA_INVESTIGACION_BRIEFING_V2.md (1143 líneas)
✓ docs/ui_roles/CONSOLIDACION_F9.md (168 líneas)
✓ docs/ui_roles/QA_checklist_consolidacion_preview_prod.md (319 líneas)
```


---

## ✅ MANTENER (Componentes Operativos)

**Confirmado - NO se eliminará:**

```
✓ mirror/ (todos los snapshots del sitio)
✓ tools/staging_*.sh (todos los scripts staging)
✓ scripts/deploy_framework/ (deploy staging)
✓ wp-content/mu-plugins/wp-staging-lite/ (briefing WordPress activo)
✓ plugins/runart-wpcli-bridge/ (bridge API activo)
✓ .github/workflows/verify-staging.yml
✓ .github/workflows/staging-cleanup-*.yml
✓ docs/integration_wp_staging_lite/ (23 documentos)
✓ _reports/lista_acciones_admin_staging.md
✓ _reports/informe_*_staging*.md (todos los informes staging)
```

---

## ❌ ELIMINAR CONFIRMADO (Sistemas Obsoletos)

### apps/briefing/ - Micrositio Cloudflare (COMPLETO)
- MkDocs Material
- Cloudflare Pages Functions
- 674 archivos de documentación interna
- **Razón:** Sistema briefing descontinuado

### _dist/build_runart_aivp/ - Build IA Visual Panel
- Plugin runart-ai-visual-panel compilado
- **Razón:** Reemplazado por wpcli-bridge

### tools/runart-ia-visual-unified/ - IA Visual Unified
- Plugin IA Visual legacy
- **Razón:** Consolidado en wpcli-bridge

### tools/data_ia/ - Datos IA Legacy
- assistants/rewrite/ (capa redundante #5)
- **Razón:** Migrado a wp-content/runart-data/

### data/assistants/ - Datos IA Repo Root
- rewrite/ (capa redundante #3)
- **Razón:** Migrado a wp-content/runart-data/

### wp-content/runart-data/ - Datos IA WordPress
- assistants/rewrite/ (capa redundante #4)
- **Razón:** Consolidado en wpcli-bridge

### _reports/FASE4/ - Documentación FASE4
- consolidacion_ia_visual_registro_capas.md
- diseño_flujo_consolidacion.md
- CIERRE_FASE4D_CONSOLIDACION.md
- **Razón:** Fase completada, archivar

### _reports/consolidacion_prod/ - Snapshots Producción
- 20251007T215004Z/
- 20251007T231800Z/
- 20251007T233500Z/
- 20251008T135338Z/
- 20251013T201500Z/
- **Razón:** Snapshots históricos, archivar

### .github/workflows/briefing_* - Workflows Briefing
- briefing_deploy.yml
- briefing-status-publish.yml
- **Razón:** Sistema briefing descontinuado

### docs/ui_roles/ - Bitácoras Completadas
- BITACORA_INVESTIGACION_BRIEFING_V2.md
- CONSOLIDACION_F9.md
- QA_checklist_consolidacion_preview_prod.md
- **Razón:** Fases 1-9 completadas, archivar

---

## 🎯 Próxima Fase

**FASE 2:** Crear respaldos en `_backup_purge_briefing_ia_2025_10_31/`

### Acciones:
1. Crear directorio backup
2. Copiar elementos marcados para eliminación
3. Comprimir en tar.gz
4. Verificar integridad del backup

---

