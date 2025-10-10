# Brief de decisión — Contenido del sitio viejo

## 1) Contexto
Explicar qué revisar, problemas detectados y objetivos.

## 2) Evidencias
Enlaces a capturas, métricas y notas.

## 3) Opciones (pros/cons)
- Opción A — Mantener tal cual
- Opción B — Modernizar y mantener esencia
- Opción C — Reemplazar por completo

## 4) Selección + Comentario (formulario)
<form id="decision-form" action="https://runart-briefing.pages.dev/api/decisiones" method="POST" aria-labelledby="decision-title">
  <h3 id="decision-title">Selección y comentario</h3>
  <input type="hidden" name="decision_id" value="contenido-sitio-viejo" />

  <fieldset>
    <legend>Selecciona tu opción</legend>
    <div>
      <input id="opt-a" type="radio" name="seleccion" value="opcion_a" required>
      <label for="opt-a">Opción A — Mantener tal cual</label>
    </div>
    <div>
      <input id="opt-b" type="radio" name="seleccion" value="opcion_b">
      <label for="opt-b">Opción B — Modernizar y mantener esencia</label>
    </div>
    <div>
      <input id="opt-c" type="radio" name="seleccion" value="opcion_c">
      <label for="opt-c">Opción C — Reemplazar por completo</label>
    </div>
  </fieldset>

  <label for="prio">Prioridad (1–5):</label>
  <input id="prio" name="prioridad" type="range" min="1" max="5" value="3" aria-describedby="prio-help" aria-valuemin="1" aria-valuemax="5" aria-valuenow="3">
  <div id="prio-help">1 = baja, 5 = alta. Valor: <output id="prio-val">3</output></div>

  <fieldset>
    <legend>Alcance</legend>
    <div>
      <input id="alc-texto" type="checkbox" name="alcance" value="texto">
      <label for="alc-texto">Solo texto</label>
    </div>
    <div>
      <input id="alc-img" type="checkbox" name="alcance" value="imagenes">
      <label for="alc-img">Texto + imágenes</label>
    </div>
    <div>
      <input id="alc-all" type="checkbox" name="alcance" value="todo">
      <label for="alc-all">Todo</label>
    </div>
  </fieldset>

  <label for="riesgo">Riesgo aceptable:</label>
  <select id="riesgo" name="riesgo">
    <option value="bajo">Bajo</option>
    <option value="medio" selected>Medio</option>
    <option value="alto">Alto</option>
  </select>

  <label for="coment">Comentario breve</label>
  <textarea id="coment" name="comentario" rows="4" placeholder="Tu comentario"></textarea>

  <button type="submit">Guardar decisión</button>
  <p id="decision-msg" role="status" aria-live="polite" hidden>✅ Decisión guardada.</p>
</form>

<script>
  (function(){
    const prio = document.getElementById('prio');
    const out  = document.getElementById('prio-val');
    if (prio && out) prio.addEventListener('input', e => {
      out.value = e.target.value;
      prio.setAttribute('aria-valuenow', e.target.value);
    });

    const form = document.getElementById('decision-form');
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const data = new FormData(form);
      const alcance = data.getAll('alcance');
      const payload = {
        decision_id: data.get('decision_id'),
        seleccion: data.get('seleccion'),
        prioridad: Number(data.get('prioridad') || 3),
        alcance,
        riesgo: data.get('riesgo') || 'medio',
        comentario: data.get('comentario') || ''
      };
      const res = await fetch(form.action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const msg = document.getElementById('decision-msg');
      if (res.ok) { msg.hidden = false; msg.textContent = '✅ Decisión guardada.'; }
      else { msg.hidden = false; msg.textContent = '❌ No se pudo guardar la decisión.'; }
      msg.focus && msg.focus();
    });
  })();
</script>
