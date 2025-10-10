# Contrato de Datos — UI Contextual
**Versión:** v0.1 — 2025-10-08  
**Responsable:** Equipo técnico UI · Coordinación con DevOps/Observabilidad

## 1. Identidad y sesión (`/api/whoami`)
```json
{
  "ok": true,
  "email": "ppcapiro@gmail.com",
  "role": "owner",
  "rol": "propietario",
  "env": "production",
  "ts": "2025-10-08T14:20:31Z"
}
```
- `role`: valores válidos → `owner`, `client_admin`, `team`, `client`, `visitor`.
- `rol`: alias en español utilizado para UI (mapa heredado en `overrides/main.html`).
- `env`: propagado a `data-env` y `window.RUNART_ENV`.
- Requisitos: latencia < 500 ms; cache 0s; respuesta 401 solo si falta sesión Access.

## 2. Eventos de actividad (`/api/logs/activity`)
```json
[
  {
    "id": "evt_01hdzh5j9z1sj",
    "ts": "2025-10-08T13:59:00Z",
    "actor": "ppcapiro@gmail.com",
    "role": "owner",
    "type": "decision_created",
    "payload": {
      "decision_id": "dec_20251008_001",
      "summary": "Aprobar wireframes UI"
    }
  }
]
```
- Debe aceptar filtros `role`, `actor`, `limit` (`<=50`).
- Ordenado DESC por `ts`.
- Fuentes: KV `LOG_EVENTS` normalizada (ver Observabilidad).

## 3. Bandeja de tareas (`/api/inbox`)
```json
[
  {
    "id": "task_20251008_01",
    "title": "Capturar evidencia Access",
    "status": "open",
    "priority": "high",
    "due_date": "2025-10-10",
    "assigned_to": "client_admin",
    "links": [
      {
        "label": "Detalle",
        "href": "/docs/internal/briefing_system/reports/2025-10-10_fase4_consolidacion_y_cierre/"
      }
    ]
  }
]
```
- Campos obligatorios: `id`, `title`, `status`, `priority`, `assigned_to`.
- `assigned_to` se mapeará a chips de colores por rol destino.
- Respetar ACL: owner/team acceden a todo; client_admin/client solo sus tareas.

## 4. Automatizaciones (GitHub Actions)
```json
{
  "workflows": [
    {
      "name": "docs-lint",
      "status": "success",
      "conclusion": "success",
      "updated_at": "2025-10-08T12:10:00Z",
      "url": "https://github.com/ppkapiro/runart-foundry/actions/runs/123"
    }
  ]
}
```
- Se expondrá vía `tools/api/workflow-status` (pendiente). Mientras tanto, mock local en JSON.
- Estados válidos: `success`, `in_progress`, `queued`, `failure`.

## 5. Métricas de observabilidad
```json
{
  "alerts": {
    "role_unknown": 0,
    "error_5xx": 1,
    "latency_p95_ms": 320
  }
}
```
- Fuente: pipeline de normalización (`ops/observabilidad.md`).
- Los dashboards deben definir umbrales: `role_unknown > 0` → rojo; `error_5xx > 3` → rojo; `latency_p95_ms > 400` → ámbar.

## 6. Configuración estática
Archivo YAML propuesto: `apps/briefing/config/ui_dashboards.yml`
```yaml
menus:
  client_admin:
    - label: "Guía rápida"
      href: "/docs/internal/briefing_system/guides/Guia_Copilot_Ejecucion_Fases/"
    - label: "Estado del sistema"
      href: "/docs/internal/briefing_system/ops/status/"
contacts:
  default:
    email: "briefing@runartfoundry.com"
    slack: "https://runartfoundry.slack.com/archives/support"
```
- Permite mantener enlaces y contactos sin tocar JS.

## 7. Convenciones generales
- Todo endpoint debe responder con `Cache-Control: no-store` para datos sensibles.
- Manejar fallbacks → si la API falla, mostrar mensajes estado y registrar en `LOG_EVENTS` un evento `ui.dashboard.error`.
- El cliente debe incluir `credentials: "include"` en los fetch para respetar Access.

## 8. Próximos pasos
1. Validar contrato con DevOps y Observabilidad.
2. Implementar mocks locales (`docs/assets/runart/userbar.js` + dataset de ejemplo).
3. Documentar ejemplos de visualización en los archivos `/dash/{rol}.md`.
