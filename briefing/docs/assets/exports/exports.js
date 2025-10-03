(function () {
  const form = document.getElementById('exp-form');
  const btnJsonl = document.getElementById('btn-jsonl');
  const btnCsv = document.getElementById('btn-csv');
  const statusEl = document.getElementById('exp-status');

  function setStatus(message) {
    if (statusEl) {
      statusEl.textContent = message;
    }
  }

  function getDateValue(name) {
    const input = form?.elements?.namedItem(name);
    if (!input || !(input instanceof HTMLInputElement)) return null;
    return input.value ? new Date(`${input.value}T00:00:00Z`) : null;
  }

  function isValidRange(from, to) {
    return from instanceof Date && to instanceof Date && !Number.isNaN(from) && !Number.isNaN(to) && from <= to;
  }

  function sanitiseString(value) {
    if (value === undefined || value === null) return '';
    return String(value).trim();
  }

  function toCsvRow(values) {
    return values
      .map((value) => {
        const cell = sanitiseString(value);
        if (cell.includes('"')) {
          return `"${cell.replace(/"/g, '""')}"`;
        }
        if (cell.includes(',') || cell.includes(';') || cell.includes('\n')) {
          return `"${cell}"`;
        }
        return cell;
      })
      .join(',');
  }

  function buildCsv(items) {
    const header = ['id', 'tipo', 'createdAt', 'artista', 'titulo', 'anio', 'token_origen'];
    const rows = items.map((item) =>
      toCsvRow([
        item.decision_id,
        item.tipo,
        item.meta?.createdAt,
        item.payload?.artista || item.payload?.artistaNombre,
        item.payload?.titulo,
        item.payload?.anio,
        item.token_origen
      ])
    );
    return [header.join(','), ...rows].join('\n');
  }

  function buildJsonl(items) {
    return items.map((item) => JSON.stringify(item)).join('\n');
  }

  function downloadBlob(content, filename, type) {
    const blob = new Blob([content], { type });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  }

  function filterItems(items, from, to) {
    const fromTime = from.getTime();
    const toTime = to.getTime() + 24 * 60 * 60 * 1000 - 1; // inclusive end of day
    return items.filter((item) => {
      if (item?.moderation?.status !== 'accepted') return false;
      const createdAt = item?.meta?.createdAt ? new Date(item.meta.createdAt) : null;
      if (!createdAt || Number.isNaN(createdAt.getTime())) return false;
      const time = createdAt.getTime();
      return time >= fromTime && time <= toTime;
    });
  }

  async function handleExport(format) {
    if (!form) return;

    const from = getDateValue('from');
    const to = getDateValue('to');

    if (!isValidRange(from, to)) {
      setStatus('Selecciona un rango válido (desde ≤ hasta).');
      return;
    }

    setStatus('Cargando fichas aceptadas…');

    try {
      const response = await fetch('/api/inbox', {
        method: 'GET',
        credentials: 'include'
      });

      if (!response.ok) {
        setStatus('Requiere sesión Cloudflare Access o hubo un error.');
        return;
      }

      const contentType = response.headers.get('Content-Type') || '';
      if (!contentType.includes('application/json')) {
        setStatus('Requiere sesión Cloudflare Access.');
        return;
      }

      const data = await response.json();
      if (!Array.isArray(data)) {
        setStatus('Respuesta inesperada del servidor.');
        return;
      }

      const filtered = filterItems(data, from, to);
      if (!filtered.length) {
        setStatus('Sin fichas accepted en ese rango.');
        return;
      }

      const fromStr = form.from.value;
      const toStr = form.to.value;

      if (format === 'jsonl') {
        downloadBlob(buildJsonl(filtered), `export_accepted_${fromStr}_to_${toStr}.jsonl`, 'application/jsonl');
      } else {
        downloadBlob(buildCsv(filtered), `export_accepted_${fromStr}_to_${toStr}.csv`, 'text/csv');
      }

      setStatus(`Exportación lista: ${filtered.length} registros.`);
    } catch (error) {
      console.error('Error exportando', error);
      setStatus('Error al exportar. Intenta nuevamente.');
    }
  }

  function init() {
    setStatus('Listo para exportar.');
    if (btnJsonl) {
      btnJsonl.addEventListener('click', () => handleExport('jsonl'));
    }
    if (btnCsv) {
      btnCsv.addEventListener('click', () => handleExport('csv'));
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
