---
title: Laboratorio · Minimal UI POC
hide:
  - toc
---

<div class="poc-lab-loader" hidden>
  <link rel="stylesheet" href="/assets/theme/tokens.poc.css" />
  <link rel="stylesheet" href="/assets/theme/minimal-poc.css" />
</div>

<script>
  (function () {
    const applyClass = () => {
      if (!document.body.classList.contains('poc-preview')) {
        document.body.classList.add('poc-preview');
      }
    };
    if (document.readyState !== 'loading') {
      applyClass();
    } else {
      document.addEventListener('DOMContentLoaded', applyClass, { once: true });
    }
  })();
</script>

<div class="poc-preview">
  <div class="poc-env-banner" style="margin-bottom: var(--poc-space-4);">
    <span class="poc-env-badge">preview poc</span>
    <p class="poc-small">Banner neutral basado en tokens — sin sombras, colores suaves y accesibles.</p>
  </div>

  <h1>Encabezado H1</h1>
  <p>Este laboratorio demuestra la propuesta de UI minimalista usando un set acotado de tokens de color, tipografía y espaciado. No afecta al sitio real.</p>

  <h2>Componentes base</h2>
  <div class="poc-card">
    <h3>Tarjeta plana</h3>
    <p>Tarjeta con borde sutil y sin sombras intensas. Ideal para dashboards o paneles de información.</p>
    <div class="poc-status ok">Estado OK — proceso completado correctamente.</div>
    <div class="poc-status warn" style="margin-top: var(--poc-space-2);">Advertencia — requiere seguimiento.</div>
    <div class="poc-status error" style="margin-top: var(--poc-space-2);">Error — acción necesaria.</div>
  </div>

  <div class="poc-card table">
    <h3>Tabla compacta</h3>
    <table>
      <thead>
        <tr>
          <th>Item</th>
          <th>Descripción</th>
          <th>Estado</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Exportación semanal</td>
          <td>Resumen de tareas y decisiones.</td>
          <td><span class="poc-status ok">OK</span></td>
        </tr>
        <tr>
          <td>Inbox moderación</td>
          <td>2 pendientes críticos.</td>
          <td><span class="poc-status warn">Warn</span></td>
        </tr>
        <tr>
          <td>Logs eventos</td>
          <td>Errores detectados en último lote.</td>
          <td><span class="poc-status error">Error</span></td>
        </tr>
      </tbody>
    </table>
  </div>

  <h2>Acciones</h2>
  <p>
    <button class="poc-btn poc-btn-primary">Guardar cambios</button>
    <button class="poc-btn poc-btn-ghost">Cancelar</button>
  </p>

  <h2>Tipografía y código</h2>
  <p class="poc-small">Texto pequeño para notas o metadatos.</p>
  <p>
    Código en línea <span class="poc-code">npm run build</span> con JetBrains Mono.
  </p>
</div>
