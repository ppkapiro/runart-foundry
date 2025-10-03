(function () {
  const form = document.getElementById('exp-form');
  const btnJsonl = document.getElementById('btn-jsonl');
  const btnCsv = document.getElementById('btn-csv');
  const statusEl = document.getElementById('exp-status');

  if (!form || !btnJsonl || !btnCsv || !statusEl) {
    return;
  }

  const setStatus = (message) => {
    statusEl.textContent = message;
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

  const handleExport = async (format) => {
    const range = parseRange();
    if (range?.error) {
      setStatus(range.error);
      return;
    }

    setStatus('Cargando…');

    const payload = await fetchInbox();
    if (!payload) return;

    const items = normaliseItems(payload);
    const accepted = items.filter((item) => item?.moderation?.status === 'accepted');
    const within = accepted.filter((item) => withinRange(item?.meta?.createdAt || item?.ts, range));
    const records = within.map(recordFromItem);

    if (records.length === 0) {
      setStatus('Sin datos en el rango seleccionado.');
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

  const init = () => {
    setStatus('Listo para exportar');
    btnJsonl.addEventListener('click', () => handleExport('jsonl'));
    btnCsv.addEventListener('click', () => handleExport('csv'));
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init, { once: true });
  } else {
    init();
  }
})();
