# Corte Fase ARQ — Briefing Interno

**Fecha:** 2025-10-03  
**Ámbito:** ARQ-0 → ARQ-5 (Baseline, Roles, Editor, Seguridad+Moderación, KPIs cliente, Exportaciones)

## 1) Resumen de entregables
- ARQ-0: Baseline y navegación con Arquitectura.
- ARQ-1: Roles/visibilidad (equipo/cliente).
- ARQ-2: Editor guiado v1 (validación, preview YAML, POST a inbox).
- ARQ-3: Seguridad + Moderación (token + honeypot, pending/accept/reject).
- ARQ-4: Dashboard KPIs (cliente) — accepted/pending/rejected, 7d, latencia + sparkline.
- ARQ-5: Exportaciones (MF) — JSONL/CSV por rango (accepted).
- ARQ-6: QA continua — smoke `qa_arq6.sh` y neutralización de enlaces internos.

## 2) Calidad y QA ejecutado
- Build MkDocs: OK (warnings previos por `_reports/` y PDFs mitigados tras migrar a `reports/`).
- Roles: navegación segmentada (equipo/cliente) validada.
- A11Y mínima: mensajes aria-live/role=status en editor e inbox.
- Access: APIs detrás de Cloudflare Access (302 sin sesión).

## 3) Limitaciones y pendientes (próxima fase)
- Limpieza de warnings moviendo reportes a docs/ o ajustando nav.
- Exportaciones v1.1: ZIP y PDF por lote (opcional).
- Endurecimiento avanzado (rate-limit, origin check estricto, smoke suite ampliada).
- KPIs con filtros por fecha y desglose por tipo de ficha.

## 4) Evidencias (enlaces internos)
- Editor: /editor/
- Inbox: /inbox/
- KPIs: /dashboards/cliente/
- Exportaciones (equipo): /exports/
- Mapa: /arq/mapa_interfaces/

**Estado:** Fase ARQ cerrada (MF completo y funcional).
