# Convenciones y Estándares (Fase B)

## Nomenclatura de ramas y PRs

- **Ramas**:
  - `feat/<módulo>-<resumen>` para nuevas funcionalidades.
  - `fix/<módulo>-<bug>` para correcciones.
  - `chore/<módulo>-<tarea>` para mantenimiento o refactors.
  - `docs/<área>-<tema>` para documentación.
- **Pull Requests**:
  - Título con formato `[<Área>] <Resumen>` (ej.: `[Apps] Modularizar briefing`).
  - Incluir checklist de regresión de CI + verificación de previews.
  - Descripción con secciones: *Contexto*, *Cambios*, *Pruebas*, *Rollback*.

## Estructura mínima por módulo

Todo módulo situado en `apps/`, `services/`, `packages/` o `tools/` debe incluir:

```
<module>/
├── README.md          # Propósito, owners, dependencias, comandos.
├── Makefile           # Targets estándar (ver abajo).
├── src/ o docs/       # Código fuente o contenido principal.
├── tests/             # Pruebas automáticas (cuando aplique).
├── contracts/         # Interfaces, esquemas, endpoints y requisitos (opcional pero recomendado).
└── .github/ (opcional) # Workflow o configuración específica si no es reusable.
```

## Targets Make comunes

Cada Makefile debe exponer los siguientes targets (no todos necesitan implementación inmediata, pero se reservan los nombres):

| Target | Descripción |
|--------|-------------|
| `install` | Instala dependencias (npm, pip, etc.). |
| `build`   | Genera artefactos listos para deploy. |
| `serve`   | Levanta entorno local (dev server, mkdocs serve, etc.). |
| `test`    | Ejecuta pruebas unitarias/integración. |
| `lint`    | Ejecuta linters/formatters. |
| `preview` | Genera build orientado a preview (si difiere de `build`). |
| `release` | Publica o empaqueta (deploy Pages, publicar paquete). |
| `clean`   | Limpia artefactos temporales. |

En caso de no aplicar (p.ej. `preview` en un paquete puro), el target debe existir y devolver un mensaje informativo + `exit 0`.

## Variables de entorno

- Prefijo obligatorio: `RUNART_` (ej.: `RUNART_ENV`, `RUNART_API_URL`).
- Documentar cada variable en `README.md` del módulo y en `docs/operations/env.md` (próxima iteración).
- Usar archivos `.env.example` cuando se necesiten valores locales.
- Evitar interpolar secretos directamente en scripts; consumir desde GitHub Actions/Pages/Workers Secrets.

## Reutilización de estilos y JS

- **Banner de entorno / UI tokens**: mover a `packages/env-banner` y `packages/ui-tokens`. Apps deben importar desde el paquete, no copiar CSS/JS localmente.
- **Componentes compartidos**: documentar en `packages/README.md` y versionar mediante `changeset` o equivalente interno.
- **Assets globales**: almacenar en `shared/assets/` con naming consistente (`env-banner.css`, `roles.js`). Apps referencian vía Make target `make sync-assets` (a definir).

## Documentación & contratos

- Cada módulo debe enlazar su documentación de contrato desde `docs/architecture/_index.md`.
- ADRs ligeros se agregan a `docs/architecture/adr/` (nueva carpeta) siguiendo convención `ADR-00X_<slug>.md`.
- Estándares se revisan trimestralmente; cambios deben venir acompañados de PR en `docs/architecture`.

Aplicar estas convenciones antes de mover código garantiza que los siguientes PRs de Fase B tengan un marco uniforme y eviten regresiones en CI/CD.
