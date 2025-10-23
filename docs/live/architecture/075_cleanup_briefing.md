---
status: active
owner: reinaldo.capiro
updated: 2025-10-23
audience: internal
tags: [briefing, runart, ops]
---

# Limpieza post-switch de la capa `briefing/`

## Objetivo

Retirar la capa de compatibilidad `briefing/` una vez que el despliegue de Cloudflare Pages opere exclusivamente contra `apps/briefing` y las validaciones de producción hayan permanecido estables. El objetivo es simplificar el árbol del monorepo, eliminar duplicidad de configuraciones y reducir el mantenimiento de workflows heredados.

## Ventana y criterios previos (F+1)

- ✅ `Docs` y `CHANGELOG` reflejan que el switch se ejecutó (ver `docs/architecture/065_switch_pages.md`).
- ✅ Previews y producción llevan ≥48 h sin desviaciones registradas en `_reports/` ni incidentes abiertos.
- ✅ `audits/2025-10-06_cloudflare_switch/` contiene logs completos de smoke tests y un README con los timestamps clave.
- ✅ `STATUS.md` marca `apps/briefing` en 🟢 y documenta el enlace a la auditoría del switch.
- ⚠️ No debe existir ninguna PR abierta apuntando a `briefing/` ni workflows monitorizando ese directorio.

## Checklist previa a la limpieza

1. Ejecutar `make lint-docs` y `make test-env` para asegurar que el árbol `apps/briefing` continúa consistente.
2. Comparar artefactos: `diff -qr briefing/site apps/briefing/site` (debe ser idéntico o con diferencias esperadas documentadas en la auditoría).
3. Confirmar que los workflows (`ci.yml`, `briefing_deploy.yml`, `promote_inbox_*`) ya consumen rutas `apps/briefing/**`.
4. Validar que no existan referencias nuevas a `briefing/` en la última semana (`git log --since=7.days --stat | grep briefing/`).
5. Notificar en Slack el inicio de la ventana de limpieza y congelar merges relacionados con briefing hasta terminar.

## Ejecución (rama `cleanup/remove-briefing-compat`)

| Paso | Acción | Archivo/directorio | Notas |
|------|--------|--------------------|-------|
| 1 | Eliminar el directorio `briefing/` completo | `briefing/` | Borrar README, Makefile, `mkdocs.yml`, `site/` y restos `_tmp/`. |
| 2 | Actualizar el `Makefile` raíz | `Makefile` | Eliminar referencias a `DEFAULT_MODULE=apps/briefing` que contemplen fallback `briefing/`; mantener `apps/briefing` como único módulo. |
| 3 | Ajustar workflows | `.github/workflows/**` | Remover paths `briefing/**`, carpetas temporales `briefing/_tmp`, mensajes que mencionan `briefing/`. |
| 4 | Limpiar scripts auxiliares | `scripts/**`, `tools/**` | Sustituir rutas hardcodeadas (`briefing/site`) por `apps/briefing/site` o variables `MODULE`. |
| 5 | Actualizar documentación | `README.md`, `STATUS.md`, `docs/architecture/` | Eliminar referencias a la capa de compatibilidad y añadir nota de cierre en `CHANGELOG`. |
| 6 | Regenerar auditoría | `audits/2025-10-08_briefing_cleanup/` | Capturar comandos de validación, diffs y smoke tests post-limpieza (ver estructura sugerida abajo). |
| 7 | Ejecutar validaciones finales | — | `make clean`, `make build`, `make lint-docs`, `make test-env`, `make test-env-preview PREVIEW_URL=...`. |

## Validaciones post-limpieza

- `make lint-docs` y `make build` pasan sin referencias faltantes.
- `tools/check_env.py` registra `source=apps/briefing` en `audits/env_check.log` sin warnings.
- Workflows de CI/CD se ejecutan sin intentar acceder a `briefing/` (ver logs de GitHub Actions).
- `apps/briefing/site` se publica correctamente en Cloudflare Pages (preview y producción) y smoke tests (`smoke_arq3.sh`, `smoke_exports.sh`) permanecen verdes.
- `git grep "briefing/"` sólo devuelve entradas históricas (e.g., en changelog) o rutas deliberadas en `audits/_structure/`.

## Estructura de auditoría recomendada

Crear la carpeta `audits/2025-10-08_briefing_cleanup/` con:

```
README.md              # Bitácora con tiempos, responsables y resultado
commands.log           # Salida de make build / lint-docs / test-env
smokes/
  smoke_arq3.log
  smoke_exports.log
artifact_diff.txt      # Resultado actualizado de diff -qr apps/briefing/site vs deploy
ci_summary.md          # Enlaces a los runs de GitHub Actions relevantes
```

Añadir la plantilla correspondiente en `audits/_structure/2025-10-08_briefing_cleanup.txt` (ver sección Proyectos de auditoría).

## Comunicación y documentación

- Actualizar `STATUS.md` (Últimos hitos) con la finalización de la limpieza y enlazar la auditoría.
- Añadir entrada en `CHANGELOG.md` bajo la versión/iteración en curso (`Removed — briefing/ compatibility layer`).
- Notificar en Slack (#briefing-dev) y cerrar congelamiento de merges.
- Revisar `docs/architecture/070_risks.md` para retirar el riesgo asociado a la duplicidad de assets.

## Rollback

1. Restaurar la rama previa (`git revert` del merge o reintroducir `briefing/` desde la etiqueta inmediatamente anterior a la limpieza).
2. Revertir los cambios en workflows y `Makefile` que dejaron de contemplar `briefing/`.
3. Ejecutar `make build MODULE=briefing` (una vez restaurada la carpeta) para validar la capa, y lanzar deploy manual si fuera necesario.
4. Registrar el incidente y documentar el motivo del rollback en `INCIDENTS.md`.

## Siguientes pasos

- Migrar los dashboards de auditoría a un panel automatizado (ver `NEXT_PHASE.md`).
- Evaluar eliminación de referencias históricas a `briefing/` en favor de términos genéricos (`legacy briefing layer`).
- Programar limpieza similar para otros wrappers que queden después de la fase B.
