# Briefing (Compat Layer)

Este directorio se mantiene temporalmente como capa de compatibilidad mientras Cloudflare Pages sigue apuntando a `runart-foundry/briefing` como directorio de build. Todo el código fuente vive ahora en `../apps/briefing` y la carpeta se retirará inmediatamente después de validar el deploy de producción.

## Uso

- `make build` → delega a `apps/briefing` para generar el sitio.
- `mkdocs.yml` → hereda la configuración principal apuntando al árbol de `apps/briefing/docs`.
- `requirements.txt` → referencia la misma lista de dependencias de la app.

Consulta `docs/architecture/065_switch_pages.md` para el plan de cambio. Una vez que Cloudflare Pages consuma `apps/briefing`, esta carpeta se eliminará.
