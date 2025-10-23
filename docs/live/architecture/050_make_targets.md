---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ops]
---

# Make Targets Unificados

## Set mínimo por módulo

Todo módulo en `apps/`, `services/`, `packages/` o `tools/` debe proporcionar (como alias o implementación real) los siguientes targets:

| Target | Objetivo | Requisitos |
|--------|----------|------------|
| `install` | Instala dependencias declaradas (npm, pip, etc.). | Debe ser idempotente y soportar CI. |
| `build` | Genera artefactos listos para distribución (ej.: `site/`, `dist/`). | Debe depender de `install`. |
| `serve` | Levanta entorno de desarrollo/local preview. | Puede delegar a frameworks (`mkdocs serve`, `wrangler dev`). |
| `lint` | Ejecuta linters/formatters según stack. | Salida debe ser non-zero ante errores. |
| `test` | Corre pruebas unitarias/integración. | Debe generar reportes en `build/` o `reports/`. |
| `preview` | Prepara artefacto orientado a preview (si difiere de `build`). | Opcional (alias a `build` si no aplica). |
| `release` | Orquesta publicación (deploy, publish). | Debe ser no destructivo en local (dry-run aceptable). |
| `clean` | Elimina artefactos temporales (`build/`, `.venv`, `node_modules` opcional). | Mantener `clean` rápido (evitar borrar caches globales por default). |

### Convenciones

- Targets no implementados deben existir y mostrar mensaje informativo (`echo "No aplica"`).
- Cada target puede llamar a scripts en `tools/` o `packages/` pero no debe duplicar lógica.
- `make help` debe listar los targets disponibles (añadir pseudo-target `help`).

## Makefile raíz (estado actual)

Archivo: `/Makefile`

```makefile
.RECIPEPREFIX := >
PYTHON ?= python3
DEFAULT_MODULE ?= apps/briefing
MODULE ?= $(DEFAULT_MODULE)
APPS := apps/briefing

.PHONY: build serve preview test lint lint-docs status clean

build:
>if [ "$(ALL)" = "1" ]; then \
>  for module in $(APPS); do \
>    $(MAKE) -C $$module build || exit 1; \
>  done; \
>else \
>  $(MAKE) -C $(MODULE) build; \
>fi

serve:
>$(MAKE) -C $(MODULE) serve

lint:
>$(MAKE) lint-docs
>$(MAKE) -C $(MODULE) lint

lint-docs:
>$(PYTHON) tools/lint_docs.py

clean:
>if [ "$(ALL)" = "1" ]; then \
>  for module in $(APPS); do \
>    $(MAKE) -C $$module clean || exit 1; \
>  done; \
>else \
>  $(MAKE) -C $(MODULE) clean; \
>fi
```

- `MODULE` apunta por defecto a `apps/briefing`; `ALL=1` itera sobre todos los módulos listados en `APPS`.
- `lint` ejecuta primero `lint-docs` (tool compartido) y después delega en el módulo.
- `preview` está documentado en `docs/architecture/065_switch_pages.md` como control manual.
- `status` imprime el extracto de `STATUS.md` para auditoría ejecutiva.
- A medida que aparezcan nuevos módulos se agregarán a `APPS` o se parametrizará por tipo (apps/services/packages).

## Tabla de compatibilidad actual

| Módulo | install | build | serve | lint | test | preview | release |
|--------|---------|-------|-------|------|------|---------|---------|
| `apps/briefing` | ⚠️ (`make venv` cumple rol, falta alias `install`) | ✅ (`make build`) | ✅ (`make serve`) | ⚠️ (`make lint` ejecuta placeholder + `lint-docs`) | ✅ (`make test` → `test-env`, `test-logs`) | ⚠️ (placeholder documentado, sin acción automática) | ⚠️ (deploy manual vía CI/Pages) |
| `briefing` (compat) | ⚠️ (delegado a `apps/briefing`) | ✅ (wrapper) | ✅ (wrapper) | ⚠️ (delegado) | ✅ (delegado) | ⚠️ (placeholder) | ⚠️ (delegado) |
| `tools` | ❌ (pendiente definir `install`) | ❌ | ❌ | ⚠️ (`make lint-docs` desde raíz consume herramientas) | ⚠️ (scripts individuales, sin target) | ❌ | ❌ |
| `audits` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `assets` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

`services/` y `packages/` aún no contienen módulos activos; se documentarán en esta tabla cuando entren en operación.

Leyenda:
- ✅ Implementado.
- ⚠️ Parcial / requiere alias.
- ❌ No disponible (debe añadirse durante migración).

## Próximos pasos

1. Extender `apps/briefing/Makefile` con alias `install`, `release` y lint específicos a medida que surjan activos (CSS/JS, Workers).
2. Formalizar Makefile para `tools/` (p. ej. `make install`, `make test`) y mover scripts top-level que cumplen criterios de reutilización.
3. Añadir módulos pilotos en `services/` y/o `packages/` con el set mínimo de targets.
4. Actualizar workflows (`ci.yml`, `briefing_deploy.yml`) para consumir `make install/build/lint/test` homogéneos.

Este set de targets será la base para integrar los workflows reusables definidos en 040_ci_shared.md.
