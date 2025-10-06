# Inbox — Decisiones recientes

Las entradas más recientes aparecen primero. Los envíos realizados desde el editor muestran la insignia “editor_v1”. Solo el equipo autenticado puede moderar usando los controles de esta bandeja.

<!-- interno:start -->
<div class="interno">

## Estados y moderación
- **Pending**: valor por defecto tras enviar desde el editor o API. Permanece oculto para clientes.
- **Accepted**: visible en dashboards e interfaces de cliente una vez aprobada desde esta bandeja.
- **Rejected**: descartado definitivamente; se mantiene para trazabilidad interna.

Los botones **Aceptar** y **Rechazar** se muestran únicamente a miembros con rol de equipo (sesión Cloudflare Access válida). El panel dibuja insignias de origen (`editor_v1`) y cambia el estilo del badge según el estado.

> Para moderar necesitas una sesión válida por Cloudflare Access y enviar el token secreto (`X-Runart-Token`).

<p class="interno editor-link"><a href="/editor/" class="md-button md-button--primary">Ir al Editor de Fichas</a></p>

<div id="inbox-app" class="inbox-app" data-role="equipo">
  <ul id="inbox-list" role="list" aria-live="polite" aria-busy="true"></ul>
  <div id="inbox-feedback" role="status" aria-live="polite"></div>
  <div id="inbox-announce" role="status" aria-live="assertive" class="inbox-announce"></div>
</div>

<script>
  const API_BASE = window.RUN_BRIEFING_BASE_URL || '';
  const API_INBOX = `${API_BASE}/api/inbox`;
  const API_MODERAR = `${API_BASE}/api/moderar`;
  const moderationState = new Map();

  function parseTimestamp(value) {
    if (!value) return null;
    const date = new Date(value);
    if (!Number.isNaN(date.getTime())) {
      return date;
    }
    const numeric = Number(value);
    if (!Number.isNaN(numeric)) {
      return new Date(numeric * 1000);
    }
    return null;
  }

  function orderValue(item) {
    const ts = item?.meta?.createdAt || item?.ts || item?.timestamp || item?.created_at;
    const date = parseTimestamp(ts);
    if (date) return date.getTime();
    if (typeof item.decision_id === 'string') {
      return item.decision_id.localeCompare('');
    }
    return 0;
  }

  function formatDate(value) {
    const date = parseTimestamp(value);
    if (!date) return 'Fecha no disponible';
    return new Intl.DateTimeFormat('es-ES', {
      dateStyle: 'medium',
      timeStyle: 'short'
    }).format(date);
  }

  function getRole() {
    const app = document.getElementById('inbox-app');
    return (app?.dataset?.role || 'cliente').toLowerCase();
  }

  function getAuthToken() {
    const token = (window.RUN_EDITOR_TOKEN || '').trim();
    return token || 'dev-token';
  }

  function getStatusBadge(status) {
    const normalized = (status || 'pending').toLowerCase();
    const labelMap = {
      pending: 'Pending',
      accepted: 'Accepted',
      rejected: 'Rejected'
    };
    const span = document.createElement('span');
    span.className = `inbox-status inbox-status--${normalized}`;
    span.textContent = labelMap[normalized] || normalized;
    span.setAttribute('aria-label', `Estado ${span.textContent}`);
    return span;
  }

  function createOriginBadge(text) {
    const span = document.createElement('span');
    span.className = 'inbox-badge';
    span.textContent = text;
    span.setAttribute('aria-label', `Origen ${text}`);
    return span;
  }

  function announce(message, type = 'info') {
    const announceRegion = document.getElementById('inbox-announce');
    if (!announceRegion) return;
    announceRegion.textContent = message;
    announceRegion.className = `inbox-announce inbox-announce--${type}`;
  }

  function clearAnnouncements() {
    const announceRegion = document.getElementById('inbox-announce');
    if (!announceRegion) return;
    announceRegion.textContent = '';
    announceRegion.className = 'inbox-announce';
  }

  function renderModerationActions(item, container) {
    if (getRole() !== 'equipo') return;

    const status = (item?.moderation?.status || 'pending').toLowerCase();
    const actions = document.createElement('div');
    actions.className = 'inbox-actions';

    const note = document.createElement('p');
    note.className = 'inbox-actions__note';
    note.textContent = 'Modera esta ficha:';
    actions.appendChild(note);

    const buttons = document.createElement('div');
    buttons.className = 'inbox-actions__buttons';

    const acceptBtn = document.createElement('button');
    acceptBtn.type = 'button';
    acceptBtn.className = 'inbox-action inbox-action--accept';
    acceptBtn.textContent = 'Aceptar';
    acceptBtn.addEventListener('click', function () {
      submitModeration(item, 'accept', acceptBtn, buttons);
    });

    const rejectBtn = document.createElement('button');
    rejectBtn.type = 'button';
    rejectBtn.className = 'inbox-action inbox-action--reject';
    rejectBtn.textContent = 'Rechazar';
    rejectBtn.addEventListener('click', function () {
      submitModeration(item, 'reject', rejectBtn, buttons);
    });

    if (status === 'accepted' || status === 'rejected') {
      acceptBtn.disabled = true;
      rejectBtn.disabled = true;
      buttons.setAttribute('data-status-locked', status);
    }

    buttons.appendChild(acceptBtn);
    buttons.appendChild(rejectBtn);
    actions.appendChild(buttons);
    container.appendChild(actions);
  }

  async function submitModeration(item, action, pressedButton, buttonGroup) {
    const decisionId = item?.decision_id;
    if (!decisionId) return;

    const activeState = moderationState.get(decisionId);
    if (activeState === 'processing') {
      announce('Ya hay una acción en curso para esta ficha.', 'info');
      return;
    }

    moderationState.set(decisionId, 'processing');
    pressedButton.disabled = true;
    buttonGroup.classList.add('is-processing');
    announce('Procesando acción de moderación…', 'loading');

    try {
      const response = await fetch(API_MODERAR, {
        method: 'POST',
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json',
          'X-Runart-Token': getAuthToken()
        },
        body: JSON.stringify({
          decision_id: decisionId,
          action,
          note: ''
        })
      });

      const result = await response.json().catch(() => ({ ok: false }));

      if (!response.ok || !result?.ok) {
        throw new Error(result?.error || `Estado ${response.status}`);
      }

      announce(`La ficha ${decisionId} ahora está ${result.status}.`, 'success');
      await loadInbox(true);
    } catch (error) {
      console.error('Moderation error:', error);
      announce(`No se pudo actualizar la ficha: ${error.message}`, 'error');
      pressedButton.disabled = false;
    } finally {
      moderationState.delete(decisionId);
      buttonGroup.classList.remove('is-processing');
    }
  }

  async function loadInbox(skipReset = false) {
    const list = document.getElementById('inbox-list');
    const feedback = document.getElementById('inbox-feedback');
    if (!list || !feedback) return;

    if (!skipReset) {
      clearAnnouncements();
    }

    list.innerHTML = '';
    list.setAttribute('aria-busy', 'true');
    feedback.textContent = 'Cargando decisiones…';

    let payload = null;
    try {
      const response = await fetch(API_INBOX, { credentials: 'include' });
      if (!response.ok) {
        throw new Error(`Estado ${response.status}`);
      }
      payload = await response.json();
    } catch (error) {
      feedback.textContent = 'No fue posible recuperar el inbox. Verifica tu acceso o inténtalo más tarde.';
      console.error('Inbox fetch error:', error);
      list.setAttribute('aria-busy', 'false');
      return;
    }

    const items = Array.isArray(payload?.items) ? payload.items.slice() : Array.isArray(payload) ? payload.slice() : [];
    items.sort((a, b) => orderValue(b) - orderValue(a));

    list.innerHTML = '';
    items.forEach((item) => {
      const listItem = document.createElement('li');
      listItem.setAttribute('role', 'listitem');
      listItem.className = 'inbox-item';

      const header = document.createElement('div');
      header.className = 'inbox-item__header';

      const idSpan = document.createElement('span');
      idSpan.className = 'inbox-item__id';
      idSpan.textContent = item.decision_id || 'Sin ID';
      header.appendChild(idSpan);

      const typeSpan = document.createElement('span');
      typeSpan.className = 'inbox-item__type';
      typeSpan.textContent = item.tipo || item.kind || 'Sin tipo';
      header.appendChild(typeSpan);

      const dateSpan = document.createElement('span');
      dateSpan.className = 'inbox-item__date';
      const ts = item?.meta?.createdAt || item.ts || item.timestamp || item.created_at;
      dateSpan.textContent = formatDate(ts);
      header.appendChild(dateSpan);

      const statusBadge = getStatusBadge(item?.moderation?.status);
      header.appendChild(statusBadge);

      if (item.token_origen === 'editor_v1') {
        const originBadge = createOriginBadge('editor_v1');
        originBadge.classList.add('badge-editor');
        header.appendChild(originBadge);
      }

      listItem.appendChild(header);

      if (item?.meta?.userEmail) {
        const user = document.createElement('p');
        user.className = 'inbox-item__user';
        user.textContent = `Enviado por: ${item.meta.userEmail}`;
        listItem.appendChild(user);
      }

      if (item.comentario || item.comment) {
        const note = document.createElement('p');
        note.className = 'inbox-item__comment';
        note.textContent = item.comentario || item.comment;
        listItem.appendChild(note);
      }

      renderModerationActions(item, listItem);

      list.appendChild(listItem);
    });

    if (items.length === 0) {
      const empty = document.createElement('li');
      empty.textContent = 'No hay decisiones registradas aún.';
      empty.className = 'inbox-item inbox-item--empty';
      empty.setAttribute('role', 'listitem');
      list.appendChild(empty);
      feedback.textContent = '';
    } else {
      feedback.textContent = `Mostrando ${items.length} decisiones (${payload?.visibility || 'accepted'}).`;
    }

    list.setAttribute('aria-busy', 'false');
  }

  loadInbox();
</script>

<style>
  .inbox-app {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .inbox-item {
    margin: 0 0 1rem 0;
    padding: 1rem;
    border: 1px solid rgba(15, 23, 42, 0.08);
    border-radius: 12px;
    background: #fff;
    box-shadow: 0 6px 16px rgba(15, 23, 42, 0.06);
    list-style: none;
  }

  .inbox-item__header {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem 1rem;
    align-items: center;
    font-weight: 600;
  }

  .inbox-item__id {
    color: #1f2937;
  }

  .inbox-item__type {
    color: #475569;
  }

  .inbox-item__date {
    color: #2563eb;
  }

  .inbox-badge {
    background: rgba(59, 130, 246, 0.15);
    color: #1d4ed8;
    border-radius: 999px;
    padding: 0.1rem 0.6rem;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .badge-editor {
    background: rgba(22, 163, 74, 0.15);
    color: #15803d;
  }

  .inbox-status {
    border-radius: 999px;
    padding: 0.1rem 0.6rem;
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    border: 1px solid transparent;
  }

  .inbox-status--pending {
    background: rgba(234, 179, 8, 0.15);
    color: #b45309;
    border-color: rgba(234, 179, 8, 0.3);
  }

  .inbox-status--accepted {
    background: rgba(34, 197, 94, 0.18);
    color: #15803d;
    border-color: rgba(34, 197, 94, 0.35);
  }

  .inbox-status--rejected {
    background: rgba(239, 68, 68, 0.18);
    color: #b91c1c;
    border-color: rgba(239, 68, 68, 0.35);
  }

  .inbox-item__user,
  .inbox-item__comment {
    margin: 0.5rem 0 0;
    color: #4b5563;
  }

  .inbox-item--empty {
    text-align: center;
    color: #64748b;
    font-style: italic;
  }

  .editor-link {
    margin: 0 0 1.5rem;
  }

  .editor-link .md-button {
    display: inline-flex;
    gap: 0.4rem;
    align-items: center;
    font-size: 0.9rem;
  }

  .inbox-actions {
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px dashed rgba(15, 23, 42, 0.12);
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .inbox-actions__note {
    margin: 0;
    font-size: 0.85rem;
    color: #475569;
  }

  .inbox-actions__buttons {
    display: flex;
    gap: 0.75rem;
    flex-wrap: wrap;
  }

  .inbox-actions__buttons.is-processing {
    opacity: 0.7;
    pointer-events: none;
  }

  .inbox-action {
    border: none;
    border-radius: 999px;
    padding: 0.45rem 1.2rem;
    font-weight: 600;
    cursor: pointer;
    transition: transform 0.15s ease, box-shadow 0.15s ease;
  }

  .inbox-action:hover {
    transform: translateY(-1px);
  }

  .inbox-action:focus-visible {
    outline: 3px solid rgba(59, 130, 246, 0.35);
    outline-offset: 2px;
  }

  .inbox-action[disabled] {
    cursor: not-allowed;
    opacity: 0.7;
  }

  .inbox-action--accept {
    background: rgba(34, 197, 94, 0.12);
    color: #15803d;
    border: 1px solid rgba(34, 197, 94, 0.4);
  }

  .inbox-action--reject {
    background: rgba(239, 68, 68, 0.12);
    color: #b91c1c;
    border: 1px solid rgba(239, 68, 68, 0.4);
  }

  .inbox-announce {
    min-height: 1.5rem;
    font-size: 0.9rem;
    font-weight: 600;
  }

  .inbox-announce--success {
    color: #15803d;
  }

  .inbox-announce--error {
    color: #b91c1c;
  }

  .inbox-announce--loading,
  .inbox-announce--info {
    color: #2563eb;
  }
</style>
</div>
<!-- interno:end -->
