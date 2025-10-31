(function () {
  const isLocalMode = () => (typeof window !== 'undefined' && window.__AUTH_MODE__ === 'none');
  const session = { role: 'visitante', email: '' };

  const normaliseItems = (payload) => {
    if (!payload) return [];
    if (Array.isArray(payload)) return payload;
    if (Array.isArray(payload.items)) return payload.items;
    if (Array.isArray(payload.data)) return payload.data;
    return [];
  };

  const recordFromItem = (item) => ({
    id: item?.decision_id || item?.id || '',
    tipo: item?.tipo || item?.payload?.tipo || '',
    createdAt: item?.meta?.createdAt || item?.ts || '',
    artista: item?.payload?.artista || item?.payload?.artistaNombre || '',
    titulo: item?.payload?.titulo || '',
    anio: item?.payload?.anio || '',
    token_origen: item?.token_origen || item?._kvKey || ''
  });

  const withinRange = (value, range) => {
    if (!value) return false;
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return false;
    return date >= range.from && date <= range.to;
  };

  const filterByRole = (items, range, currentSession = session) => {
    const accepted = items.filter((item) => (item?.moderation?.status || '').toLowerCase() === 'accepted');
    const ranged = accepted.filter((item) => withinRange(item?.meta?.createdAt || item?.ts, range));

    const role = (currentSession?.role || 'visitante').toLowerCase();
    const email = (currentSession?.email || '').toLowerCase();

    if (role === 'cliente') {
      return ranged.filter((item) => {
        const owner = (item?.meta?.userEmail || item?.meta?.email || '').toLowerCase();
        return owner && email && owner === email;
      });
    }

    return ranged;
  };

  const toJsonl = (records) => records.map((rec) => JSON.stringify(rec)).join('\n');

  const csvEscape = (value) => {
    const str = value == null ? '' : String(value);
    if (/["];|\n/.test(str)) {
      return `"${str.replace(/"/g, '""')}"`;
    }
    return str;
  };

  const toCsv = (records) => {
    const header = ['id', 'tipo', 'createdAt', 'artista', 'titulo', 'anio', 'token_origen'];
    const lines = [header.join(';')];
    for (const record of records) {
      lines.push(header.map((key) => csvEscape(record[key])).join(';'));
    }
    return lines.join('\n');
  };

  const helpers = { normaliseItems, recordFromItem, withinRange, filterByRole };
  if (typeof globalThis !== 'undefined') {
    globalThis.RunartExports = helpers;
  }

  if (typeof document === 'undefined') {
    return;
  }

  const form = document.getElementById('exp-form');
  const btnJsonl = document.getElementById('btn-jsonl');
  const btnCsv = document.getElementById('btn-csv');
  const statusEl = document.getElementById('exp-status');

  if (!form || !btnJsonl || !btnCsv || !statusEl) {
    return;
  }

  const allowedRoles = new Set(['admin', 'equipo']);
  const formElements = Array.from(form.querySelectorAll('input, button, select'));

  const setStatus = (message) => {
    statusEl.textContent = message;
  };

  const setFormEnabled = (enabled) => {
    formElements.forEach((el) => {
      el.disabled = !enabled;
    });
    btnJsonl.disabled = !enabled;
    btnCsv.disabled = !enabled;
  };

  const parseRange = () => {
    const fromValue = form.from?.value?.trim();
    const toValue = form.to?.value?.trim();

    if (!fromValue || !toValue) {
      return { error: 'Selecciona un rango válido.' };
    }

    const from = new Date(`${fromValue}T00:00:00.000Z`);
    const to = new Date(`${toValue}T23:59:59.999Z`);

    if (Number.isNaN(from.getTime()) || Number.isNaN(to.getTime())) {
      return { error: 'Fechas inválidas. Usa el formato YYYY-MM-DD.' };
    }

    if (from > to) {
      return { error: 'La fecha "Desde" no puede ser mayor que "Hasta".' };
    }

    return { from, to, fromValue, toValue };
  };

  const download = (content, type, filename) => {
    const blob = new Blob([content], { type });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  const fetchInbox = async () => {
    if (isLocalMode()) {
      // Modo local: sin llamadas a endpoints cloud. Devolver lista vacía.
      return [];
    }
    try {
      const res = await fetch('/api/inbox', { credentials: 'include', redirect: 'manual' });

      if (res.status === 401 || res.status === 403 || res.status === 302 || res.type === 'opaqueredirect') {
        setStatus('Requiere sesión Cloudflare Access.');
        return null;
      }

      if (!res.ok) {
        setStatus(`Error ${res.status}: no se pudo obtener el inbox.`);
        return null;
      }

      const contentType = res.headers.get('Content-Type') || '';
      if (!contentType.includes('application/json')) {
        setStatus('Respuesta inesperada: se esperaba JSON.');
        return null;
      }

      return res.json();
    } catch (error) {
      console.error('Error al consultar /api/inbox', error);
      setStatus('Error de red al consultar /api/inbox.');
      return null;
    }
  };

  const fetchSession = async () => {
    if (isLocalMode()) {
      // Modo local: simular sesión mínima para habilitar UI si procede.
      session.role = 'equipo';
      session.email = 'local@runart.dev';
      return;
    }
    try {
      const res = await fetch('/api/whoami', { credentials: 'include' });
      if (!res.ok) throw new Error('whoami failed');
      const data = await res.json();
      session.role = (data?.role || 'visitante').toLowerCase();
      session.email = (data?.email || '').toLowerCase();
    } catch (error) {
      console.warn('No se pudo resolver el rol del usuario', error);
      session.role = 'visitante';
      session.email = '';
    }
  };

  const ensureAccess = () => {
    if (isLocalMode()) {
      setFormEnabled(true);
      setStatus('Modo local: exportaciones desactivadas (sin APIs).');
      return true;
    }
    const role = (session.role || 'visitante').toLowerCase();
    if (!['admin', 'equipo', 'cliente'].includes(role)) {
      setFormEnabled(false);
      setStatus('Requiere sesión Cloudflare Access.');
      return false;
    }

    if (!allowedRoles.has(role)) {
      setFormEnabled(false);
      setStatus('Exportaciones disponibles solo para el equipo interno.');
      return false;
    }

    setFormEnabled(true);
    setStatus('Listo para exportar');
    return true;
  };

  const handleExport = async (format) => {
    const role = (session.role || 'visitante').toLowerCase();
    if (!allowedRoles.has(role)) {
      setStatus('Exportaciones restringidas al equipo.');
      return;
    }

    const range = parseRange();
    if (range?.error) {
      setStatus(range.error);
      return;
    }

    setStatus('Cargando…');

  const payload = await fetchInbox();
    if (!payload) return;

    const items = normaliseItems(payload);
    const filtered = filterByRole(items, range, session);
    const records = filtered.map(recordFromItem);
    if (isLocalMode()) {
      setStatus('Modo local: sin datos remotos que exportar.');
      return;
    }

    if (records.length === 0) {
      const msg = role === 'cliente'
        ? 'Sin fichas propias en el rango seleccionado.'
        : 'Sin datos en el rango seleccionado.';
      setStatus(msg);
      return;
    }

    const filenameBase = `export_accepted_${range.fromValue}_to_${range.toValue}`;

    if (format === 'jsonl') {
      download(toJsonl(records), 'application/jsonl', `${filenameBase}.jsonl`);
    } else {
      download(toCsv(records), 'text/csv', `${filenameBase}.csv`);
    }

    setStatus(`Exportación lista: ${records.length} registros.`);
  };

  const bootstrap = async () => {
    setFormEnabled(false);
    setStatus('Validando sesión…');
    await fetchSession();
    if (!ensureAccess()) return;
    btnJsonl.addEventListener('click', () => handleExport('jsonl'));
    btnCsv.addEventListener('click', () => handleExport('csv'));
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bootstrap, { once: true });
  } else {
    bootstrap();
  }
})();
