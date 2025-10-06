# Bandeja — Fichas de Proyectos

Aquí se mostrarán las fichas propuestas que los clientes envíen desde el formulario.  
El sistema usa `/api/inbox` para listar entradas almacenadas en KV.

<div id="inbox"></div>

<script>
fetch('/api/inbox')
  .then(r => r.json())
  .then(data => {
    const div = document.getElementById('inbox');
    if (data.length === 0) {
      div.innerHTML = "<p>No hay fichas registradas aún.</p>";
    } else {
      div.innerHTML = "<ul>" + data.map(d => `<li><strong>${d.title}</strong> — ${d.artist || 'Artista no definido'} (${d.year || 'Año N/D'})</li>`).join("") + "</ul>";
    }
  });
</script>

---
