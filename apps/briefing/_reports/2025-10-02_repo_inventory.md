# Inventario del Repositorio — 2 de octubre de 2025

> **Fase 0 / Verificación total.** Punto de verdad para preparar la interfase **GRIFFIN**.

## 🧭 Meta rápida
- Timestamp: 2025-10-02 (auto-generado 18:27:15 UTC)
- Rama analizada: `main`
- Commit HEAD: `90ff6d5d7b2e6adfa22073be39fc59e2b27ae945`
- Total de archivos escaneados: **28 068**
- Tamaño total del working tree: **923 MB**
- Artefacto JSON asociado: [`audits/reports/2025-10-02_repo_inventory.json`](../../audits/reports/2025-10-02_repo_inventory.json)

## 🏗️ Estructura & tamaños
### Resumen por módulo (nivel 1)
| Módulo | Tamaño | % del repo | Archivos |
| --- | --- | --- | --- |
| `mirror/` | 728.21 MB | 78.90% | 12 535 |
| `.tools/` | 189.26 MB | 20.50% | 15 432 |
| `audits/` | 5.22 MB | 0.57% | 43 |
| `briefing/` | 196.72 KB | 0.02% | 36 |
| `docs/` | 47.97 KB | 0.01% | 4 |

> **Hallazgo**: El 99.4% del peso está concentrado en dos módulos: `mirror/raw/2025-10-01/` (snapshot WordPress) y `.tools/node_modules/` (lighthouse/axe).

### Directorios más pesados (nivel 2)
| Directorio | Tamaño | % del repo |
| --- | --- | --- |
| `mirror/raw/` | 728.20 MB | 78.89% |
| `.tools/node_modules/` | 189.13 MB | 20.49% |
| `audits/_structure/` | 5.09 MB | 0.55% |
| `audits/reports/` | 92.03 KB | 0.01% |
| `briefing/_logs/` | 93.73 KB | 0.01% |

### Archivos individuales más pesados
| Archivo | Tamaño | Origen |
| --- | --- | --- |
| `.tools/node_modules/chromedriver/lib/chromedriver/chromedriver` | 17.38 MB | Tooling (Chromedriver) |
| `.tools/node_modules/selenium-webdriver/bin/macos/selenium-manager` | 7.71 MB | Tooling |
| `.tools/node_modules/selenium-webdriver/bin/linux/selenium-manager` | 5.15 MB | Tooling |
| `mirror/raw/2025-10-01/wp-content/uploads/2015/06/IMG_5994.jpg` | 4.95 MB | WordPress uploads |
| `.tools/node_modules/third-party-web/dist/domain-map.csv` | 4.42 MB | Lighthouse dataset |
| `.tools/node_modules/chromium-bidi/lib/iife/mapperTab.js.map` | 3.99 MB | Tooling |
| `.tools/node_modules/selenium-webdriver/bin/windows/selenium-manager.exe` | 3.51 MB | Tooling |
| `mirror/raw/2025-10-01/wp-content/uploads/2015/09/20150708_115725-e1446218438917.jpg` | 2.91 MB | WordPress uploads |

### Extensiones dominantes
- **Por cantidad**: `.js` (21.1%), `.jpg` (20.0%), `.ts` (16.2%), `.map` (12.1%), `.php` (8.8%).
- **Por peso**: `.jpg` (370 MB, 40.2%), `.png` (198 MB, 21.5%), `.js` (52 MB), `.map` (34 MB), `.json` (33 MB).

## 🔌 Módulos clave
- **Mirror (`mirror/raw/2025-10-01/`):** Snapshot WordPress con 759 MB de `wp-content` (imágenes sin optimizar, plugins, themes).
- **Tooling (`.tools/`):** Dependencias npm para Lighthouse/Axe/Puppeteer. Se recomienda mantenerlo fuera del repositorio remoto (YA ignorado).
- **Audits (`audits/`):** Reportes estratégicos y técnicos (`reports/`), métricas SEO (`seo/`), inventarios (`inventory/`).
- **Briefing (`briefing/`):** Micrositio MkDocs + Cloudflare Pages con Pages Functions (`functions/api/*`).
- **Scripts (`scripts/` y `audits/scripts/`):** Automatización (`validate_structure.sh`, `fase3_auditoria.sh`, `generar_informes_maestros.sh`).

## 🛠️ Sistemas operativos
### MkDocs (Briefing)
- Configuración: `briefing/mkdocs.yml`
- `site_name`: **RUN Art Foundry — Briefing Privado**
- Navegación top-level (10 entradas): Inicio, Plan & Roadmap, Fases, Auditoría, Proceso, Decisiones, Galería, Inbox (Decisiones), Acerca, Smoke Test.
- Tema: Material; features activas (`navigation.sections`, `navigation.expand`, `content.code.copy`, `content.action.edit`, `search.suggest`).

### Cloudflare Pages & Workers
- Config: `briefing/wrangler.toml`
- Proyecto: `runart-briefing`
- `pages_build_output_dir`: `site`
- KV Namespace `DECISIONES` (prod + preview) listo para Pages Functions (`briefing/functions/api/*`).

### GitHub Workflows
| Workflow | Archivo | Alcance |
| --- | --- | --- |
| **Briefing — Deploy to Cloudflare Pages** | `.github/workflows/briefing_deploy.yml` | Build MkDocs (`briefing/`) y deploy vía `cloudflare/pages-action@v1` (push/PR a `main`). |
| **Structure & Governance Guard** | `.github/workflows/structure-guard.yml` | Ejecuta `scripts/validate_structure.sh` en pushes/PRs a `main`.

## 🧩 Inventario WordPress (mirror)
### Plugins activos
AddToAny Share Buttons, GP Premium, Justified Gallery, Portfolio Post Type, SiteOrigin Panels & Widgets Bundle, Yoast SEO, WP Fastest Cache, WP-Optimize.

### Temas instalados
GeneratePress 3.5.1 (activo), GeneratePress Child 0.1, Twenty Twenty-Five 1.2, Twenty Twenty-Four 1.3.

### Imágenes & SEO
- **Imágenes >500 KB:** 189 (`audits/inventory/2025-10-01_imagenes_pesadas.txt`).
- **Páginas sin meta description:** 6 (`audits/seo/2025-10-01_sin_meta_description.txt`).
- **Extensiones pesadas:** `.jpg` y `.png` representan el 61.6% del peso total.

## ✅ TODOs críticos para cerrar Fase 0 → GRIFFIN
| Prioridad | Acción | Fuente |
| --- | --- | --- |
| 🔴 Alta | Optimizar 189 imágenes >500 KB (`mirror/wp-content/uploads/…`). | JSON `todos[0]` + `audits/inventory/2025-10-01_imagenes_pesadas.txt` |
| 🔴 Alta | Completar meta descriptions en 6 páginas estáticas. | `audits/seo/2025-10-01_sin_meta_description.txt` |
| 🟠 Media | Activar Cloudflare Access y documentar configuración final. | `briefing/_reports/cloudflare_access_plan.md` |
| 🟠 Media | Integrar `scripts/validate_structure.sh` en pipelines operativos. | `.github/workflows/structure-guard.yml` |
| 🟢 Baja | Externalizar `mirror/raw/wp-content` (>700 MB) o documentar exclusiones R2/S3. | `docs/proyecto_estructura_y_gobernanza.md` |

## 🔗 Enlaces útiles
- Reporte JSON para dashboards: [`audits/reports/2025-10-02_repo_inventory.json`](../../audits/reports/2025-10-02_repo_inventory.json)
- Gobernanza y estructura: [`docs/proyecto_estructura_y_gobernanza.md`](../../docs/proyecto_estructura_y_gobernanza.md)
- Auditoría integral (contexto 2025-10-01): [`audits/reports/2025-10-01_auditoria_integral.md`](../../audits/reports/2025-10-01_auditoria_integral.md)
- Scripts operativos: [`scripts/validate_structure.sh`](../../scripts/validate_structure.sh), [`scripts/fase3_auditoria.sh`](../../scripts/fase3_auditoria.sh)
- Briefing Cloudflare Access: [`briefing/_reports/cloudflare_access_audit.md`](./cloudflare_access_audit.md), [`briefing/_reports/cloudflare_access_plan.md`](./cloudflare_access_plan.md)

---
**Siguiente paso:** usar este inventario como input de la interfase **GRIFFIN** y coordinar acciones de optimización (imágenes, SEO, Access) antes de avanzar a Fase 1.
