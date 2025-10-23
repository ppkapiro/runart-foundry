# PR-04 — Validadores STRICT + CI

## Qué hace
- Activa validación estricta (frontmatter, enlaces, duplicados) y la integra en CI (bloqueante).

## Qué NO hace
- No borra legacy; solo falla si hay problemas.

## Validación esperada
- CI en verde; 0 errores strict.
