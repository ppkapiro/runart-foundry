# Gobernanza documental (RunArt Foundry / Briefing)

> Placeholder inicial — Fase 1 (preparar terreno)

Esta guía define reglas mínimas para mantener la documentación ordenada bajo el modelo de tres capas: `live/`, `archive/`, `_meta/`.

## Objetivos
- Claridad entre contenido vigente vs histórico.
- Trazabilidad y audiencias claras.
- Estandarización (naming, frontmatter, revisiones).

## Capas
- `docs/live/`: Contenido vigente, referenciado por operaciones y producto.
- `docs/archive/`: Histórico estable, solo lectura salvo correcciones menores.
- `docs/_meta/`: Reglas, plantillas, resúmenes de fase, inventarios.

## Naming y convenciones
- Fechas: `YYYY-MM-DD` para documentos cronológicos (ej.: `2025-10-23_resumen.md`).
- Fases: prefijo `F#_` cuando aplique (ej.: `F7_*`).
- Idioma: sufijos `-es`/`-en` solo si coexisten versiones paralelas.
- Evitar espacios; usar `_` o `-` de forma consistente.

## Frontmatter requerido
Todos los documentos deben incluir el frontmatter definido en `_meta/frontmatter_template.md`.

Campos mínimos: `status`, `owner`, `updated`, `audience`, `tags`.

## Ciclo de vida documental (borrador)
- Draft → Active → Stale → Archived/Deprecated.
- Revisión mínima trimestral de `live/`.
- Movimiento a `archive/` tras cierre de fase o desuso.

## Audiencias
- `internal`: equipo técnico/ops.
- `external`: stakeholders externos (si aplica).

## Roles y responsabilidades
- Owner por documento (campo `owner`).
- PR de cambios en docs debe asignar revisor de gobernanza.

## TODO
- Completar RACI de documentación.
- Definir etiquetas/boards para flujos de revisión.
- Integrar validaciones en CI (lint de frontmatter, enlaces, orfandad).
 - Documentar proceso de “Curaduría Activa” (PR-03): consolidación en `docs/live/`, archivado en `docs/archive/` y validadores en modo soft.
