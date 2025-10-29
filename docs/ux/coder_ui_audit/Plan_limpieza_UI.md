# Plan de limpieza UI — Minimalista (POC local)

## Fase 0 · Preparación
- Rama local creada: `feat/ui-minimal-poc`.
- Snapshot de métricas (paleta, fuentes, sombras) referenciando:
  - `REPORT_UI_MINIMALISTA.md`
  - `tokens_detectados.json`
  - `site_map_local.md`
- Instrumentación pendiente: script local para contar tokens por archivo antes/después.

## Quick wins (0–2 h)
| Paso | Descripción | Estado | Validación |
|------|-------------|--------|------------|
| Fuentes | Restringir a Inter + JetBrains Mono en `mkdocs.yml`/`overrides/main.html` (eliminar Playfair, Roboto). *Solo plan, no aplicado.* | ▶️ | Verificar carga con `mkdocs serve`. |
| Botones globales | Redefinir estilos primario/ghost usando tokens (sin `box-shadow` ni `transform` agresivo). *Implementar en rama futura.* | ▶️ | Inspeccionar `poc-btn-*` en laboratorio. |
| Env banner | Variar a versión neutral (`.poc-env-banner`) con tokens. *Prototipo en POC.* | ✅ | Revisar en `minimal_poc.md`. |

## Corto plazo (1–2 días)
- Crear `apps/briefing/docs/assets/theme/tokens.css` real (después del POC).  
- Homologar tarjetas (`.md-content` blocks, `.ui-card`, `.ra-dash__card`, `.editor-section`) con borde + padding tokens.  
- Reubicar view-as y userbar al header con estilo unificado.  
- Actualizar documentación de tokens en `docs/internal/briefing_system/ui`.

## Sprint base
- Refactor dashboards/editor eliminando gradientes y sombras intensas; sustitución por tokens.  
- Implementar modo oscuro token-driven (switch de superficie/contraste).  
- Desactivar overlays redundantes (env-banner fixed, view-as flotante) a favor de componentes persistentes.  
- Automatizar detección de tokens no autorizados (script CI).

## Riesgos y rollback
- **Riesgo:** ruptura visual en producción si se mezclan tokens nuevos con estilos legacy.  
  - *Mitigación:* aplicar cambios en ramas aisladas; usar feature flags y validaciones `mkdocs serve`.  
- **Riesgo:** pérdida de contraste al reducir sombras/colores.  
  - *Mitigación:* checklist AA/AAA y pruebas manuales en `minimal_poc.md`.  
- **Rollback:** mantener copias de `extra.css` actuales; revertir merges si los tokens generan regresiones.  
- **Orden de merge futuro:** primero tokens centrales → botones/env-banner → tarjetas/dashboards → modo oscuro → limpieza de overlays.

## Matriz de cambios
| Cambio | Impacto | Esfuerzo | Riesgo | Validación |
|--------|---------|----------|--------|-----------|
| Tokens globales (`tokens.css`) | Alto (base de diseño) | Medio | Medio | Revisar `mkdocs serve` + lint de tokens. |
| Fuentes simplificadas | Medio | Bajo | Bajo | Verificar carga en dev tools. |
| Botones sin sombras | Medio | Bajo | Medio | QA visual + tests de foco. |
| Env banner neutral | Bajo | Bajo | Bajo | Vista `minimal_poc.md`. |
| Tarjetas homologadas | Alto | Medio | Medio | Revisar dashboards y docs. |
| View-as/userbar al header | Alto | Alto | Alto | Navegación manual + QA accesibilidad. |
| Modo oscuro token-driven | Alto | Alto | Alto | Validación en `mkdocs serve` (light/dark). |
