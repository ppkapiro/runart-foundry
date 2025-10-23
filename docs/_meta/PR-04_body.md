# PR-04 — Validadores STRICT + CI

## Qué hace
- Activa validación estricta (frontmatter, enlaces, duplicados) y la integra en CI (bloqueante).

## Reglas finales integradas
- **Frontmatter obligatorio**: status, owner, updated, audience, tags
- **Enlaces internos**: deben resolver (relativos .md)
- **Enlaces externos**: validación HTTP/HTTPS con timeout y reintentos
- **Tags únicos**: lowercase, sin duplicados, sin valores vacíos
- **Duplicados prohibidos**: no múltiples archivos con mismo nombre base en docs/live/

## Qué NO hace
- No borra legacy; solo falla si hay problemas.

## Validación esperada
- CI en verde; 0 errores strict.
