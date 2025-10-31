---
title: Guía de Estructura del Proyecto RunArt Foundry
---
# Guía de Estructura del Proyecto — RunArt Foundry

**Última actualización:** 2025-10-08  
**Fuente maestra:** `docs/proyecto_estructura_y_gobernanza.md` (repositorio raíz)

## Propósito
Proveer a Copilot y al equipo operativo una vista resumida de la organización del monorepo RunArt Foundry, destacando rutas críticas, reglas de ubicación y buenas prácticas al crear o modificar archivos. Esta guía se consulta junto con el [Plan Estratégico de Consolidación](../plans/Plan_Estrategico_Consolidacion_Runart_Briefing.md) antes de iniciar cualquier fase.

## Mapa rápido del monorepo
| Módulo | Descripción | Rutas clave | Owner principal |
| --- | --- | --- | --- |
| `apps/briefing/` | Micrositio interno (MkDocs + Cloudflare Pages + Access). | `docs/`, `functions/`, `guides/`, `templates/`, `_reports/` | Project Manager + Copilot |
| `audits/` | Auditorías técnicas/SEO/estructura del sitio cliente. | `_structure/`, `reports/`, `inventory/`, `docs_lint.log` | Equipo ARQ |
| `mirror/` | Snapshots del sitio del cliente (referencia, *no subir binarios pesados*). | `raw/`, `normalized/`, `scripts/` | Equipo infra |
| `docs/` | Documentación global y gobernanza. | `proyecto_estructura_y_gobernanza.md`, `README.md` | Gobernanza (Reinaldo) |
| `scripts/` | Scripts globales de auditoría y soporte. | `validate_structure.sh`, `fase3_auditoria.sh` | Equipo ARQ |
| `tools/` | Utilidades Python (checks, diffs, listados). | `check_env.py`, `lint_docs.py` | Copilot + QA |

> Las rutas antiguas bajo `briefing/` sin `apps/` viven ahora en `_archive/legacy_removed_20251007/briefing/` para referencia histórica.

## Referencias esenciales
- **Gobernanza:** consultar `docs/proyecto_estructura_y_gobernanza.md` (documento maestro en raíz).
- **Bitácora activa:** [`ci/082_reestructuracion_local.md`](../ci/082_reestructuracion_local.md) (contexto de reorganización 2025-10-07/08).
- **Plan maestro:** [`plans/Plan_Estrategico_Consolidacion_Runart_Briefing.md`](../plans/Plan_Estrategico_Consolidacion_Runart_Briefing.md).

### Roles de Access (corte 2025-10-09)
- **owner:** `ppcapiro@gmail.com`
- **clients:** `runartfoundry@gmail.com`, `musicmanagercuba@gmail.com`
- **team:** `infonetwokmedia@gmail.com`
- **visitor:** cualquier correo fuera de los listados anteriores (rol por defecto)

## Reglas rápidas de colocación
1. **Documentación interna de Briefing:** dentro de `apps/briefing/docs/internal/briefing_system/` siguiendo subcarpetas (`guides/`, `templates/`, `reports/`, `plans/`, `archives/`).
2. **Reportes operativos:**
   - Briefing → `apps/briefing/docs/internal/briefing_system/reports/` o `apps/briefing/_reports/` según audiencia.
   - Auditorías → `audits/reports/`.
3. **Logs y artefactos temporales:** nunca versionados; se guardan en `_logs/`, `_tmp/` o `archives/` y se referencian desde los reportes.
4. **Código y funciones:** Pages Functions bajo `apps/briefing/functions/api/`; cualquier middleware relacionado va a `apps/briefing/functions/_middleware.js`.
5. **Plantillas:** vivirán en `apps/briefing/docs/internal/briefing_system/templates/` y se instancian en subcarpetas (`templates/instancias/`).
6. **Archivos >25 MB o credenciales:** prohibido subirlos. Usar `.gitignore` + storage externo.

## Convenciones de nombres
- **Reportes:** `YYYY-MM-DD_descripcion.md` (ej: `2025-10-08_cierre_fase1.md`).
- **Tareas por fase:** `F#_<tema>.md` (ej: `F2_normalizacion_roles.md`).
- **Branches Git:** `tipo/descripcion-kebab-case` (`feature/roles-access`, `docs/actualizar-guia-qa`).
- **Commits:** `<modulo>: <acción>` (`apps/briefing: crear plantilla reporte`).

## Checklist de ubicación antes de comitear
- [ ] El archivo nuevo está en la carpeta prevista (ver tabla de módulos).
- [ ] Si es documentación, enlaza a referencias relevantes con rutas relativas.
- [ ] Si es reporte/artefacto grande, está comprimido o referenciado en `archives/`.
- [ ] `validate_structure.sh --staged-only` pasa sin alertas relacionadas a rutas prohibidas.
- [ ] `mkdocs build --strict` no muestra enlaces rotos derivados del archivo.

## Flujo de alta de nuevo documento en Briefing
1. **Definir audiencia:** Cliente (`docs/client_projects/`) vs Equipo (`docs/internal/`).
2. **Seleccionar carpeta:** dentro de `internal/briefing_system/` elegir subcarpeta adecuada (plan, guía, plantilla, reporte o archivo histórico).
3. **Crear archivo base:** usar plantillas existentes cuando aplique (`templates/`, `reports/`).
4. **Actualizar enlaces cruzados:**
   - Agregar referencia en índice correspondiente (por ejemplo, `internal/briefing_system/index.md`).
   - Registrar en bitácora 082 si impacta reorganización.
5. **Ejecutar QA documental:** `make lint-docs` y `mkdocs build --strict`.
6. **Documentar en reporte de avance:** enlazar el nuevo archivo y resultados de QA.

## Responsabilidades por carpetas
| Carpeta | Responsable de contenido | Revisión cruzada |
| --- | --- | --- |
| `apps/briefing/docs/internal/briefing_system/guides/` | Copilot + QA | Project Manager |
| `apps/briefing/docs/internal/briefing_system/templates/` | Copilot | QA (para coherencia) |
| `apps/briefing/docs/internal/briefing_system/reports/` | Project Manager | Stakeholder (según fase) |
| `apps/briefing/docs/internal/briefing_system/archives/` | Copilot (custodio) | Gobernanza |
| `audits/` | Equipo ARQ | Copilot (cuando impacta briefing) |

## Compatibilidad con IA y tareas futuras
- Los archivos de guía y plantillas están diseñados para que Copilot los consuma como "prompt base" antes de ejecutar nuevas tareas.
- Mantener las guías actualizadas garantiza que cualquier nuevo ciclo pueda reiniciarse sin pérdida de contexto (principio de "cierre modular").
- Cuando se detecte divergencia entre la estructura real y la documentada, registrar incidencia en `ci/` y actualizar tanto esta guía como el documento maestro de gobernanza.

## Próximas revisiones sugeridas
- **Tras Fase 2:** confirmar que `apps/briefing/functions/` y `access/` reflejen la nueva lógica de roles.
- **Tras Fase 3:** agregar ejemplos de políticas Access y dashboards a esta guía.
- **Tras Fase 4:** mover artefactos de cierre a `archives/` y documentar rutas definitivas.

---
**Historial del documento**
- 2025-10-08 · Versión inicial por Copilot (alineada al documento maestro de gobernanza).
