---
generated_by: copilot
phase: pr-02-root-alignment
date: 2025-10-23T00:00:00-04:00
repo: runart-foundry
branch: feature/pr-02-root-alignment
---

# PR-02 — Root Alignment (roles y enlaces canónicos)

## Objetivo
Alinear los documentos de raíz del repositorio con la fuente canónica docs/live/, definiendo roles y enlaces sin mover todavía ningún archivo.

## Documentos de raíz a evaluar
1. README.md  
2. STATUS.md  
3. NEXT_PHASE.md  
4. CHANGELOG.md  

## Rol propuesto para cada uno
- **README.md** → Portada del repositorio.  
  Rol: presentación general y enlace directo a docs/live/index.md.  
- **STATUS.md** → Tablero vivo o estado operativo.  
  Rol: migrar o duplicar a docs/live/operations/status_overview.md (manteniendo el original con enlace).  
- **NEXT_PHASE.md** → Plan operativo o roadmap técnico.  
  Rol: integrar a docs/live/operations/roadmap.md o a un workflow de releases.  
- **CHANGELOG.md** → Registro formal de cambios.  
  Rol: mantener en raíz y enlazar desde docs/live/index.md.

## Acciones planeadas
1. Crear enlaces canónicos bidireccionales (docs/live ↔ raíz).  
2. Estandarizar secciones iniciales (frontmatter + bloque meta) en estos archivos.  
3. Validar referencias existentes (por ejemplo, a `docs/status.json` o a bitácoras).  
4. Alinear naming y estructura de enlaces para integrarse con Briefing.  

## Consideraciones
- No tocar todavía el contenido original de los archivos.  
- Documentar dependencias detectadas (issues, pipelines, workflows).  
- Registrar riesgos o duplicaciones.

## Criterios de aceptación
- Plan documentado y checklist validado.  
- Ningún cambio directo en archivos raíz.  
- Listos los pasos exactos para ejecutar PR-02 real (implementación).  