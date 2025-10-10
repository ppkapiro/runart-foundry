# Observabilidad y Métricas — LOG_EVENTS
**Versión:** v0.1 — 2025-10-08  
**Stream:** Observabilidad Fase 5  
**Responsable primario:** Plataforma / DevOps  
**Soporte:** Equipo Técnico Briefing, Operaciones

---

## 1. Objetivo
Establecer un flujo reproducible para registrar, consultar y monitorear los eventos operativos de RUNART Briefing. El alcance cubre:

- Definición del contrato de datos para la colección `LOG_EVENTS` (Cloudflare KV).
- Normalización y muestreo de eventos generados por Pages Functions.
- Exposición de consultas operativas (`/api/logs/list`) para dashboards internos.
- Métricas clave, umbrales y alertas recomendadas.
- Guías de extracción y transformación para reportes periódicos.

## 2. Flujo de ingesta
1. **Origen:** Pages Functions instrumentadas con `putEvent()` (`functions/_lib/log.js`).
   - Acciones permitidas (`log_policy.js`): `page_view`, `export_run`, `admin_action`, `auth_event`, `custom`.
   - Muestreo por acción/rol (ej.: `page_view` conserva 30% para roles `admin` o `equipo`).
2. **Normalización:**
   - Emails se guardan con máscara (`p***@dominio`).
   - Metadatos extensos (>2000 chars) se truncan automáticamente.
   - TTL estándar: 30 días (`expirationTtl = 2592000`).
3. **Persistencia:** Cloudflare KV binding `LOG_EVENTS` (`wrangler.toml`).  
   - Producción: `id = 9fbb7e6c2d6a4c1cb3ad2b3cce4040f5`.  
   - Preview: `preview_id = 17937e5c45fa49ec83b4d275f1714d44`.
4. **Consumo:**
   - API interna GET `/api/logs/list?limit=50` (requiere rol admin; ver `functions/api/logs_list.js`).
   - Dashboards `/dash/{role}` (roles admin/owner) consumirán resumen horario.
   - Reportes manuales vía script `tools/log_events_summary.py`.

## 3. Contrato de datos
Formato canonical (JSON) por evento:

```json
{
  "ts": "2025-10-08T15:30:25.412Z",
  "role": "admin",
  "email": "p***@runart.com",
  "path": "/dash/owner",
  "action": "page_view",
  "meta": {
    "ref": "dashboard",
    "status": 200,
    "client": "runartfoundry"
  }
}
```

### Campos obligatorios
| Campo | Tipo | Descripción | Notas |
| --- | --- | --- | --- |
| `ts` | string (ISO-8601) | Marca de tiempo UTC. | Se usa como prefijo de clave (`evt:<ts>:<rand>`). |
| `role` | string | Rol lógico (`owner`, `client_admin`, `team`, `client`, `visitor`, `admin`, `equipo`). | Se normaliza en el middleware de Access. |
| `email` | string | Correo enmascarado. | `maskEmail()` mantiene dominio y oculta usuario. |
| `path` | string | Ruta interna que originó el evento. | Vacío si no aplica. |
| `action` | string | Acción en la lista blanca. | Ver `log_policy.js`. |
| `meta` | object | Payload adicional normalizado. | Se trunca si excede 2k chars. |

### Campos derivados / internos
- Clave KV: `evt:<ts>:<id>` (`<id>` aleatorio 6 chars).  
- TTL: 30 días.  
- Flags de respuesta al escribir: `{ ok, key }` o `{ ok, fallback: true }`.

## 4. Registro y fallbacks
| Escenario | Resultado | Evidencia |
| --- | --- | --- |
| KV disponible | Evento almacenado, retorna `key`. | `_reports/kv_roles/20251008T150000Z/log_events.json` (snapshot). |
| KV ausente (local sin binding) | Se imprime `console.warn('[log:fallback]')`; respuesta `{ ok: true, fallback: true }`. | Usar para tests sin KV. |
| Error de escritura | Respuesta `{ ok: false, error, fallback }` + `console.warn('[log:error]')`. | Revisar Cloudflare dashboard. |

## 5. Consulta operativa
### 5.1 API interna (admin)
```bash
curl -H "Authorization: Bearer <token-admin>" \
  "https://briefing.runartfoundry.com/api/logs/list?limit=100"
```
Respuesta:
```json
{
  "ok": true,
  "events": [ { ... } ],
  "fallback": false
}
```
Se recomienda en dashboards consumir un subconjunto (`limit=200`) y aplicar agregaciones en cliente.

### 5.2 Wrangler CLI (Cloudflare)
- Listar claves recientes:
  ```bash
  wrangler kv:key list --binding=LOG_EVENTS --limit=10
  ```
- Obtener payload:
  ```bash
  wrangler kv:key get --binding=LOG_EVENTS --key="evt:2025-10-08T15:30:25.412Z:abc123"
  ```

## 6. Normalización para dashboards
Se incorpora el script `tools/log_events_summary.py` para generar métricas rápidas desde un JSON de eventos:

```bash
# Obtener eventos (admin)
curl -H "Authorization: Bearer <token>" \
  "https://briefing.runartfoundry.com/api/logs/list?limit=200" \
  | python tools/log_events_summary.py --bucket hourly
```

Salida esperada:
```
Total eventos: 180
Por acción:
  admin_action: 12
  page_view: 148
  auth_event: 20
Por rol:
  owner: 40
  client_admin: 30
  equipo: 55
  visitor: 55
Bucket (hourly):
  2025-10-08T14:00Z -> 32
  2025-10-08T15:00Z -> 51
  ...
Anomalías:
  Roles desconocidos: []
  Eventos sin ruta: 4
```

Los dashboards `/dash/owner` y `/dash/client_admin` deben consumir estas métricas para:
- Gráficas de actividad por hora.
- Conteo de eventos críticos (`admin_action`, `export_run`).
- Indicadores de errores (`meta.status >= 400`, `meta.error`).

## 7. Alertas recomendadas
| Alerta | Umbral | Acción |
| --- | --- | --- |
| Ausencia total de eventos | 0 eventos en 60 min (horario laboral). | Verificar Pages Functions y bindings; revisar `wrangler tail`. |
| Roles desconocidos | `role ∉ {owner, client_admin, team, client, visitor, admin, equipo}`. | Registrar incidente y revisar middleware `classifyRole`. |
| Errores de dashboard | `meta.error` presente o `meta.status >= 400` en `ui.dashboard.*`. | Notificar guardia QA (`ops/qa_guardias.md`). |
| Pico de exportaciones | `export_run > 5` en 30 min. | Confirmar si hay campañas; posible abuso. |

## 8. Integración con QA y reporting
- `ops/qa_guardias.md` registra responsables y checklist de revisión diaria.
- `STATUS.md` semáforo Observabilidad dependerá de:
  - Documentación actualizada (`este archivo`).
  - Evidencia de corridas (`_reports/qa_runs/...`).
  - Dashboard publicado (pendiente de datos reales).
- Bitácora 082 anotará hits relevantes (ver sección “Guardia QA — 2025-10-08T22:15Z”).

## 9. Próximos pasos
1. Agregar endpoint `/api/logs/summary` con agregaciones precalculadas (evita transferir eventos crudos).
2. Conectar dashboards MkDocs a datos reales cuando se habilite Access (desacoplar de mocks).
3. Automatizar extracción diaria hacia `_reports/observabilidad/<date>/` usando el script `log_events_summary.py`.
4. Integrar métricas a alertas Slack/Email (Webhook pendiente).

## 10. Anexo — Namespace `DECISIONES`
- Binding Pages Functions: `DECISIONES` (`wrangler.toml` → id `6418ac6ace59487c97bda9c3a50ab10e`).
- Claves con prefijo `decision:<decision_id>:<timestamp>`.
- Payload base (ver `functions/api/moderar.js`):
  ```json
  {
    "decisionId": "runart-20251008-001",
    "form": { "type": "alta_ficha", "payload": { ... } },
    "moderation": {
      "status": "pending",
      "updatedAt": "2025-10-08T15:00:00Z",
      "by": "dev@local",
      "note": ""
    },
    "moderationTrail": [
      { "status": "pending", "by": "dev@local", "at": "2025-10-08T15:00:00Z" }
    ],
    "meta": { "createdAt": "2025-10-08T15:00:00Z", "updatedAt": "2025-10-08T15:00:00Z" }
  }
  ```
- La ruta `POST /api/moderar` actualiza el estado (`accepted|rejected|pending`) y añade a `moderationTrail`.
- Exportaciones (`api/export_zip.js`) listan registros con prefijo `decision:` y empaquetan un ZIP para descarga interna.
- Próximas integraciones: replicar métricas de moderación (pendientes vs aprobadas) en los dashboards de `owner` y `client_admin`.
