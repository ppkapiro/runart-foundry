# Plan de Fase — Sistema Briefing Interno (Visualización) · v0

> **Propósito**: Definir cómo el panel briefing se usa para comunicar con el cliente, visualizar el estado, capturar/normalizar datos y gestionar documentación.  
> **Naturaleza**: plan **incompleto** y **evolutivo**; se ajustará en ejecución.

## Fase ARQ-0 · Alineación y baseline (1 semana)
**Objetivo:** Que todos vean lo mismo y en el mismo lugar.
**Entregables:**
- Documento de arquitectura publicado y enlazado.
- Sección “Estado del proyecto” visible en README_briefing.
- Menú “Reportes” con Master Plan, Corte Fase 2 y Arquitectura.
**Tareas:**
- [ ] Verificar briefing_arquitectura.md en navegación.
- [ ] Añadir “Arquitectura” al Master Plan (referencia).
- [ ] Revisar README_briefing como ficha ejecutiva.
**Definición de Hecho (DoD):**
- [ ] Todo accesible desde menú, sin enlaces rotos.

## Fase ARQ-1 · Roles y visibilidad de menús (2–3 semanas)
**Objetivo:** Segmentar qué ve el equipo vs. qué ve el cliente.
**Entregables:**
- Política de visibilidad (matriz: sección × rol).
- Implementación inicial (banderas simples y/o dos builds).
**Tareas:**
- [ ] Definir roles: `equipo`, `cliente`, `visitante`.
- [ ] Matriz de visibilidad por sección (tablas en el plan).
- [ ] Estrategia técnica: 
  - Opción A: dos builds (internal/public-lite).
  - Opción B: conmutadores de navegación por flag/env var.
- [ ] Probar acceso cliente (demo) sin logs internos.
**DoD:**
- [ ] Navegación “modo cliente” sin secciones internas (logs, workflows).

## Fase ARQ-2 · Editor guiado de fichas (3–4 semanas)
**Objetivo:** Capturar datos de proyecto sin “hablar YAML”.
**Entregables:**
- Formulario/Editor que mapea a schema de fichas.
- Validación en cliente (campos obligatorios, formatos).
**Tareas:**
- [ ] UI por secciones (Identificación, Materiales, Dimensiones, Proceso, Medios, Enlaces, Testimonio).
- [ ] Validación básica (campos obligatorios, URLs).
- [ ] Exportar a inbox (JSON) y vista previa de YAML.
- [ ] Botón “Enviar para promoción”.
**DoD:**
- [ ] Genera un YAML válido (pasa `validate_projects.py`) en preview.

## Fase ARQ-3 · Seguridad de formularios y moderación (2–3 semanas)
**Objetivo:** Evitar spam y garantizar trazabilidad previa a promoción.
**Entregables:**
- Protección de endpoints (token/captcha).
- Registro de moderación (quién aprueba qué).
**Tareas:**
- [ ] Token/captcha en `/api/decisiones`.
- [ ] Flag “pendiente/aceptada/rechazada” en inbox.
- [ ] Bitácora mínima (usuario, timestamp, acción).
**DoD:**
- [ ] Ningún envío anónimo sin token; moderación obligatoria.

## Fase ARQ-4 · Dashboards y métricas (2–3 semanas)
**Objetivo:** Una mirada visual al avance (para cliente y equipo).
**Entregables:**
- Dashboard “estado de fichas” (reales vs dummy, errores, enlaces).
- Indicadores de Press-kit y cortes de control.
**Tareas:**
- [ ] Componente de KPIs embebido (o enlace a dashboard externo).
- [ ] “Semáforo” por ficha (OK/Atención/Pendiente).
- [ ] Panel de incidencias del último corte.
**DoD:**
- [ ] Tablero visible “modo cliente” con KPIs claros.

## Fase ARQ-5 · Exportaciones y paquetes (2 semanas)
**Objetivo:** Entregables por lote, listos para enviar.
**Entregables:**
- Export ZIP por selección: fichas + imágenes optimizadas + PDF.
**Tareas:**
- [ ] Selector de proyectos.
- [ ] Comando/Workflow: empaquetado y descarga.
**DoD:**
- [ ] ZIP descargable con estructura coherente.

## Fase ARQ-6 · QA, accesibilidad y “corte ARQ” (1–2 semanas)
**Objetivo:** Cerrar la etapa con calidad y trazabilidad.
**Entregables:**
- Reporte “Corte ARQ” (navegación, accesibilidad, fallos, métricas).
- Lista de pendientes priorizados.
**Tareas:**
- [ ] Testing navegación (rotos/403).
- [ ] Revisión accesibilidad básica (alt, landmarks, foco).
- [ ] Informe final con semáforos.
**DoD:**
- [ ] Reporte publicado en `_reports/` y enlazado.

---

## Backlog abierto (se madura en ejecución)
- Integración con repos audiovisual externo.
- Editor de testimonios (audio/video) con transcripción.
- Versionado fino por ficha (changelog visible).
- Webhooks para notificar cambios al cliente.

## Riesgos & mitigación
- Requisitos cambiantes → plan evolutivo por fases, ADRs para decisiones clave.
- Carga operativa en equipo → automatizar promoción/validación.
- Acceso cliente → segmentación clara y datos sensibles fuera de su vista.

## KPIs de esta etapa
- % secciones correctamente segmentadas por rol.
- % fichas con YAML válido generado desde editor.
- Tiempo medio inbox → YAML (moderado).
- Incidencias por corte ARQ resueltas al siguiente.

---
