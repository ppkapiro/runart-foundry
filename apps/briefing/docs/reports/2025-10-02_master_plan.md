# Master Plan RUN Art Foundry — Panel Briefing

## 1) Introducción
RUN Art Foundry opera este briefing como un panel interno de control y documentación. Aquí se orquesta el backlog de contenidos, se registran auditorías y se ejecutan las automatizaciones que nutren a la web pública y a los entregables para el cliente. No es un sitio público, sino la base que asegura gobernanza, trazabilidad y despliegues reproducibles.

## 2) Diagnóstico inicial (Fase 0)
El diagnóstico técnico-operativo cerró la Fase 0 con evidencias recopiladas en `2025-10-02_cierre_fase0.md`. Los hallazgos clave fueron:
- La web legada no ofrecía valor de rescate y presentaba problemas de indexación y SEO severo.
- Inventario de activos sobredimensionados (189 imágenes >500KB) y sin metadatos consistentes.
- Auditorías de infraestructura confirmaron CI/CD disponible y gobernanza lista para nuevos flujos.

La salida estableció como prioridades optimizar assets, restablecer meta descriptions y asegurar accesos (Cloudflare, repositorio audiovisual, etc.).

## 3) Fase 1 — Pilotos y estructura base
Fase 1 se centró en construir la arquitectura mínima y tres pilotos de ficha:
- Fichas YAML piloto para `mons-roman-2015`, `raider-2018` y `colaboracion-internacional-01`, con estructura validada y campos completos.
- Definición de plantilla YAML común y creación de directorios de assets por proyecto.
- Generación de press-kit v0 (dummy) y v1 (estructura con narrativa preliminar) que se publican desde MkDocs.
- Primer pipeline CI/CD conectado a MkDocs para asegurar builds consistentes.

## 4) Fase 2 — Automatización y control
La Fase 2 consolidó procesos automáticos y control de calidad:
- Workflows que promueven entradas del inbox a fichas YAML, cuidando assets y colisiones (`promote_inbox.yml` y vista previa).
- Formulario para clientes en el briefing, de modo que nuevas solicitudes entren al inbox estructurado.
- Validaciones automáticas de esquema (Cerberus) y linting ejecutadas tanto en pre-commit como en CI.
- Pipeline que genera PDFs de press-kit y los publica en `briefing/site/presskit/` (v0 y v1, ES/EN).
- Corte de control generado con métricas integrales de fichas, imágenes y enlaces. Ver `corte_control_fase2.md` para el detalle completo.

## 5) Estado de fases
### Estado actual
- **Fase 0 – Diagnóstico** → ✅ Cerrada.
- **Fase 1 – Pilotos y estructura base** → ✅ Cerrada.
- **Fase 2 – Automatización y control** → ✅ Cerrada.  
	- Ver reporte: [Corte de Control — Fase 2](corte_control_fase2.md).  
	- Este reporte incluye métricas globales, detalle por ficha y acciones recomendadas.

### Acciones pendientes (tras el corte Fase 2)
- Reemplazar imágenes dummy por optimizadas en fichas piloto e intermedias.
- Corregir enlaces externos con alerta o pendientes de validación manual.
- Confirmar la publicación correcta de todos los PDFs (v0/v1 ES/EN).
- Ejecutar el corte de control nuevamente tras completar estas correcciones.

## 6) Roadmap extendido (próximas fases)
### Roadmap próximo (Fases 3–8)
- **Fase ARQ — Sistema Briefing (visualización y uso con cliente)**  
  Ver: [Plan de Fase — Sistema Briefing Interno](plan_fase_arq.md)
- **Fase 3 – Escalamiento de fichas y contenidos**  
	- Ampliar de 10 a 20–30 proyectos documentados.  
	- Sustituir imágenes dummy por optimizadas (<300 KB, webp/jpg).  
	- Completar biografía extendida de Uldis, narrativa corporativa definitiva y testimonios reales.  
	- Enriquecer Press-kit v1 con contenidos finales y publicarlo como versión institucional.
- **Fase 4 – Traducción bilingüe completa**  
	- Traducir todas las fichas y press-kit a inglés.  
	- Validar consistencia en PDFs y navegación bilingüe.
- **Fase 5 – Integración audiovisual y SEO**  
	- Integrar clips de procesos y testimonios en media de fichas.  
	- Optimizar el repositorio audiovisual.  
	- Implementar metadatos, schema.org y ajustes SEO.
- **Fase 6 – Consolidación y despliegue extendido**  
	- Generar press-kit institucional definitivo y dossier para convocatorias.  
	- Mantener el briefing como panel interno de control y automatización.  
	- Añadir automatizaciones de reportes por lote y dashboards.
- **Fase 7 – Presentación al cliente y feedback**  
	- Mostrar briefing y press-kit final.  
	- Recoger cambios y feedback vía formularios de decisiones.  
	- Ajustar fichas y materiales según comentarios.
- **Fase 8 – Expansión opcional**  
	- Incorporar nuevos módulos en el briefing (contratos, métricas, tracking de proyectos).  
	- Evaluar integraciones externas (APIs, repositorios).

## 7) KPIs y métricas de control
- Nº de fichas en español: 10 preliminares activas.
- Nº de PDFs generados y publicados: 4 (press-kit v0/v1 en ES y EN).
- Workflows activos: `presskit_pdf.yml`, `promote_inbox.yml`, `promote_inbox_preview.yml`, `corte_control_fase2.yml`.
- Formularios cliente activos: 1 (ficha de proyecto).
- Validaciones de calidad activas: esquema de proyectos + hooks pre-commit.
- Próximo hito: 20–30 fichas completas con contenido real y assets definitivos.

## 8) Naturaleza del briefing (aclaración estratégica)
Este briefing permanece como panel interno permanente. Aquí se consolida documentación, se monitorean fases y se ejecutan automatizaciones que alimentan los entregables públicos. Es un espacio vivo para el equipo RUN Art Foundry y el cliente, donde cada avance se versiona y queda trazado. A medida que escalemos fases, este panel seguirá incorporando nuevas capacidades (automatización de fichas, dashboards, repositorio audiovisual) antes de exponer capas públicas.

## 9) Conclusión
El Master Plan queda actualizado desde el diagnóstico hasta la planificación extendida. Las Fases 0, 1 y 2 están cerradas con métricas verificadas en el corte de control, dejando un sistema estable para escalar. Este documento funciona como el marco extendido del proyecto, más allá de un horizonte de 90 días, y guía la evolución progresiva del briefing. El foco inmediato es activar la Fase 3: multiplicar las fichas, integrar contenido real y enriquecer el press-kit, sobre una base ya gobernada por CI/CD y reportes automáticos.

---
