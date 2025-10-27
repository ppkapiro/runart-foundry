# CLEANUP_LEGACY_BRIEFING_REPORT — 2025-10-25T14:40Z

## Objetivo
Eliminar completamente todos los restos del Briefing viejo (legacy) del repositorio y dejar operativo únicamente el Briefing nuevo, organizado como fue definido en la reestructuración documental con interfaz en tres partes:
1. Cliente · RunArt Foundry
2. Equipo Técnico · Briefing System
3. Proyectos

---

## Acciones ejecutadas

### 1. Detención de servidor y backup temporal
- Comando: `pkill -f "mkdocs serve"` (detener instancias activas)
- Backup creado: `tmp/legacy_backup/briefing/` (copia de `_archive/legacy_removed_20251007/briefing/`)
  - Tamaño del backup: incluye mkdocs.yml, docs/, overrides/, site/ legacy

### 2. Eliminación del Briefing legacy
- Directorio eliminado: `_archive/legacy_removed_20251007/briefing/`
  - Contenía: mkdocs.yml legacy, docs/ legacy, overrides/ legacy, site/ legacy
- Archivos obsoletos fuera de apps/briefing: ninguno detectado (solo node_modules/.cache y backup temporal)

### 3. Limpieza de artefactos de build
- Eliminados de `apps/briefing/`:
  - `site/` (build previo)
  - `.cache/` (si existía)
- Propósito: regenerar desde cero con configuración limpia

### 4. Validación de unicidad de configuración
- mkdocs.yml activos en el repositorio (excluyendo backup y dependencias):
  - **ÚNICO:** `/home/pepe/work/runartfoundry/apps/briefing/mkdocs.yml`
  - Detectados en mirror/vendor: `./mirror/raw/2025-10-01/wp-content/plugins/wp-optimize/vendor/simplehtmldom/simplehtmldom/mkdocs.yml` (externo, no afecta)
  - Backup temporal: `./tmp/legacy_backup/briefing/mkdocs.yml` (respaldo, no operativo)

### 5. Reconstrucción de la documentación
- Comando: `AUTH_MODE=none make -C apps/briefing build`
- Resultado: **SUCCESS**
  - Build completado en 2.84 segundos
  - Site generado: `apps/briefing/site/`
  - Index HTML: `apps/briefing/site/index.html` (77K)
  - Warnings: enlaces relativos a `docs/live/` (esperado; fuera del scope actual)

---

## Verificación de estructura activa

### Configuración única (apps/briefing/)
- mkdocs.yml: `/home/pepe/work/runartfoundry/apps/briefing/mkdocs.yml` ✅
- docs_dir: `docs` (por defecto) ✅
- site_dir: `site` (por defecto, regenerado) ✅
- overrides activos: `overrides/main.html`, `overrides/extra.css`, `overrides/roles.js` ✅

### Estructura documental (3 partes)
1. **Cliente · RunArt Foundry**
   - Índice: `docs/client_projects/runart_foundry/index.md` ✅
   - Subsecciones: plan, auditorías, decisiones, inbox, dashboards, herramientas

2. **Equipo Técnico · Briefing System**
   - Índice: `docs/internal/briefing_system/index.md` ✅
   - Subsecciones: planes, deploy, CI/QA, guías, reportes, arquitectura, operación

3. **Proyectos**
   - Índice: `docs/projects/index.md` ✅
   - Contenido: fichas YAML (ES/EN) con esquema y plantilla

### Navegación en el HTML generado
- Verificado en `apps/briefing/site/index.html`:
  - "Cliente · RunArt Foundry" ✅ (detectado 2 veces)
  - "Equipo Técnico · Briefing System" ✅ (detectado 2 veces)
  - "Proyectos" ✅ (detectado 4 veces)

---

## Archivos eliminados (resumen)

### Directorio principal eliminado
- `_archive/legacy_removed_20251007/briefing/` (completo, con toda su estructura interna)

### Artefactos de build limpiados
- `apps/briefing/site/` (rebuild forzado)
- `apps/briefing/.cache/` (si existía)

---

## Estado final

### Estructura operativa
```
apps/briefing/
├── mkdocs.yml (ÚNICO config activo)
├── Makefile
├── requirements.txt
├── .venv/
├── docs/
│   ├── index.md (Home)
│   ├── client_projects/runart_foundry/ (Cliente)
│   ├── internal/briefing_system/ (Equipo Técnico)
│   ├── projects/ (Proyectos)
│   ├── assets/ (auth-mode.js, env-flag.js, dashboards/, etc.)
│   └── ... (otras secciones)
├── overrides/
│   ├── main.html
│   ├── extra.css
│   └── roles.js
├── scripts/
│   └── mark_internal.py
└── site/ (generado, limpio)
```

### Validación de build
- Comando: `AUTH_MODE=none make -C apps/briefing build`
- Exit code: 0 ✅
- Tiempo: 2.84s
- Warnings: solo enlaces relativos fuera del árbol docs/ (no bloqueantes)

### Navegación verificada
- Home carga correctamente
- Tres secciones principales presentes en la navegación HTML
- Overrides de roles y env banner activos
- Local Mode (AUTH_MODE=none) operativo

---

## Próximos pasos (opcional)

1. **Validación visual en servidor local:**
   ```bash
   make -C apps/briefing serve-local
   ```
   - Abrir: http://127.0.0.1:8000
   - Confirmar: navegación, UI por rol, placeholders en KPIs/Exports

2. **Eliminar backup temporal (si ya no es necesario):**
   ```bash
   rm -rf tmp/legacy_backup/
   ```

3. **Commit de limpieza:**
   ```bash
   git add -A
   git commit -m "briefing: Eliminar legacy completo y confirmar estructura nueva (3 partes)"
   ```

---

## Conclusión

✅ **Limpieza del Briefing legacy completada.**

- Solo permanece el Briefing nuevo con organización documental actualizada y navegación en tres partes:
  1. Cliente · RunArt Foundry
  2. Equipo Técnico · Briefing System
  3. Proyectos

- El repositorio ahora contiene un único `mkdocs.yml` operativo en `apps/briefing/`.
- Build limpio y sitio regenerado sin residuos legacy.
- Estructura validada y lista para desarrollo/deploy.

**Fecha de ejecución:** 2025-10-25T14:40Z  
**Rama:** feat-local-no-auth-briefing
