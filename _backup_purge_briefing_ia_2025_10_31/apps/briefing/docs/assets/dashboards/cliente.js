(function () {
  const isLocalMode = () => (typeof window !== 'undefined' && window.__AUTH_MODE__ === 'none');
  const statusEl = document.getElementById('kpi-status');
  const dom = {
    accepted: document.getElementById('kpi-accepted'),
    pending: document.getElementById('kpi-pending'),
    rejected: document.getElementById('kpi-rejected'),
    last7: document.getElementById('kpi-last7'),
    latency: document.getElementById('kpi-latency'),
    sparkline: document.getElementById('sparkline')
  };

  function setStatus(message) {
    if (statusEl) {
      statusEl.textContent = message;
    }
  }

  function setKpi(el, value) {
    if (el) {
      el.textContent = value;
    }
  }

  function hoursBetween(start, end) {
    const diff = end.getTime() - start.getTime();
    return diff > 0 ? diff / (1000 * 60 * 60) : 0;
  }

  function formatHours(value) {
    return `${value.toFixed(1)} h`;
  }

  function normaliseDate(value) {
    if (!value) return null;
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
  }

  function getDayKey(date) {
    return date.toISOString().slice(0, 10);
  }

  function buildSparkline(counts) {
    const totalBars = counts.length;
    if (!dom.sparkline) return;

    const maxValue = counts.reduce((max, item) => Math.max(max, item.count), 0);
    if (maxValue === 0) {
      dom.sparkline.innerHTML = '<p>No hay actividad registrada en los últimos 14 días.</p>';
      return;
    }

    const width = totalBars * 12;
    const height = 48;
    const barWidth = 8;
    const gap = 4;

    const bars = counts
      .map((item, index) => {
        const barHeight = Math.round((item.count / maxValue) * height) || 2;
        const x = index * (barWidth + gap);
        const y = height - barHeight;
        return `<rect x="${x}" y="${y}" width="${barWidth}" height="${barHeight}" rx="2" ry="2">
  <title>${item.label}: ${item.count} envíos</title>
</rect>`;
      })
      .join('\n');

    dom.sparkline.innerHTML = `<svg viewBox="0 0 ${width} ${height}" role="img" aria-hidden="false">
  <title>Actividad últimos 14 días</title>
  ${bars}
</svg>`;
  }

  async function loadKPIs() {
    if (isLocalMode()) {
      setStatus('Modo local: KPIs no disponibles sin Access.');
      // Limpiar mostradores a guiones para evitar confusión
      setKpi(dom.accepted, '–');
      setKpi(dom.pending, '–');
      setKpi(dom.rejected, '–');
      setKpi(dom.last7, '–');
      setKpi(dom.latency, '–');
      if (dom.sparkline) dom.sparkline.innerHTML = '<p>Modo local</p>';
      return;
    }
    setStatus('Cargando KPIs…');
    try {
      const response = await fetch('/api/inbox', {
        method: 'GET',
        credentials: 'include'
      });

      if (!response.ok) {
        setStatus('Requiere sesión de Access o hubo un error al cargar los KPIs.');
        return;
      }

      const contentType = response.headers.get('Content-Type') || '';
      if (!contentType.includes('application/json')) {
        setStatus('Requiere sesión de Access. Inicia sesión para ver los KPIs.');
        return;
      }

      const items = await response.json();
      if (!Array.isArray(items)) {
        setStatus('Respuesta inesperada del servidor.');
        return;
      }

      const now = new Date();
      const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      const fourteenDays = [...Array(14).keys()]
        .map((offset) => {
          const day = new Date(now);
          day.setDate(now.getDate() - (13 - offset));
          day.setHours(0, 0, 0, 0);
          return day;
        });

      let accepted = 0;
      let pending = 0;
      let rejected = 0;
      let recent = 0;
      const latencyValues = [];
      const dailyCounts = new Map(fourteenDays.map((date) => [getDayKey(date), { date, count: 0 }]));

      items.forEach((item) => {
        const status = item?.moderation?.status || 'pending';
        if (status === 'accepted') accepted += 1;
        else if (status === 'rejected') rejected += 1;
        else pending += 1;

        const createdAt = normaliseDate(item?.meta?.createdAt);
        if (!createdAt) {
          return;
        }

        if (createdAt >= sevenDaysAgo) {
          recent += 1;
        }

        const dayKey = getDayKey(createdAt);
        if (dailyCounts.has(dayKey)) {
          dailyCounts.get(dayKey).count += 1;
        }

        if (status === 'accepted' || status === 'rejected') {
          const trail = Array.isArray(item?.moderation?.trail) ? item.moderation.trail : [];
          const lastEvent = [...trail].reverse().find((event) => {
            const action = event?.action;
            return action === 'accept' || action === 'reject' || action === 'accepted' || action === 'rejected';
          });
          const finalDate = normaliseDate(lastEvent?.at);
          if (finalDate) {
            latencyValues.push(hoursBetween(createdAt, finalDate));
          }
        }
      });

      const latency = latencyValues.length
        ? latencyValues.reduce((sum, value) => sum + value, 0) / latencyValues.length
        : 0;

      setKpi(dom.accepted, accepted);
      setKpi(dom.pending, pending);
      setKpi(dom.rejected, rejected);
      setKpi(dom.last7, recent);
      setKpi(dom.latency, latencyValues.length ? formatHours(latency) : '–');

      const sparklineData = Array.from(dailyCounts.values()).map(({ date, count }) => ({
        label: date.toLocaleDateString(undefined, { month: 'short', day: 'numeric' }),
        count
      }));
      buildSparkline(sparklineData);

      setStatus('KPIs listos.');
    } catch (error) {
      console.error('Error cargando KPIs', error);
      setStatus('Error al cargar los KPIs. Intenta nuevamente.');
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', loadKPIs);
  } else {
    loadKPIs();
  }
})();
