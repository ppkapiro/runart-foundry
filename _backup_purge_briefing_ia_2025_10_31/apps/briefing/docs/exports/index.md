---
title: Exportaciones (MF)
access:
  - admin
  - equipo
---

# Exportaciones (MF) {.interno}

<!-- canonical-crosslink: pr-01 -->
> Fuente canónica de Briefing: ver `docs/live/` → [Índice](../../../../docs/live/index.md) · Hubs: [Arquitectura](../../../../docs/live/architecture/index.md), [Operaciones](../../../../docs/live/operations/index.md), [UI/Roles](../../../../docs/live/ui_roles/index.md).

Descarga fichas **aceptadas** como **JSONL** o **CSV** en un rango de fechas.

<form id="exp-form">
  <fieldset>
    <legend>Rango</legend>
    <label for="from">Desde (YYYY-MM-DD)</label>
    <input type="date" id="from" name="from" required>
    <label for="to">Hasta (YYYY-MM-DD)</label>
    <input type="date" id="to" name="to" required>
  </fieldset>
  <button id="btn-jsonl" type="button">Descargar JSONL</button>
  <button id="btn-csv"   type="button">Descargar CSV</button>
</form>

<div id="exp-status" role="status" aria-live="polite"></div>

<script defer src="/assets/exports/exports.js"></script>
<link rel="stylesheet" href="/assets/exports/exports.css" />
