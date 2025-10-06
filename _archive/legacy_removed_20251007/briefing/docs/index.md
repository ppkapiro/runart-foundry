# RUN Art Foundry — Briefing Privado

## Estado del proyecto
Fase ARQ cerrada y ARQ+ v1 completada: navegación limpia dentro de `docs/`, exportaciones JSONL/CSV/ZIP operativas y herramientas listas para QA continuo.

## Mapa rápido
- [Arquitectura](briefing_arquitectura.md)
- [Corte Fase ARQ](reports/corte_arq.md)
- [Mapa de interfaces (ARQ)](arq/mapa_interfaces.md)
- [Dashboards KPIs (cliente)](dashboards/cliente.md)
- [Herramientas → Editor](editor/index.md)
- [Herramientas → Inbox](inbox/index.md)
- [Herramientas → Exportaciones](exports/index.md)

> APIs y herramientas están protegidas por Cloudflare Access.

## Secciones principales
- [Plan & Roadmap](plan/index.md)
- [Fases](fases/index.md)
- [Auditoría](auditoria/index.md)
- [Proceso](proceso/index.md)
- [Decisiones](decisiones/index.md)
- [Galería](galeria/index.md)
- [Acerca](acerca/index.md)

## Accesos y estilos (ETAPA 2)
Este sitio está protegido por **Cloudflare Access**. Los roles (**admin**, **equipo**, **cliente**) se derivan del email autenticado:
- **admin** → el correo aparece en `ACCESS_ADMINS`.
- **equipo** → el dominio del correo aparece en `ACCESS_EQUIPO_DOMAINS`.
- **cliente** → cualquier otro correo autenticado.

La visibilidad interna se controla con la clase `.interno`.  
Cuando el rol es **cliente**, todo lo marcado como `.interno` se oculta automáticamente en la UI (y también si un admin usa “Ver como = cliente”).

**Estados de UI disponibles:**
- `.is-busy` → desactiva interacciones y baja opacidad durante procesos.
- `.msg-ok` → mensaje de confirmación.
- `.msg-warn` → advertencia.
- `.msg-err` → error.

> Nota rápida: el atributo `data-role` se aplica en `<html>` para que la UI conozca el rol actual. Opcionalmente, los admins pueden simular la vista de otro rol con el selector “Ver como”.
