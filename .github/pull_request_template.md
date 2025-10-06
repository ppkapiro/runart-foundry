## ¿Qué cambia?

<!-- Resume brevemente el alcance del PR y módulos tocados. Usa viñetas si hay múltiples piezas. -->

## Checklist rápida

- [ ] Build local ejecutado sobre el módulo principal (`make build MODULE=apps/briefing` u otro).
- [ ] Compat layer `briefing/` verificada cuando se toquen wrappers (build delega correctamente).
- [ ] Preview validada (Cloudflare Pages/Workers) y comportamiento acorde al entorno (`make test-env-*`).
- [ ] Documentación/065 actualizada o confirmada innecesaria.
- [ ] Tests / linters relevantes ejecutados (`make lint`, `make lint-docs`, etc.).

## Checks esperados de CI (docs-lint, env-report, status-update)

- [ ] Check “Docs Lint” en verde o con notas de follow-up.
- [ ] Comentario `ENV CHECK PASSED — env=preview` presente en la PR.
- [ ] `status-update` sin acciones pendientes (solo aplica tras merge a `main`).

## Impacto en Arquitectura

<!-- Referencia documentos en docs/architecture/XXX si este PR suma, modifica o depende de ellos. -->

## Riesgos

<!-- Enumera riesgos conocidos y su probabilidad. Si corresponde, enlaza entradas en docs/architecture/070_risks.md. -->

## Plan de rollback

<!-- Explica cómo revertir el cambio de forma segura y qué validaciones hacer tras el rollback. Considera el plan en docs/architecture/065_switch_pages.md si aplica. -->
