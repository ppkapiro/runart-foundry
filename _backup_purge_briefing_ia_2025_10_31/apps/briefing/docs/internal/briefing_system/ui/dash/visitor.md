# Dashboard Visitor — Draft
**Última actualización:** 2025-10-08  
**Responsable:** Equipo técnico UI  

## Objetivo
Mostrar a usuarios no autenticados mensajes de bienvenida, acceso a material público y guía para solicitar credenciales.

## Mock interactivo
<div class="ra-dash-preview" data-runart-dashboard="visitor" aria-label="Vista previa dashboard visitor"></div>

## Wireframe propuesto
```
┌──────────────────────────────────────────────────────────────┐
│ Hero público: mensaje + video opcional                       │
├──────────────────────────────────────────────────────────────┤
│ Documentos públicos (A)                                      │
├──────────────────────────────────────────────────────────────┤
│ CTA solicitud acceso (B)                                     │
├──────────────────────────────────────────────────────────────┤
│ Noticias destacadas (C)                                      │
└──────────────────────────────────────────────────────────────┘
```
- **Hero**: incluye botón “Iniciar sesión via RunArt Access”.
- **A**: lista de hasta 6 documentos con etiquetas (Comunicado, Caso de éxito, Press-kit).
- **B**: formulario embed (Typeform) o botón que abre modal con instrucciones.
- **C**: carrusel con tarjetas (imagen + titular + fecha).

### Breakpoints
- Desktop: hero + grid 2 columnas para documentos.
- Tablet: lista vertical con tarjetas; CTA ocupa ancho completo.
- Mobile: secciones en pila con botones grandes, video reemplazado por imagen.

## Contenido dinámico
| Sección | Fuente | Tratamiento |
| --- | --- | --- |
| Hero | `config/ui_dashboards.yml` (`visitor.hero`) | Soporta traducciones en ES/EN. |
| Documentos públicos | YAML `visitor.public_docs` | Generar badges y descripciones cortas. |
| CTA acceso | URL configurable + email contacto | Añadir tracking `utm_source=briefing`. |
| Noticias destacadas | feed manual JSON / API marketing | Mostrar máximo 3; fallback a último boletín. |

## Estados y mensajes
- Sin documentos: mensaje “Estamos actualizando el catálogo” y enlace a contacto.
- CTA offline: fallback correo `briefing@runartfoundry.com`.
- Noticias vacías: mostrar enlace a blog corporativo.

## Reglas de visibilidad
- No mostrar rutas internas ni datos sensibles.
- Forzar `rel="noopener"` en enlaces externos.

## Checklist de implementación
- [x] Redactar contenido público aprobado por comunicación.
- [ ] Implementar CTA con tracking UTM.
- [ ] Evaluar incluir video introductorio (pendiente confirmación).
- [ ] Subir capturas en `_reports/ui_context/<timestamp>/visitor/`.

## Evidencias
- `_reports/ui_context/20251011T153200Z/wireframe_visitor.md` (wireframe v1).
