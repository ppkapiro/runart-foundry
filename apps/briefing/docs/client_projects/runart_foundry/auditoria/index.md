# Auditoría

## Resumen ejecutivo
- Identidad legal verificada y activa en Florida.  
- Presencia digital amplia pero con brechas en medios internacionales.  
- Portafolio validado con artistas de alto perfil.  
- Riesgo: presión inmobiliaria en Bird Road Art District.

## Hallazgos clave
- Imágenes pesadas y poco optimizadas.  
- SEO incompleto, sin schema ni FAQ.  
- Seguridad básica: sin Access configurado aún.  
- Falta de tablero de monitoreo y archivo documental consolidado.

## Recomendaciones inmediatas
1. Estandarizar fichas técnicas de proyectos.  
2. Crear press-kit bilingüe.  
3. Activar Google Alerts y Wayback.  
4. Mejorar SEO técnico (titles, metas, schema).

---

## Auditoría y Logs (Etapa 6)

Para esta iteración habilitamos un sistema liviano de trazabilidad que registra acciones relevantes dentro del briefing.

### Almacenamiento
- **Origen**: Cloudflare KV (`LOG_EVENTS`).
- **Retención**: 30 días (TTL configurado en `putEvent`).
- **Fallback**: si el binding no está disponible en el entorno, el evento se emite en consola (`[log:fallback]`) y la operación continúa.

### Campos de cada evento
| Campo | Descripción |
| --- | --- |
| `ts` | Timestamp ISO8601 generado en el edge. |
| `role` | Rol derivado del correo autenticado (`admin`, `equipo`, `cliente`, `visitante`). |
| `email` | Correo ofuscado (`f***@dominio`). |
| `path` | Ruta o recurso asociado (ej. `/exports/`). |
| `action` | Etiqueta corta (`page_view`, `export`, `custom`). |
| `meta` | Objeto opcional con contexto adicional no sensible. |

### Endpoints disponibles
- `POST /api/log_event` *(equipo+)*
	```json
	{
		"action": "page_view",
		"path": "/exports/",
		"meta": { "source": "autolog" }
	}
	```
	Devuelve `{ ok: true, key?, fallback? }`.

- `GET /api/logs_list?limit=50` *(admin)*
	Devuelve los últimos eventos ordenados de forma descendente. `limit` está acotado a `1-200`.

### Instrumentación de la UI
- El layout agrega un bloque `runart:autolog` que envía `page_view` para roles `admin` y `equipo` al cargar una página.
- Se puede desactivar removiendo el bloque o filtrando roles en el script.

### Buenas prácticas
- Evitar PII dentro de `meta` (usar IDs internos cuando sea necesario).
- Extender el logger en Workers al procesar exportaciones o moderaciones relevantes.
- Revisar periódicamente `/api/logs_list` (o replicar en panel) para detectar accesos sospechosos.

### Allowlist de acciones
Para reducir ruido y asegurar consistencia, solo se persisten eventos cuya `action` pertenece a la siguiente lista blanca:

- `page_view` &rarr; vistas internas para `admin`/`equipo`.
- `export_run` &rarr; ejecuciones de exportaciones o entregables.
- `admin_action` &rarr; cambios administrativos relevantes.
- `auth_event` &rarr; autenticaciones (login/logout) con metadatos mínimos.
- `custom` &rarr; último recurso, idealmente con claves estandarizadas.

Las solicitudes con acciones fuera de este conjunto responden `200 OK` pero incluyen `{"skipped":"not-allowed"}` para dejar constancia de que fueron descartadas.

### Muestreo (sampling)
No todos los eventos necesitan persistirse. Para balancear observabilidad y costos, el logger aplica muestreo sin estado por acción y rol:

| Acción        | Rol evaluado           | Porcentaje guardado |
| ------------- | ---------------------- | ------------------- |
| `page_view`   | `admin` / `equipo`     | 30 %                |
| `page_view`   | `cliente` / `visitante`| 0 %                 |
| `export_run`  | cualquiera             | 100 %               |
| `admin_action`| cualquiera             | 100 %               |
| `auth_event`  | cualquiera             | 50 %                |
| `custom`      | cualquiera             | 50 %                |

El endpoint responde `200 OK` y puede indicar `{"skipped":"sampled-out"}` cuando un evento se descarta por muestreo. Esto es esperado, especialmente para `page_view`.

### Pipeline y secrets
- Se añadió `wrangler.template.toml` (en la raíz del repo) con placeholders `${CF_LOG_EVENTS_ID}` y `${CF_LOG_EVENTS_PREVIEW_ID}`.
- El flujo de CI copia ese template a `briefing/wrangler.toml` antes de desplegar, reemplazando los placeholders con secrets definidos en GitHub (`CF_LOG_EVENTS_ID`, `CF_LOG_EVENTS_PREVIEW_ID`).
- Para despliegues automatizados se requieren además `CLOUDFLARE_API_TOKEN` y `CLOUDFLARE_ACCOUNT_ID`. Define estos secrets en **Settings → Secrets and variables → Actions**.
