# 01 · Estructura del Repositorio

**Fecha:** 2025-10-29  
**Rama:** `feat/content-audit-v1`  
**Propósito:** Documentar árbol de carpetas del repositorio local RunArt Foundry

---

## Resumen Ejecutivo

El repositorio contiene **98 directorios principales** organizados en 6 categorías:
- **Tema WordPress:** `wp-content/themes/runart-base/` (14 plantillas PHP)
- **Biblioteca de medios:** `content/media/` (6,162 imágenes catalogadas)
- **Documentación:** `docs/` y `_reports/` (43 subdirectorios)
- **Herramientas:** `tools/`, `scripts/`, `apps/` (automatización y briefing)
- **Artefactos:** `_artifacts/`, `_dist/`, `_tmp/` (entregas y temporal)
- **Tests/CI:** `tests/`, `audits/`, `ci_artifacts/`

---

## Árbol de Directorios Principales

### wp-content/themes/runart-base/
```
runart-base/
├── assets/
│   ├── css/
│   │   └── responsive.overrides.css  (v0.3.1.3, 8,694 bytes)
│   └── js/
│       ├── custom.js
│       ├── navigation.js
│       └── responsive.fixes.js
├── languages/
│   ├── en_US.po
│   ├── es_ES.po
│   └── runart-base.pot
└── [14 plantillas PHP]:
    - front-page.php (Home)
    - page-about.php, page-blog.php, page-contact.php, page-home.php
    - archive-project.php, archive-service.php, archive-testimonial.php
    - single-project.php, single-service.php, single-testimonial.php
    - header.php, footer.php, index.php, page.php
```

### content/media/
```
media/
├── library/          (VACÍO - imágenes originales pendientes)
├── variants/         (6,162 imágenes con variantes WebP/AVIF)
│   └── [IDs de imagen]/
│       ├── webp/  (w2560, w1600, w1200, w800, w400)
│       └── avif/  (w2560, w1600, w1200, w800, w400)
├── exports/          (.gitkeep - vacío)
├── media-index.json  (343,841 líneas, índice completo)
├── media_manifest.json
└── association_rules.yaml
```

### docs/ (Documentación arquitectónica)
```
docs/
├── _artifacts/
│   ├── chrome_overflow_audit_results.json
│   ├── lighthouse/
│   └── screenshots_*/
├── architecture/
│   ├── deployment/
│   ├── plugin_interfaces/
│   └── theme_responsive/
├── ci/
├── ops/
├── ui_roles/
└── [Manifiestos, deployment logs, briefings]
```

### _reports/ (Informes de fase)
```
_reports/
├── FASE10_CIERRE_EJECUTIVO.md
├── FASE11_CIERRE_EJECUTIVO.md
├── FASE7_SUMMARY_FINAL_20251020.md
├── CHROME_OVERFLOW_AUDIT.md
├── ESTADO_FINAL_TRADUCCION_20251027.md
├── FORMULARIOS_COMPLETADOS_20251027.md
└── [43 reportes más de auditorías y fases]
```

### tools/ (Scripts de deployment y auditoría)
```
tools/
├── deploy_wp_ssh.sh
├── chrome_overflow_audit.js
├── find_horizontal_overflow.js
├── capture_header_screens.js
├── fase7_collect_evidence.sh
├── fase7_process_evidence.py
├── ionos_create_staging.sh
├── staging_isolation_audit.sh
├── repair_auto_prod_staging.sh
├── repair_final_prod_staging.sh
└── repair_autodetect_prod_staging.sh
```

### apps/ (Briefings y specs)
```
apps/
├── briefing/
│   ├── runartfoundry_briefing_2025_06_18.md
│   └── Project_Status_Update_2025_08_09.md
└── runmedia/  (Pendiente integración)
```

---

## Archivos de Configuración Clave

| Archivo | Propósito | Estado |
|---------|-----------|--------|
| `package.json` | Dependencias Node.js (Puppeteer, auditorías) | ✅ |
| `requirements.txt` | Dependencias Python (Flask, RunMedia) | ✅ |
| `Makefile` | Comandos de build y deployment | ✅ |
| `wp-content/themes/runart-base/functions.php` | Enqueue CSS v0.3.1.3, Polylang, RunMedia | ✅ |
| `wp-content/themes/runart-base/style.css` | Header de tema (version 0.3.1) | ✅ |

---

## Hallazgos Críticos

1. **Biblioteca de medios vacía:** `content/media/library/` está vacío, pero `media-index.json` tiene 6,162 imágenes catalogadas con rutas relativas a `mirror/raw/2025-10-01/` (estructura histórica).

2. **Textos hardcodeados:** Las plantillas PHP contienen arrays bilingües ES/EN hardcodeados, no usan archivos `.po` de traducción.

3. **14 plantillas identificadas:**
   - **Páginas estáticas:** `front-page.php`, `page-about.php`, `page-blog.php`, `page-contact.php`, `page-home.php`, `page.php`
   - **Archivos:** `archive-project.php`, `archive-service.php`, `archive-testimonial.php`
   - **Singles:** `single-project.php`, `single-service.php`, `single-testimonial.php`
   - **Core:** `header.php`, `footer.php`, `index.php`

4. **Deployment tools completos:** Scripts para SSH deployment, auditorías de overflow, snapshots de header, reparación automática de prod/staging.

5. **Documentación exhaustiva:** 43 reportes de fase, 98 directorios de arquitectura y operaciones.

---

## Estadísticas

- **Total de directorios:** 98
- **Plantillas PHP:** 14
- **Imágenes catalogadas:** 6,162 (variantes WebP/AVIF)
- **CSS principal:** 8,694 bytes (v0.3.1.3)
- **Archivos JS:** 3 (navigation, responsive fixes, custom)
- **Archivos de traducción:** 3 (en_US.po, es_ES.po, .pot)
- **Scripts de deployment:** 11
- **Reportes de fase:** 43+

---

## Próximos Pasos (ver 06_next_steps.md)

1. Poblar `content/media/library/` con imágenes originales
2. Migrar textos hardcodeados a archivos `.po` de Polylang
3. Integrar RunMedia para gestión de imágenes
4. Normalizar rutas de imágenes (eliminar dependencia de `mirror/raw/`)
5. Documentar custom post types (project, service, testimonial)
