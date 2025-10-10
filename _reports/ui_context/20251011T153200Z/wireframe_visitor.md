# Wireframe v1 — Dashboard Visitor
**Fecha:** 2025-10-08T16:06Z  
**Responsable:** Copilot

## Layout
- Hero informativo con mensaje clave y botón “Solicitar acceso”.
- Lista de documentos públicos con badges y descripciones.
- Bloque CTA con formulario embebido.
- Carrusel de noticias destacadas.

## Consideraciones UX
- Evitar referencias a áreas privadas.
- CTA con tracking UTM y fallback a correo.
- Modo responsivo con secciones apiladas en móvil.

## Estados
- Sin documentos: mensaje temporal y enlace a contacto.
- CTA offline: fallback a correo `briefing@runartfoundry.com`.
- Sin noticias: enlace a blog principal.

## Próximos pasos
- Definir YAML de contenidos públicos.
- Integrar formulario Typeform o CF Worker.
- Generar capturas cuando se activen campañas.
