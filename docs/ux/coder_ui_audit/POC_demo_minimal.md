# POC — UI Minimalista (laboratorio)

## Objetivo
Visualizar el set de tokens minimalistas sin modificar el build principal. El laboratorio vive en `apps/briefing/docs/internal/briefing_system/ui/lab/minimal_poc.md`.

## Pasos para probar en local
1. Asegurarse de estar en la rama `feat/ui-minimal-poc`.
2. Desde `apps/briefing/`, ejecutar:
   ```bash
   mkdocs serve
   ```
   > Nota: en este entorno el comando falla con `PermissionError: [Errno 1] Operation not permitted` al abrir el puerto. Reintentar en la estación local del equipo.
3. Abrir en el navegador: `http://127.0.0.1:8000/internal/briefing_system/ui/lab/minimal_poc/`.
4. Verificar que la página cargue los estilos `tokens.poc.css` y `minimal-poc.css` (se importan solo en esa página).

## Qué observar
- **Tipografía:** jerarquía H1–H3, body, small y code usando Inter + JetBrains Mono.
- **Componentes básicos:** tarjetas `.poc-card`, tabla, botones primario/ghost, estados (`.poc-status`).
- **Banner neutro:** `.poc-env-banner` reemplaza la versión actual con tonos neutros.
- **Espaciado:** comprobar ritmo vertical (escala 8px) y densidad.

## Evidencia y notas
- Contraste AA verificado manualmente (tarjeta, botones, estados). Registrar resultados en `docs/ux/coder_ui_audit/Checklist_accesibilidad.md`.
- Capturas opcionales: guardar en `_reports/ui_minimal_poc/<timestamp>/` si se requiere documentación adicional.

## Limpieza
No se enlazan estos estilos en el build general. Tras las pruebas, detener `mkdocs serve` con `Ctrl+C`.
