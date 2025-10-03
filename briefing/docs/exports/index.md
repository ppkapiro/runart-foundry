# Exportaciones (MF)

Descarga fichas **aceptadas** como **JSONL**, **CSV** o **ZIP** (JSONL+CSV) filtradas por rango de fechas.

## Requisitos
- Sesión válida mediante Cloudflare Access; sin autenticación las llamadas a `/api/inbox` y `/api/export_zip` devuelven 302.
- Token `RUN_TOKEN` configurado en el navegador (inyectado desde Access o variables del entorno local).

## Formatos disponibles
- **JSONL**: un registro por línea para importar a analytics o ETL.
- **CSV**: resumen tabular compatible con hojas de cálculo.
- **ZIP (JSONL+CSV)**: empaqueta ambos archivos; implementado en `functions/api/export_zip.js`.

Completa el rango de fechas y usa los botones para iniciar cada descarga.

<form id="exp-form">
  <fieldset>
    <legend>Rango</legend>
    <label for="from">Desde (YYYY-MM-DD)</label>
    <input type="date" id="from" name="from" required>
    <label for="to">Hasta (YYYY-MM-DD)</label>
    <input type="date" id="to" name="to" required>
  </fieldset>
  <button id="btn-jsonl" type="button">Descargar JSONL</button>
  <button id="btn-csv" type="button">Descargar CSV</button>
  <button id="btn-zip" type="button">Descargar ZIP (JSONL+CSV)</button>
</form>

<p>Todas las solicitudes se ejecutan desde el navegador; el ZIP contiene los mismos datos que las descargas individuales.</p>

<div id="exp-status" role="status" aria-live="polite"></div>

<script defer src="/assets/exports/exports.js"></script>
<link rel="stylesheet" href="/assets/exports/exports.css" />
