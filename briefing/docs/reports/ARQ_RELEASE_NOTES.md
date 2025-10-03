# ARQ Release Notes — cierre MF + ARQ+ v1

## Entregado
- **ARQ-0 → ARQ-5**: baseline MkDocs, roles/visibilidad, editor guiado, seguridad + moderación, dashboard cliente y exportaciones JSONL/CSV.
- **ARQ-6**: QA y smoke suite (`qa_arq6.sh`, neutralización automática de enlaces internos fuera de `docs/`).
- **ARQ+ v1**: limpieza de navegación (links neutralizados) y export ZIP (JSONL+CSV) vía `/api/export_zip`.
- Documentación consolidada: corte ARQ, mapa de interfaces (`/arq/mapa_interfaces/`), dashboards (`/dashboards/cliente/`) y herramientas (`/editor/`, `/inbox/`, `/exports/`).

## Pendiente (próxima etapa)
- Roles diferenciados con vistas específicas (admin/equipo/cliente) y “ver como”.
- Refrescar CSS/UI: tokens, componentes y estados de interacción.
- Endurecimiento opcional: rate-limit, validación estrica de `Origin/Referer`, smoke suite ampliada.
- Publicación gradual de `audits/`, `scripts/` y `assets/` o uso del toggle documentado.
